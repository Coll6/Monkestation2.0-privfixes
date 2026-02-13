/obj/structure/brine_chamber
	name = "brine chamber"
	desc = "A large structure for a pool of water. Its large open surface area allows water to evaporate leaving behind, salts creating a very salty brine solution."
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "brine_chamber"

/obj/structure/brine_chamber/controller
	name = "brine chamber controller"
	desc = "The controller for the brine chamber. Accepts water to be pumped into the pool and output brine to be pumped out."
	icon_state = "brine_chamber_controller"

	/// Pack to return when deconstructed with crowbar.
	var/obj/item/flatpacked_machine/ore_processing/machine = /obj/item/flatpacked_machine/ore_processing/brine_chamber

/obj/structure/brine_chamber/controller/Destroy()
	machine = null
	return ..()

/obj/structure/brine_chamber/controller/deconstruct(disassembled)
	if(disassembled && !isnull(machine))
		new machine(src.loc)

	return ..()

/obj/structure/brine_chamber/controller/crowbar_act(mob/living/user, obj/item/tool)
	if(isitem(tool))
		if(!(flags_1 & NODECONSTRUCT_1) && tool.tool_behaviour == TOOL_CROWBAR)
			tool.play_tool_sound(src, 50)
			deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS
	return

