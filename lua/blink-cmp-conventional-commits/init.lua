---@module 'blink.cmp'

---@class blink-cmp-conventional-commits.Options

---@class ConventionalCommitsSource : blink.cmp.Source, blink-cmp-conventional-commits.Options
---@field completion_items blink.cmp.CompletionItem[]
local conventional_commits = {}

---@param type string
---@param doc string
---@return blink.cmp.CompletionItem
local function make_completion_item(type, doc)
    return {
        label = type,
        insertText = type,
        kind = require('blink.cmp.types').CompletionItemKind.Class,
        documentation = doc,
    }
end

---@param opts blink-cmp-conventional-commits.Options
function conventional_commits.new(opts)
    ---@type blink-cmp-conventional-commits.Options
    local default_opts = {}

    opts = vim.tbl_deep_extend('keep', opts, default_opts, {
        completion_items = {
            make_completion_item('feat', 'A new feature for the user.'),
            make_completion_item('fix', 'A bug fix for the user.'),
            make_completion_item('docs', 'Documentation changes.'),
            make_completion_item(
                'style',
                'Changes that do not affect the meaning of the code (white-space, formatting, etc.).'
            ),
            make_completion_item(
                'refactor',
                'A code change that neither fixes a bug nor adds a feature.'
            ),
            make_completion_item(
                'perf',
                'A code change that improves performance.'
            ),
            make_completion_item(
                'test',
                'Adding missing tests or correcting existing tests.'
            ),
            make_completion_item(
                'chore',
                'Changes to the build process or auxiliary tools and libraries.'
            ),
            make_completion_item('ci', 'Changes to CI/CD pipelines.'),
            make_completion_item('revert', 'Reverts a specific commit.'),
        },
    })

    return setmetatable(opts, { __index = conventional_commits })
end

local function get_breaking_completion_item()
    local breaking = make_completion_item(
        'BREAKING CHANGE',
        'Mark change as including a breaking change.'
    )
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if not first_line:match '!:' then
        -- if '!' is missing then make sure to add it to the completion item
        local colon_pos = first_line:find ':'
        if colon_pos ~= nil then
            breaking.additionalTextEdits = {
                {
                    range = {
                        start = { line = 0, character = colon_pos - 1 },
                        ['end'] = { line = 0, character = colon_pos - 1 },
                    },
                    newText = '!',
                },
            }
        end
    end
    return breaking
end

---@param context blink.cmp.Context
---@param callback fun(T: table)
---@return function|nil
function conventional_commits:get_completions(context, callback)
    local row, col = unpack(context.cursor)
    local space_before_cursor = context.line:sub(0, col):find ' '
    if not space_before_cursor then
        if row > 1 then
            -- add optional footer below
            callback {
                items = { get_breaking_completion_item() },
            }
        elseif not context.line:find '[():]' then
            -- only complete conventional commits for first word of first line before ':' and optional scope
            callback {
                is_incomplete_forward = false,
                is_incomplete_backward = false,
                items = vim.deepcopy(self.completion_items),
            }
        end
    end
    callback { items = {} }
end

return conventional_commits
