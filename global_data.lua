return {
	-- глобальные постоянные данные
	data = {
	},

	-- глобальные вспомогательные функции
	helpers = {
        forecast_weather = function (z_hpa, z_month, z_wind, z_trend, z_hemisphere, z_upper, z_lower, wh_temp_out)
        	if(z_hemisphere) then z_where = z_hemisphere end
        	if(z_upper) then z_baro_top = z_upper end
	        if(z_lower) then z_baro_bottom = z_lower end
	        
	        local z_forecast = {
	            "Settled fine",
	            "Fine weather",
	            "Becoming fine",
	            "Fine, becoming less settled",
	            "Fine, possible showers",
	            "Fairly fine, improving",
	            "Fairly fine, possible showers early",
	            "Fairly fine, showery later",
	            "Showery early, improving",
	            "Changeable, mending",
	            "Fairly fine, showers likely",
	            "Rather unsettled clearing later",
	            "Unsettled, probably improving",
	            "Showery, bright intervals",
	            "Showery, becoming less settled",
	            "Changeable, some rain",
	            "Unsettled, short fine intervals",
	            "Unsettled, rain later",
	            "Unsettled, some rain",
	            "Mostly very unsettled",
	            "Occasional rain, worsening",
	            "Rain at times, very unsettled",
	            "Rain at frequent intervals",
	            "Rain, very unsettled",
	            "Stormy, may improve",
	            "Stormy, much rain"
            }
	        
	        -- Если температура менее +2 градусов, то в качестве осадков будет снег, а не дождь
	        if (wh_temp_out < 2) then
	            local z_forecast_ru = {
	                "Устойчивая ясная",
	                "Хорошая погода",
	                "Становление хорошей",
	                "Хорошая, становится неустойчивой",
	                "Хорошая, возможен дождь",
	                "Достаточно хорошая, улучшается",
                }
            else
	            local z_forecast_ru = {
	                "Устойчивая ясная",
	                "Хорошая погода",
	                "Становление хорошей",
	                "Хорошая, становится неустойчивой",
	                "Хорошая, возможен дождь",
	                "Достаточно хорошая, улучшается",
                }
            end

	        -- equivalents of Zambretti 'dial window' letters A - Z
            local rise_options   = { 26, 26, 26, 25, 25, 20, 17, 13, 12, 10,  9,  7,  6,  3, 2, 2, 1, 1, 1, 1, 1, 1 }
            local steady_options = { 26, 26, 26, 26, 26, 26, 24, 24, 23, 19, 16, 14, 11,  5, 2, 2, 1, 1, 1, 1, 1, 1 }
            local fall_options   = { 26, 26, 26, 26, 26, 26, 26, 26, 24, 24, 22, 21, 18, 15, 8, 4, 2, 2, 2, 1, 1, 1 }

	        z_range = z_baro_top - z_baro_bottom
	        z_constant = tonumber(string.format("%.3f", z_range / 22))

	        z_season = (z_month >= 4 and z_month <= 9)   -- true если "Лето"
	        
	        if (z_where == 1) then  		-- Северное полушарие
		        if (z_wind == "N") then
			        z_hpa = z_hpa + 6 / 100 * z_range
		        elseif (z_wind == "NNE") then
			        z_hpa = z_hpa + 5 / 100 * z_range
		        elseif (z_wind == "NE") then
        			-- z_hpa += 4
			        z_hpa = z_hpa + 5 / 100 * z_range
		        elseif (z_wind == "ENE") then
			        z_hpa = z_hpa + 2 / 100 * z_range
		        elseif (z_wind == "E") then
			        z_hpa = z_hpa - 0.5 / 100 * z_range
		        elseif (z_wind == "ESE") then
        			-- z_hpa -= 3
			        z_hpa = z_hpa - 2 / 100 * z_range
		        elseif (z_wind == "SE") then
			        z_hpa = z_hpa - 5 / 100 * z_range
		        elseif (z_wind == "SSE") then
			        z_hpa = z_hpa - 8.5 / 100 * z_range
		        elseif (z_wind == "S") then
        			-- z_hpa -= 11
			        z_hpa = z_hpa - 12 / 100 * z_range
		        elseif (z_wind == "SSW") then
			        z_hpa = z_hpa - 10 / 100 * z_range
		        elseif (z_wind == "SW") then
			        z_hpa = z_hpa - 6 / 100 * z_range
                elseif (z_wind == "WSW") then
			        z_hpa = z_hpa - 4.5 / 100 * z_range
		        elseif (z_wind == "W") then
			        z_hpa = z_hpa - 3 / 100 * z_range
		        elseif (z_wind == "WNW") then
			        z_hpa = z_hpa - 0.5 / 100 * z_range
		        elseif (z_wind == "NW") then
			        z_hpa = z_hpa + 1.5 / 100 * z_range
		        elseif (z_wind == "NNW") then
			        z_hpa = z_hpa + 3 / 100 * z_range
		        end
		        
		        if (z_season == 1) then  	-- Если лето
			        if (z_trend == 1) then  -- Давление растет
				        z_hpa = z_hpa + 7 / 100 * z_range
			        elseif (z_trend == 2) then  -- Давление падает
				        z_hpa = z_hpa - 7 / 100 * z_range
			        end
		        end
	        else  	-- Южное полушарие
		        if (z_wind == "S") then
			        z_hpa = z_hpa + 6 / 100 * z_range
		        elseif (z_wind == "SSW") then
			        z_hpa = z_hpa + 5 / 100 * z_range
		        elseif (z_wind == "SW") then
        			-- z_hpa += 4
			        z_hpa = z_hpa + 5 / 100 * z_range
		        elseif (z_wind == "WSW") then
			        z_hpa = z_hpa + 2 / 100 * z_range
		        elseif (z_wind == "W") then
			        z_hpa = z_hpa - 0.5 / 100 * z_range
		        elseif (z_wind == "WNW") then
        			-- z_hpa -= 3
			        z_hpa = z_hpa - 2 / 100 * z_range
		        elseif (z_wind == "NW") then
			        z_hpa = z_hpa - 5 / 100 * z_range
		        elseif (z_wind == "NNW") then
			        z_hpa = z_hpa - 8.5 / 100 * z_range
		        elseif (z_wind == "N") then
        			-- z_hpa -= 11
			        z_hpa = z_hpa - 12 / 100 * z_range
		        elseif (z_wind == "NNE") then
			        z_hpa = z_hpa - 10 / 100 * z_range
		        elseif (z_wind == "NE") then
			        z_hpa = z_hpa - 6 / 100 * z_range
		        elseif (z_wind == "ENE") then
			        z_hpa = z_hpa - 4.5 / 100 * z_range
		        elseif (z_wind == "E") then
			        z_hpa = z_hpa - 3 / 100 * z_range
		        elseif (z_wind == "ESE") then
			        z_hpa = z_hpa - 0.5 / 100 * z_range
		        elseif (z_wind == "SE") then
			        z_hpa = z_hpa + 1.5 / 100 * z_range
		        elseif (z_wind == "SSE") then
			        z_hpa = z_hpa + 3 / 100 * z_range
		        end
		        
		        if (z_season == 0) then 	-- Если зима
			        if (z_trend == 1) then  -- Давление растет
				        z_hpa = z_hpa + 7 / 100 * z_range
			        elseif (z_trend == 2) then  -- Давление падает
				        z_hpa = z_hpa - 7 / 100 * z_range
                    end
		        end
	        end 	-- Конец Север / Юг

	        if(z_hpa == z_baro_top) then z_hpa = z_baro_top - 1 end
	        z_option = math.floor((z_hpa - z_baro_bottom) / z_constant)
 	        z_output = ""
 	        
	        if (z_option < 1) then
		        z_option = 1
		        z_output = "Exceptional Weather, "
	        end
	        
	        -- Почему 22 ???
	        if (z_option > 22) then
		        z_option = 22
		        z_output = "Exceptional Weather, "
	        end

	        if (z_trend == 1) then 	-- Давление растет
		        z_output = z_output .. z_forecast[rise_options[z_option]]
	        elseif (z_trend == 2) then 	-- Давление падает
		        z_output = z_output .. z_forecast[fall_options[z_option]]
	        else 	-- Давление стабильно
		        z_output = z_output .. z_forecast[steady_options[z_option]]
	        end

            return z_output
        end,	-- Конец функции
	}
}
