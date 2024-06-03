return {
  adapters = {
    anthropic = "anthropic",
    ollama = "ollama",
    openai = "openai",
  },
  strategies = {
    chat = "openai",
    inline = "openai",
    tool = "openai",
  },
  tools = {
    ["code_runner"] = {
      name = "Code Runner",
      description = "Run code generated by the LLM",
      enabled = true,
    },
    opts = {
      auto_submit_errors = false,
      mute_errors = false,
    },
  },
  saved_chats = {
    save_dir = vim.fn.stdpath("data") .. "/codecompanion/saved_chats",
  },
  display = {
    action_palette = {
      width = 95,
      height = 10,
    },
    chat = {
      window = {
        layout = "float",
        border = "single",
        height = 0.8,
        width = 0.8,
        relative = "editor",
        opts = {
          cursorcolumn = false,
          cursorline = false,
          foldcolumn = "0",
          linebreak = true,
          list = false,
          signcolumn = "no",
          spell = false,
          wrap = true,
        },
      },
      show_settings = true,
      show_token_count = true,
    },
  },
  keymaps = {
    ["<C-s>"] = "keymaps.save",
    ["<C-c>"] = "keymaps.close",
    ["q"] = "keymaps.stop",
    ["gc"] = "keymaps.clear",
    ["ga"] = "keymaps.codeblock",
    ["gs"] = "keymaps.save_chat",
    ["gt"] = "keymaps.add_tool",
    ["]"] = "keymaps.next",
    ["["] = "keymaps.previous",
  },
  intro_message = "Welcome to CodeCompanion ✨! Save the buffer to send a message...",
  log_level = "ERROR",
  send_code = true,
  silence_notifications = false,
  use_default_actions = true,
}
