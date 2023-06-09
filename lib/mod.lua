local fx = require("fx/lib/fx")
local mod = require 'core/mods'
local music = require("musicutil")

local FxResonator = fx:new {
    subpath = "/fx_resonator"
}

function FxResonator:add_params()
    params:add_separator("fx_resonator", "fx resonator")
    FxResonator:add_slot("fx_resonator_slot", "slot")
    params:add_number("fx_resonator_note", "note", 12, 127, 36, function(p)
        return music.note_num_to_name(p:get(), true)
    end)
    params:set_action("fx_resonator_note", function(n)
        osc.send({ "localhost", 57120 }, self.subpath .. "/set", { "note", n })
    end)
    FxResonator:add_control("fx_resonator_structure", "structure", "structure", controlspec.new(0, 1, 'lin', 0, 0.25))
    FxResonator:add_control("fx_resonator_brightness", "brightness", "brightness", controlspec.new(0, 1, 'lin', 0, 0.5))
    FxResonator:add_control("fx_resonator_damping", "damping", "damping", controlspec.new(0, 1, 'lin', 0, 0.7))
    FxResonator:add_control("fx_resonator_position", "position", "position", controlspec.new(0, 1, 'lin', 0, 0.25))
    params:add_option("fx_resonator_model", "model", {
        "modal",
        "symp. strings",
        "inarm. string",
        "2-op fm",
        "western chords",
        "reverb string",
    }, 1)
    params:set_action("fx_resonator_model", function(m)
        osc.send({ "localhost", 57120 }, self.subpath .. "/set", { "model", m - 1 })
    end);
    FxResonator:add_control("fx_resonator_poly", "poly", "poly", controlspec.new(1, 4, 'lin', 1, 1, "", 0.25))
    FxResonator:add_control("fx_resonator_width", "width", "width", controlspec.UNIPOLAR)
    FxResonator:add_taper("fx_resonator_amp", "amp", "amp", 0, 1, 0.5, 2)
    FxResonator:add_control("fx_resonator_pan", "pan", "pan", controlspec.BIPOLAR)
    FxResonator:add_taper("fx_resonator_send_a", "send a", "sendA", 0, 1, 0, 2)
    FxResonator:add_taper("fx_resonator_send_b", "send b", "sendB", 0, 1, 0, 2)
    FxResonator:add_control("fx_resonator_egg", "egg", "easteregg", controlspec.new(0, 1, 'lin', 1, 0, "", 1))
end

mod.hook.register("script_pre_init", "resonator mod pre init", function()
    FxResonator:install()
    local player = {}
    function player:note_on(note, vel, properties)
        osc.send({ "localhost", 57120 },  "/fx_resonator/note", { note })
    end
    if note_players == nil then
        note_players = {}
    end
    function player:describe()
        return {
            name = "resonator ",
            supports_bend = false,
            supports_slew = false,
            modulate_description = "unsupported",
        }
    end
    note_players["resonator"] = player
end)

mod.hook.register("script_post_cleanup", "resonator mod post cleanup", function()
end)

return FxResonator
