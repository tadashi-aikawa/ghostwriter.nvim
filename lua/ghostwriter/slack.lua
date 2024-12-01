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

---@param dst string
---@return string channel_id, string | nil ts
function M.pick_channel_and_ts(dst)
	local channel_id, message_id, ts

	channel_id, message_id = dst:match("https://%w+.slack.com/archives/(%w+)/p(%d+)")
	if channel_id and message_id then
		ts = message_id:sub(1, 10) .. "." .. message_id:sub(11)
		return channel_id, ts
	end

	_, channel_id = dst:match("https://%w+.slack.com/client/(%w+)/(%w+)")
	if channel_id then
		return channel_id, nil
	end

	-- urlでない場合はchannel_id,ts形式
	channel_id, ts = unpack(vim.split(dst, ","))
	if not channel_id then
		error("Invalid dst format")
	end

	return channel_id, ts
end

return M
