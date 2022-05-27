local neorg = require("neorg")

neorg.setup {
    load = {
        ["core.defaults"] = {},
        ["core.export"] = {},
        ["core.norg.completion"] = {
            config = {
                engine = "nvim-cmp",
            },
        },
        ["core.norg.concealer"] = {},
        ["core.norg.dirman"] = {
            config = {
                workspaces = {
                    notes = "~/notes",
                },
                default_workspaces = "notes",
                open_last_workspace = true,
            },
        },
        ["core.norg.qol.toc"] = {},
    },
}
