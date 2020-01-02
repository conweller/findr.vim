-- Namespace
M = {}
-- Helpers:
function M.split(line)
    local t = {}
    for str in string.gmatch(line, "[^%s]+") do
        table.insert(t, str)
    end
    return t
end

function M.escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

-- Stack:
--  - head: head of stack
--  - push: push to top of stack
--  - pop: pop from top of stack

-- Node:
--  - data: node's data
--  - next: next node

function M.push(stack, item)
    local node = {}
    node.data = item
    node.next = stack.head
    stack.head = node
end

function M.pop(stack)
    if stack.head ~= nil then
        local tmp = stack.head.data
        stack.head = stack.head.next
        return tmp
    end
    return nil
end

function M.scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    table.sort(t, function(a,b)
        if a == '.' then
            return true
        elseif a ~= '.' and b == '..' then
            return false
        elseif string.len(a) == string.len(b) then
            return a < b
        else
            return string.len(a) < string.len(b)
        end
    end)
    return t
end

function M.candidates(list, inputs)
    local matches = {}
    for _, item in ipairs(list) do
        local match = true
        for _, input in ipairs(inputs) do
            if not string.match(string.lower(item), string.lower(M.escape_pattern(input))) then
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

function M.update(input, stack)
    while stack.head ~= nil and not M.is_input_subset(stack.head.data.input, input) do
        M.pop(stack)
    end
    local completions
    if stack.head == nil then
        input = ''
        completions = M.candidates(M.scandir('.'), M.split(input))
    else
        local new_source = stack.head.data.completions
        completions = M.candidates(new_source, M.split(input))
    end
    local data = {}
    data.input = input
    data.completions = completions
    M.push(stack, data)
end

function M.update_display(stack)
    M.display = stack.head.data.completions
end

function M.tablelength(T)
    local count = 0
    for _, _ in ipairs(T) do
        count = count + 1
    end
    return count
end

function M.scroll_down(count)
    local len = M.tablelength(M.display)
    local new_T = {}
    for i, item in ipairs(M.display) do
        new_T[(i-(1+count))%len+1] = item
    end
    M.display = new_T
end

function M.scroll_up(count)
    local len = M.tablelength(M.display)
    local new_T = {}
    for i, item in ipairs(M.display) do
        new_T[(i+(count-1))%len+1] = item
    end
    M.display = new_T
end

M.comp_stack = {}
M.comp_stack.head = nil
M.display = {}

function M.reset()
    M.comp_stack = {}
    M.comp_stack.head = nil
    M.display = {}
end

function M.is_input_subset(old, new)
    return new == old or string.match(M.escape_pattern(new),M.escape_pattern(old))
end

return M
