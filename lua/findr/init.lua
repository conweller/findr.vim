-- Namespace
findr = {}
-- Helpers:
function findr.split(line)
    local t = {}
    for str in string.gmatch(line, "[^%s]+") do
        table.insert(t, str)
    end
    return t
end

function findr.escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

-- Stack:
--  - head: head of stack
--  - push: push to top of stack
--  - pop: pop from top of stack

-- Node:
--  - data: node's data
--  - next: next node

function findr.push(stack, item)
    local node = {}
    node.data = item
    node.next = stack.head
    stack.head = node
end

function findr.pop(stack)
    if stack.head ~= nil then
        tmp = stack.head.data
        stack.head = stack.head.next
        return tmp
    end
    return nil
end

function findr.scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function findr.candidates(list, inputs)
    local matches = {}
    for i, item in ipairs(list) do
        local match = true
        for i, input in ipairs(inputs) do
            if not string.match(string.lower(item), string.lower(findr.escape_pattern(input))) then
                match = false
                break
            end
        end
        if match then
            table.insert(matches, item)
        end
    end
    table.sort(matches, function(a,b)
        if a == './' then
            return true
        elseif b == './' then
            return false
        elseif a == '../' then
            return true
        elseif b == '../' then
            return false
        else
            return string.len(a) < string.len(b)
        end
    end)
    return matches
end

function findr.update(input, stack)
    while stack.head ~= nil and not findr.is_input_subset(stack.head.data.input, input) do
        findr.pop(stack)
    end
    local completions
    if stack.head == nil then
        input = ''
        completions = findr.scandir('.')
    else
        local new_source = stack.head.data.completions
        completions = findr.candidates(new_source, findr.split(input))
    end
    local data = {}
    data.input = input
    data.completions = completions
    findr.push(stack, data)
end

function findr.update_display(stack, winheight)
    findr.display = stack.head.data.completions
end

function findr.tablelength(T)
    local count = 0
    for i, item in ipairs(T) do
        count = count + 1
    end
    return count
end

function findr.scroll_down(count)
    local len = findr.tablelength(findr.display)
    local new_T = {}
    for i, item in ipairs(findr.display) do
        new_T[(i-(1+count))%len+1] = item
    end
    findr.display = new_T
end

function findr.scroll_up(count)
    local len = findr.tablelength(findr.display)
    local new_T = {}
    for i, item in ipairs(findr.display) do
        new_T[(i+(count-1))%len+1] = item
    end
    findr.display = new_T
end

findr.comp_stack = {}
findr.comp_stack.head = nil
findr.display = {}

function findr.reset()
    findr.comp_stack = {}
    findr.comp_stack.head = nil
    findr.display = {}
end

function findr.is_input_subset(old, new)
    return new == old or string.match(findr.escape_pattern(new),findr.escape_pattern(old))
end
