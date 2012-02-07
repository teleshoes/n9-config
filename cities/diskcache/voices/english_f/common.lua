-- ----------------------------------------------------------------------------
-- Copyright (C) 2009 Nokia Gate5 GmbH Berlin
--
-- These coded instructions, statements, and computer programs contain
-- unpublished proprietary information of Nokia Gate5 GmbH Berlin, and
-- are copy protected by law. They may not be disclosed to third parties
-- or copied or duplicated in any form, in whole or in part, without the
-- specific, prior written permission of Nokia Gate5 GmbH Berlin.
-- ----------------------------------------------------------------------------
--      Authors: Raul Ferrandez Salvador
-- ----------------------------------------------------------------------------

function get_common_code( )

    if maneuver_1 ~= nil then
        maneuver_1.dist_to_unit = maneuver_1.dist_to_unit_string
    end

    if maneuver_2 ~= nil then
        maneuver_2.dist_to_unit = maneuver_2.dist_to_unit_string
    end
    
    is_double_command()
    
    -- Maneuver triggers
    if trigger == "COMMAND" or trigger == "REMINDER1" or trigger == "REMINDER2" or trigger =="ANNOUNCEMENT" then
        process_maneuver_triggers( )
    end 

    -- GPS triggers
    if trigger == "GPS_SIGNAL_LOST" or trigger == "GPS_SIGNAL_RESTORED" or trigger == "NO_GPS_SIGNAL" or trigger == "ROUTE_RECALCULATION" then
        process_gps_triggers( )
    end 

     -- Safety SpotWarner
    if trigger == "SAFETYSPOT_WARNER" then
       table.insert(result_list, misc[ "beep_sound" ] )
        if above_speed_limit == true then
            table.insert(result_list, misc[ "safety_camara_ahead_wav" ] )
        end
    end

    -- Speed Warners triggers
    if trigger == "SPEED_WARNER" then
        table.insert(result_list, misc[ "over_speed_limit_wav" ] )
    end

    if trigger == "TRAFFIC_WARNER" then
        if avoidance_mode == "AUTOMATIC_AVOIDANCE" then
            table.insert(result_list, misc[ "traffic_automatic_detour_wav" ] )
        elseif avoidance_mode == "MANUAL_AVOIDANCE" then
            table.insert(result_list, misc[ "traffic_manual_detour_wav" ] )
        end
    end

    -- Traffic detour failed
    if trigger == "TRAFFIC_DETOUR_FAILED" then
        table.insert(result_list, misc[ "no_detour_possible" ] )
    end

    -- Pedestrian command
    if trigger == "PEDESTRIAN_COMMAND" then
        if maneuver_1.id == "STOPOVER" then
            table.insert(result_list, misc[ "stopover_wav" ] ) 
        elseif maneuver_1.id == "END" then
            table.insert(result_list, misc[ "destination_wav" ] )
        else
            table.insert(result_list, misc[ "beep_sound" ] )
        end 
    end

end

function process_gps_triggers()
    if guidance_mode ~= "pedestrian" then
        if trigger == "GPS_SIGNAL_LOST" then
            -- "GPS signal lost"
            table.insert( result_list, misc[ "gps_signal_lost_wav" ]) 
        end

        if trigger == "GPS_SIGNAL_RESTORED" then
            -- "GPS connection has been restored"
            table.insert( result_list, misc[ "gps_signal_restored_wav" ] )
        end
    end

 --   if trigger == "NO_GPS_SIGNAL" then
        -- "No GPS signal"
 --       table.insert( result_list, misc[ "no_gps_signal_wav" ] )
 --   end

    if trigger == "ROUTE_RECALCULATION" then
        -- "Route recalculation"
        table.insert( result_list, misc[ "route_recalculation_wav" ] )
    end
end

function is_double_command()
    
    double_command = false
    if ( maneuver_set_count == 2 and maneuver_set_type == "NORMAL" ) then
        double_command = true
    end
    
end
