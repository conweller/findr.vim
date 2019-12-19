-- Namespace
findr = {}
-- Helpers:
findr.split = function(line)
    local t = {}
    for str in string.gmatch(line, "[^%s]+") do
        table.insert(t, str)
    end
    return t
end

--- Check if a file or directory exists in this path

--- Check if a directory exists in this path
findr.isdir = function(path)
    local function exists(file)
        local ok, err, code = os.rename(file, file)
        if not ok then
            if code == 13 then
                -- Permission denied, but it exists
                return true
            end
        end
        return ok, err
    end
    -- "/" works on both Unix and Windows
    return exists(path.."/")
end

findr.escape_pattern = function(text)
    return text:gsub("([^%w])", "%%%1")
end

-- Stack:
--  - head: head of stack
--  - push: push to top of stack
--  - pop: pop from top of stack

-- Node:
--  - data: node's data
--  - next: next node

findr.push = function(list, item)
    local node = {}
    node.data = item
    node.next = list.head
    list.head = node
end

findr.pop = function(list)
    assert(list.head ~= nil)
    assert(list.head.next ~= nil)
    list.head = list.head.next
    return list.head
end

findr.scandir = function(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        if findr.isdir(filename) or filename =='.' or filename == '..' then
            t[i] = filename .. '/'
        else
            t[i] = filename
        end
    end
    pfile:close()
    return t
end

findr.candidates = function(list, inputs)
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
    table.sort(matches, function(a,b) return string.len(a) < string.len(b) end)
    return matches
end

findr.update = function(input, stack)
    while stack.head ~= nil and not is_input_subset(stack.head.data.input, input) do
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

findr.update_display = function(stack, winheight)
    findr.display = stack.head.data.completions
end

findr.tablelength = function(T)
    local count = 0
    for i, item in ipairs(T) do
        count = count + 1
    end
    return count
end

findr.scroll_down = function(count)
    local len = findr.tablelength(findr.display)
    local new_T = {}
    for i, item in ipairs(findr.display) do
        new_T[(i-(1+count))%len+1] = item
    end
    findr.display = new_T
end

findr.scroll_up = function(count)
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

findr.reset = function()
    findr.comp_stack = {}
    findr.comp_stack.head = nil
    findr.display = {}
end

function is_input_subset(old, new)
    return string.match(findr.escape_pattern(new),findr.escape_pattern(old))
end
