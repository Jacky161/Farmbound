import "code/ui/menus/panels/panel"
import "CoreLibs/graphics"
import "CoreLibs/object"


local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local ITEMS_PER_ROW <const> = 6
local ROW_HEIGHT <const> = 50


class("PanelItems").extends(Panel)
function PanelItems:init(num_rows, menu_items, initial_selection, max_selection)
    PanelItems.super.init(self, ROW_HEIGHT * num_rows, true)
    self.num_rows = num_rows
    self.menu_items = menu_items
    self.current_selection = initial_selection
    self.max_selection = max_selection

    if self.current_selection == nil then
        self.current_selection = 1
    end

    if self.max_selection == nil then
        self.max_selection = #menu_items
    end
end


function PanelItems:draw(x, y)
    -- Draw the boxes that represent our inventory (content)
    local cur_inv_idx = 1
    for row = 1, self.num_rows do
        local y_row_start = y + (ROW_HEIGHT * (row - 1))

        for x = 50, 50 * ITEMS_PER_ROW, 50 do
            local rect = geometry.rect.new(x, y_row_start, 50, 50)
            Panel.fill_stroke_rect(rect)

            -- See if an item exists in this position
            if cur_inv_idx <= #self.menu_items then
                local item = self.menu_items[cur_inv_idx]

                -- Draw image
                if item ~= nil then
                    self:get_item_image(item):draw(x + 5, y_row_start + 5)

                    -- Draw stack count if needed
                    local stack_count = self:get_item_count(item)
                    if stack_count ~= nil then
                        gfx.drawText(stack_count, x + 40, y_row_start + 2)
                    end

                    -- Text in the footer
                    -- if self.current_selection == cur_inv_idx then
                    --     gfx.drawText(self:get_item_description(item), footer_rect.x + 5, footer_rect.y + 5)
                    -- end
                end
            end

            -- If it is the current selection, draw the little selector arrow
            if self.current_selection == cur_inv_idx then
                gfx.setColor(gfx.kColorWhite)
                gfx.drawTriangle(x + 25, y_row_start + 10, x + 25 - 5, y_row_start + 5, x + 25 + 5, y_row_start + 5)
                gfx.setColor(gfx.kColorBlack)
                gfx.fillTriangle(x + 25, y_row_start + 10, x + 25 - 5, y_row_start + 5, x + 25 + 5, y_row_start + 5)
            end

            cur_inv_idx += 1
        end
    end
end


function PanelItems:update(menu_instance, focused)
    if not focused then
        return
    end

    -- Move the selection based on what they press
    local inv_capacity = self.max_selection
    if playdate.buttonJustReleased(playdate.kButtonUp) then
        local new_selection = self.current_selection - ITEMS_PER_ROW

        if new_selection < 1 then
            menu_instance:focus_up()
        else
            self.current_selection = new_selection
        end
    elseif playdate.buttonJustReleased(playdate.kButtonDown) then
        local new_selection = self.current_selection + ITEMS_PER_ROW

        if new_selection > self.max_selection then
            menu_instance:focus_down()
        else
            self.current_selection = new_selection
        end
    elseif playdate.buttonJustReleased(playdate.kButtonLeft) then
        local new_selection = self.current_selection - 1

        if new_selection < 1 or new_selection == ITEMS_PER_ROW then
            menu_instance:pane_left()
        else
            self.current_selection = new_selection
        end
    elseif playdate.buttonJustReleased(playdate.kButtonRight) then
        local new_selection = self.current_selection + 1

        if new_selection > self.max_selection or new_selection == ITEMS_PER_ROW + 1 then
            menu_instance:pane_right()
        else
            self.current_selection = new_selection
        end
    elseif playdate.buttonJustReleased(playdate.kButtonB) then
        menu_instance:exit(nil)
    elseif playdate.buttonJustReleased(playdate.kButtonA) then
        menu_instance:exit(self.current_selection)
    end
end


function PanelItems:get_selected_item_description()
    local cur_item = self.menu_items[self.current_selection]

    if cur_item ~= nil then
        return self:get_item_description(cur_item)
    end

    return ""
end


function PanelItems:get_item_image(item)
    error("RowMenu:get_item_image() must be implemented by subclass.")
end


function PanelItems:get_item_description(item)
    error("RowMenu:get_item_description() must be implemented by subclass.")
end


function PanelItems:get_item_count(item)
    error("RowMenu:get_item_count() must be implemented by subclass.")
end
