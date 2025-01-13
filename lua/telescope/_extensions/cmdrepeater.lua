local inspect = require("inspect")
return require("telescope").register_extension({
	exports = {
		pickcmds = function(opts)
			local utils = require("telescope.utils")
			local action_state = require("telescope.actions.state")
			local actions = require("telescope.actions")
			local finders = require("telescope.finders")
			local pickers = require("telescope.pickers")
			local sorters = require("telescope.sorters")
			local make_entry = require("telescope.make_entry")
			local cmdrepeater = require("cmdrepeater")
			local cmd_table = cmdrepeater.get_cmd_table()

			opts = opts or {}
			opts.cwd = opts.cwd or vim.fn.getcwd()

			local string_entry_maker = make_entry.gen_from_string()
			opts.entry_maker = string_entry_maker
			vim.notify("Current commands")
			for index, data in ipairs(cmd_table) do
				vim.notify("CMD@" .. index)
				vim.notify(data)
			end
			pickers
				.new(opts, {
					prompt_title = "Remember Commands",
					finder = finders.new_table(cmd_table or {}),
					sorter = sorters.get_generic_fuzzy_sorter(),
					attach_mappings = function(prompt_bufnr, map)
						local try_exec_command = function()
							local picker = action_state.get_current_picker(prompt_bufnr)
							local selections = picker:get_multi_selection()
							if next(selections) == nil then
								selections = { picker:get_selection() }
							end
							actions.close(prompt_bufnr)

							local cmd = action_state.get_selected_entry()[1] or ""
							vim.notify(inspect(cmd))
							if require("toggleterm") then
								require("toggleterm").exec(cmd)
							else
								vim.api.nvim_command(":1Tclear")
								vim.api.nvim_command(":1T " .. cmd)
							end
						end

						map("i", "<CR>", try_exec_command)
						map("n", "<CR>", try_exec_command)

						-- Change The Saved Command At location
						map({ "i", "n" }, "<C-r>", function(_prompt_bufnr)
							print("You typed <C-r>")

							local picker = action_state.get_current_picker(prompt_bufnr)
							local selections = picker:get_multi_selection()
							if next(selections) == nil then
								selections = { picker:get_selection() }
							end
							actions.close(prompt_bufnr)

							vim.notify(inspect(action_state.get_selected_entry()))
							local pos = action_state.get_selected_entry()[2] or ""
							local cmdstr = vim.fn.input("cmd:", "")
							cmdrepeater.change_cmd(pos, cmdstr)
						end)

						return true
					end,
				})
				:find()
		end,
	},
})
