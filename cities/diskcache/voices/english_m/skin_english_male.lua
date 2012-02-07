-- ----------------------------------------------------------------------------
-- Copyright (C) 2011 Nokia Gate5 GmbH Berlin
--
-- These coded instructions, statements, and computer programs contain
-- unpublished proprietary information of Nokia Gate5 GmbH Berlin, and
-- are copy protected by law. They may not be disclosed to third parties
-- or copied or duplicated in any form, in whole or in part, without the
-- specific, prior written permission of Nokia Gate5 GmbH Berlin.
-- ----------------------------------------------------------------------------
-- 				Authors: Raul Ferrandez, Fabian TP Riek
-- ----------------------------------------------------------------------------
--             Voice Skin: english_m

description = "" 
output_type = "audio"
speaker = ""
gender = "m"
travel_mode = "1"
language = "English"
marc_code = "eng"
language_id = "1"
id = "1101"
config_file = "english_m/config.lua"
audio_files_path = "english_m/english_male"
audio_files_version = "0.3.0.2011071001"
feature_list = { "metric", "imperial_uk", "imperial_us" }
client_range = "[client >= 1.4.6.0 ]"

down = 1
up = 2

maneuver_turns = {
    ["NO_TURN"] = {"g5man_001e", "g5man_001"},
    ["KEEP_MIDDLE"] = {"g5man_010e", "g5man_010"},
    ["KEEP_RIGHT"] = {"g5tur_001e", "g5tur_001"},
    ["LIGHT_RIGHT"] = {"g5tur_002e", "g5tur_002"},
    ["QUITE_RIGHT"] = {"g5tur_003e", "g5tur_003"},
    ["HEAVY_RIGHT"] = {"g5tur_004e", "g5tur_004"},
    ["RETURN"] = {"g5man_004e", "g5man_004"},
    ["HEAVY_LEFT"] = {"g5tul_004e", "g5tul_004"},
    ["QUITE_LEFT"] = {"g5tul_003e", "g5tul_003"},
    ["LIGHT_LEFT"] = {"g5tul_002e", "g5tul_002"},
    ["KEEP_LEFT"] = {"g5tul_001e", "g5tul_001"},
    ["nil"] = {nil, nil},
    ["UNDEFINED"] = {nil, nil}
}


maneuver_check = {
    ["END"] = {"g5ann_001e_alt2", "g5ann_001e_alt2"},              -- You will reached your destination
    ["STOPOVER"] = {"g5ann_002e_alt2", "g5ann_002e_alt2"},         -- You will reached a stopover
    ["JUNCTION"] = {nil, nil},                                     -- No voice file needed -> check maneuver_turn
    ["PASS_JUNCTION"] = {nil, nil},                                -- the junction
    ["ROUNDABOUT"] = {"g5mod_005", "g5mod_005"},                   -- At the roundabout
    ["EXIT_ROUNDABOUT"] = {"g5ext_000e", "g5ext_000"},             -- take the exit
    ["UTURN"] = {"g5man_004e", "g5man_004"},                       -- Make a uturn
    ["ENTER_HIGHWAY"] = {"g5man_005e", "g5man_005"},
    ["LEAVE_HIGHWAY"] = {"g5ext_000e", "g5ext_000"},               -- take the exit
    ["CHANGE_HIGHWAY"] = {"g5man_006e", "g5man_006"},
    ["CONTINUE_HIGHWAY"] = {"g5ext_000e", "g5ext_000"},
    ["ENTER_URBAN_HIGHWAY"] = {"g5man_005e", "g5man_005"},
    ["LEAVE_URBAN_HIGHWAY"] = {"g5ext_000e", "g5ext_000"},               -- take the exit
    ["CHANGE_URBAN_HIGHWAY"] = {"g5man_006e", "g5man_006"},
    ["CONTINUE_URBAN_HIGHWAY"] = {"g5ext_000e", "g5ext_000"},
    ["DRIVE_TO_NEAREST_ROAD"] = {"g5serv_001e", "g5serv_001e"},      -- drive to nearest road 
    ["FERRY"] = {"g5serv_004", "g5serv_004"}
}


exit_number_check = {
    [1] = {"g5ext_001e","g5ext_001"},                   -- take the first exit
    [2] = {"g5ext_002e","g5ext_002"},                   -- take the second exit
    [3] = {"g5ext_003e","g5ext_003"},                   -- take the third exit
    [4] = {"g5ext_004e","g5ext_004"},                   -- take the fourth exit
    [5] = {"g5ext_005e","g5ext_005"},                   -- take the fifth exit
    [6] = {"g5ext_006e","g5ext_006"},                   -- take the sixth exit
    [7] = {"g5ext_007e","g5ext_007"},                   -- take the seventh exit
    [8] = {"g5ext_008e","g5ext_008"},                   -- take the eighth exit
    [9] = {"g5ext_009e","g5ext_009"},                   -- take the ninth exit
    [10] = {"g5ext_010e","g5ext_010"},                  -- take the tenth exit
    [11] = {"g5ext_011e_exit","g5ext_011_exit"},        -- take the eleventh exit
    [12] = {"g5ext_012e_exit","g5ext_012_exit"}         -- take the twelfth exit 
}

