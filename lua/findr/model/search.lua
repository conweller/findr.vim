-- Namespace
local M = {}
-- Helpers:
local function split(line)
    local t = {}
    for str in string.gmatch(line, "[^%s]+") do
        table.insert(t, str)
    end
    return t
end

local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

-- Stack:
--  - head: head of stack
--  - push: push to top of stack
--  - pop: pop from top of stack

-- Node:
--  - data: node's data
--  - next: next node

local function push(stack, item)
    local node = {}
    node.data = item
    node.next = stack.head
    stack.head = node
end

local function pop(stack)
    if stack.head ~= nil then
        local tmp = stack.head.data
        stack.head = stack.head.next
        return tmp
    end
    return nil
end

function M.candidates(list, inputs)
    local matches = {}
    for _, item in ipairs(list) do
        local match = true
        for _, input in ipairs(inputs) do
            if not string.match(string.lower(item), string.lower(escape_pattern(input))) then
                match = false
                break
            end
        end
        if match then
            table.insert(matches, item)
        end
    end
    return matches
end

local function is_input_subset(old, new)
    return new == old or string.match(escape_pattern(new),escape_pattern(old))
end

function M.update(input, stack, source)
    while stack.head ~= nil and not is_input_subset(stack.head.data.input, input) do
        pop(stack)
    end
    local completions
    if stack.head == nil then
        input = ''
        completions = M.candidates(source(), split(input))
    else
        local new_source = stack.head.data.completions
        completions = M.candidates(new_source, split(input))
    end
    local data = {}
    data.input = input
    data.completions = completions
    push(stack, data)
end


function M.reset()
    M.comp_stack = {}
    M.comp_stack.head = nil
end

M.comp_stack = {}
M.comp_stack.head = nil


return M
