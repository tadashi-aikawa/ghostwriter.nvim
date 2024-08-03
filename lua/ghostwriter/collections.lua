local M = {}

---@generic T, A
---@param tbl T[]
---@param fn fun(acc: A, x: T): A
---@param init A
---@return A
function M.reduce(tbl, fn, init)
	local acc = init
	for _, v in ipairs(tbl) do
		acc = fn(acc, v)
	end
	return acc
end

---wordとマッチする要素の直前までの配列を返す
---@param arr string[]
---@param word string
---@return string[]
function M.head_while(arr, word)
	local result = {}
	for _, value in ipairs(arr) do
		if value == word then
			break
		end
		table.insert(result, value)
	end
	return result
end

return M
