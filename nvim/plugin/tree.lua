require("neo-tree").setup({
	filesystem = {
		window = {
			mappings = {
				["h"] = "close_node",
				["l"] = "open",
			},
		},
	},

	event_handlers = {
		{
			event = "file_opened",
			handler = function(_)
				require("neo-tree.command").execute({ action = "close" })
			end,
		},
	},
})


vim.keymap.set("n", "<leader>e", ":Neotree toggle right<CR>", { desc = "Open NeoTree on the right side" })
