import "CoreLibs/graphics"


local gfx <const> = playdate.graphics


-- All globals stored in this table
Global = {}

Global.COLLISION_TAGS =
{
        PLAYER = 0,
        HOUSE = 1,
        SHIPPING_BOX = 2,
        NPC = 3,
        TOWN_HOUSE_1 = 4,
        TOWN_HOUSE_2 = 5,
        TOWN_HOUSE_1_EXIT = 6,
        TOWN_HOUSE_2_EXIT = 7
}
Global.COLLISION_RESPONSE =
{
    gfx.sprite.kCollisionTypeFreeze,   -- Default
    gfx.sprite.kCollisionTypeOverlap,  -- HOUSE
    gfx.sprite.kCollisionTypeOverlap,  -- SHIPPING_BOX
    gfx.sprite.kCollisionTypeOverlap,  -- NPC
    gfx.sprite.kCollisionTypeOverlap,  -- TOWN_HOUSE_1
    gfx.sprite.kCollisionTypeOverlap,  -- TOWN_HOUSE_2
    gfx.sprite.kCollisionTypeOverlap,  -- TOWN_HOUSE_1_EXIT
    gfx.sprite.kCollisionTypeOverlap   -- TOWN_HOUSE_2_EXIT
}
Global.DIRECTIONS =
{
    NORTH = 1,
    EAST = 2,
    SOUTH = 3,
    WEST = 4
}
Global.STATES =
{
    MAIN_MENU = 1,
    PLAYING = 2,
    TRANSITION = 3,
    MENU_INVENTORY = 4,
    MENU_SHIP = 5,
    MENU_SHOP = 6,
    GAME_OVER = 7,
    MENU_LOAD = 8,
    MENU_LOAD_FAIL = 9
}
Global.STATE_IS_MENU =
{
    true,
    false,
    false,
    true,
    true,
    true,
    true,
    true,
    true
}
Global.ITEMS =
{
    -- Must be kept in parallel with Global.ITEM_DATA
    HOE = 1,
    WATERING_CAN = 2,
    CARROT_SEEDS = 3,
    CARROTS = 4,
    WATER_GUN = 5,
    FISHING_ROD = 6,
    FISH = 7,
    POTATO_SEEDS = 8,
    POTATOES = 9,
    CORN_SEEDS = 10,
    CORN = 11,
    STRAWBERRY_SEEDS = 12,
    STRAWBERRIES = 13,
    RUNNING_SHOES = 14
}
Global.ITEM_DATA = {
    -- item_id = the index into this table.
    -- ship_stat_id is set at runtime
    {
        name = "Hoe",
        sprite = gfx.image.new("images/items/hoe"),
        purchase_price = 0,
        sell_price = nil,
        max_stack_size = 1,
        id = Global.ITEMS.HOE,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = nil
    },
    {
        name = "Watering Can",
        sprite = gfx.image.new("images/items/watering_can"),
        purchase_price = 0,
        sell_price = nil,
        max_stack_size = 1,
        id = Global.ITEMS.WATERING_CAN,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = nil
    },
    {
        name = "Carrot Seeds",
        sprite = gfx.image.new("images/items/seeds_carrot"),
        purchase_price = 20,
        sell_price = 10,
        max_stack_size = 9,
        id = Global.ITEMS.CARROT_SEEDS,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = nil
    },
    {
        name = "Carrots",
        sprite = gfx.image.new("images/items/crop_carrot"),
        purchase_price = 0,
        sell_price = 50,
        max_stack_size = 9,
        id = Global.ITEMS.CARROTS,
        ship_stat_id = nil,
        ship_quest_valid = true,
        obtain_dialogue = nil
    },
    {
        name = "Water Gun",
        sprite = gfx.image.new("images/items/water_gun"),
        purchase_price = 100,
        sell_price = nil,
        max_stack_size = 1,
        id = Global.ITEMS.WATER_GUN,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = {"You got the water gun! Use the crank to aim the water stream once activated."}
    },
    {
        name = "Fishing Rod",
        sprite = gfx.image.new("images/items/fishing_rod"),
        purchase_price = 50,
        sell_price = nil,
        max_stack_size = 1,
        id = Global.ITEMS.FISHING_ROD,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = {"You got the fishing rod! You wonder if anyone in town knows how to use it."}
    },
    {
        name = "Fish",
        sprite = gfx.image.new("images/items/fish"),
        purchase_price = 0,
        sell_price = 30,
        max_stack_size = 9,
        id = Global.ITEMS.FISH,
        ship_stat_id = nil,
        ship_quest_valid = true,
        obtain_dialogue = nil
    },
    {
        name = "Potato Seeds",
        sprite = gfx.image.new("images/items/seeds_potato"),
        purchase_price = 40,
        sell_price = 20,
        max_stack_size = 9,
        id = Global.ITEMS.POTATO_SEEDS,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = nil
    },
    {
        name = "Potatoes",
        sprite = gfx.image.new("images/items/crop_potato"),
        purchase_price = 0,
        sell_price = 100,
        max_stack_size = 9,
        id = Global.ITEMS.POTATOES,
        ship_stat_id = nil,
        ship_quest_valid = true,
        obtain_dialogue = nil
    },
    {
        name = "Corn Seeds",
        sprite = gfx.image.new("images/items/seeds_corn"),
        purchase_price = 70,
        sell_price = 35,
        max_stack_size = 9,
        id = Global.ITEMS.CORN_SEEDS,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = nil
    },
    {
        name = "Corn",
        sprite = gfx.image.new("images/items/crop_corn"),
        purchase_price = 0,
        sell_price = 175,
        max_stack_size = 9,
        id = Global.ITEMS.CORN,
        ship_stat_id = nil,
        ship_quest_valid = true,
        obtain_dialogue = nil
    },
    {
        name = "Strawberry Seeds",
        sprite = gfx.image.new("images/items/seeds_strawberry"),
        purchase_price = 90,
        sell_price = 45,
        max_stack_size = 9,
        id = Global.ITEMS.STRAWBERRY_SEEDS,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = nil
    },
    {
        name = "Strawberries",
        sprite = gfx.image.new("images/items/crop_strawberry"),
        purchase_price = 0,
        sell_price = 200,
        max_stack_size = 9,
        id = Global.ITEMS.STRAWBERRIES,
        ship_stat_id = nil,
        ship_quest_valid = true,
        obtain_dialogue = nil
    },
    {
        name = "Running Shoes",
        sprite = gfx.image.new("images/items/running_shoes"),
        purchase_price = 30,
        sell_price = nil,
        max_stack_size = 1,
        id = Global.ITEMS.RUNNING_SHOES,
        ship_stat_id = nil,
        ship_quest_valid = false,
        obtain_dialogue = {"You got the running shoes! Use the crank to charge your running stamina!"}
    }
}
Global.STATS =
{
    CURRENT_DAY =
    {
        stat_id = 1,
        min = 1,
        max = math.huge,  -- I like Lua's name for infinity :P
        name = "Current Day"
    },
    TOTAL_MONEY_EARNED =
    {
        stat_id = 2,
        min = 0,
        max = math.huge,
        name = "Total Money Earned"
    },
    NUM_FISH_CAUGHT =
    {
        stat_id = 3,
        min = 0,
        max = math.huge,
        name = "# of Fish Caught"
    }
}
Global.STATS_META =
{
    last_manual_stat = nil,
    last_harvest_stat = nil,
    last_shipped_stat = nil
}
Global.CROPS =
{
    CARROTS = 1,
    POTATOES = 2,
    CORN = 3,
    STRAWBERRIES = 4
}
Global.CROP_DATA =
{
    -- crop_id = the index into this table.
    -- harvest_stat_id is set at runtime
    {
        name = "Carrots",
        tile_images =
        {
            gfx.image.new("images/farmtiles/carrot_1"),
            gfx.image.new("images/farmtiles/carrot_2"),
            gfx.image.new("images/farmtiles/carrot_3")
        },
        seeds_item_id = Global.ITEMS.CARROT_SEEDS,
        crop_item_id = Global.ITEMS.CARROTS,
        harvest_stat_id = nil,
        max_grow_stage = 3
    },
    {
        name = "Potatoes",
        tile_images =
        {
            gfx.image.new("images/farmtiles/potato_1"),
            gfx.image.new("images/farmtiles/potato_2"),
            gfx.image.new("images/farmtiles/potato_3"),
            gfx.image.new("images/farmtiles/potato_4"),
            gfx.image.new("images/farmtiles/potato_5")
        },
        seeds_item_id = Global.ITEMS.POTATO_SEEDS,
        crop_item_id = Global.ITEMS.POTATOES,
        harvest_stat_id = nil,
        max_grow_stage = 5
    },
    {
        name = "Corn",
        tile_images =
        {
            gfx.image.new("images/farmtiles/corn_1"),
            gfx.image.new("images/farmtiles/corn_2"),
            gfx.image.new("images/farmtiles/corn_3"),
            gfx.image.new("images/farmtiles/corn_4"),
            gfx.image.new("images/farmtiles/corn_5"),
            gfx.image.new("images/farmtiles/corn_6"),
            gfx.image.new("images/farmtiles/corn_7")
        },
        seeds_item_id = Global.ITEMS.CORN_SEEDS,
        crop_item_id = Global.ITEMS.CORN,
        harvest_stat_id = nil,
        max_grow_stage = 7
    },
    {
        name = "Strawberries",
        tile_images =
        {
            gfx.image.new("images/farmtiles/strawberry_1"),
            gfx.image.new("images/farmtiles/strawberry_2"),
            gfx.image.new("images/farmtiles/strawberry_3"),
            gfx.image.new("images/farmtiles/strawberry_4"),
            gfx.image.new("images/farmtiles/strawberry_5"),
            gfx.image.new("images/farmtiles/strawberry_6"),
            gfx.image.new("images/farmtiles/strawberry_7"),
            gfx.image.new("images/farmtiles/strawberry_8")
        },
        seeds_item_id = Global.ITEMS.STRAWBERRY_SEEDS,
        crop_item_id = Global.ITEMS.STRAWBERRIES,
        harvest_stat_id = nil,
        max_grow_stage = 8
    }
}
Global.NPC_DATA =
{
    {
        name = "Fisherman",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "We're the fisherman brothers!",
            "Tell me son, do you like fish?",
            "Fishing is so awesome. The thrill of the nibble on your line, the struggle to get it out of the water.",
            "You should try it sometime."
        }
    },
    {
        name = "Fisherman2",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "We're the fisherman brothers!",
            "Fishing is an art. It takes skill and practice to become a master.",
            "First, you pull out the rod and charge up your cast. When you're ready, spin the crank *slightly* and stop.",
            "You'll see your bobber out on the sea. Eventually, a fish will bite! That's when you start cranking.",
            "But make sure not too much! The fish get spooked easily!",
            "The sweet spot is always *around the centre*. Remember that my boy. And good luck!"
        }
    },
    {
        name = "OldMan",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "Oh hello there. You must be new around these parts.",
            "This town hasn't seen a new soul in ages.",
            "I'll tell you a little something about this pond.",
            "Legend has it that a great fairy used to sleep here, and would bless those who came to visit her.",
            "I've never seen her though in all my years."
        }
    },
    {
        name = "SleepyGuy",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
            "I guess he's sleeping."
        }
    },
    {
        name = "Tommy",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "My dad told me he brought a really talented farmer from Earth. That's you!",
            "Don't tell him I said this, but he can be a little scary sometimes. But he means well!",
            "Just try not to get on his bad side. I'm sure if you work hard, you'll be fine!",
            "Where is he? I think he's taking a nap. You know, he's a bit old."
        }
    },
    {
        name = "Rose",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "..............................................",
            "(They're pretending not to notice you...)",
            "Oh... Who are you?",
            "Oh yeah. The new farmer kid. I wonder why they keep bringing new people... What happened to Jess...",
            "AHHH! Did I say that out loud? You didn't hear me say that!",
            "Please don't tell papa."
        }
    },
    {
        name = "Benchboy",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "Hey boy! You there!",
            "Are you taking good care of the crops on your farm?",
            "My boy Joey's got a shop that has all the goods you need. You should go see him if you haven't!"
        }
    },
    {
        name = "Sarah",
        sprite = gfx.image.new("images/undead"),
        dialogue = {
            "(She's lying down on a flowerbed, humming a cheerful tune.)",
            "I love flowers. Mr. Farmer, will you ever grow flowers on your farm?",
            "I guess Joey doesn't have any seeds... What a shame.",
            "One day, I hope this field will be filled with flowers. Wouldn't that be so wonderful?"
        }
    },
    {
        name = "fakenpc",
        sprite = gfx.image.new("images/undead"),
        dialogue =
        {
            "Congratulations! You broke the game.",
            "Please tell Jacky161 about this bug!"
        }
    }
}
Global.SHOPKEEPER_DATA =
{
    {
        name = "Shady Joe",
        sprite = gfx.image.new("images/undead"),
        selling =
        {
            {
                id = Global.ITEMS.CARROT_SEEDS,
                quantity = nil
            },
            {
                id = Global.ITEMS.POTATO_SEEDS,
                quantity = nil
            },
            {
                id = Global.ITEMS.CORN_SEEDS,
                quantity = nil
            },
            {
                id = Global.ITEMS.STRAWBERRY_SEEDS,
                quantity = nil
            },
            {
                id = Global.ITEMS.FISHING_ROD,
                quantity = 1
            },
            {
                id = Global.ITEMS.WATER_GUN,
                quantity = 1
            },
            {
                id = Global.ITEMS.RUNNING_SHOES,
                quantity = 1
            }
        }
    }
}
Global.TILE_TYPES =
{
    tile_farm = 1,
    tile_water = 2
}
Global.POIS =
{
    PLAYER_SPAWN = "PlayerSpawn"
}
Global.OBJECTIVE_TYPES =
{
    SHIPPING_BASED = 1,
    HARVEST_BASED = 2,
    STAT_BASED = 3
}
Global.OBJECTIVE_STATES =
{
    STARTED = 1,
    COMPLETED = 2,
    FAILED = 3
}
Global.PLAYER_STARTING_ITEMS =
{
    Global.ITEMS.HOE,
    Global.ITEMS.WATERING_CAN
}


