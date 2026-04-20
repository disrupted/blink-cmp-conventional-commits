---@module 'blink.cmp'

---@class blink-cmp-conventional-commits.CompletionItemInput
---@field type string
---@field doc? string

---@class blink-cmp-conventional-commits.CompletionOptions
---@field items? blink-cmp-conventional-commits.CompletionItemInput[]
---@field use_defaults? boolean

---@class blink-cmp-conventional-commits.Options
---@field completion? blink-cmp-conventional-commits.CompletionOptions
---@field git_log_count? integer Number of non-merge commits to scan for scopes (default: 200)
---@field scopes? false Disable automatic scope discovery

---@class ConventionalCommitsSource : blink.cmp.Source, blink-cmp-conventional-commits.Options
---@field completion_items blink.cmp.CompletionItem[]
---@field scope_items blink.cmp.CompletionItem[]
local conventional_commits = {}

---@param scope string
---@return blink.cmp.CompletionItem
local function make_scope_item(scope)
    return {
        label = scope,
        insertText = scope,
        kind = require('blink.cmp.types').CompletionItemKind.Value,
    }
end

---@param count integer
---@param callback fun(scopes: string[])
local function discover_scopes(count, callback)
    vim.system(
        { 'git', 'log', '--no-merges', '--oneline', '-' .. count },
        { text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                callback {}
                return
            end
            local seen = {}
            local scopes = {}
            for line in result.stdout:gmatch '[^\n]+' do
                local scope = line:match '^%x+ %w+%((.-)%)'
                if scope then
                    scope = scope:match '^%s*(.-)%s*$'
                    if scope ~= '' and not seen[scope] then
                        seen[scope] = true
                        table.insert(scopes, scope)
                    end
                end
            end
            callback(scopes)
        end)
    )
end

---@param type string
---@param doc string
---@return blink.cmp.CompletionItem
local function make_completion_item(type, doc)
    return {
        label = type,
        insertText = type,
        kind = require('blink.cmp.types').CompletionItemKind.Class,
        documentation = {
            kind = 'markdown',
            value = doc,
        },
    }
end

local default_completion_items = {
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
    make_completion_item('perf', 'A code change that improves performance.'),
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
}

---@param opts blink-cmp-conventional-commits.Options
function conventional_commits.new(opts)
    opts = opts or {}
    local completion = opts.completion or {}
    local use_defaults = completion.use_defaults ~= false
    local custom_items = completion.items or {}

    local by_type = {}
    if use_defaults then
        for _, item in ipairs(default_completion_items) do
            by_type[item.label] = item
        end
    end
    for _, input in ipairs(custom_items) do
        by_type[input.type] = make_completion_item(input.type, input.doc)
    end

    local completion_items = {}
    for _, item in pairs(by_type) do
        completion_items[#completion_items + 1] = item
    end
    table.sort(completion_items, function(a, b)
        return a.label < b.label
    end)

    opts.completion_items = completion_items

    opts.scope_items = {}
    if opts.scopes ~= false then
        discover_scopes(opts.git_log_count or 200, function(scopes)
            local items = {}

            for _, scope in ipairs(scopes) do
                table.insert(items, make_scope_item(scope))
            end
            opts.scope_items = items
        end)
    end

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
    local line_before_cursor = context.line:sub(0, col)
    local space_before_cursor = line_before_cursor:find '%s'
    if not space_before_cursor then
        if row > 1 then
            -- add optional footer below
            callback {
                items = { get_breaking_completion_item() },
            }
        elseif
            #self.scope_items > 0 and line_before_cursor:match '^%w+%([^)]*$'
        then
            -- complete scopes inside type(...)
            callback {
                is_incomplete_forward = false,
                is_incomplete_backward = false,
                items = vim.deepcopy(self.scope_items),
            }
        elseif not line_before_cursor:find '[():]' then
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
