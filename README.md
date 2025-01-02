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
    -- Set hotkeys
  },
  opts = {
    -- Set options
  }
}
```

#### keys example

```lua
  keys = {
    { "gsw", ":GhostwriterWrite<CR>", silent = true },
    { "gsp", ":GhostwriterPost ", mode = { "v" } },
    { "gsm", ":GhostwriterRecentMessages " },
    { "gsy", ":GhostwriterCopy<CR>", mode = { "v" }, silent = true },
  }
```

## Create a slack token

You should create a [Slack user token](https://api.slack.com/concepts/token-types#user) with the following scopes and set it to the `GHOSTWRITER_SLACK_TOKEN` environment variable.

- **Required**
    - [chat:write](https://api.slack.com/scopes/chat:write)
- Optional (Used only for the `GhostwriterRecentMessages` command)
    - [channels:history](https://api.slack.com/scopes/channels:history)
    - [groups:history](https://api.slack.com/scopes/groups:history)
    - [im:history](https://api.slack.com/scopes/im:history)
    - [mpim:history](https://api.slack.com/scopes/mpim:history)

## Key Terms

### `channel_name`

Note that the `channel_name` is **not the actual Slack channel name** but is specified in the config.

For example, the `channel_name` specified in the following configuration is "times", but the actual channel name in Slack is `#times_tadashi-aikawa`.

```lua
  opts = {
    channel = {
      { name = "times", id = "C1J80C5MF" },
    },
  },
```

### `destination`

In ghostwriter.nvim, the term **`destination`** refers to information that uniquely identifies a Slack channel or a post for posting. The list of supported destinations is as follows.

| Description       | Target  | Sample value                                                   |
| -                 | -       | -                                                              |
| Slack post URL    | post    | https://minerva.slack.com/archives/C2J10C5MF/p1722259290076499 |
| Slack channel URL | channel | https://app.slack.com/client/TKY180702/C2J10C5MF               |
| channel_id & ts   | post    | C2J10C5MF,1722347931.398509                                    |
| channel_id        | channel | C2J10C5MF                                                      |
| channel_name & ts | post    | @times,1722347931.398509                                       |
| channel_name      | channel | @times                                                         |

### `block`

The sections separated by "---" are referred to as **`blocks`**.

```markdown
C123456789

First block

---
@times

Second block

---
https://minerva.slack.com/archives/C2J10C5MF/p1722259290076499

Last block
```

The `destination` is specified on the first line of the block.

## Commands

### GhostwriterWrite

Notify the contents of the **`block`** at the **current cursor position** to Slack.

```
GhostwriterWrite
```

When the command succeeds, the `destination` is **overwritten with the posted target**. This is because ghostwriter.nvim wants to share the progress, so it makes sense to remove outdated posts and post the latest message where everyone can see it.

If you **do not** want to overwrite the `destination`, add `!` to the end of `channel_id` or `channel_name`. This is useful when using ghostwriter.nvim solely as a Slack posting client.

#### ex: Write patterns

##### *Delete* the relevant message and *repost* it in the channel *as a new message*

```markdown
https://minerva.slack.com/archives/C2J10C5MF/p1722259290076499

- [x] task1
- [x] task2
  - [x] task2-1
  - [~] task2-2
- [ ] task3
```

##### Post a new message in the channel

```markdown
https://app.slack.com/client/TKY180702/C2J10C5MF

- [x] task1
- [x] task2
  - [x] task2-1
  - [ ] task2-2
- [ ] task3
```

##### *Delete* the relevant message and *repost* it in the channel (`channel_name` is `times`) *as a new message*

```markdown
@times,1722347931.398509

- [x] task1
- [x] task2
  - [x] task2-1
  - [ ] task2-2
- [ ] task3
```

##### Post a new message in the channel (`channel_name` is `times`) and don't rewrite the destination

```markdown
@times!

Hello!
```

##### Post a new message in the channel (`channel_name` is `times`)

```markdown
@times

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

### GhostwriterPost

Notify the selected range in visual mode to a specified Slack channel.

```
GhostwriterPost <channel_name> [mode]
```

| Parameter      | Required   | Description                        |
| -------------- | ---------- | ---------------------------------- |
| channel_name   | true       | See [channel_name](#channel_name)  |
| mode           | false      | `code`: Post as a code block.      |


#### Examples

```
GhostwriterPost times
GhostwriterPost times code
```

### GhostwriterCopy

Copy the selected range in visual mode to the clipboard as Slack post format

```
GhostwriterCopy
```

### GhostwriterRecentMessages

> [!IMPORTANT]
> This command requires [telescope.nvim].

Select a channel from the list defined in the config file and display its latest messages using Telescope.nvim. When you select an item, it will be yanked. The feature is useful for checking a channel's posting status before running a posting command (ex: `GhostwriterPost`) or for quickly reviewing Slack messages to write them into the current buffer or for similar tasks.

```
GhostwriterRecentMessages <channel_name> <limit>
```

| Parameter      | Required   | Default | Description                                             |
| -------------- | ---------- | -       | ------------------------------------------------------- |
| channel_name   | true       |         | See [channel_name](#channel_name)                       |
| limit          | false      | 20      | The maximum number of messages to return                |

You can also post the entered query as a message to Slack by pressing Alt+Enter.

#### Examples

```
GhostwriterRecentMessages times
GhostwriterRecentMessages times 50
```

## Configration

```lua
  opts = {
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
    -- Defines the replacers in Slack notification messages
    replacers = {
      { pattern = "202%d+_", replaced = " " },
      { pattern = " %d%d:%d%d ", replaced = " " },
    },
    -- Mapping of channel names and channel IDs specified by command arguments or selections
    channel = {
      { name = "times", id = "C1C5MJ80F" },
      { name = "task", id = "C06JRG10V2L" },
    },
  }
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

[vusted]: https://github.com/notomo/vusted
[mise]: https://github.com/jdx/mise/tree/main
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
