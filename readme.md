# 🔄 Previous Workspace - WezTerm Plugin

A lightweight WezTerm plugin that enables quick switching between your current and previous workspaces, enhancing your terminal workflow with efficient workspace navigation.
IT's a simple `Go back to previous workspace` feature for WezTerm.

## ✨ Features

- 🔄 Seamless switching to previous workspace
- 📝 Automatic workspace history for quick navigation
- 🐛 Debug logging capabilities

## 📦 Installation

1. Import the plugin in your `wezterm.lua`:

```lua
local previous_workspace = require("previous_workspace.wez")
```

2. Add keybinding for switching to previous workspace:

```lua
config.keys = {
  {
    key = "b",
    mods = "CTRL|ALT",
    action = previous_workspace.switch_to_previous_workspace(),
  },
}

return config
```

### Debug Mode

Enable debug logging when needed:

```lua
previous_workspace.set_debug(true)
```

## 🤝 Contributing

Contributions are welcome! Please note:

- This project is maintained as time permits
- Focus on meaningful improvements that don't add unnecessary complexity

## 📄 License

This project follows the MIT License conventions. Feel free to use, modify, and distribute as per MIT License terms.
