-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Gruvbox dark, pale (base16)"

-- You can specify some parameters to influence the font selection;
-- for example, this selects a Bold, Italic font variant.
config.font = wezterm.font("JetBrains Mono", { weight = "Medium", italic = false })
config.font_size = 14

-- How many lines of scrollback you want to retain per tab
config.scrollback_lines = 10000
-- Enable the scrollbar.
-- It will occupy the right window padding space.
-- If right padding is set to 0 then it will be increased
-- to a single cell width
config.enable_scroll_bar = true

-- Set ssh_domains manually for quick_domains.wezterm plugin.
local ssh_domains = {}
for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
	table.insert(ssh_domains, {
		-- the name can be anything you want; we're just using the hostname
		name = host,
		-- remote_address must be set to `host` for the ssh config to apply to it
		remote_address = host,

		-- if you don't have wezterm's mux server installed on the remote
		-- host, you may wish to set multiplexing = "None" to use a direct
		-- ssh connection that supports multiple panes/tabs which will close
		-- when the connection is dropped.

		multiplexing = "None",

		-- if you know that the remote host has a posix/unix environment,
		-- setting assume_shell = "Posix" will result in new panes respecting
		-- the remote current directory when multiplexing = "None".
		assume_shell = "Unknown",
	})
end
config.ssh_domains = ssh_domains

-- Plugins
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	options = {
		icons_enabled = true,
		theme = "GruvboxDarkHard",
		tabs_enabled = true,
		theme_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			{ "parent", padding = 0 },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
		tabline_x = { "ram", "cpu" },
		tabline_y = { "datetime", "battery" },
		tabline_z = { "domain" },
	},
	extensions = {},
})

local domains = wezterm.plugin.require("https://github.com/DavidRR-F/quick_domains.wezterm")
local domains_config = {
	keys = {
		-- open domain in new tab
		attach = {
			-- mod keys for fuzzy domain finder
			mods = "SUPER",
			-- base key for fuzzy domain finder
			key = "d",
			-- key table to insert key map to if any
			tbl = "",
		},
		-- open domain in split pane
		-- excludes remote domains
		-- add remote domains as exec domain for split binds
		vsplit = {
			key = "v",
			mods = "CTRL",
			tbl = "",
		},
		hsplit = {
			key = "h",
			mods = "CTRL",
			tbl = "",
		},
	},
	-- swap in and out icons for specific domains
	icons = {
		hosts = "",
		ssh = "󰣀",
		tls = "󰢭",
		unix = "",
		exec = "",
		bash = "",
		zsh = "",
		fish = "",
		pwsh = "󰨊",
		powershell = "󰨊",
		wsl = "",
		windows = "",
		docker = "",
		kubernetes = "󱃾",
	},
	-- auto-configuration
	auto = {
		-- disable ssh multiplex auto config
		ssh_ignore = true,
		-- disable exec domain auto configs
		exec_ignore = {
			ssh = true,
			docker = true,
			kubernetes = true,
		},
	},
	-- default shells
	docker_shell = "/bin/bash",
	kubernetes_shell = "/bin/bash",
}
domains.apply_to_config(config, domains_config)


-- keybiding
local act = wezterm.action
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Middle" } },
		mods = "NONE",
		action = act.PasteFrom "Clipboard",
	},
}


-- and finally, return the configuration to wezterm
return config
