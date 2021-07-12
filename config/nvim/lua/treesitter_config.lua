local treesitter = require"nvim-treesitter.configs"

treesitter.setup {
    ensure_installed = {
        "bash",
        "c",
        "c_sharp",
        "cmake",
        "comment",
        "cpp",
        "css",
        "dockerfile",
        "go",
        "gomod",
        "hcl",
        "html",
        "java",
        "javascript",
        "json",
        "kotlin",
        "lua",
        "python",
        "regex",
        "typescript",
        "vue",
        "yaml",
    },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
        disable = {},
    },
}
