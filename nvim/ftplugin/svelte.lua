-- Exit if the language server isn't available
if vim.fn.executable('svelte-language-server') ~= 1 then
	return
end

vim.lsp.enable({ "svelte" })
