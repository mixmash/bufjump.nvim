
local M = {}


---@type function
local on_success = nil
---@type string[]
local excluded_filetypes = {}


---Jumps the number of times back in the jumplist
---@param num integer
local jumpbackward = function(num)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(tostring(num) .. "<c-o>", true, true, true), "n", false)
end


---Jumps the number of times forward in the jumplist
---@param num integer
local jumpforward = function(num)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(tostring(num) .. "<c-i>", true, true, true), "n", false)
end

---@param stop_cond fun(from_bufnr: integer, to_bufnr: integer):boolean
M.backward_cond = function(stop_cond)
    local jumplist, to_pos = unpack(vim.fn.getjumplist())
    if #jumplist == 0 or to_pos == 0 then
        return
    end

    local from_bufnr = vim.fn.bufnr()
    local from_pos = to_pos + 1
    repeat
        local to_bufnr = jumplist[to_pos].bufnr
        if stop_cond(from_bufnr, to_bufnr) then
            jumpbackward(from_pos - to_pos)
            if on_success then
                on_success()
            end
            return
        end
        to_pos = to_pos - 1
    until to_pos == 0
end


---Returns whether the value is contained in the table
---@param table table
---@param val any
---@return boolean
local function contains(table, val)
    for i=1,#table do
        if table[i] == val then
            return true
        end
    end
    return false
end


---Returns boolean whether the file type of buffer is in excluded file types and will be skipped by jumps
---@param bufnr integer
---@return boolean
M.is_valid_filetype = function (bufnr)
    local buf_filetype = vim.fn.getbufvar(vim.api.nvim_buf_get_name(bufnr), "&filetype")
    return not contains(excluded_filetypes, buf_filetype)
end


---Jumps backward to buffer if the buffer is valid and and its file type is not excluded
M.backward = function()
    M.backward_cond(function(from_bufnr, to_bufnr)
        return from_bufnr ~= to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr) and M.is_valid_filetype(to_bufnr)
    end)
end


---Jumps backward in the current buffer
M.backward_same_buf = function()
    M.backward_cond(function(from_bufnr, to_bufnr)
        return from_bufnr == to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr)
    end)
end


---@param stop_cond fun(from_bufnr: integer, to_bufnr: integer):boolean
M.forward_cond = function(stop_cond)
    local getjumplist = vim.fn.getjumplist()
    local jumplist, from_pos = getjumplist[1], getjumplist[2] + 1
    local max_pos = #jumplist

    if max_pos == 0 or from_pos >= max_pos then
        return
    end

    local from_bufnr = vim.fn.bufnr()
    local to_pos = from_pos + 1

    repeat
        local to_bufnr = jumplist[to_pos].bufnr
        if stop_cond(from_bufnr, to_bufnr) then
            jumpforward(to_pos - from_pos)
            if on_success then
                on_success()
            end
            return
        end
        to_pos = to_pos + 1
    until to_pos == max_pos + 1
end


---Jumps forward to buffer if the buffer is valid and and its file type is not excluded
M.forward = function()
    M.forward_cond(function(from_bufnr, to_bufnr)
        return from_bufnr ~= to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr) and M.is_valid_filetype(to_bufnr)
    end)
end


---Jumps forward in the current buffer
M.forward_same_buf = function()
    M.forward_cond(function(from_bufnr, to_bufnr)
        return from_bufnr == to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr)
    end)
end


---Setups the bufjump keymappings, excluded file types and the on_success function
---@class Config
---@field forward_key string
---@field backward_key string
---@field forward_same_buf string
---@field backward_same_buf string
---@field excluded_buftypes string[]
---@field on_success function
M.setup = function(config)
    local bufjump = require("bufjump")
    config = config or {}
    if config.forward_key ~= false then
        local forward_key = config.forward_key
        vim.keymap.set("n", forward_key, bufjump.forward)
    end
    if config.backward_key ~= false then
        local backward_key = config.backward_key
        vim.keymap.set("n", backward_key, bufjump.backward)
    end
    if config.forward_same_buf_key then
        vim.keymap.set("n", config.forward_same_buf_key, bufjump.forward_same_buf)
    end
    if config.backward_same_buf_key then
        vim.keymap.set("n", config.backward_same_buf_key, bufjump.backward_same_buf)
    end
    if config.excluded_filetypes ~= false then
        excluded_filetypes = config.excluded_filetypes
    end
    if config.on_success ~= false then
        on_success = config.on_success
    end
end

return M

