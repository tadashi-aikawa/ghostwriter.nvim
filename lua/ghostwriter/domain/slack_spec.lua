-- WARNING: 実行に影響を与えずLSPエラーを抑制する回避策
local assert = require("luassert.assert")
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global

local slack = require("ghostwriter.domain.slack")

describe("slack.pick_channel_and_ts", function()
	it("from archive URL", function()
		local channel_id, ts =
			slack.pick_channel_and_ts("https://minerva.slack.com/archives/ABCDEFGHI/p1234567890123456")
		assert.same("ABCDEFGHI", channel_id)
		assert.same("1234567890.123456", ts)
	end)

	it("from client URL", function()
		local channel_id, ts = slack.pick_channel_and_ts("https://app.slack.com/client/T1234567R/C12345ABC")
		assert.same("C12345ABC", channel_id)
		assert.same(nil, ts)
	end)

	it("from channel id", function()
		local channel_id, ts = slack.pick_channel_and_ts("C12345ABC")
		assert.same("C12345ABC", channel_id)
		assert.same(nil, ts)
	end)

	it("from channel id & ts", function()
		local channel_id, ts = slack.pick_channel_and_ts("C12345ABC,1234567890.123456")
		assert.same("C12345ABC", channel_id)
		assert.same("1234567890.123456", ts)
	end)
end)
