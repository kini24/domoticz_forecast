-- beteljuice.com - near enough Zambretti Algorhithm 
-- June 2008 - v1.0
-- tweak added so decision # can be output

--[[
Negretti and Zambras 'slide rule' is supposed to be better than 90% accurate 
for a local forecast upto 12 hrs, it is most accurate in the temperate zones and about 09:00  hrs local solar time.
I hope I have been able to 'tweak it' a little better ;-)	

This code is free to use and redistribute as long as NO CHARGE is EVER made for its use or output
--]]

-- ---- 'environment' variables ------------
z_where = 1;            -- Northern = 1 or Southern = 2 hemisphere
z_baro_top = 1050;      -- upper limits of your local 'weather window' (1050.0 hPa for UK)
z_baro_bottom = 950;    -- lower limits of your local 'weather window' (950.0 hPa for UK)

-- usage:   forecast = betel_cast( z_hpa, z_month, z_wind, z_trend [, z_where] [, z_baro_top] [, z_baro_bottom])[0];

-- z_hpa is Sea Level Adjusted (Relative) barometer in hPa or mB
-- z_month is current month as a number between 1 to 12
-- z_wind is English windrose cardinal eg. N, NNW, NW etc.
-- NB. if calm a 'nonsense' value should be sent as z_wind (direction) eg. 1 or calm !
-- z_trend is barometer trend: 0 = no change, 1= rise, 2 = fall
-- z_where - OPTIONAL for posting with form
-- z_baro_top - OPTIONAL for posting with form
-- z_baro_bottom - OPTIONAL for posting with form
-- [0] a short forecast text is returned
-- [1] zambretti severity number (0 - 25) is returned ie. betel_cast() returns a two deep array

return {
	on = {
		devices = {
		},
		timer = {
			'every 5 minutes',
		},
		httpResponses = {
			'weather_history',
		},
	},
	execute = function(domoticz, item)
	    local idTempDevice = 45     -- Барометр
	    local idWindDevice = 222    -- Ветер
	    local baroDiff = 0          -- Разница между показаниями давления час назад и сейчас
	    local baroTrend = 0         -- Тренд давления: растет, падает, стабильно
	    
		if (item.isTimer)
		then
		    -- Запрашиваем историю изменений барометра
			domoticz.openURL({
				url = 'http://127.0.0.1:8081/json.htm?type=graph&sensor=temp&idx=' .. idTempDevice .. '&range=day',
				method = 'GET',
				callback = 'weather_history',
			})
    	end

        -- Получаем историю изменений барометра за последние 7 дней (меньше не дает)
		if (item.isHTTPResponse and item.trigger == 'weather_history' and item.ok)
		then
		    local json = domoticz.utils.fromJSON(item.data)
		    -- Получаем показания барометра час назад
		    local baroHourAgo = json.result[#json.result - 12].ba
		    -- Получаем показания барометра сейчас
		    local baroCurrent = json.result[#json.result].ba
		    
		    -- domoticz.log('Давление час назад: ' .. baroHourAgo)
		    -- domoticz.log('Давление сейчас: ' .. baroCurrent)
		    
		    -- Вычисляем разницу между показаниями барометра
		    baroDiff = baroCurrent - baroHourAgo
		    
		    -- Определяем тренд изменений показаний
		    if (baroDiff < 0) then baroTrend = 2
            elseif (baroDiff > 0) then baroTrend = 1
            else baroTrend = 0
            end
		end

        -- Запрашиваем функцию вычисления краткосрочного прогноза из файла global_data
        -- Температуру передаем для того, чтобы определить осадки: дождь или снег
        local forecast = domoticz.helpers.forecast_weather(domoticz.devices(idTempDevice).barometer, domoticz.time.month, domoticz.devices(idWindDevice).directionString, baroTrend, z_where, z_baro_top, z_baro_bottom, domoticz.devices(idTempDevice).temperature)
        
        domoticz.log('Прогноз погоды: ' .. forecast)
    end
}
