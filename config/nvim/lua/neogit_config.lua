local neogit = require("neogit")

neogit.setup {
    disable_hint = false,
    disable_context_highlighting = false,
    disable_signs = false,
    disable_commit_confirmation = true,
    disable_builtin_notifications = true,
    disable_insert_on_commit = true,
    use_magit_keybindings = false,
    auto_refresh = true,
    kind = "tab",
    status = {
        recent_commit_count = 10,
    },
    commit_popup = {
        kind = "split",
    },
    signs = {
        hunk = { "", "" },
        item = { ">", "v" },
        section = { ">", "v" }
    },
    integrations = {
        diffview = true
    },
    sections = {
        untracked = {
            folded = false,
            hidden = false
        },
        unstaged = {
            folded = false,
            hidden = false
        },
        staged = {
            folded = false,
            hidden = false
        },
        stashes = {
            folded = true,
            hidden = false
        },
        unpulled = {
            folded = true,
            hidden = true
        },
        unmerged = {
            folded = false,
            hidden = false
        },
        recent = {
            folded = true,
            hidden = true
        },
    },
    mappings = {
        status = {
            ["q"] = "Close",
            ["1"] = "Depth1",
            ["2"] = "Depth2",
            ["3"] = "Depth3",
            ["4"] = "Depth4",
            ["<tab>"] = "Toggle",
            ["x"] = "Discard",
            ["s"] = "Stage",
            ["S"] = "StageUnstaged",
            ["<c-s>"] = "StageAll",
            ["u"] = "Unstage",
            ["U"] = "UnstageStaged",
            -- ["d"] = "DiffAtFile",
            ["$"] = "CommandHistory",
            ["<c-r>"] = "RefreshBuffer",
            ["<enter>"] = "GoToFile",
            ["<c-v>"] = "VSplitOpen",
            ["<c-x>"] = "SplitOpen",
            ["<c-t>"] = "TabOpen",
            -- ["?"] = "HelpPopup",
            -- ["D"] = "DiffPopup",
            -- ["p"] = "PullPopup",
            -- ["r"] = "RebasePopup",
            -- ["P"] = "PushPopup",
            -- ["c"] = "CommitPopup",
            -- ["L"] = "LogPopup",
            -- ["Z"] = "StashPopup",
            -- ["b"] = "BranchPopup",
        }
    }
}

vim.keymap.set("n", "mgo", neogit.open, {
    noremap = true,
    silent = true,
})
