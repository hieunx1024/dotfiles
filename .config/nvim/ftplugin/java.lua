local home = os.getenv("HOME")
local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name

local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities
--
-- detect OS
local os_config = ""
if vim.fn.has("mac") == 1 then
    os_config = "config_mac"
elseif vim.fn.has("unix") == 1 then
    os_config = "config_linux"
elseif vim.fn.has("win32") == 1 then
    os_config = "config_win"
end

-- Load capabilities from cmp_nvim_lsp for autocomplete/code actions support
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_status then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local on_attach = function(client, bufnr)
    local opts = { silent = true, buffer = bufnr }
    -- Standard LSP keymaps for Java buffer
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", function()
        require("fzf-lua").lsp_code_actions({ previewer = false, silent = true })
    end, { desc = "LSP Code Actions", silent = true, buffer = bufnr })

    -- Advanced Java specific keymaps
    vim.keymap.set("n", "<leader>co", "<Cmd>lua require'jdtls'.organize_imports()<CR>", { desc = "Organize Imports", buffer = bufnr })
    vim.keymap.set("n", "<leader>crv", "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = "Extract Variable", buffer = bufnr })
    vim.keymap.set(
        "v",
        "<leader>crv",
        "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
        { desc = "Extract Variable", buffer = bufnr }
    )
    vim.keymap.set("n", "<leader>crc", "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = "Extract Constant", buffer = bufnr })
    vim.keymap.set(
        "v",
        "<leader>crc",
        "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
        { desc = "Extract Constant", buffer = bufnr }
    )
    vim.keymap.set(
        "v",
        "<leader>crm",
        "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
        { desc = "Extract Method", buffer = bufnr }
    )
end

local root_dir = require("jdtls.setup").find_root({
    ".git",
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
    "settings.gradle",
})

-- Dự phòng: Nếu không tìm thấy file đánh dấu root dự án, dùng thư mục chứa file Java hiện tại
if not root_dir or root_dir == "" then
    root_dir = vim.fn.expand("%:p:h")
end

local config = {
    cmd = {
        home .. "/.sdkman/candidates/java/current/bin/java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
        "-jar",
        -- vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
        vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration",
        home .. "/.local/share/nvim/mason/packages/jdtls/" .. os_config,
        "-data",
        workspace_dir,
    },
    root_dir = root_dir,

    capabilities = capabilities,
    on_attach = on_attach,

    settings = {
        java = {
            signatureHelp = { enabled = true },
            extendedClientCapabilities = extendedClientCapabilities,
            maven = {
                downloadSources = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            inlayHints = {
                parameterNames = {
                    enabled = "all", -- literals, all, none
                },
            },
            format = {
                enabled = true,
                settings = {
                    profile = "GoogleStyle",
                },
            },
        },
    },

    init_options = {
        bundles = {},
    },
}
require("jdtls").start_or_attach(config)

