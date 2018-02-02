do


-- Returns the key (index) in the config.enabled_plugins table

local function plugin_enabled( name )

  for k,v in pairs(_config.enabled_plugins) do

    if name == v then

      return k

    end

  end

  -- If not found

  return false

end


-- Returns true if file exists in plugins folder

local function plugin_exists( name )

  for k,v in pairs(plugins_names()) do

    if name..'.lua' == v then

      return true

    end

  end

  return false

end


local function list_all_plugins(only_enabled)

  local tmp = check_markdown('\n\n@Arashsud')

  local text = ''

  local nsum = 0

  for k, v in pairs( plugins_names( )) do

    -- ✔ enabled, ❌ disabled

    local status = '*[❌]➣*'

    nsum = nsum+1

    nact = 0

    -- Check if is enabled

    for k2, v2 in pairs(_config.enabled_plugins) do

      if v == v2..'.lua' then 

        status = '*[✅]➣*'

      end

      nact = nact+1

    end

    if not only_enabled or status == '*[✅]➣*'then

      -- get the name

      v = string.match (v, "(.*)%.lua")

      text = text..nsum..'.'..status..' '..v..' \n'

    end

  end

  local text = text..'\n\n'..nsum..' *📁plugins installed*\n\n'..nact..' _✔plugins enabled_\n\n'..nsum-nact..' _❌plugins disabled_'..tmp

  return text

end


local function list_plugins(only_enabled)

  local text = ''

  local nsum = 0

  for k, v in pairs( plugins_names( )) do

    -- ✔ enabled, ❌ disabled

    local status = '*[❌]➣*'

    nsum = nsum+1

    nact = 0

    -- Check if is enabled

    for k2, v2 in pairs(_config.enabled_plugins) do

      if v == v2..'.lua' then 

        status = '*[✅]➣*'

      end

      nact = nact+1

    end

    if not only_enabled or status == '*[✅]➣*'then

      -- get the name

      v = string.match (v, "(.*)%.lua")

     -- text = text..v..' '..status..'\n'

    end

  end

  local text = text.."\n_🍃All Plugins Reloaded🍃_\n\n"..nact.." *✔Plugins Enabled*\n"..nsum.." *📁Plugins Installed*\n\n@Arashsud"

return text

end


local function reload_plugins( )

  plugins = {}

  load_plugins()

  return list_plugins(true)

end



local function enable_plugin( plugin_name )

  print('checking if '..check_markdown(plugin_name)..' exists')

  -- Check if plugin is enabled

  if plugin_enabled(plugin_name) then

    return ''..check_markdown(plugin_name)..' _is enabled_'

  end

  -- Checks if plugin exists

  if plugin_exists(plugin_name) then

    -- Add to the config table

    table.insert(_config.enabled_plugins, plugin_name)

    print(plugin_name..' added to _config table')

    save_config()

    -- Reload the plugins

    return reload_plugins( )

  else

    return ''..plugin_name..' _does not exists_'

  end

end


local function disable_plugin( name, chat )

  -- Check if plugins exists

  if not plugin_exists(name) then

    return ' '..check_markdown(name)..' _does not exists_'

  end

  local k = plugin_enabled(name)

  -- Check if plugin is enabled

  if not k then

    return ' '..check_markdown(name)..' _not enabled_'

  end

  -- Disable and reload

  table.remove(_config.enabled_plugins, k)

  save_config( )

  return reload_plugins(true) 

end


local function disable_plugin_on_chat(receiver, plugin)

  if not plugin_exists(plugin) then

    return "_Plugin doesn't exists_"

  end


  if not _config.disabled_plugin_on_chat then

    _config.disabled_plugin_on_chat = {}

  end


  if not _config.disabled_plugin_on_chat[receiver] then

    _config.disabled_plugin_on_chat[receiver] = {}

  end


  _config.disabled_plugin_on_chat[receiver][plugin] = true


  save_config()

  return ' '..plugin..' _disabled on this chat_'

