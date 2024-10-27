-- WARNING: 実行に影響を与えずLSPエラーを抑制する回避策
local assert = require("luassert.assert")
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global

local strings = require("ghostwriter.utils.strings")

describe("strings.replace", function()
	it("replaces RegExp", function()
		assert.same("XXX", strings.replace("abc", "[a-z]", "X"))
	end)
	it("does not replace an unescaped RegExp correctly", function()
		assert.same("[true-true]", strings.replace("[a-z]", "[a-z]", "true"))
	end)
	it("replaces an unescaped RegExp correctly", function()
		assert.same("true", strings.replace("[a-z]", "%[a%-z%]", "true"))
	end)
end)

describe("strings.convert_link", function()
	it("does not convert plain text", function()
		assert.same("hogehoge", strings.convert_link("hogehoge", {}))
	end)
	it("does not convert a URL", function()
		assert.same("https://sample.com", strings.convert_link("https://sample.com", {}))
	end)
	it("does not convert a Wiki link", function()
		assert.same("[[hogehoge]]", strings.convert_link("[[hogehoge]]", {}))
	end)

	describe("(link.disabled: false)", function()
		it("converts a Markdown link to a Slack link", function()
			assert.same("<https://title.com|title>", strings.convert_link("[title](https://title.com)", {}))
		end)
		it(
			"converts a Markdown link with square brackets, parentheses, or hyphens in the title to a Slack link",
			function()
				assert.same(
					"<https://title.com|[title] desc - (note) - >",
					strings.convert_link("[\\[title\\] desc \\- \\(note\\) \\- ](https://title.com)", {})
				)
			end
		)
	end)

	describe("(link.disabled: true)", function()
		it("converts a Markdown link to just its title", function()
			assert.same("title", strings.convert_link("[title](https://title.com)", { disabled = true }))
		end)
		it(
			"converts a Markdown link with square brackets, parentheses, or hyphens in the title to just its title",
			function()
				assert.same(
					"[title] desc - (note) - ",
					strings.convert_link(
						"[\\[title\\] desc \\- \\(note\\) \\- ](https://title.com)",
						{ disabled = true }
					)
				)
			end
		)
	end)
end)

describe("strings.convert_header", function()
	it("converts an H1 header to bold text", function()
		assert.same("*head*", strings.convert_header("# head"))
	end)
	it("converts an H2 header to bold text", function()
		assert.same("*head*", strings.convert_header("## head"))
	end)
	it("converts an H3 header to bold text", function()
		assert.same("*head*", strings.convert_header("### head"))
	end)
	it("converts an H4 header to bold text", function()
		assert.same("*head*", strings.convert_header("#### head"))
	end)
	it("converts an H5 header to bold text", function()
		assert.same("*head*", strings.convert_header("##### head"))
	end)
	it("converts an H6 header to bold text", function()
		assert.same("*head*", strings.convert_header("###### head"))
	end)

	describe("(before_blank_lines: 2)", function()
		it("converts a header to bold text and adds two line breaks before it", function()
			assert.same("\n\n*head*", strings.convert_header("# head", 2))
		end)
	end)
end)
