local strings = require("ghostwriter.utils.strings")
local collections = require("ghostwriter.utils.collections")
local M = {}

---@param dst string
---@param channels {name:string, id:string}[]
---@return string | nil channel_id, string | nil ts
function M.pick_channel_and_ts(dst, channels)
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

	channel_id, ts = unpack(vim.split(dst, ","))
	if strings.starts_with(channel_id, "@") then
		local chname = channel_id:sub(2)
		local ch = collections.find(channels, function(x)
			return x.name == chname
		end)
		if ch then
			return ch.id, ts
		else
			return nil, ts
		end
	end

	if #channel_id ~= 9 then
		return nil, nil
	end

	return channel_id, ts
end

return M
