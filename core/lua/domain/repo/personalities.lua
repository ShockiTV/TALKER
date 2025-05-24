package.path = package.path .. ";./core/lua/?.lua;"
local log = require("framework.logger")
local unique_character_personalities = require("infra.STALKER.unique_character_personalities")
local queries = talker_game_queries or require("core.tests.mocks.mock_game_queries")

local M = {}
local character_personalities = {}

---------------------------------------------------------------------------------------------------
-- FOR MOCKING
---------------------------------------------------------------------------------------------------
function M.set_queries(q)
    log.spam("Setting queries...")
    queries = q
end

---------------------------------------------------------------------------------------------------
-- LOAD FROM XMLS
---------------------------------------------------------------------------------------------------

local function get_random_faction_personality(faction)
    log.spam("Fetching random personality for faction: "..faction)
    return queries.load_random_xml("traits_" .. faction)
end

local function get_random_personality()
    log.spam("Fetching a generic random personality...")
    return queries.load_random_xml("traits")
end

---------------------------------------------------------------------------------------------------
-- SET
---------------------------------------------------------------------------------------------------
local function set_personality(character, personality)
    character_personalities[character.game_id] = personality
end

local function set_random_personality(character)
    -- If the character is unique, we need to assign a specific personality
    if tostring(character.game_id) == "0" then
        return "" -- player
    end
    if queries.is_unique_character_by_id(character.game_id) then
        log.debug("Handling unique character: "..character.game_id)
        local tech_name = queries.get_technical_name_by_id(character.game_id)
        local personality = unique_character_personalities[tech_name]
        if not personality then
            log.warn("No personality found for unique character: ".. tech_name)
            return
        end
        set_personality(character, personality)
        return
    end
    -- Otherwise, we assign a random personality based on the faction
    local personality = get_random_faction_personality(character.faction)
    if not personality or personality == "" then
        log.spam("Faction personality empty, loading generic personality.")
        personality = get_random_personality()
    end
    log.spam("Assigning random personality to character: "..character.game_id .. " - " .. personality)
    set_personality(character, personality)
end



---------------------------------------------------------------------------------------------------
-- GET
---------------------------------------------------------------------------------------------------

local function get_personality(character)
    return character_personalities[character.game_id]
end

function M.get_personality(character)
    log.spam("Retrieving personality for character: "..character.game_id)
    local personality = get_personality(character)
    if not personality then
        log.spam("No personality cached, setting a random one.")
        set_random_personality(character)
        personality = get_personality(character)
        if not personality then
            log.warn("No personality found after assignment: "..character.game_id)
        end
    end
    return personality or ""
end

---------------------------------------------------------------------------------------------------
-- SAVING DATA
---------------------------------------------------------------------------------------------------

function M.get_save_data()
    log.debug("Returning character personalities for save.")
    return character_personalities
end

function M.clear()
    log.debug("Clearing character personalities cache.")
    character_personalities = {}
end

function M.load_save_data(saved_character_personalities)
    log.debug("Loading saved character personalities.")
    character_personalities = saved_character_personalities
end

return M
