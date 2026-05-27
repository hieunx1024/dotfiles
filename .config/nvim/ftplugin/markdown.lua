-- ~/.config/nvim/ftplugin/markdown.lua

-- Hide raw formatting characters (like **, _, link URLs) to show beautiful rendered text
vim.opt_local.conceallevel = 2

-- Automatically wrap long lines for a pleasant reading and writing experience
vim.opt_local.wrap = true

-- Disable spell checking by default (set to true if you want english spell check)
vim.opt_local.spell = false

-- Disable the vertical column line to keep the screen uncluttered and clean
vim.opt_local.colorcolumn = ""

-- Prevent Neovim from overriding your preferred indentation tab settings in Markdown
vim.g.markdown_recommended_style = 0
