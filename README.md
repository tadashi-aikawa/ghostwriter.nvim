<div align="center">
    <h1>ghostwriter.nvim</h1>
    <img src="./ghostwriter.webp" width="334" />
    <p>
    <div>A Neovim plugin to share Markdown task lists as Slack posts.</div>
    </p>
</div>

> [!IMPORTANT]
> This plugin is newly created and its specifications are likely to change soon, so please use it with that in mind.

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
    -- Default options
    require("ghostwriter").setup({
      check = {
        { mark = "x", emoji = "large_green_circle" },
        { mark = " ", emoji = "white_circle" },
      },
      indent = {
        ratio = 1,
      },
    })
  end,
}
```

## Requirements

You should create a "Slack user token" with the [chat:write] scope and set it to the `SLACK_USER_TOKEN` environment variable.

## Quick start

1. Create a markdown file (ex: `task.md`)
2. In the first line, write either **the URL of the reference Slack post** or **the channel ID and ts separated by a comma**
3. List the tasks from the **third** line onwards
4. Execute the `Ghostwrite` command (the default keymap is `<C-j>m`)
5. Let's check the relevant Slack channel! 👻

ex1:

```markdown
C2J10C5MF,1722347931.398509

- [x] task1
- [x] task2
  - [x] task2-1
  - [ ] task2-2
- [ ] task3
```

ex2:

```markdown
https://minerva.slack.com/archives/C2J10C5MF/p1722259290076499

- [x] task1
- [x] task2
  - [x] task2-1
  - [~] task2-2
- [ ] task3
```


## Configration

ex:

```lua
  config = function()
    require("ghostwriter").setup({
      check = {
        { mark = "~", emoji = "loading" },
        { mark = "x", emoji = "ok_green" },
        { mark = "_", emoji = "rip" },
        { mark = " ", emoji = "circle-success" },
      },
      indent = {
        ratio = 2,
      },
    })
  end,
```

> [!NOTE]
> TODO: description


[chat:write]: https://api.slack.com/scopes/chat:write

