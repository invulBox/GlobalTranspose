-- @description Add JSFX to selected tracks at first position, ensure Global Transpose Master on master track
-- @version 1.0
-- @author HelloFromTokyo
-- @about
--   Add JSFX to selected tracks at first position, ensure Global Transpose Master on master track

-- USER CONFIG:
local jsfx_name = "JS: midislave"  -- JSFX to add to selected tracks
local master_jsfx = "JS: midimaster" -- Master JSFX to check/add

-- Helper function to check if a specific FX exists on a track
local function TrackHasFX(track, fx_name)
  local fx_count = reaper.TrackFX_GetCount(track)
  for i = 0, fx_count - 1 do
    local _, name = reaper.TrackFX_GetFXName(track, i, "")
    if name:find(fx_name, 1, true) then
      return true
    end
  end
  return false
end

-- === MAIN ===
local num_sel = reaper.CountSelectedTracks(0)
if num_sel == 0 then
  reaper.ShowMessageBox("No tracks selected.", "Error", 0)
  return
end

reaper.Undo_BeginBlock()

-- Step 1: Add JSFX to selected tracks at first position
for i = 0, num_sel - 1 do
  local track = reaper.GetSelectedTrack(0, i)
  if track then
    local fx_index = reaper.TrackFX_AddByName(track, jsfx_name, false, -1)
    if fx_index ~= -1 then
      -- Move to first position
      reaper.TrackFX_CopyToTrack(track, fx_index, track, 0, true)
    else
      reaper.ShowMessageBox("JSFX not found: " .. jsfx_name, "Error", 0)
      reaper.Undo_EndBlock("Add JSFX to selected tracks (failed)", -1)
      return
    end
  end
end

-- Step 2: Check Master track for the Transpose Master
local master_track = reaper.GetMasterTrack(0)
if not TrackHasFX(master_track, master_jsfx) then
  local fx_index = reaper.TrackFX_AddByName(master_track, master_jsfx, false, -1)
  if fx_index ~= -1 then
    reaper.ShowConsoleMsg("Added '" .. master_jsfx .. "' to master track.\n")
  else
    reaper.ShowMessageBox("Could not find: " .. master_jsfx, "Error", 0)
  end
end

reaper.Undo_EndBlock("Add JSFX to selected tracks + ensure Master Transpose", -1)
