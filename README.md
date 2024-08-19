<div align="center">
    <h1>ghostwriter.nvim</h1>
    <img src="./ghostwriter.webp" width="334" />
    <p>
    <div>A Neovim plugin to share Markdown task lists as Slack posts.</div>
    </p>
</div>

> [!IMPORTANT]
> This plugin is newly created and its specifications are likely to change soon, so please use it with that in mind.

## Support Neovim version

0.10 or higher

## Installation

### lazy.nvim

```lua
return {
  "tadashi-aikawa/ghostwriter.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<C-j>m", ":Ghostwrite<CR>", silent = true },
  },
  config = function()
    require("ghostwriter").setup({
      -- Set options
    })
  end,
}
```

## Requirements

You should create a "Slack user token" with the [chat:write] scope and set it to the `GHOSTWRITER_SLACK_TOKEN` environment variable.

## Quick start

1. Create a markdown file (ex: `task.md`)
2. In the first line, write one of the following
    - the URL of the reference Slack post
    - the channel ID and ts separated by a comma
    - the channel ID
3. List the tasks from the **third** line onwards
4. Execute the `Ghostwrite` command
5. Let's check the relevant Slack channel! 👻

ex1:

```markdown
https://minerva.slack.com/archives/C2J10C5MF/p1722259290076499

- [x] task1
- [x] task2
  - [x] task2-1
  - [~] task2-2
- [ ] task3
```

ex2:

```markdown
C2J10C5MF,1722347931.398509

- [x] task1
- [x] task2
  - [x] task2-1
  - [ ] task2-2
- [ ] task3
```

ex3:

```markdown
C2J10C5MF

## section1

- [x] task1
  - note1
  - note2

## section2

- [ ] task2

---
This line and below are excluded.

- hoge
- hoge

```

## Configration

```lua
  config = function()
    -- Default configration
    require("ghostwriter").setup({
      -- If true, the buffer will be automatically saved when the post is successful
      autosave = true,
      -- Defines the checkboxes converted to emojis in Slack notification messages
      check = {
        { mark = "x", emoji = "large_green_circle" },
        { mark = " ", emoji = "white_circle" },
      },
      bullet = {
        -- The emoji that bullets are converted to in Slack notification messages
        emoji = "small_blue_diamond",
      },
      indent = {
        -- How many times the Markdown indentation is multiplied in Slack notification messages
        ratio = 2,
      },
      header = {
        -- Number of visual line breaks before headers
        before_blank_lines = 1,
      },
      link = {
        -- Convert Markdown links to plaintext (ex: [hoge](http://hoge) -> hoge) 
        disabled = false,
      },
    })
  end,
```

## Recommended plugins to use together

- [MeanderingProgrammer/markdown.nvim](https://github.com/MeanderingProgrammer/markdown.nvim)
- [roodolv/markdown-toggle.nvim](https://github.com/roodolv/markdown-toggle.nvim)

[chat:write]: https://api.slack.com/scopes/chat:write
