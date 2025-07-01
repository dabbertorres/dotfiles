require("codecompanion").setup {
    adapters = {
        opts = {
            show_defaults = false,
        },
        ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "my ollama",
                env = {
                    url = "http://192.168.0.25:11434",
                },
                schema = {
                    model = {
                        default = "codellama",
                    },
                    num_ctx = {
                        default = 4096,
                    },
                },
            })
        end,
    },
    strategies = {
        chat = {
            adapter = "ollama",
            provider = "ollama",
        },
        inline = {
            adapter = "ollama",
            provider = "ollama",
        },
        cmd = {
            adapter = "ollama",
            provider = "ollama",
        },
    },
}
