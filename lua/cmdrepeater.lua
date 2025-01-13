local Path = require("plenary.path")
local config_path = vim.fn.stdpath("config")
local data_path = vim.fn.stdpath("data")
local inspect = require("inspect")

local user_config = string.format("%s/cmdrepeat.json", config_path)
local cache_config = string.format("%s/cmdrepeat.json", data_path)

local CmdRepeaterConfig = {}

local M = {}

M.get_cmd_table = function()
	vim.notify(inspect(CmdRepeaterConfig))

	local cwd = vim.fn.getcwd()
	local project_cfg = CmdRepeaterConfig.projects[cwd]

	return project_cfg.cmds
end

M.add_cmd = function(pos, cmd)
	local cwd = vim.fn.getcwd()
	local project_cfg = CmdRepeaterConfig.projects[cwd]

	project_cfg.cmds[pos] = cmd
	if CmdRepeaterConfig.global_settings.save_on_change then
		M.save()
	end
end

-- tbl_deep_extend does not work the way you would think
local function merge_table_impl(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k]) == "table" then
				merge_table_impl(t1[k], v)
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
end

local function merge_tables(...)
	local out = {}
	for i = 1, select("#", ...) do
		merge_table_impl(out, select(i, ...))
	end
	return out
end

local function read_config(local_config)
	return vim.json.decode(Path:new(local_config):read())
end

M.save = function()
	vim.notify("save(): Saving cache config to" .. cache_config)
	Path:new(cache_config):write(vim.fn.json_encode(CmdRepeaterConfig), "w")
end

local function expand_dir(config)
	c = config or {}
	local projects = c.projects or {}
	for k in pairs(projects) do
		local expanded_path = Path.new(k):expand()
		projects[expanded_path] = projects[k]
		if expanded_path ~= k then
			projects[k] = nil
		end
	end
	return c
end
function M.setup(config)
	-- TODO: Get configs / commands from projects config / task files
	local ok, u_config = pcall(read_config, user_config)

	if not ok then
		u_config = {}
	end

	local ok2, c_config = pcall(read_config, cache_config)

	if not ok2 then
		c_config = {}
	end

	local complete_config = merge_tables({
		projects = {}, -- ma[project_key][{cmds}]
		global_settings = {
			["save_on_toggle"] = false,
			["save_on_change"] = true,
		},
	}, expand_dir(c_config), expand_dir(u_config), expand_dir(config))

	CmdRepeaterConfig = complete_config

	local cwd = vim.fn.getcwd()
	if CmdRepeaterConfig.projects[cwd] == nil then
		local cmd_table = {}
		CmdRepeaterConfig.projects[cwd] = {}
		CmdRepeaterConfig.projects[cwd].cmds = cmd_table
	end
end

M.setup()

return M
