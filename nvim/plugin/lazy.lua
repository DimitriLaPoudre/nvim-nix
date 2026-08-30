local lg = require('lazygit')
lg.setup()

vim.keymap.set("n", "<leader>gg", ":LazyGit", {
    desc = "Open LazyGit",
})

local ld = require('lazydocker')
ld.setup({
    border = "curved", -- valid options are "single" | "double" | "shadow" | "curved"
    width = 0.9,       -- width of the floating window (0-1 for percentage, >1 for absolute columns)
    height = 0.9,      -- height of the floating window (0-1 for percentage, >1 for absolute rows)
})

vim.keymap.set("n", "<leader>dd", function()
    ld.open()
end, {
    desc = "Open LazyDocker (docker)",
})