distances = {
    [0.10] = "g5num_pt_1",
    [0.20] = "g5num_pt_2",
    [0.25] = "g5num_0_25_mile",
    [0.30] = "g5num_pt_3",
    [0.40] = "g5num_pt_4",
    [0.50] = "g5num_0_50_mile",
    [0.60] = "g5num_pt_6",
    [0.70] = "g5num_pt_7",
    [0.75] = "g5num_0_75_mile",
    [0.80] = "g5num_pt_8",
    [0.90] = "g5num_pt_9",
    [50] = "g5num_050",
    [100] = "g5num_100",
    [150] = "g5num_150",
    [200] = "g5num_200",
    [250] = "g5num_250",
    [300] = "g5num_300",
    [400] = "g5num_400",
    [500] = "g5num_500",
    [600] = "g5num_600",
    [700] = "g5num_700",
    [800] = "g5num_800",
    [900] = "g5num_900",
    [1] = "g5num_001",
    [2] = "g5num_002",
    [3] = "g5num_003",
    [4] = "g5num_004",
    [5] = "g5num_005",
    [6] = "g5num_006",
    [7] = "g5num_007",
    [8] = "g5num_008",
    [9] = "g5num_009",
    [10] = "g5num_010"
}

unit = {                                    -- Intonation down, intonation up
    ["MILE"] = {"g5unt_007e","g5unt_007"},
    ["YARDS"] = {"g5unt_006","g5unt_006"},
    ["KILOMETER"] = {"g5unt_003e","g5unt_003"},
    ["METERS"] = {"g5unt_002","g5unt_002"},
    ["METER"] = {nil, nil},
    ["KILOMETERS"] = {"g5unt_004e","g5unt_004"},
    ["MILES"] = {"g5unt_008e","g5unt_008"},
    ["FEET"] = {"g5unt_ft_after_2","g5unt_ft_after_2"},
    ["nil"] = {nil, nil},
    ["UNDEFINED"] = {nil, nil}
}

misc = { 
    ["beep_sound"] = "beep",
    ["gps_signal_lost_wav"] = "g5war_027e",         
    ["gps_signal_restored_wav"] = "g5war_010e",     -- gps connection has been restored
    ["no_gps_signal_wav"] = "g5war_028e",           
    ["route_recalculation_wav"] = "g5war_012e",     -- route recalculation
    ["now_wav"] = "g5mod_006",
    ["destination_wav"] = "g5ann_001_02",
    ["stopover_wav"] = "g5ann_002e_alt1",                 
    ["end_of_street_wav"] = "g5mod_004",
    ["follow_hwy_wav"] = "g5man_008",
    ["follow_road_e_wav"] = "g5man_002e",
    ["follow_road_wav"] = "g5man_002",
    ["the_junction_wav"] = "g5mod_016e_new",           
    ["for_wav"] = "g5pre_002",
    ["roundabout_wav"] = "g5mod_005",
    ["after_wav"] = "g5pre_003",
    ["half_a_mile_wav"] = "g5num_0_50_mile",
    ["quarter_a_mile_wav"] = "g5num_0_25_mile",
    ["three_quarter_of_mile_wav"] = "g5num_0_75_mile",
    ["and_wav"] = "g5con_002",
    ["second_right_wav"] = "g5ext_013e",
    ["second_left_wav"] = "g5ext_014e",
    ["immediately_wav"] = "g5immediately", 
    ["safety_camara_ahead_wav"] = "g5war_037e",
    ["over_speed_limit_wav"] = "g5war_speed_limit_soft4edit9",
    ["traffic_automatic_detour_wav"] = "g5war_018e",
    ["traffic_manual_detour_wav"] = "g5war_017e",  
    ["no_detour_possible"] = "g5war_021e",     
    ["and_then_wav"] = "g5con_001"

}

right = { ["QUITE_RIGHT"] = 0, ["HEAVY_RIGHT"] = 0, ["LIGHT_RIGHT"] = 0, ["KEEP_RIGHT"] = 0 }
left = { ["QUITE_LEFT"] = 0, ["HEAVY_LEFT"] = 0, ["LIGHT_LEFT"] = 0, ["KEEP_LEFT"] = 0 }


check_files = { maneuver_turns, maneuver_check, exit_number_check, distances, unit, misc }
