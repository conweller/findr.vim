local M = {}
M.controller = require('findr.controller')

function M.init(source, directory)
    M.controller.init(source, directory)
end

function M.reset()
    M.controller.reset()
end

function M.quit()
    M.controller.quit()
end

return M
