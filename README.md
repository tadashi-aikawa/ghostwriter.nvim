<div align="center">
    <h1>ghostwriter.nvim</h1>
    <img src="./ghostwriter.webp" width="334" />
    <p>
    <div>A Neovim plugin to share Markdown task lists as Slack posts.</div>
    </p>
    <a href="https://github.com/tadashi-aikawa/ghostwriter.nvim/releases/latest"><img src="https://img.shields.io/github/release/tadashi-aikawa/ghostwriter.nvim.svg" /></a>
</div>

## Support Neovim version

0.10 or higher

## Installation

### lazy.nvim

```lua
return {
  "tadashi-aikawa/ghostwriter.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim", -- Required for the GhostwriterRecentMessages command
  },
  keys = {
    { "<C-j>w", ":GhostwriterWrite<CR>", silent = true },
    { "<C-j>p", ":GhostwriterPost ", mode = { "v" } },
    { "<C-j>m", ":GhostwriterRecentMessages " },
    { "<C-j>y", ":GhostwriterCopy<CR>", mode = { "v" }, silent = true },
    { "<C-j>S", ":GhostwriterInsertChannelID<CR>", silent = true },
  },
  cmd = {
    "GhostwriterPost",
    "GhostwriterRecentMessages",
  },
  config = function()
    require("ghostwriter").setup({
      -- Set options
    })
  end,
}
```

## Requirements

You should create a "Slack user token" with the following scopes and set it to the `GHOSTWRITER_SLACK_TOKEN` environment variable.

- [chat:write]
- [channels:history]
- [groups:history]
- [im:history]
- [mpim:history]

## Quick start

1. Create a markdown file (ex: `task.md`)
2. In the first line, write one of the following
    a. the URL of the reference Slack post
    b. the URL of the channel
    c. the channel ID and ts separated by a comma
    d. the channel ID
3. List the tasks from the **third** line onwards
4. Execute the `GhostwriterWrite` command
5. Let's check the relevant Slack channel! 👻

Ex a: Delete the relevant message and repost it in the channel as a new message.

```markdown
https://minerva.slack.com/archives/C2J10C5MF/p1722259290076499

- [x] task1
- [x] task2
  - [x] task2-1
  - [~] task2-2
- [ ] task3
```

Ex b: Post a new message in the channel.

```markdown
https://app.slack.com/client/TKY180702/C2J10C5MF

- [x] task1
- [x] task2
  - [x] task2-1
  - [ ] task2-2
- [ ] task3
```

Ex c: Delete the relevant message and repost it in the channel as a new message.

```markdown
C2J10C5MF,1722347931.398509

- [x] task1
- [x] task2
  - [x] task2-1
  - [ ] task2-2
- [ ] task3
```

Ex d: Post a new message in the channel.

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

## Commands

### GhostwriterWrite

Notify the contents of the block at the **current cursor position** (the block separated by '---') to Slack.

```
GhostwriterWrite
```

`Ex: blocks separated by "---"`
```markdown
C123456789

First block

---
C234567890

Second block

---
C345678901

Last block
```

### GhostwriterPost

Notify the selected range in visual mode to a specified Slack channel.

```
GhostwriterPost <channel_name> [header]
```

| Parameter    | Required | Description                                                                                                                                     |
|--------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| channel_name | true     | The name used to identify the channel. This is `channel.name` specified in the config, and is different from the **actual slack channel name**. |
| header       | false    | Header message to be added before the selected text.                                                                                            |

#### Examples

```
GhostwriterPost times
GhostwriterPost times I like *Neovim!!!*
GhostwriterPost task walking
```

### GhostwriterCopy

Copy the selected range in visual mode to the clipboard as Slack post format

```
GhostwriterCopy
```

### GhostwriterInsertChannelID

Selects a channel from the list defined in the config file and inserts its channel ID into the buffer. This is useful for specifying a notification destination before executing the `GhostwriterWrite` command.

```
GhostwriterInsertChannelID <channel_name>
```

| Parameter    | Required | Description                                                                                                                                     |
|--------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| channel_name | true     | The name used to identify the channel. This is `channel.name` specified in the config, and is different from the **actual slack channel name**. |

### GhostwriterRecentMessages

> [!IMPORTANT]
> This command requires [telescope.nvim].

Select a channel from the list defined in the config file and display its latest messages using Telescope.nvim. Selecting an item inserts the message body at the current cursor position. It is useful for checking a channel's posting status before executing a posting command (ex: `GhostwriterPost`) or quickly reviewing Slack messages to write them into the current buffer.

```
GhostwriterRecentMessages <channel_name> <limit>
```

| Parameter    | Required | Description                                                                                                                                     |
|--------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| channel_name | true     | The name used to identify the channel. This is `channel.name` specified in the config, and is different from the **actual slack channel name**. |
| limit        | false    | The maximum number of messages to return (default: 20)                                                                                          |


## Configration

```lua
  config = function()
    -- Default configration
    require("ghostwriter").setup({
      -- If true, the buffer will be automatically saved when the post is successful
      autosave = true,
      -- Defines the replacers in Slack notification messages
      replacers = {
        { pattern = "202%d+_", replaced = " " },
        { pattern = " %d%d:%d%d ", replaced = " " },
      },
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
      -- Mapping of channel names and channel IDs specified by command arguments or selections
      channel = {
        { name = "times", id = "C1C5MJ80F" },
        { name = "task", id = "C06JRG10V2L" },
      },
    })
  end,
```

## Restrictions

> [!WARNING]
> If the body exceeds **4000** characters, an error will occur. Please keep each post under **4000** characters.

> [!IMPORTANT]
> This plugin is newly created and its specifications are likely to change soon, so please use it with that in mind.

## Recommended plugins to use together

- [MeanderingProgrammer/markdown.nvim](https://github.com/MeanderingProgrammer/markdown.nvim)
- [roodolv/markdown-toggle.nvim](https://github.com/roodolv/markdown-toggle.nvim)

## For developers

### Setup

```bash
git config core.hooksPath hooks
```

### Test

#### Requirements

- [vusted]
  - Lua v5.1
- [mise] (`Optional` If using watch mode)

#### Run tests

```bash
vusted lua
```

#### With watch mode

```bash
mise watch -t test
```

### Release

Run [Release Action](https://github.com/tadashi-aikawa/ghostwriter.nvim/actions/workflows/release.yaml) manually.

[chat:write]: https://api.slack.com/scopes/chat:write
[channels:history]: https://api.slack.com/scopes/channels:history
[groups:history]: https://api.slack.com/scopes/groups:history
[im:history]: https://api.slack.com/scopes/im:history
[mpim:history]: https://api.slack.com/scopes/mpim:history
[vusted]: https://github.com/notomo/vusted
[mise]: https://github.com/jdx/mise/tree/main
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
