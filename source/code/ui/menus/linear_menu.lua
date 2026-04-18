
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics
local DISPLAY_WIDTH <const> = playdate.display.getWidth()
local DISPLAY_HEIGHT <const> = playdate.display.getHeight()
local PANEL_WIDTH <const> = 300
local MENU_MARGIN <const> = 20


class("LinearMenu").extends()
function LinearMenu:init(bg_image, num_panes, callback_exit, exit_panes, exit_btns)
    self.bg_image = bg_image
    self.callback_exit = callback_exit

    self.cur_pane = 1
    self.panes = {}
    self.focused_panel = {}

    self.exit_panes = {}
    for i=1, num_panes do
        self.panes[i] = {}
        self.focused_panel[i] = 0

        if exit_panes == nil then
            self.exit_panes[i] = true
        end
    end

    if exit_panes ~= nil then
        self.exit_panes = exit_panes
    end

    self.exit_btns = exit_btns
    if exit_btns == nil then
        self.exit_btns = {playdate.kButtonB}
    end


end


function LinearMenu:draw(x, y)
    gfx.clear()
    if self.bg_image ~= nil then
        self.bg_image:draw(0, 0)
    end

    local cur_pane = self.panes[self.cur_pane]
    local height = 0
    for _, panel in ipairs(cur_pane) do
        height += panel:get_height()
    end

    if height > DISPLAY_HEIGHT then
        print("[WARN] LinearMenu[" .. self.cur_pane .. "] has height " .. height .. "px but screen can only fit " .. DISPLAY_HEIGHT .. "px.")
    end

    -- Half the height on one half of the screen, half on the other side
    local x_left = (DISPLAY_WIDTH / 2) - (PANEL_WIDTH / 2)
    local y_cur = (DISPLAY_HEIGHT / 2) - (height / 2)
    local x_right = (DISPLAY_WIDTH / 2) + (PANEL_WIDTH / 2)

    -- Clear out the shape of the menu
    gfx.fillRect(x_left - MENU_MARGIN, y_cur - MENU_MARGIN, PANEL_WIDTH + MENU_MARGIN * 2, height + MENU_MARGIN * 2)

    -- Draw an arrow to the left and right
    gfx.setColor(gfx.kColorWhite)
    if self:pane_try_left() then
        gfx.drawTriangle(x_left - 5, DISPLAY_HEIGHT / 2 - 5, x_left - 5, DISPLAY_HEIGHT / 2 + 5, x_left - 15, DISPLAY_HEIGHT / 2)
    end
    if self:pane_try_right() then
        gfx.drawTriangle(x_right + 5, DISPLAY_HEIGHT / 2 - 5, x_right + 5, DISPLAY_HEIGHT / 2 + 5, x_right + 15, DISPLAY_HEIGHT / 2)
    end
    gfx.setColor(gfx.kColorBlack)


    if x ~= nil then
        x_left = x
    end
    if y ~= nil then
        y_cur = y
    end

    for _, panel in ipairs(cur_pane) do
        gfx.pushContext()
        panel:draw(x_left, y_cur)
        gfx.popContext()
        y_cur += panel:get_height()
    end
end


function LinearMenu:add_panel(panel, pane_no)
    if pane_no == nil then
        pane_no = 1
    end

    table.insert(self.panes[pane_no], panel)

    -- First panel that is focusable is focused
    if self.focused_panel[pane_no] == 0 and panel:is_focusable() then
        self.focused_panel[pane_no] = #self.panes[pane_no]
    end
end


function LinearMenu:update()
    if self.focused_panel[self.cur_pane] == 0 then
        -- Need someway to switch panes if none of the panels can
        if playdate.buttonJustReleased(playdate.kButtonLeft) then
            self:pane_left()
        end
        if playdate.buttonJustReleased(playdate.kButtonRight) then
            self:pane_right()
        end

        -- And someway to exit the menu
        if self.exit_panes[self.cur_pane] then
            for _, btn in ipairs(self.exit_btns) do
                if playdate.buttonJustReleased(btn) then
                    self:exit(nil)
                end
            end
        end
    end

    for i, panel in ipairs(self.panes[self.cur_pane]) do
        panel:update(self, self.focused_panel[self.cur_pane] == i)
    end
end


-- Implementation defined.
function LinearMenu:exit(payload)
    if self.callback_exit ~= nil then
        self.callback_exit(payload)
    end
end


function LinearMenu:focus_shift(delta)
    local new_focus = math.min(math.max(1, self.focused_panel[self.cur_pane] + delta), #self.panes[self.cur_pane])

    if self.panes[self.cur_pane][new_focus]:is_focusable() then
        self.focused_panel[self.cur_pane] = new_focus
    end
end


function LinearMenu:focus_up()
    return self:focus_shift(-1)
end


function LinearMenu:focus_down()
    return self:focus_shift(1)
end


function LinearMenu:pane_shift(delta)
    local old_pane_no = self.cur_pane
    self.cur_pane = math.min(math.max(1, self.cur_pane + delta), #self.panes)

    return self.cur_pane ~= old_pane_no
end


function LinearMenu:pane_try_left()
    return self.cur_pane - 1 >= 1
end


function LinearMenu:pane_try_right()
    return self.cur_pane + 1 <= #self.panes
end


function LinearMenu:pane_left()
    return self:pane_shift(-1)
end


function LinearMenu:pane_right()
    return self:pane_shift(1)
end
