local control_source = "game" -- this is most likely what you're looking
local curent_title = "unknown" -- this is the default for when obs hasn't bound to an application yet
-- It will never use this after the source binds even once, even if the source is deactivated or hidden!

--[[
    Only these sources will work!

        Window Capture (Windows)

        Game Capture (Windows)

        Application Audio Output Capture (Windows)

        Window Capture (Xcomposite)
    
    We add a signal_handler_connect for the "hooked" signal which only exsits for a slim number of sources
    See https://docs.obsproject.com/reference-sources#source-specific-signals
]]

if false then obslua = require("../lua_doc_builder/obslua") end  -- visual studio moment
local obs = obslua or error("Not loaded with obs")

-- Defining and finding out our source based on its name. This is much easier then pulling the currently active one.
    local source =
        obs.obs_get_source_by_name(control_source) 
        or
        error("please set source on line 1 of the lua script file. i know im sorry for not adding a real setting screen :(")
        ;
    
    local source_specific_handler = 
        obs.obs_source_get_signal_handler(source) 
        or
        error("Failed to retrive the signal handler for the selected source? Quite a weird issue because we had no problem retriving the source.")
        ;

    obs.obs_source_release(source)


-- Source Hook event to update our tile name variable
    local function hook_signal_function(...)
        local args = {...}
        print("Signal called, changing curent_title")
        curent_title = obs.calldata_string(args[1],"title") -- Ask obs to give us the title returned in the userdata type
        
        -- See if the returned value as dots in it, this will remove version numbers from games that append them to the game name as long as it has at least one dot
        if curent_title:find(".") then
            curent_title = curent_title
            :gsub("%d",""):gsub("%.","") -- removing all dots and digets
            :reverse():gsub("%s+",""):reverse(); -- and trailling spaces
        end
            
    end
    obs.signal_handler_connect(source_specific_handler,"hooked",hook_signal_function)


-- pretty large un-named function passed here for our save replay buffer callback   
obs.obs_frontend_add_event_callback(function(...)
    local event = {...}
    if event[1] == obs.OBS_FRONTEND_EVENT_REPLAY_BUFFER_SAVED then

        -- Get last replay's path
            local old_path = obs.obs_frontend_get_current_record_output_path()
            local replay_location = obs.obs_frontend_get_last_replay()
            print(replay_location)
            print(curent_title)
            obs.obs_frontend_get_recording_output()

        --Structure and execute command
            local new_path = ([["]]..old_path.."/"..curent_title..[[/"]])
            
            if os.getenv("os") == "Windows_NT" then
                print("Windows")
                
                local command = 
                [[move "]]..
                -- We need to gsub out all the unix style forward slashes "/" to replace them with windows terible back slash dir system "\"
                replay_location:gsub("/","\\")..
                "\" ".. -- whitespace my beloved
                new_path:gsub("/","\\");
                
                -- Create all the dir required, this just silently fails if the exsist. Windows also does this recursively by default.
                os.execute("mkdir "..new_path) 
                print("Executing command: "..command) -- For debuging
                os.execute(command)
            else
                print("Unix-like or unknown")
                local command =
                    [[mv "]]..
                    replay_location..
                    "\" ".. -- whitespace my beloved
                    new_path;

                -- Create all the dir required, this just silently fails if the exsist.
                os.execute("mkdir -r "..new_path)
                print("Executing command: "..command)  -- For debuging
                os.execute(command)
            end

    end
end)