-- gemini.lua
local http   = require("infra.HTTP.HTTP")
local json   = require("infra.HTTP.json")
local log    = require("framework.logger")
local config = require("interface.config")

local gemini = {}

-- model registry
local MODEL = {
  smart = "gemini-2.0-flash",
  fast  = "gemini-2.0-flash-lite",
  mid   = "gemini-2.0-flash",
}

-- sampling presets
local PRESET = {
  creative = {
    model = MODEL.smart,
    generationConfig = {
      temperature = 0.9,
      maxOutputTokens = 150,
      topP = 1.0,
    }
  },
  strict = {
    model = MODEL.fast,
    generationConfig = {
      temperature = 0.0,
      maxOutputTokens = 150,
      topP = 1.0,
    }
  },
}

-- helpers --------------------------------------------------------------
local API_KEY = config.GEMINI_API_KEY or config.GOOGLE_API_KEY

local function gpt_to_gemini_messages(messages)
  local contents = {}
  for _, msg in ipairs(messages or {}) do
    -- Convert GPT role format to Gemini format
    local role = msg.role
    if role == "assistant" then
      role = "model"
    elseif role == "system" then
      -- Gemini doesn't have system role, convert to user message
      role = "user"
    end
    
    table.insert(contents, {
      role = role,
      parts = {
        { text = msg.content }
      }
    })
  end
  return contents
end

local function build_body(messages, opts)
  opts = opts or PRESET.creative
  local body = {
    contents = gpt_to_gemini_messages(messages)
  }
  
  -- Add generation config if present
  if opts.generationConfig then
    body.generationConfig = opts.generationConfig
  end
  
  return body
end

local function send(messages, cb, opts)
  assert(type(cb) == "function", "callback required")
  opts = opts or PRESET.creative
  
  local model = opts.model or MODEL.smart
  local api_url = "https://generativelanguage.googleapis.com/v1beta/models/" ..
    model .. ":generateContent?key=" .. API_KEY

  local headers = {
    ["Content-Type"] = "application/json",
    ["Accept"]       = "application/json",
  }

  local body_tbl = build_body(messages, opts)
  log.http("Gemini request: %s", json.encode(body_tbl))

  return http.send_async_request(api_url, "POST", headers, body_tbl, function(resp, err)
    if resp and resp.error then
      err = resp.error
    end
    if err or (resp and resp.error) then
      log.error("Gemini error: error:" .. (err or "no-err") .. " body:" .. json.encode(resp))
      error("Gemini error: error:" .. (err or "no-err") .. " body:" .. json.encode(resp))
    end

    local text = (((resp or {}).candidates or {})[1] or {}).content
    text = ((text or {}).parts or {})[1]
    text = text and text.text or "<no response>"

    log.debug("Gemini response: %s", text)
    cb(text)
  end)
end

-- public shortcuts -----------------------------------------------------
function gemini.generate_dialogue(msgs, cb)
  return send(msgs, cb, PRESET.creative)
end

function gemini.pick_speaker(msgs, cb)
  return send(msgs, cb, {
    model = MODEL.fast, 
    generationConfig = {
      temperature = 0.0,
      maxOutputTokens = 30
    }
  })
end

function gemini.summarize_story(msgs, cb)
  return send(msgs, cb, {
    model = MODEL.fast, 
    generationConfig = {
      temperature = 0.2, 
      maxOutputTokens = 100
    }
  })
end

return gemini