# blink-cmp-conventional-commits

[Conventional Commits](https://www.conventionalcommits.org) source for [blink.cmp](https://github.com/Saghen/blink.cmp) completion plugin.

It provides the different types of conventional commits when writing a new Git commit message. Mainly because I am just starting to adopt conventional commits and can never remember the commonly used types.

![screenshot showing completion in gitcommit buffer](https://github.com/user-attachments/assets/af851953-acf5-4744-9f2c-340add739ba7)

## Installation

example using [Lazy](https://github.com/folke/lazy.nvim) plugin manager

```lua
{
    'saghen/blink.cmp',
    dependencies = {
        { 'disrupted/blink-cmp-conventional-commits' },
    },
    opts = {
        sources = {
            default = {
                'conventional_commits', -- add it to the list
                'lsp',
                'buffer',
                'path',
            },
            providers = {
                conventional_commits = {
                    name = 'Conventional Commits',
                    module = 'blink-cmp-conventional-commits',
                    enabled = function()
                        return vim.bo.filetype == 'gitcommit'
                    end,
                    ---@module 'blink-cmp-conventional-commits'
                    ---@type blink-cmp-conventional-commits.Options
                    opts = {}, -- none so far
                },
            },
        },
    },
}
```
