local M = {}
M.display = {}

local search = require('findr/model/search')
local utils = require('findr/utils')
local scroll = require('findr/model/scroll')
local selected_loc = 1

M.history = require('findr/model/history')

function M.reset()
    search.reset()
    selected_loc = 1
    M.display = {}
end

function M.update(input, source)
    selected_loc = 1
    search.update(input, search.comp_stack, source)
    M.display = search.comp_stack.head.completions
end

function M.select_next()
    if selected_loc + 1 > #M.display then
        return false
    end
    selected_loc = selected_loc + 1
    return true
end

function M.select_prev()
    if selected_loc - 2 < 0 then
        selected_loc = 0
        return false
    end
    selected_loc = selected_loc - 1
    return true
end

function M.scroll_down()
    M.display = scroll.scroll_down(1, M.display)
end

function M.scroll_up()
    M.display = scroll.scroll_up(1, M.display)
end

function M.get_selected()
    local selected = search.comp_stack.head.completions[selected_loc]
    if selected then
        return selected.value
    end
end

return M