end


local function reenable_plugin_on_chat(receiver, plugin)

  if not _config.disabled_plugin_on_chat then

    return 'There aren\'t any disabled plugins'

  end


  if not _config.disabled_plugin_on_chat[receiver] then

    return 'There aren\'t any disabled plugins for this chat'

  end


  if not _config.disabled_plugin_on_chat[receiver][plugin] then

    return '_This plugin is not disabled_'

  end


  _config.disabled_plugin_on_chat[receiver][plugin] = false

  s

ave_config()

  return ' '..plugin..' is enabled again'

end


local function run(msg, matches)

  -- Show the available plugins 

  if is_sudo(msg) then

  if matches[1]:lower() == '!plist' or matches[1]:lower() == '/plist' or matches[1]:lower() == '#plist' then --after changed to moderator mode, set only sudo

    return list_all_plugins()

  end

end

  -- Re-enable a plugin for this chat

   if matches[1] == 'pl' or matches[1] == 'Pl' then

  if matches[2] == '+' and matches[4] == 'chat' then

      if is_momod(msg) then

    local receiver = msg.chat_id_

    local plugin = matches[3]

    print("enable "..plugin..' on this chat')

    return reenable_plugin_on_chat(receiver, plugin)

  end

    end


  -- Enable a plugin

  if matches[2] == '+' and is_sudo(msg) then --after changed to moderator mode, set only sudo

      if is_mod(msg) then

    local plugin_name = matches[3]

    print("enable: "..matches[3])

    return enable_plugin(plugin_name)

  end

    end

  -- Disable a plugin on a chat

  if matches[2] == '-' and matches[4] == 'chat' then

      if is_mod(msg) then

    local plugin = matches[3]

    local receiver = msg.chat_id_

    print("disable "..plugin..' on this chat')

    return disable_plugin_on_chat(receiver, plugin)

  end

    end

  -- Disable a plugin

  if matches[2] == '-' and is_sudo(msg) then --after changed to moderator mode, set only sudo

    if matches[3] == 'plugins' then

     return 'This plugin can\'t be disabled'

    end

    print("disable: "..matches[3])

    return disable_plugin(matches[3])

  end

end

  -- Reload all the plugins!

  if matches[1] == '*' and is_sudo(msg) then --after changed to moderator mode, set only sudo

    return reload_plugins(true)

  end

  if matches[1]:lower() == 'reload' and is_sudo(msg) or matches[1]:lower() == 'Reload' and is_sudo(msg) then --after changed to moderator mode, set only sudo

    return reload_plugins(true)

  end

end


return {

  description = "Plugin to manage other plugins. Enable, disable or reload.", 

  usage = {

      moderator = {

          "!plug disable [plugin] chat : disable plugin only this chat.",

          "!plug enable [plugin] chat : enable plugin only this chat.",

          },

      sudo = {

          "!plist : list all plugins.",

          "!pl + [plugin] : enable plugin.",

          "!pl - [plugin] : disable plugin.",

          "!pl * : reloads all plugins." },

          },

  patterns = {

    "^[!/#]plist$",

    "^[!/#](pl) (+) ([%w_%.%-]+)$",

    "^[!/#](pl) (-) ([%w_%.%-]+)$",

    "^[!/#](pl) (+) ([%w_%.%-]+) (chat)",

    "^[!/#](pl) (-) ([%w_%.%-]+) (chat)",

    "^!pl? (*)$",

    "^[!/](reload)$",

    "^([Pp]l) (+) ([%w_%.%-]+)$",

    "^([Pp]l) (-) ([%w_%.%-]+)$",

    "^([Pp]l) (+) ([%w_%.%-]+) (chat)",

    "^([Pp]l) (-) ([%w_%.%-]+) (chat)",

 "^([Rr]eload)$"

    },

  run = run

}


end