local function gen_stats()
    local cur_stat_id = 0
    for _, stat in pairs(Global.STATS) do
        cur_stat_id = math.max(stat.stat_id, cur_stat_id)
    end
    Global.STATS_META.last_manual_stat = cur_stat_id
    cur_stat_id += 1

    -- Harvest stats
    print("[DEBUG] Generating harvest stats.")
    for _, crop in ipairs(Global.CROP_DATA) do
        local stat =
        {
            stat_id = cur_stat_id,
            min = 0,
            max = math.huge,
            name = "# of " .. crop.name .. " Harvested"
        }
        crop.harvest_stat_id = stat.stat_id
        Global.STATS["NUM_HARVESTS_" .. string.upper(crop.name)] = stat

        cur_stat_id += 1
        print("[DEBUG] Generated stat_id = " .. stat.stat_id)
    end

    Global.STATS["NUM_HARVESTS"] =
    {
        stat_id = cur_stat_id,
        min = 0,
        max = math.huge,
        name = "Total Harvests"
    }
    Global.STATS_META.last_harvest_stat = cur_stat_id
    cur_stat_id += 1

    -- Shipping stats
    print("[DEBUG] Generating shipping stats.")
    for _, item in ipairs(Global.ITEM_DATA) do
        if item.sell_price == nil then
            goto continue
        end

        local stat =
        {
            stat_id = cur_stat_id,
            min = 0,
            max = math.huge,
            name = "# of " .. item.name .. " Shipped"
        }
        item.ship_stat_id = stat.stat_id
        Global.STATS["NUM_SHIPPED_" .. string.upper(item.name)] = stat

        cur_stat_id += 1
        print("[DEBUG] Generated stat_id = " .. stat.stat_id)

        ::continue::
    end

    Global.STATS["NUM_SHIPPED"] =
    {
        stat_id = cur_stat_id,
        min = 0,
        max = math.huge,
        name = "Total Shipped"
    }
    Global.STATS_META.last_shipped_stat = cur_stat_id
    cur_stat_id += 1
