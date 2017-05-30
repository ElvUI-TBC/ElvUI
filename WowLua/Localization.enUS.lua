WowLuaLocals = {}
local L = WowLuaLocals

SLASH_WOWLUA1 = "/wowlua"
SLASH_WOWLUA2 = "/lua"

L.NEW_PAGE_TITLE = "Untitled %d"
L.RELOAD_COMMAND = "/reload"
L.RESET_COMMAND  = "/reset"

L.TOOLTIPS = {}
L.TOOLTIPS["New"] = { name = "New", text = "Create a new script page" }
L.TOOLTIPS["Open"] = { name = "Open", text = "Open an existing script page" }
L.TOOLTIPS["Save"] = { name = "Save", text = "Save the current page\n\nHint: You can shift-click this button to rename a page" }
L.TOOLTIPS["Undo"] = { name = "Undo", text = "Undo the last change" }
L.TOOLTIPS["Redo"] = { name = "Redo", text = "Redo the last change" }
L.TOOLTIPS["Delete"] = { name = "Delete", text = "Delete the current page" }
L.TOOLTIPS["Lock"] = { name = "Lock", text = "This page is unlocked to allow changes. Click to lock." }
L.TOOLTIPS["Unlock"] = { name = "Unlock", text = "This page is locked to prevent changes. Click to unlock." }
L.TOOLTIPS["Previous"] = { name = "Previous", text = "Navigate back one page" }
L.TOOLTIPS["Next"] = { name = "Next", text = "Navigate forward one page" }
L.TOOLTIPS["Run"] = { name = "Run", text = "Run the current script" }
L.TOOLTIPS["Close"] = { name = "Close" }
	
L.OPEN_MENU_TITLE = "Select a Script"
L.SAVE_AS_TEXT = "Save %s with the following name:"
L.UNSAVED_TEXT = "You have unsaved changes on this page that will be lost if you navigate away from it.  Continue?"
