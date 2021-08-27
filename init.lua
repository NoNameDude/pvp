local storage = minetest.get_mod_storage()
function is_pvp_allowed_save(data)
    if type(data) == "table" then
        storage:set_string("is_new", minetest.serialize(data))
    end
end
 
function is_pvp_allowed()
    local datas = storage:get_string("is_new")
    if datas ~= nil then
        datas = minetest.deserialize(datas)
	    if type(datas) ~= "table" then
            datas = {} 
        end
    else
        datas = {}  
    end
    return datas
end 

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if not hitter:is_player() then
		return false
	end

	--tournament_on_punchplayer(player, hitter, damage)
    local pvp_data = is_pvp_allowed()
	local localname = player and player:get_player_name()
	local hittername = hitter and hitter:get_player_name()

    local is_hitter_new = pvp_data[hittername]
    local is_player_new = pvp_data[localname]


    

	if localname == hittername then
		return false 
	end

	if is_hitter_new == true then
		minetest.chat_send_player(hittername, "Your to new to pvp.")
		return true
	end
	if is_player_new == true then
		minetest.chat_send_player(hittername, "This player is to new to pvp.")
		return true
	end
	return false 
end) 

 
minetest.register_on_newplayer(function(player) 
    local name = player and player:get_player_name()
    local pvp_data = is_pvp_allowed()
    if pvp_data[name] == nil then
        pvp_data[name] = true
        is_pvp_allowed_save(pvp_data)
    end
end) 

local timer = 0 
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    local online_players = minetest.get_connected_players()
    local pvp_data = is_pvp_allowed()
    if timer >= 600 then 
        for _, player in pairs(online_players) do
            local name = player and player:get_player_name()
            if pvp_data[name] == nil then
                pvp_data[name] = false
            end
            if pvp_data[name] ~= false then
                pvp_data[name] = false
            end
        end 
        timer = 0
        is_pvp_allowed_save(pvp_data) 
    end
end)

