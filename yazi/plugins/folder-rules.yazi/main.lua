-- Define a sync function to access cx state safely
local apply_rules = ya.sync(function()
	if not cx or not cx.active or not cx.active.current then
		return
	end

	local cwd = cx.active.current.cwd
	local cwd_str = tostring(cwd)

	if cwd_str:find("vaults/second%-brain") then
		ya.mgr_emit("sort", { "btime", reverse = true, dir_first = true })
		ya.mgr_emit("linemode", { "btime" })
	else
		ya.mgr_emit("sort", { "alphabetical", reverse = false, dir_first = true })
		ya.mgr_emit("linemode", { "none" })
	end
end)

local function setup()
	-- Run on startup
	apply_rules()

	-- Run on directory change
	ps.sub("cd", function()
		apply_rules()
	end)
end

return { setup = setup }