local util = require("my_util")

util.make_augroup("terminal_buf", true,
    function()
        return "TermOpen", {
            desc = "easy navigation away from a terminal",
            callback = function()
                vim.keymap.set("t", "<C-w>h", "<C-\\><C-N><C-w>h", { buffer = true })
                vim.keymap.set("t", "<C-w>j", "<C-\\><C-N><C-w>j", { buffer = true })
                vim.keymap.set("t", "<C-w>k", "<C-\\><C-N><C-w>k", { buffer = true })
                vim.keymap.set("t", "<C-w>l", "<C-\\><C-N><C-w>l", { buffer = true })
            end,
        }
    end,
    function()
        return "TermClose", {
            desc = "silence false 'modifying a readonly buffer' message",
            callback = function()
                vim.fn.feedkeys("\\<CR>")
            end,
        }
    end,
    function()
        return { "BufEnter", "BufWinEnter", "WinEnter" }, {
            desc = "start in insert mode when opening a terminal",
            pattern = "term://*",
            command = "startinsert",
        }
    end
)

util.make_augroup("extra_file_types", true,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "C++ template implementation files",
            pattern = "*.tpp",
            command = "set filetype=cpp",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "C++ importable module unit",
            pattern = "*.cppm",
            command = "set filetype=cpp",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "Dockerfile with extension",
            pattern = "Dockerfile.*",
            command = "set filetype=dockerfile",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "F# file",
            pattern = "*.fs",
            command = "set filetype=fsharp",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "GLSL Fragment Shader",
            pattern = "*.frag",
            command = "set filetype=glsl",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "Go module file",
            pattern = "go.mod",
            command = "set filetype=gomod",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "C# HTML Template",
            pattern = "*.cshtml",
            command = "set filetype=html",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "Go HTML Template",
            pattern = "*.gohtml",
            command = "set filetype=html",
        }
    end,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            desc = "Freemarker HTML template",
            pattern = "*.ftlh",
            command = "set filetype=html",
        }
    end
)

util.make_augroup("different_indent_filetypes", true,
    function()
        return "FileType", {
            pattern = "cmake",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "csv",
            command = "setlocal nowrap",
        }
    end,
    function()
        return "FileType", {
            pattern = "hcl",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "html",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "json",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "jsonnet",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "make",
            command = "setlocal noexpandtab",
        }
    end,
    function()
        return "FileType", {
            pattern = "markdown",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "sql",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2 commentstring=--%s",
        }
    end,
    function()
        return "FileType", {
            pattern = "svelte",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "terraform",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2 commentstring=#%s",
        }
    end,
    function()
        return "FileType", {
            pattern = "typescript",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "vue",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "xml",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end,
    function()
        return "FileType", {
            pattern = "yaml",
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
        }
    end
)

-- ensure TODOs are always highlighted
util.make_augroup("highlight_todo", true,
    function()
        return { "WinEnter", "VimEnter" }, {
            command = "silent! call matchadd('Todo', 'TODO', -1)",
        }
    end
)

util.make_augroup("large_files", true,
    function()
        return "BufReadPre", {
            desc = "disable syntax processing and such on large files",
            callback = function()
                local size = vim.fn.getfsize(vim.fn.expand("%"))
                -- nothing to do for directories or not-existent files
                if size == 0 or size == -1 then return end

                -- nothing to do if the file isn't too big
                if size ~= -2 or size < 1024 * 1024 then return end

                if vim.fn.exists(":TSBufDisable") ~= 0 then
                    vim.api.nvim_cmd({
                        cmd = "TSBufDisable",
                        args = { "incremental_selection", "highlight", "indent", "matchup" },
                    }, { output = false })
                end

                if vim.fn.exists(":LspStop") ~= 0 then
                    vim.api.nvim_cmd({ cmd = "LspStop" }, { output = false })
                end
            end,
        }
    end
)
