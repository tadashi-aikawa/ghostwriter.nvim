local M = {}

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
