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
                    opts = {
                        -- See Configuration section below for available options
                    },
                },
            },
        },
    },
}
```

## Configuration

The plugin provides several configuration options to customize the conventional commit types:

### Default Behavior

By default, the plugin provides the following conventional commit types:

- `feat` - A new feature for the user
- `fix` - A bug fix for the user
- `docs` - Documentation changes
- `style` - Changes that do not affect the meaning of the code (white-space, formatting, etc.)
- `refactor` - A code change that neither fixes a bug nor adds a feature
- `perf` - A code change that improves performance
- `test` - Adding missing tests or correcting existing tests
- `chore` - Changes to the build process or auxiliary tools and libraries
- `ci` - Changes to CI/CD pipelines
- `revert` - Reverts a specific commit

### Options

```lua
opts = {
    completion = {
        -- Add custom commit types (will be merged with defaults)
        items = {
            { type = 'custom', doc = 'My custom commit type' },
        },
        -- Set to false to disable default types and only use your custom ones
        use_defaults = true, -- default: true
    },
}
```

### Examples

#### Extending Defaults

Add your own custom types while keeping the defaults:

```lua
opts = {
    completion = {
        items = {
            { type = 'wip', doc = 'Work in progress' },
            { type = 'build', doc = 'Changes to build system' },
        },
    },
}
```

#### Overriding Defaults

Override specific default types with your own descriptions:

```lua
opts = {
    completion = {
        items = {
            { type = 'feat', doc = 'A new feature (customized description)' },
            { type = 'fix', doc = 'A bug fix (customized description)' },
        },
    },
}
```

#### Using Only Custom Types

Disable all defaults and provide your own complete set:

```lua
opts = {
    completion = {
        use_defaults = false,
        items = {
            { type = 'add', doc = 'Add new functionality' },
            { type = 'change', doc = 'Change existing functionality' },
            { type = 'remove', doc = 'Remove functionality' },
            { type = 'fix', doc = 'Fix a bug' },
        },
    },
}
```
