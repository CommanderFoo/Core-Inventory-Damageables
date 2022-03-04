local INVENTORY = script:GetCustomProperty("Inventory"):WaitForObject()
local DAMAGEABLES = script.parent:FindDescendantsByType("Damageable")

local inv_objs = {}

local function find_obj(slot)
	for id, slot_index in pairs(inv_objs) do
		if(slot == slot_index) then
			return id
		end
	end

	return nil
end

local function destroy_obj(slot)
	local id = find_obj(slot)

	if(id ~= nil) then
		for i, d in ipairs(DAMAGEABLES) do
			if(Object.IsValid(d)) then
				if(d.id == id) then
					d:Die()
					inv_objs[id] = nil
				end
			else
				inv_objs[id] = nil
			end
		end
	end
end

local function changed(inv, slot)
	local item = inv:GetItem(slot)

	if(item ~= nil) then
		inv_objs[item:GetCustomProperty("id")] = slot
	else
		destroy_obj(slot)
	end
end

if(Environment.IsClient()) then
	INVENTORY.changedEvent:Connect(changed)

	for i, slot in pairs(INVENTORY:GetItems()) do
		changed(INVENTORY, i)
	end

	local lookup = {}

	for index, slot in pairs(INVENTORY:GetItems()) do
		lookup[slot:GetCustomProperty("id")] = 1
	end

	for i, d in ipairs(DAMAGEABLES) do
		if(Object.IsValid(d) and not lookup[d.id]) then
			d:Destroy()
		end
	end
end

if(Environment.IsServer()) then
	for i, d in ipairs(DAMAGEABLES) do
		local item = d:GetCustomProperty("Item")
		local params = {
		
			customProperties = {

				id = d.id

			}

		}

		if(INVENTORY:CanAddItem(item, params)) then
			INVENTORY:AddItem(item, params)
		end

		d.destroyEvent:Connect(function()
			for index, item in pairs(INVENTORY:GetItems()) do
				if(item:GetCustomProperty("id") == d.id) then
					INVENTORY:RemoveFromSlot(item.slot)
				end
			end
		end)
	end
end