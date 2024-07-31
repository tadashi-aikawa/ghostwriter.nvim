-- FIXME: importを認識したい
local curl = require("plenary.curl")

local M = {}

local function get_token()
	return vim.fn.getenv("GHOSTWRITER_SLACK_TOKEN")
end

function M.post_message(channel_id, message)
	local response = curl.post({
		url = "https://slack.com/api/chat.postMessage",
		headers = {
			["Content-Type"] = "application/json; charset=UTF-8",
			["Authorization"] = "Bearer " .. get_token(),
		},
		body = vim.fn.json_encode({
			channel = channel_id,
			text = message,
		}),
	})

	return vim.fn.json_decode(response.body)
end

function M.delete_message(channel_id, ts)
	local response = curl.post({
		url = "https://slack.com/api/chat.delete",
		headers = {
			["Content-Type"] = "application/json; charset=UTF-8",
			["Authorization"] = "Bearer " .. get_token(),
		},
		body = vim.fn.json_encode({
			channel = channel_id,
			ts = ts,
		}),
	})

	return vim.fn.json_decode(response.body)
end

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
