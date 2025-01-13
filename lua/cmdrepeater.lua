local cmd_table = {}

local M = {}

M.get_cmd_table = function()
	return cmd_table
end

M.add_cmd = function(pos, cmd)
	cmd_table[pos] = cmd
end

function M.setup(config)
	-- TODO: Get configs / commands from projects config / task files
	cmd_table = {
		"",
		"",
		"",
	}
end

M.setup()

return M