end


gen_stats()


Global.OBJECTIVES =
{
    {
        backstory = "We demand that you do your job.",
        string = "Harvest %d %s.",
        min_amount = 6,
        max_amount = 10,
        min_days = 10,
        max_days = 15,
        type = Global.OBJECTIVE_TYPES.HARVEST_BASED
    },
    {
        backstory = "Sell, sell, sell.",
        string = "You shall sell %d %s",
        min_amount = 6,
        max_amount = 10,
        min_days = 10,
        max_days = 15,
        type = Global.OBJECTIVE_TYPES.SHIPPING_BASED
    },
    {
        backstory = "Profit Maxing.",
        string = "Make $%d or else.",
        min_amount = 200,
        max_amount = 400,
        min_days = 5,
        max_days = 10,
        type = Global.OBJECTIVE_TYPES.STAT_BASED,
        valid_stats =
        {
            Global.STATS.TOTAL_MONEY_EARNED.stat_id
        }
    },
    {
        backstory = "Farm till you drop.",
        string = "Harvest %d crops.",
        min_amount = 3,
        max_amount = 10,
        min_days = 5,
        max_days = 12,
        type = Global.OBJECTIVE_TYPES.STAT_BASED,
        valid_stats =
        {
            Global.STATS.NUM_HARVESTS.stat_id
        }
    },
    {
        backstory = "Fish Extermination.",
        string = "Catch %d fish.",
        min_amount = 3,
        max_amount = 5,
        min_days = 2,
        max_days = 3,
        type = Global.OBJECTIVE_TYPES.STAT_BASED,
        valid_stats =
        {
            Global.STATS.NUM_FISH_CAUGHT.stat_id
        }
    }
}


local function process_item_sprites()
    -- Process images
    for _, item in ipairs(Global.ITEM_DATA) do
        print("[DEBUG] Processing sprite for " .. item.name)
        local width, height = item.sprite:getSize()

        if width == height and width == 20 then
            item.sprite = item.sprite:scaledImage(2)
        elseif width ~= height or width ~= 40 or height ~= 40 then
            error("[ERROR] " .. item.name .. " has invalid sprite image.")
        end
    end
end


process_item_sprites()
