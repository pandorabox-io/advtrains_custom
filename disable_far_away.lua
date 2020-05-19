local has_monitoring_mod = minetest.get_modpath("monitoring")

local active_trains_metric, inactive_trains_metric

if has_monitoring_mod then
	active_trains_metric = monitoring.gauge(
		"advtrains_custom_active_trains",
		"number of active trains"
	)
	inactive_trains_metric = monitoring.gauge(
		"advtrains_custom_inactive_trains",
		"number of inactive trains"
	)
end


-- id -> true
local disabled_trains = {}

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 2 then return end
	timer=0

  disabled_trains = {}
	local max_range_setting = minetest.settings:get("advtrains_custom.max_range") or "500"
  local max_range = tonumber(max_range_setting)
	local players = minetest.get_connected_players()

	local active_trains = 0
	local inactive_trains = 0

  for id, train in pairs(advtrains.trains) do
    disabled_trains[id] = true
    local tpos = train.last_pos
    for _, player in pairs(players) do
      local ppos = player:get_pos()
      local distance = vector.distance(tpos, ppos)
      if distance < max_range then
        -- enable train
        disabled_trains[id] = nil
				-- skip other players
				break
      end
    end

		if has_monitoring_mod then
			-- collect metrics
			if disabled_trains[id] then
				inactive_trains = inactive_trains + 1
			else
				active_trains = active_trains + 1
			end

			active_trains_metric.set(active_trains)
			inactive_trains_metric.set(inactive_trains)
		end
  end
end)

-- overrides

assert(type(advtrains.train_ensure_init) == "function")
local old_train_ensure_init = advtrains.train_ensure_init
advtrains.train_ensure_init = function(k, v)
  if disabled_trains[k] then
    return
  else
    return old_train_ensure_init(k, v)
  end
end

assert(type(advtrains.train_step_b) == "function")
local old_train_step_b = advtrains.train_step_b
advtrains.train_step_b = function(k, v, dtime)
  if disabled_trains[k] then
    return
  else
    return old_train_step_b(k, v, dtime)
  end
end

assert(type(advtrains.train_step_c) == "function")
local old_train_step_c = advtrains.train_step_c
advtrains.train_step_c = function(k, v, dtime)
  if disabled_trains[k] then
    return
  else
    return old_train_step_c(k, v, dtime)
  end
end
