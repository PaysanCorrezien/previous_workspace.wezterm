local wezterm = require("wezterm")
local M = {}

-- Plugin configuration
M.config = {
	debug = false, -- Can be toggled via M.set_debug()
	namespace = "plugins.previous_workspace",
}

-- Initialize the plugin state in a namespaced location
local function init_plugin_state()
	-- Create plugins table if it doesn't exist
	wezterm.GLOBAL.plugins = wezterm.GLOBAL.plugins or {}

	-- Create our plugin namespace
	local plugin_state = wezterm.GLOBAL.plugins[M.config.namespace]
		or {
			workspaces = {
				current = nil,
				previous = nil,
			},
			initialized = false,
		}

	wezterm.GLOBAL.plugins[M.config.namespace] = plugin_state
	return plugin_state
end

-- Helper function for logging
local function log(message, force)
	if M.config.debug or force then
		wezterm.log_info(string.format("[%s] %s", M.config.namespace, message))
	end
end

-- Enable/disable debug logging
function M.set_debug(enabled)
	M.config.debug = enabled
	log(string.format("Debug logging %s", enabled and "enabled" or "disabled"), true)
end

-- Get the plugin state
local function get_state()
	return wezterm.GLOBAL.plugins[M.config.namespace]
end

-- Update workspace history
local function update_workspace_history(current_workspace)
	local state = get_state()
	if current_workspace ~= state.workspaces.current then
		log(
			string.format("Workspace change: %s -> %s", tostring(state.workspaces.current), tostring(current_workspace))
		)

		state.workspaces.previous = state.workspaces.current
		state.workspaces.current = current_workspace
	end
end

-- Function to switch to the previous workspace
function M.switch_to_previous_workspace()
	return wezterm.action_callback(function(window, pane)
		local state = get_state()
		local previous = state.workspaces.previous

		log(string.format("Attempting to switch to previous workspace: %s", tostring(previous)))

		if previous then
			window:perform_action(wezterm.action.SwitchToWorkspace({ name = previous }), pane)
		else
			log("No previous workspace available", true)
		end
	end)
end

-- Initialize the plugin
local function initialize()
	local state = init_plugin_state()

	if not state.initialized then
		-- Setup workspace tracking
		wezterm.on("update-right-status", function(window, pane)
			update_workspace_history(window:active_workspace())
		end)

		state.initialized = true
		log("Plugin initialized", true)
	end
end

-- Function to inspect current history state
function M.debug_print_history()
	local state = get_state()
	log("Current history state:", true)
	for i, entry in ipairs(state.history) do
		log(string.format("\nEntry %d (timestamp: %s):", i, os.date("%Y-%m-%d %H:%M:%S", entry.timestamp)), true)
		for _, zone in ipairs(entry.zones) do
			log(
				string.format(
					"  Type: %s, Text: %s",
					zone.semantic_type,
					zone.text:sub(1, 50) .. (#zone.text > 50 and "..." or "")
				),
				true
			)
		end
	end
end

-- Function to get history stats
function M.get_history_stats()
	local state = get_state()
	local stats = {
		total_entries = #state.history,
		commands = 0,
		outputs = 0,
		prompts = 0,
	}

	for _, entry in ipairs(state.history) do
		for _, zone in ipairs(entry.zones) do
			if zone.semantic_type == "Command" then
				stats.commands = stats.commands + 1
			elseif zone.semantic_type == "Output" then
				stats.outputs = stats.outputs + 1
			elseif zone.semantic_type == "Prompt" then
				stats.prompts = stats.prompts + 1
			end
		end
	end

	return stats
end

-- Function to clear history
function M.clear_history()
	local state = get_state()
	state.history = {}
	log("History cleared", true)
end

-- Function to get last N commands with timestamps
function M.get_recent_commands(n)
	n = n or 5
	local commands = M.get_command_history(n)
	local formatted = {}
	for _, entry in ipairs(commands) do
		table.insert(formatted, {
			timestamp = os.date("%Y-%m-%d %H:%M:%S", entry.timestamp),
			command = entry.zone.text:gsub("^%s*(.-)%s*$", "%1"), -- Trim whitespace
		})
	end
	return formatted
end

-- Setup the plugin when the module is loaded
initialize()

return M
