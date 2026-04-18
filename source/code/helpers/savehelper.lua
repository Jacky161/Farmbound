import "CoreLibs/object"

class("SaveHelper").extends()

function SaveHelper.verify_has_keys(saved_data, required_keys)
    if saved_data == nil then
        return false
    end

    for _, key in ipairs(required_keys) do
        if saved_data[key] == nil then
            print("[ERROR] Expected key '" .. key .. "' but value is nil")
            return false
        end
    end

    return true
end
