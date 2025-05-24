package.path = package.path .. ';./core/lua/?.lua;./core/lua/*/?.lua'
local luaunit = require('core.tests.utils.luaunit')
local assert_or_record = require("core.tests.utils.assert_or_record")

package.path = package.path .. ';./gamedata/scripts/?.script'
require('talker_trigger_reload')

----------------------------------------------------------------------------------------------------
-- Mocks
----------------------------------------------------------------------------------------------------

local mock_interface = require('core.tests.mocks.mock_game_interface')
local mock_game_adapter = require('core.tests.mocks.mock_game_adapter')

----------------------------------------------------------------------------------------------------
-- Test event on player reload
----------------------------------------------------------------------------------------------------

function testTriggerReload()
    insert_mocks(mock_interface, mock_game_adapter)
    on_player_reloads_weapon()
end

os.exit(luaunit.LuaUnit.run())