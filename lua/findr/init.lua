local M = {}
M.controller = require('findr.controller')

function M.init(source, directory)
    M.controller.init(source, directory)
end

return M
