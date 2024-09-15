local M = {}

---@generic T, U
---@param tbl T[]
---@param fn fun(x: T): U
---@return U[]
function M.map(tbl, fn)
	local result = {}
	for k, v in pairs(tbl) do
		result[k] = fn(v)
	end
	return result
end

---@generic T
---@param tbl T[]
---@param predicate fun(x: T): boolean
---@return T | nil
function M.find(tbl, predicate)
	for _, item in ipairs(tbl) do
		if predicate(item) then
			return item
		end
	end
	return nil
end

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
