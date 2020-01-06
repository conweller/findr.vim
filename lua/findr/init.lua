local M = {}
M.controller = require('findr.controller')
M.start_loc = 1

-- TODO: give directory
function M.init(source)
    M.controller.init(source)
end

return M
