local M = {}

function M.scroll_down(count, display_table)
    local len = #display_table
    local new_T = {}
    for i, item in ipairs(display_table) do
        new_T[(i-(1+count))%len+1] = item
    end
    return new_T
end

function M.scroll_up(count, display_table)
    local len = #display_table
    local new_T = {}
    for i, item in ipairs(display_table) do
        new_T[(i+(count-1))%len+1] = item
    end
    return new_T
end

return M
