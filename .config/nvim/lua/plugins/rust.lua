return {
	"mrcjkb/rustaceanvim",
	version = "^5", -- Recommended
	lazy = false, -- rustaceanvim is already an ftplugin, no need to lazy-load it via lazy.nvim
	init = function()
		vim.g.rustaceanvim = {
			server = {
				on_attach = function(client, bufnr)
					-- Custom keymaps for Rust
					vim.keymap.set("n", "<leader>ca", function()
						vim.cmd.RustLsp("codeAction")
					end, { desc = "Rust Code Action", buffer = bufnr })

					vim.keymap.set("n", "K", function()
						vim.cmd("RustLsp hover actions")
					end, { desc = "Rust Hover", buffer = bufnr })

					vim.keymap.set("n", "<leader>rd", function()
						vim.cmd.RustLsp("debuggables")
					end, { desc = "Rust Debuggables", buffer = bufnr })
				end,
				default_settings = {
					-- rust-analyzer language server settings
					["rust-analyzer"] = {
						checkOnSave = true,
						check = {
							command = "clippy",
						},
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							runBuildScripts = true,
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["mz-adapter-macros"] = { "adapter" },
							},
						},
					},
				},
			},
		}
	end,
}
