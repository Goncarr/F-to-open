-- mod inicialization (duh!)
local mod = RegisterMod("f to open", 1)

--###########
-- VARIABLES
--###########

local CHESTS_ENTITIES = {
            PickupVariant.PICKUP_CHEST,
            PickupVariant.PICKUP_MIMICCHEST,
            PickupVariant.PICKUP_ETERNALCHEST,
            PickupVariant.PICKUP_OLDCHEST,
            PickupVariant.PICKUP_WOODENCHEST,
            PickupVariant.PICKUP_REDCHEST,
            PickupVariant.PICKUP_LOCKEDCHEST
        }

local RADIUS = 100
local RAIN_CLOUD_VARIANT = Isaac.GetEntityVariantByName("Sad Rain Cloud")

--###########
-- FUNCTIONS
--###########

-- Checks if it should remove/add the cloud
function mod:OnRainCloudInit(cloud)


    local player = Isaac.GetPlayer()
    local distance = (player.Position - cloud.Parent.Position):Length()

    if cloud.Parent
    and distance <= RADIUS
    and cloud.Parent:GetData().isInRange then

        cloud.Position = cloud.Parent.Position
        cloud.SpriteOffset = Vector(0, -40)
        cloud.Parent:GetData().isInRange = true

    else
        cloud:Remove()
        cloud.Parent:GetData().isInRange = false
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.OnRainCloudInit, RAIN_CLOUD_VARIANT)

function mod:onPlayerSpawned()
    local player = Isaac.GetPlayer(0)
    local radius = Isaac.FindInRadius(player.Position, RADIUS)

    for _, entity in ipairs(radius) do
        local pickup = entity:ToPickup()

        for chest_type = 1, #CHESTS_ENTITIES do
            if pickup ~= nil and pickup.Variant == CHESTS_ENTITIES[chest_type]
            and pickup.SubType == 1 then

                local data = pickup:GetData()
                    
                    if not data.isInRange then
                        data.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                        local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT,RAIN_CLOUD_VARIANT,0,entity.Position,Vector(0,0),nil)

                        cloud.Parent = pickup
                        cloud.SpriteOffset = Vector(0, -20)
                        data.isInRange = true
                        
                    end

            end
            
        end
    end
    
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE , mod.onPlayerSpawned)

function mod:disableCollisisons(pickup)
    for _, entity in ipairs(CHESTS_ENTITIES) do
        if entity == pickup.Variant then
            return true
        end
    end
    
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.disableCollisisons)

-- Opens the chest if the key 'X' is pressed
function mod:openChest()
    local pressed_key = Input.IsButtonPressed(Keyboard.KEY_X, 0)

    if pressed_key then

        local player = Isaac.GetPlayer(0)
        local radius = Isaac.FindInRadius(player.Position, RADIUS)

        for _, entity in ipairs(radius) do
            local pickup = entity:ToPickup()

            for chest_type = 1, #CHESTS_ENTITIES do
                if pickup ~= nil and pickup.Variant == CHESTS_ENTITIES[chest_type] then
                    local data = pickup:GetData()

                    
                    if data.isInRange == true then
                        
                        pickup:TryOpenChest(player)
                        data.isInRange = false

                        
                    end

                end

            end

        end
    end

end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.openChest)


function mod:FindChests()
    local entities = Isaac.GetRoomEntities()

    for _, entity in ipairs(entities) do
        for chest_type = 1, #CHESTS_ENTITIES do
            local pickup = entity:ToPickup()
            
            if pickup ~= nil and pickup.Variant == CHESTS_ENTITIES[chest_type] then
                
                local data = pickup:GetData()
                
                data.isInRange = false
            end
        
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , mod.FindChests)
mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, mod.FindChests)