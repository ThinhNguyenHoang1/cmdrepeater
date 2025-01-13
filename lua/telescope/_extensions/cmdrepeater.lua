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
			cmd_table = cmdrepeater.get_cmd_table()

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

							local coauthors = { "", "" }
							for _, c in ipairs(selections) do
								table.insert(coauthors, "Co-authored-by: " .. c[1])
							end
							cmd = action_state.get_selected_entry() or ""
							vim.notify("Exec@" .. cmd)
							vim.api.nvim_command(":TermExec " .. cmd)
						end

						map("i", "<CR>", try_exec_command)
						map("n", "<CR>", try_exec_command)

						return true
					end,
				})
				:find()
		end,
	},
})
