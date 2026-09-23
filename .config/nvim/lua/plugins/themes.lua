return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			-- Setup gruvbox
			require("gruvbox").setup({
				terminal_colors = true, -- add neovim terminal colors
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = true,
					emphasis = true,
					comments = true,
					operators = false,
					folds = true,
				},
				strikethrough = true,
				invert_selection = false,
				invert_signs = false,
				invert_tabline = false,
				invert_intend_guides = false,
				inverse = true, -- invert background for search, diffs, statuslines and errors
				contrast = "hard", -- can be "hard", "medium" or "soft"
				palette_overrides = {},
				overrides = {},
				dim_inactive = false,
				transparent_mode = false,
			})
			
			local themes = {
				"gruvbox",
				"tokyonight",
				"accent",
				"catppuccin",
				"rose-pine",
			}
			local current_theme_index = 1
			-- Set default theme (first theme)
			vim.cmd.colorscheme(themes[current_theme_index])

			-- Key mapping to switch themes (e.g., <leader>nt)
			vim.keymap.set("n", "<leader>nt", function()
				current_theme_index = current_theme_index + 1
				if current_theme_index > #themes then
					current_theme_index = 1
				end
				local theme = themes[current_theme_index]
				vim.cmd.colorscheme(theme)
				print("Changed nvim theme to: " .. theme)
			end, { noremap = true, silent = true })
		end,
	},
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		priority = 999,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 800,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
	},
	{
		"alligator/accent.vim",
		name = "accent",
		priority = 1100,
	},
}
