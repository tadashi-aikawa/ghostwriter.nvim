local async = require("ghostwriter.utils.async")

local M = {}

---@return string | nil
local function get_token()
	---@diagnostic disable-next-line: missing-parameter
	return vim.uv.os_getenv("GHOSTWRITER_SLACK_TOKEN")
end

---@async
---@param channel_id string
---@param message string
---@return {ok: boolean, channel: string, ts: string}
function M.post_message(channel_id, message)
	local response = async.post({
		url = "https://slack.com/api/chat.postMessage",
		headers = {
			["Content-Type"] = "application/json; charset=UTF-8",
			["Authorization"] = "Bearer " .. get_token(),
		},
		body = vim.json.encode({
			channel = channel_id,
			text = message,
		}),
	})

	return vim.json.decode(response.body)
end

---@async
---@param channel_id string
---@param ts string
---@return {ok: boolean}
function M.delete_message(channel_id, ts)
	local response = async.post({
		url = "https://slack.com/api/chat.delete",
		headers = {
			["Content-Type"] = "application/json; charset=UTF-8",
			["Authorization"] = "Bearer " .. get_token(),
		},
		body = vim.json.encode({
			channel = channel_id,
			ts = ts,
		}),
	})

	return vim.json.decode(response.body)
end

---@async
---@param channel_id string
---@param limit number
---@return {ok: boolean, messages: {text: string, ts: string}[]}
function M.get_coversations_history(channel_id, limit)
	local response = async.get({
		url = "https://slack.com/api/conversations.history",
		headers = {
			["Content-Type"] = "application/json; charset=UTF-8",
			["Authorization"] = "Bearer " .. get_token(),
		},
		query = { channel = channel_id, limit = limit },
	})

	return vim.json.decode(response.body)
end

--- @class SlackMessageMatch
--- @field ts string
--- @field text string
--- @field username string
--- @field channel {id: string, name: string}
--- @field permalink string

--- @alias sort "timestamp" | "score"

---@async
---@param query string
---@param page number 1以上
---@param count number
---@param sort sort
---@return {ok: boolean, messages: {
---  matches: SlackMessageMatch[],
---}}
function M.get_search_messages(query, count, page, sort)
	local response = async.get({
		url = "https://slack.com/api/search.messages",
		headers = {
			["Content-Type"] = "application/json; charset=UTF-8",
			["Authorization"] = "Bearer " .. get_token(),
		},
		query = { query = query, count = count, page = page, sort = sort },
	})

	return vim.json.decode(response.body)
end

return M
