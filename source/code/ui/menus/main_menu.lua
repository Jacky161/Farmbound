import "code/global"
import "code/ui/menus/linear_menu"
import "code/ui/menus/panels/panel_image"
import "code/ui/menus/panels/panel_simple_text"
import "CoreLibs/graphics"
import "CoreLibs/object"

local gfx <const> = playdate.graphics


class("MainMenu").extends(LinearMenu)
function MainMenu:init(callback_exit)
    MainMenu.super.init(self, nil, 5, callback_exit, {false, false, false, false, true}, {playdate.kButtonA})

    -- Pane 1
    self:add_panel(PanelSimpleText(playdate.metadata.name, kTextAlignment.center), 1)
    self:add_panel(PanelSimpleText("Welcome to " .. playdate.metadata.name .. "!\nPress Right to continue.", kTextAlignment.center), 1)

    -- Pane 2
    self:add_panel(PanelSimpleText("Controls", kTextAlignment.center), 2)
    self:add_panel(PanelSimpleText("Movement: D-Pad\nUse Item / Interact: A\nMenu: B\nSome Items Require the Crank.", kTextAlignment.left), 2)

    -- Pane 3
    self:add_panel(PanelSimpleText("Game Info", kTextAlignment.center), 3)
    self:add_panel(PanelSimpleText("Your objective is shown in the B menu.\nFailing to complete your task is\ngame over!", kTextAlignment.left), 3)

    -- Pane 4
    self:add_panel(PanelSimpleText("Saving", kTextAlignment.center), 4)
    self:add_panel(PanelSimpleText("This game has an auto saving feature.\nIf on, progress is saved on exit.\nYou can turn it off via the Playdate\nmenu button.", kTextAlignment.left), 4)
    local floppy_img = gfx.image.new("images/floppy")
    self:add_panel(PanelImage(floppy_img:scaledImage(0.5)), 4)

    -- Pane 5
    self:add_panel(PanelSimpleText(playdate.metadata.name, kTextAlignment.center), 5)
    self:add_panel(PanelSimpleText("Press A to begin! Have fun!", kTextAlignment.center), 5)
end
