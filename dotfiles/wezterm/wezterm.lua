-- Pull in the wezterm API
local wezterm = require("wezterm")

local mux = wezterm.mux
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

wezterm.on('gui-startup', function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
  end)

local dark_mode = wezterm.gui.get_appearance():find("Dark")

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end


config.keys = {
	{ key = '\'', mods = 'CMD', action = act.SplitVertical { domain =  'CurrentPaneDomain' } },
	{ key = '/', mods = 'CMD', action = act.SplitHorizontal { domain =  'CurrentPaneDomain' } },
}


config.max_fps = 90
config.automatically_reload_config = true
if dark_mode then
	config.color_scheme = "Catppuccin Frappe"
else
	config.color_scheme = "Catppuccin Latte"
end
config.bold_brightens_ansi_colors = "No"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 17.2
config.line_height = 1.04
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 18

function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local apps = {
	-- shells
	fish = 0xee41,
	bash = 0xe760,
	zsh = 0xe760,

	-- ssh
	ssh = 0xf08c0,

	-- rust
	cargo = 0xf1617,
	rustc = 0xf1617,
	rustup = 0xf1617,

	-- top like software
	htop = 0xeb17,
	top = 0xeb17,
	btop = 0xeb17,

	-- java
	java = 0xe738,
	javac = 0xe738,
	kotlinc = 0xe81b,

	-- gradle
	gradle = 0xe7f2,
	gradlew = 0xe7f2,

	-- xcode / swift
	xcodebuild = 0xe755,
	swiftc = 0xe755,
	swift = 0xe755,

	-- vim
	vim = 0xe7c5,
	nvim = 0xe7c5,

	-- other editors
	nano = 0xe838,
	emacs = 0xe7cf,

	-- git
	git = 0xf02a2,
	tig = 0xf02a2,

	-- python
	python = 0xe73c,
	python3 = 0xe73c,

	-- file managers
	mc = 0xeaf0,
	ranger = 0xeaf0,
	yazi = 0xeaf0,

	-- misc
	bat = 0xf0b5f,
	ncdu = 0xeb83,
}
local default_app = 0xf1577

function get_app_icon(program_name)
	local program_icon = apps[program_name]
	if not program_icon then
		program_icon = default_app
	end
	-- most of NerdFont symbols needs space to be displayed properly
	-- otherwise they will blend into first character of text
	-- why? not sure, but it is what it is
	return utf8.char(program_icon) .. " "
end

function fancy_digit(number)
	-- can't you have numbers in normal order in NerdFonts? Apparently not
	local zero = 0xf03a1
	local n = zero + number * 3
	-- patch 5 because using formula which works for other numbers give us different 5 without filled background
	-- why? because xD thats why I guess
	if number == 5 then
		n = 0xf03b1
	end
	return utf8.char(n)
end

function fancy_number(number)
	-- do not support numbers bigger than 99 because this should be enough for everyone
	local n = math.fmod(number, 100)
	local first = math.floor(n / 10)
	local last = math.fmod(n, 10)
	if n < 10 then
		return fancy_digit(last) .. ' '
	end
	return fancy_digit(first) .. fancy_digit(last) .. ' '
end

function battery_icon(b)
	local level = math.floor(b.state_of_charge * 10)
	local discharge = {
		0xf008e, -- 0%
		0xf007a, -- 10%
		0xf007b,
		0xf007c,
		0xf007d,
		0xf007e,
		0xf007f,
		0xf0080,
		0xf0081,
		0xf0082,
		0xf0079, -- 100%
	}
	local charging = {
		0xf089f, -- 0%
		0xf089c, -- 10%
		0xf0086,
		0xf0087,
		0xf0088,
		0xf089d,
		0xf0089,
		0xf089e,
		0xf008a,
		0xf008b,
		0xf0085, -- 100%
	}
	if b.state == "Charging" then
		return utf8.char(charging[level + 1])
	end
	return utf8.char(discharge[level + 1])
end

