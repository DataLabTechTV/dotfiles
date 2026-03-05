local wezterm = require("wezterm")

local config = wezterm.config_builder()

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_domain = "WSL:Debian"
end

config.term = "xterm-256color"

config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.window_background_opacity = 0.85
config.kde_window_background_blur = true
config.macos_window_background_blur = 30
config.win32_system_backdrop = "Acrylic"

config.window_decorations = "TITLE | RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.skip_close_confirmation_for_processes_named = {
	"bash",
	"sh",
	"zsh",
	"fish",
	"tmux",
	"nu",
	"cmd.exe",
	"pwsh.exe",
	"powershell.exe",
	"wslhost.exe",
	"wsl.exe",
	"conhost.exe",
}

config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.font_size = 12

config.window_frame = {
	font = wezterm.font("CaskaydiaCove Nerd Font", { bold = true }),
	font_size = 10,
}

local function segments_for_right_status(window)
	return {
		window:active_workspace(),
		wezterm.strftime("%a %b %-d %H:%M"),
		wezterm.hostname(),
	}
end

wezterm.on("update-status", function(window)
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	local segments = segments_for_right_status(window)

	local color_scheme = window:effective_config().resolved_palette

	local bg = wezterm.color.parse(color_scheme.background)
	local fg = color_scheme.foreground

	local gradient_to = bg
	local gradient_from = gradient_to:lighten(0.2)

	local gradient = wezterm.color.gradient({
		orientation = "Horizontal",
		colors = { gradient_from, gradient_to },
	}, #segments)

	local elements = {}

	for i, seg in ipairs(segments) do
		local is_first = i == 1

		if is_first then
			table.insert(elements, { Background = { Color = "none" } })
		end

		table.insert(elements, { Foreground = { Color = gradient[i] } })
		table.insert(elements, { Text = SOLID_LEFT_ARROW })

		table.insert(elements, { Foreground = { Color = fg } })
		table.insert(elements, { Background = { Color = gradient[i] } })
		table.insert(elements, { Text = " " .. seg .. " " })
	end

	window:set_right_status(wezterm.format(elements))
end)

config.initial_cols = 105
config.initial_rows = 33

config.color_scheme = "Tokyo Night"

--- Utilities ---

local function get_home_dir()
	local success, stdout, _ = wezterm.run_child_process({ "bash", "-c", "echo $HOME" })

	if success then
		local home_dir = stdout:gsub("\r?\n", "")

		if home_dir ~= "" then
			return home_dir
		end
	end

	return nil
end

local function glob(path)
	local success, stdout, _ = wezterm.run_child_process({ "bash", "-c", "ls -d " .. path })

	if success then
		local paths = {}

		for line in stdout:gmatch("[^\r\n]+") do
			table.insert(paths, line)
		end

		return paths
	end

	return {}
end

--- Project Switcher ---

local function project_dirs()
	local home_dir = get_home_dir()
	local projects = { "default" }

	wezterm.log_info(glob(home_dir .. "/Code/*"))

	for _, dir in ipairs(glob(home_dir .. "/Code/*")) do
		table.insert(projects, dir)
	end

	return projects
end

local function choose_project()
	local choices = {}
	for _, value in ipairs(project_dirs()) do
		table.insert(choices, { label = value })
	end

	return wezterm.action.InputSelector({
		title = "Projects",
		choices = choices,
		fuzzy = true,
		action = wezterm.action_callback(function(child_window, child_pane, _, label)
			if not label then
				return
			end

			child_window:perform_action(
				wezterm.action.SwitchToWorkspace({
					name = label:match("([^/]+)$"),
					spawn = { cwd = label },
				}),
				child_pane
			)
		end),
	})
end

--- Key Bindings ---

config.disable_default_key_bindings = true

config.leader = { mods = "CTRL", key = " ", timeout_milliseconds = 1000 }

config.keys = {
	{
		key = "F11",
		action = wezterm.action.ToggleFullScreen,
	},
	{
		mods = "CTRL | SHIFT",
		key = "p",
		action = wezterm.action.ShowTabNavigator,
	},
	{
		mods = "CTRL",
		key = ",",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = get_home_dir(),
			args = { "vim", ".config/wezterm/wezterm.lua" },
		}),
	},
	{
		mods = "LEADER",
		key = "p",
		action = choose_project(),
	},
	{
		mods = "LEADER",
		key = "f",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
	{
		mods = "CTRL",
		key = "0",
		action = wezterm.action.ResetFontSize,
	},
	{
		mods = "CTRL",
		key = "+",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		mods = "CTRL",
		key = "-",
		action = wezterm.action.DecreaseFontSize,
	},
	{
		mods = "CTRL",
		key = "Space",
		action = wezterm.action.SendString("\x00"),
	},
}

--- Mouse Bindings ---

config.mouse_bindings = {
	{
		mods = "NONE",
		event = { Up = { streak = 1, button = "Left" } },
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		mods = "CTRL",
		event = { Up = { streak = 1, button = "Left" } },
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	{
		mods = "CTRL",
		event = { Down = { streak = 1, button = "Left" } },
		action = wezterm.action.Nop,
	},
	{
		mods = "ALT",
		event = { Drag = { streak = 1, button = "Left" } },
		action = wezterm.action.StartWindowDrag,
	},
	{
		mods = "CTRL",
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		action = wezterm.action.IncreaseFontSize,
	},
	{
		mods = "CTRL",
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		action = wezterm.action.DecreaseFontSize,
	},
}

return config
