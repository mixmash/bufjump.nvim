# bufjump.nvim

https://user-images.githubusercontent.com/38927155/132891665-88f70573-c1d8-462d-8a76-9786ba115f7d.mov

Have you ever had to temporarily go to another file, perhaps previewing some changes with lsp go to refrenece, fiddle a bit, and have to jump back to the main file that you were working with? Instead of aimlessly smashing `CTRL-o` and `CTRL-i`, bufjump.nvim allows you to jump to previous or next buffer in the vim native jumplist with one single command.

Or, have you ever wanted to browse your jumplist _within_ the current buffer, _not_ jumping outside that buffer? Read on.

## Prerequistes

- Neovim 0.7 or higher

## Installing
with [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "kwkarlwang/bufjump.nvim",
    config = function()
        require("bufjump").setup()
    end,
    opts = {
        forward_key = "<M-o>",
        forward_same_buf_key = "<M-i>",
        backward_key = "<M-o>",
        backward_same_buf = "<M-i>",
        on_success = function ()
            -- something
        end,
        excluded_filetypes = {
        -- "oil",
        -- "qf",
        -- "help",
        -- "man",
        -- "floaterm",
        -- "lazy",
        -- "mason",
        -- "lspinfo",
        -- "lir",
        -- "lsp-installer",
        -- "null-ls-info",
        -- "tsplayground",
        -- "DressingSelect",
        -- "Jaq",
        },
    },
    -- alternatively "lazy's" way to lazy load via keymapping
    keys = {
        { "<M-o>", require('bufjump').backward },
        { "<M-i>", require('bufjump').forward },
        { "<M-o>", require('bufjump').backward_same_buf },
        { "<M-i>", require('bufjump').forward_same_buf },
    }
}

```

with [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'kwkarlwang/bufjump.nvim'
```

with [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "kwkarlwang/bufjump.nvim",
    config = function()
        require("bufjump").setup()
    end
}
```

## Configuration

bufjump.nvim provides the following configuration options (and does not setup any keymappings by default):

- `forward_key`, `backward_key` the keymappings to jump to the next and previous
  buffer in the jumplist respectively.
- `forward_same_buf_key`, `backward_same_buf_key` provide keymappings to jump the the
  next and previous jumplist positions within the same buffer.
- `on_success` a function that is executed when a jump is successfully executed.
- `excluded_filetypes` a list of filetypes that are skipped for the jumps


You can also bind the function `forward`, `backward` `forward_same_buf`, `backward_same_buf` as followed

```lua
local opts = { silent=true, noremap=true }
vim.keymap.set("n", "<M-o>", require('bufjump').backward, opts)
vim.keymap.set("n", "<M-i>", require('bufjump').forward, opts)
vim.keymap.set("n", "<M-o>", require('bufjump').backward_same_buf, opts)
vim.keymap.set("n", "<M-i>", require('bufjump').forward_same_buf, opts)
```

### on_success

`on_success` is a callback function that only executes after a successful backward or forward jump, which means that if there are no previous buffers in the jumplist, then `on_success` will not be executed.

Suppose that you want to jump to the last cursor position after exiting the buffer instead of the last cursor position in the jumplist stack, you can set the `on_success` function as followed:

```lua
use({
    "kwkarlwang/bufjump.nvim",
    config = function()
        require("bufjump").setup({
            forward_key = "<C-n>",
            backward_key = "<C-p>",
            on_success = function()
                vim.cmd([[execute "normal! g`\"zz"]])
            end,
        })
    end,
})

```

This will jump to the last cursor position before you left the buffer while also center the cursor to the middle of the screen. You can check `:h last-position-jump` for more information.

## How it works

Under the hood, this plugin uses native `CTRL-o` and `CTRL-i` to jump until the buffer is different from the current buffer. If there are no previous or next buffer, then the command does not jump at all.

### backward

When jumping to the previous buffer, it will jump to the last occurance in the jumplist that is different from the current buffer. Below is a simple illustration of the before and after position in the jumplist stack.

#### Before

```
Buffer 1    line 1
Buffer 1    line 2
Buffer 1    line 3
Buffer 2    line 10
Buffer 2    line 20     <--
Buffer 2    line 30
```

#### After

```
Buffer 1    line 1
Buffer 1    line 2
Buffer 1    line 3      <--
Buffer 2    line 10
Buffer 2    line 20
Buffer 2    line 30
```

### forward

When jumping to the next buffer, it will jump to the last occurance in the jumplist that is different from the current buffer. Below is a simple illustration of the before and after position in the jumplist stack.

#### Before

```
Buffer 1    line 1      <--
Buffer 1    line 2
Buffer 1    line 3
Buffer 2    line 10
Buffer 2    line 20
Buffer 2    line 30
```

#### After

```
Buffer 1    line 1
Buffer 1    line 2
Buffer 1    line 3
Buffer 2    line 10
Buffer 2    line 20
Buffer 2    line 30     <--
```

### Notable differences from the original
- integrates [phanen's](https://github.com/phanen) [PR](https://github.com/kwkarlwang/bufjump.nvim/pull/5)
- adds the excluded filetypes table to skip certain buffers