wezterm.on("update-right-status", function(window, pane)
	-- Each element holds the text for a cell in a "powerline" style << fade
	local cells = {}

	local proc = pane:get_foreground_process_info()
	if proc then
		local program_name = basename(proc.executable)
		local program_icon = get_app_icon(program_name)
		local program = program_icon .. program_name .. "/" .. tostring(proc.pid)
		table.insert(cells, program)
	end

	-- An entry for each battery (typically 0 or 1 battery)
	for _, b in ipairs(wezterm.battery_info()) do
		table.insert(cells, string.format(battery_icon(b) .. " %.0f%%", b.state_of_charge * 100))
	end

	local date = wezterm.strftime("%H:%M:%S")
	table.insert(cells, utf8.char(0xf0954) .. " " .. date)

	-- The powerline < symbol
	local LEFT_ARROW = utf8.char(0xe0b3)
	-- The filled in variant of the < symbol
	local SOLID_LEFT_ARROW = utf8.char(0xe0c2) .. " "

	-- Color palette for the backgrounds of each cell
	local colors = {
		"#2aa274",
		"#b64639",
		"#398bb6",
		"#b6b039",
		"#6f39b6",
	}

	-- Foreground color for the text across the fade
	local text_fg = "#000000"

	-- The elements to be formatted
	local elements = {}

	-- How many cells have been formatted
	local num_cells = 0
	table.insert(elements, { Foreground = { Color = colors[1] } })
	table.insert(elements, { Text = SOLID_LEFT_ARROW })

	-- Translate a cell into elements
	function push(text, is_last)
		local cell_no = num_cells + 1
		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
		end
		num_cells = num_cells + 1
	end

	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end

	window:set_right_status(wezterm.format(elements))
end)

local function isempty(s)
	return s == nil or s == ""
end

local tab_colors = wezterm.color.gradient({ preset = "Rainbow" }, 6)

function fancy_tab_title(info, tabs, hover, max_width)
	-- for some reason this returns first and last color as the same
	-- so we will need to do #tab_colors - 1
	local text_fg = "#000000"

	local title = info.tab_title
	if isempty(title) then
		title = info.active_pane.title
	end
	-- we need to make sure that extra formatting chars are accounted for
	-- hence substraction below
	if #title >= max_width - 5 then
		title = string.sub(title, 0, max_width - 5)
	end
	local index = info.tab_index + 1
	local cur_index = math.fmod(info.tab_index + 1, #tab_colors - 1) + 1
	local next_index = math.fmod(info.tab_index + 2, #tab_colors - 1) + 1
	local next_color = tab_colors[next_index]:lighten(0.22)
	local next_color_og = next_color
	local cur_color = tab_colors[cur_index]:lighten(0.22)
	local cur_color_og = cur_color

	local is_next_active = false
	if index + 1 <= #tabs and tabs[index + 1].is_active then
		is_next_active = true
	end

	if hover or info.is_active then
		cur_color = cur_color:darken(0.73)
		next_color = next_color:darken(0.73)
		text_fg = "#fefdff"
	end

	local elements = {}
	table.insert(elements, "ResetAttributes")
	table.insert(elements, { Attribute = { Intensity = "Bold" } })
	table.insert(elements, { Background = { Color = cur_color } })
	table.insert(elements, { Foreground = { Color = text_fg } })
	table.insert(elements, { Text = fancy_number(index) })
	table.insert(elements, { Attribute = { Intensity = "Normal" } })
	table.insert(elements, { Text = title .. " " })
	if is_next_active then
		table.insert(elements, { Background = { Color = next_color_og:darken(0.73) } })
		table.insert(elements, { Foreground = { Color = cur_color_og } })
	else
		table.insert(elements, { Background = { Color = next_color_og } })
		table.insert(elements, { Foreground = { Color = cur_color } })
	end
	table.insert(elements, { Text = utf8.char(0xe0b4) .. " " })
	table.insert(elements, "ResetAttributes")

	return wezterm.format(elements)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = fancy_tab_title(tab, tabs, hover, max_width)
	return {
		{ Text = title },
	}
end)


local gradient_colors = {
	'#eff1f5',
	'#e6e9ef',
	'#e6e9ef',
}
if dark_mode then
	gradient_colors = {
		'#303446',
		'#292c3c',
		'#292c3c',
	}
end
config.window_background_gradient = {
	orientation = 'Vertical',
	colors = gradient_colors,
	interpolation = 'Linear',
	blend = 'LinearRgb',
	noise = 64,
}

return config
