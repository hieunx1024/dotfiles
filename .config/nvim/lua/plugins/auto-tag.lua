return {
	"windwp/nvim-ts-autotag",
	-- Only load for tag-based languages
	ft = {
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"svelte",
		"vue",
		"tsx",
		"xml",
		"php",
		"markdown",
	},
	opts = {
		opts = {
			enable_close = true,
			enable_rename = true,
			enable_close_on_slash = false,
		},
	},
}
