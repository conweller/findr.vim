local M = {}
M.controller = require('findr.controller')
M.start_loc = 1

function M.init(source, directory)
    M.controller.init(source, directory)
end

return M
