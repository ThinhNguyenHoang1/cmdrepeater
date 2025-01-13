# My personal neovim plugin for quickly replaying frequently used command

- Integration [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) - Replay command is played inside a toggle term
- Integration [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Quickly search and edit saved commands
- Save commands per project

# Default mapping

```
+--------------------------+--------------------------------------------------------+-----------------------------------------------------------------+
|           API            |                Combo(@Telescope window)                |                              Desc                               |
+--------------------------+--------------------------------------------------------+-----------------------------------------------------------------+
| get_cmd_table()          | require("telescope").extensions.cmdrepeater.pickcmds() | List all commands                                               |
| add_cmd(pos, cmd)        | <C-a>                                                  | Add new saved command                                           |
| change_cmd(pos, new_cmd) | <C-r> at entry                                         | Replaced saved command at pos                                   |
| change_cmd(pos)          | <C-x> at entry                                         | Replaced saved command at pos. Clear all commands if pos == nil |
+--------------------------+--------------------------------------------------------+-----------------------------------------------------------------+

```
