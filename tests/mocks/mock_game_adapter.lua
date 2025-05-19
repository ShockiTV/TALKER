local nearby_characters = require('tests.mocks.mock_characters')
local Event = require('domain.model.Event')

-- The mocker module
local mocker = {}

function mocker.get_characters_near(obj)
    return nearby_characters
end

function mocker.get_characters_near_player()
    return nearby_characters
end

function mocker.get_player_character()
    return nearby_characters[001]
end

function mocker.get_weapon(id)
    local game_id = '2'
    local name = 'mock_weapon'
    return Item.new(game_id, name)
end

function mocker.get_player_weapon()
    local game_id = '2'
    local name = 'mock_weapon'
    return Item.new(game_id, name)
end


function mocker.create_game_event(description, objects, witnesses)
    print('mock creating game event')
    local game_time = os.time() * 1000
    local world_context = "Cordon"
    local new_event = Event.create_event(description, objects, game_time, world_context, witnesses)
    return new_event
end

function mocker.create_character(game_object_person)
    return nearby_characters[1]
end

function mocker.create_item(game_object_item)
    local game_id = '1'
    local name = 'mock_item'
    return Item.new(game_id, name)
end

function mocker.create_dialogue_event(speaker_id, dialogue)
    local witnesses = mocker.get_characters_near_player()
    local speaker_char = mocker.get_name_by_id(speaker_id)
    local dialogue_event = mocker.create_game_event("%s said: %s", {speaker_char, dialogue}, witnesses)
    return dialogue_event
end

function mocker.get_name_by_id(game_id)
    for _, character in ipairs(nearby_characters) do
        if character.game_id == game_id then
            return character.name
        end
    end
end

-- Mock ASYNC
function mocker.repeat_until_true(seconds_between_attempts, func, ...)
    local args = {...}
    while true do
        if func(unpack(args)) then
            break
        end
        os.execute("sleep " .. tonumber(seconds_between_attempts))
    end
end

-- Mock DIALOGUE
function mocker.display_dialogue(speaker_id, dialogue)
    print('mocking display dialogue')
    print(string.format("%s: %s", speaker_id, dialogue))
end

function mocker.display_to_player(message, seconds)
    print(message)
end

-- FILES
function mocker.get_base_path()
    return ""
end

function mocker.is_mock()
    return true
end

return mocker