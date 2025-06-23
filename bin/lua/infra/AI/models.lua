local m = {}

local gpt = require("infra.AI.GPT")
local gemini = require("infra.AI.Gemini")
local config = require("interface.config")

local function get_current_provider()
  if config.dialogue_model() == "gemini" then
    return gemini
  else 
    return gpt
  end
end

function m.generate_dialogue(msgs, cb)
  return get_current_provider().generate_dialogue(msgs, cb)
end

function m.pick_speaker(msgs, cb)
  return get_current_provider().send(msgs, cb, PRESET.strict)
end

function m.summarize_story(msgs, cb)
  return get_current_provider().send(msgs, cb, {temperature = 0.2, max_tokens = 100})
end

return m