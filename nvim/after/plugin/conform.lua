require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true, },
        typescript = { "prettierd", "prettier", stop_after_first = true, },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true, },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true, },
        css = { "prettierd", "prettier", stop_after_first = true, },
        scss = { "prettierd", "prettier", stop_after_first = true, },
        json = { "prettierd", "prettier", stop_after_first = true, },
        html = { "prettierd", "prettier", stop_after_first = true, },
        prisma = { "prisma_fmt", stop_after_first = true, },
    },
    formatters = {
        prisma_fmt = {
            command = "npx",
            args = { "prisma", "format", "--schema", "$FILENAME" },
            stdin = false,
        },
    },
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
})
