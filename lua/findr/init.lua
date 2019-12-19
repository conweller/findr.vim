-- Helpers:
function slice (tbl, s, e)
    local pos, new = 1, {}
    for i = s, e do
        new[pos] = tbl[i]
        pos = pos + 1
    end

    return new
end

function split(line)
    t = {}
    for str in string.gmatch(line, "[^%s]+") do
        table.insert(t, str)
    end
    return t
end

--- Check if a file or directory exists in this path
function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

--- Check if a directory exists in this path
function isdir(path)
    -- "/" works on both Unix and Windows
    return exists(path.."/")
end

function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

-- Stack:
--  - head: head of stack
--  - push: push to top of stack
--  - pop: pop from top of stack

-- Node:
--  - data: node's data
--  - next: next node

function print_list(list)
    iter = list.head
    while iter ~= nil do
        print(iter.data[1])
        iter = iter.next
    end
end

function push(list, item)
    node = {}
    node.data = item
    node.next = list.head
    list.head = node
end

function pop(list)
    assert(list.head ~= nil)
    assert(list.head.next ~= nil)
    list.head = list.head.next
    return list.head
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        if isdir(filename) or filename =='.' or filename == '..' then
            t[i] = filename .. '/'
        else
            t[i] = filename
        end
    end
    pfile:close()
    return t
end

function candidates(list, inputs)
    local matches = {}
    for i, item in ipairs(list) do
        local match = true
        for i, input in ipairs(inputs) do
            if not string.match(string.lower(item), string.lower(escape_pattern(input))) then
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

function update(input, stack)
    while stack.head ~= nil and not is_input_subset(stack.head.data.input, input) do
        pop(stack)
    end
    if stack.head == nil then
        input = ''
        completions = scandir('.')
    else
        new_source = stack.head.data.completions
        completions = candidates(new_source, split(input))
    end
    data = {}
    data.input = input
    data.completions = completions
    push(stack, data)
end

function display(stack, winheight)
    -- comp_display = slice(stack.head.data.completions, 1, winheight)
    comp_display = stack.head.data.completions
end

function tablelength(T)
    count = 0
    for i, item in ipairs(T) do
        count = count + 1
    end
    return count
end

function scroll_down()
    len = tablelength(comp_display)
    new_T = {}
    for i, item in ipairs(comp_display) do
        new_T[(i-2)%len+1] = item
    end
    comp_display = new_T
end

function scroll_up()
    len = tablelength(comp_display)
    new_T = {}
    for i, item in ipairs(comp_display) do
        new_T[(i)%len+1] = item
    end
    comp_display = new_T
end

function settable(old, new)
    old.val= new
end

comp_stack = {}
comp_stack.head = nil
comp_display = {}

function reset()
    comp_stack = {}
    comp_stack.head = nil
    comp_display = {}
end

function is_input_subset(old, new)
    return string.match(escape_pattern(new),escape_pattern(old))
end
