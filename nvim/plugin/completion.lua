if vim.g.did_load_completion_plugin then
	return
end
vim.g.did_load_completion_plugin = true


-- C-Space = manually trigger completion
vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.get()
end, { desc = "Show completion" })

-- C-j = next
vim.keymap.set("i", "<C-j>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	end

	return "<C-j>"
end, { expr = true, desc = "Next completion" })

-- C-k = previous
vim.keymap.set("i", "<C-k>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	end

	return "<C-k>"
end, { expr = true, desc = "Previous completion" })

-- Tab = accept
vim.keymap.set("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-y>"
	end

	return "<Tab>"
end, { expr = true, desc = "Accept completion" })

-- Cancel completion
vim.keymap.set("i", "<C-c>", "<C-E>", {
	desc = "Cancel completion",
})
