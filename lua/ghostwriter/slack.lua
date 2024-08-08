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

---@param dst string
---@return string channel_id, string ts
function M.pick_channel_and_ts(dst)
	local channel_id, message_id = dst:match("https://%w+.slack.com/archives/(%w+)/p(%d+)")
	if channel_id and message_id then
		local ts = message_id:sub(1, 10) .. "." .. message_id:sub(11)
		return channel_id, ts
	end

	-- urlでない場合はchannel_id,ts形式
	local channel_id2, ts = unpack(vim.split(dst, ","))
	if not channel_id2 then
		error("Invalid dst format")
	end

	return channel_id2, ts
end

return M
