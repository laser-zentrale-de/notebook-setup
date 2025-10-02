-- -----------------------------------
-- Keymaps
-- -----------------------------------
local keymap = vim.keymap.set

-- Remove highlight search
keymap('n', '<ESC>', '<cmd>nohlsearch<cr>')

-- Disable space in normal mode
keymap("n", "<Space>", "<Nop>")

-- keep visual selection when (de)indenting
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Move multilines in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
keymap("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Centralize while going page up and down
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Void registry pasting
keymap("x", "<leader>p", [["_dP]])

-- Copy to system clipboard
keymap({ "n", "v" }, "<leader>y", [["+y]])
keymap("n", "<leader>Y", [["+Y]])

-- Paste form system clipboard
keymap({ "n", "v" }, "<leader>p", [["+p]])
keymap("n", "<leader>P", [["+P]])

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dP')
keymap("v", "P", '"_dP')

-- Delete to void registry
keymap({ "n", "v" }, "<leader>d", [["_d]])

-- Sarch and replace in current file
keymap("n", "<leader>sr", ":%s/")
keymap("v", "<leader>sr", "y:%s/<C-r>\"", { noremap = true, silent = false })

-- Sarch and replace in quickfix
keymap("n", "<leader>qr", ":cdo :%s/")
keymap("n", "<leader>qR", ":cfdo :%s/")

-- Open Quickfix list
keymap("n", "<leader>qq", "<cmd>copen<CR>")
keymap("n", "<leader>qc", "<cmd>cclose<CR>")

-- Remap cnext and cprev for quickfix lists
keymap('n', '<M-n>', '<cmd>cnext<CR>zz')
keymap('n', '<M-p>', '<cmd>cprev<CR>zz')

-- -----------------------------------
-- Options
-- -----------------------------------
local opt = vim.opt

-- Line numbers
opt.nu = true
opt.relativenumber = true

-- Linebreak
opt.wrap = false

-- Curser line
opt.cursorline = true

-- Indenting
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Split for replaces
opt.inccommand = "split"

-- Search settings
opt.smartcase = true
opt.ignorecase = true

-- Scrollin
opt.scrolloff = 10

-- split windows
opt.splitright = true
opt.splitbelow = true

-- Undo
opt.undofile = true

-- Swap
opt.swapfile = false

-- Colors
opt.termguicolors = true

-- Window border for floating windows
opt.winborder = 'single'

-- -----------------------------------
-- AutoCmds
-- -----------------------------------

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Diagnostic config
vim.diagnostic.config({
  virtual_text = true,
})

-- -----------------------------------
-- LSP
-- -----------------------------------

-- Enable all LSPs here and place the config to the lsp directory.
vim.lsp.enable({})

-- LSP auto commands.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- Keymaps
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end)

    -- Auto-format on save.
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end

    -- Inlay hints
    if client:supports_method("textDocument/inlayHint") then
      -- Enable by default
      vim.lsp.inlay_hint.enable(true)

      -- Keymap for toggle
      vim.keymap.set("n", '<leader>ih', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { desc = "Toggle LSP inlay hints" })
    end
  end,
})
