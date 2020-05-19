
-- id -> true
local disabled_trains = {}

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 2 then return end
	timer=0

  disabled_trains = {}
  local max_range = 500
	local players = minetest.get_connected_players()
  for id, train in pairs(advtrains.trains) do
    disabled_trains[id] = true
    local tpos = train.last_pos
    for _, player in pairs(players) do
      local ppos = player:get_pos()
      local distance = vector.distance(tpos, ppos)
      if distance < max_range then
        -- enable train
        disabled_trains[id] = nil
      end
    end
  end
end)


local old_train_ensure_init = advtrains.train_ensure_init
advtrains.train_ensure_init = function(k, v)
  if disabled_trains[k] then
    return
  else
    return old_train_ensure_init(k, v)
  end
end

local old_train_step_b = advtrains.train_step_b
advtrains.train_step_b = function(k, v, dtime)
  if disabled_trains[k] then
    return
  else
    return old_train_step_b(k, v, dtime)
  end
end

local old_train_step_c = advtrains.train_step_c
advtrains.train_step_c = function(k, v, dtime)
  if disabled_trains[k] then
    return
  else
    return old_train_step_c(k, v, dtime)
  end
end
