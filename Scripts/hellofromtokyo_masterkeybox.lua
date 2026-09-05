-- @description Master Transpose Key Display
-- @version 1.0
-- @author HelloFromTokyo
-- @about
--   # Master Transpose Key Display

local ctx = reaper.ImGui_CreateContext("Master Transpose Key Dropdown")

local NOTES = {
    "C", "C#", "D", "D#", "E", "F",
    "F#", "G", "G#", "A", "A#", "B"
}

local window_alpha = 0.0

-- Position relative to REAPER's main window
local offset_x = 20
local offset_y = 70

------------------------------------------------------------
-- FIND MIDI MASTER FX
------------------------------------------------------------

local function GetFX()
    local master = reaper.GetMasterTrack(0)

    if not master then
        return nil, nil
    end

    local count = reaper.TrackFX_GetCount(master)

    for i = 0, count - 1 do
        local _, name = reaper.TrackFX_GetFXName(master, i, "")

        if name and name:find("MIDI Global Transpose Master", 1, true) then
            return master, i
        end
    end

    return nil, nil
end

------------------------------------------------------------
-- GET KEY
------------------------------------------------------------

local function GetKey(master, fx)
    if not master or fx == nil then
        return 0
    end

    local key = reaper.TrackFX_GetParam(master, fx, 0)

    if not key then
        return 0
    end

    key = math.floor(key + 0.5)

    if key < 0 then
        key = 0
    elseif key > 11 then
        key = 11
    end

    return key
end

------------------------------------------------------------
-- SET KEY
------------------------------------------------------------

local function SetKey(master, fx, key)
    if not master or fx == nil then
        return
    end

    key = math.max(0, math.min(11, key))

    reaper.TrackFX_SetParam(master, fx, 0, key)
end

------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------

local function Loop()

    --------------------------------------------------------
    -- FIND FX
    --------------------------------------------------------

    local master, fx = GetFX()

    -- No MIDI Master FX = idle
    if not master or fx == nil then
        reaper.defer(Loop)
        return
    end

    --------------------------------------------------------
    -- WINDOW FLAGS
    --------------------------------------------------------

    local flags =
          reaper.ImGui_WindowFlags_NoTitleBar()
        + reaper.ImGui_WindowFlags_NoCollapse()
        + reaper.ImGui_WindowFlags_NoScrollbar()
        + reaper.ImGui_WindowFlags_NoMove()
        + reaper.ImGui_WindowFlags_NoFocusOnAppearing()
        + reaper.ImGui_WindowFlags_NoNavFocus()

    --------------------------------------------------------
    -- GET REAPER MAIN WINDOW POSITION
    --------------------------------------------------------

    local main_hwnd = reaper.GetMainHwnd()

    local retval, x, y, w, h =
        reaper.JS_Window_GetRect(main_hwnd)

    if retval then
        reaper.ImGui_SetNextWindowPos(
            ctx,
            x + offset_x,
            y + offset_y,
            reaper.ImGui_Cond_Always()
        )
    end

    --------------------------------------------------------
    -- STYLE
    --------------------------------------------------------

    reaper.ImGui_PushStyleColor(
        ctx,
        reaper.ImGui_Col_WindowBg(),
        reaper.ImGui_ColorConvertDouble4ToU32(
            0.627,
            0.627,
            0.627,
            window_alpha
        )
    )

    reaper.ImGui_PushStyleVar(
        ctx,
        reaper.ImGui_StyleVar_WindowBorderSize(),
        0
    )

    --------------------------------------------------------
    -- WINDOW
    --------------------------------------------------------

    local visible, open =
        reaper.ImGui_Begin(
            ctx,
            "Master Transpose Key",
            true,
            flags
        )

    if visible then

        local key_index = GetKey(master, fx)

        ----------------------------------------------------
        -- MOUSE WHEEL
        ----------------------------------------------------

        if reaper.ImGui_IsWindowHovered(ctx) then

            local wheel = reaper.ImGui_GetMouseWheel(ctx)

            -- Reversed wheel direction
            if wheel ~= 0 then

                local new_key =
                    key_index - (wheel > 0 and 1 or -1)

                -- Wrap around
                if new_key < 0 then
                    new_key = 11
                elseif new_key > 11 then
                    new_key = 0
                end

                SetKey(master, fx, new_key)

                key_index = new_key
            end
        end

        ----------------------------------------------------
        -- DROPDOWN
        ----------------------------------------------------

        if reaper.ImGui_BeginCombo(
            ctx,
            "Key##combo",
            NOTES[key_index + 1]
        ) then

            for i = 0, 11 do

                if reaper.ImGui_Selectable(
                    ctx,
                    NOTES[i + 1],
                    i == key_index
                ) then

                    SetKey(master, fx, i)
                end
            end

            reaper.ImGui_EndCombo(ctx)
        end
    end

    reaper.ImGui_End(ctx)

    --------------------------------------------------------
    -- RESTORE STYLE
    --------------------------------------------------------

    reaper.ImGui_PopStyleVar(ctx)
    reaper.ImGui_PopStyleColor(ctx)

    --------------------------------------------------------
    -- KEEP RUNNING
    --------------------------------------------------------

    if open then
        reaper.defer(Loop)
    end
end

Loop()
