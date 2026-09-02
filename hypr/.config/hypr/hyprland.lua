-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Make windows a bit transparent (active, inactive).
-- Overrides Omarchy's default opacity of 0.985 / 0.96.
o.window({ tag = "default-opacity" }, { opacity = "0.9 0.85" })

-- HyprMod managed settings (GUI). Nil out the module so it re-executes on
-- every reload — Omarchy's bootstrap only invalidates default.hypr/*, hypr/*
-- and omarchy.current.theme/* modules, not third-party ones like this.
package.loaded["hyprland-gui"] = nil
require("hyprland-gui")

-- Re-apply the Omarchy theme after HyprMod so theme border/shadow colors
-- always win. HyprMod stays the owner of geometry (gaps, border size,
-- rounding, blur, animations); Omarchy themes stay the owner of colors.
package.loaded["omarchy.current.theme.hyprland"] = nil
pcall(require, "omarchy.current.theme.hyprland")
