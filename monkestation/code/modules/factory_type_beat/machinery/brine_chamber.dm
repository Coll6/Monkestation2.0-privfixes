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
	var/obj/item/multitool/marker_tool

	var/obj/effect/brine_marker/corner_a
	var/obj/effect/brine_marker/corner_b

/obj/structure/brine_chamber/controller/Destroy()
	machine = null
	clear_marking()
	return ..()

/obj/structure/brine_chamber/controller/deconstruct(disassembled)
	if(disassembled && !isnull(machine))
		new machine(src.loc)

	return ..()

/obj/structure/brine_chamber/controller/proc/mark_border(datum/source, mob/living/user, atom/target, params)
	SIGNAL_HANDLER
	if(QDELETED(marker_tool) || multitool_get_buffer(marker_tool) != src)
		clear_marking()
		return
	if(marker_tool != source)
		return

/obj/structure/brine_chamber/controller/proc/clear_marking()
	SIGNAL_HANDLER
	UnregisterSignal(marker_tool, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY))
	if(!QDELETED(marker_tool) && multitool_get_buffer(marker_tool) == src)
		multitool_set_buffer(marker_tool, null)
	marker_tool = null

/obj/structure/brine_chamber/controller/proc/validate_markings()

/obj/structure/brine_chamber/controller/multitool_act(mob/living/user, obj/item/tool)
	if(QDELETED(tool))
		return
	var/datum/buffer = multitool_get_buffer(tool)
	if(!marker_tool)
		if(QDELETED(buffer) || !istype(buffer, /obj/structure/brine_chamber/controller))
			marker_tool = tool
			multitool_set_buffer(marker_tool, src)
			RegisterSignals(marker_tool, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING), PROC_REF(clear_marking))
			RegisterSignal(marker_tool, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(mark_border))
			balloon_alert_to_viewers("Mark the corners with the multitool.")
			return ITEM_INTERACT_SUCCESS
		if(buffer == src)
			clear_marking()
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_FAILURE
	if(marker_tool)
		if(tool != marker_tool)
			return ITEM_INTERACT_FAILURE
		if(buffer != src)
			clear_marking()
			return ITEM_INTERACT_FAILURE
		validate_markings()
		return ITEM_INTERACT_SUCCESS

/obj/structure/brine_chamber/controller/crowbar_act(mob/living/user, obj/item/tool)
	if(isitem(tool))
		if(!(flags_1 & NODECONSTRUCT_1))
			tool.play_tool_sound(src, 50)
			deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS
	return

// Marker for the boundary corners.
/obj/effect/brine_marker
	icon_state = "scanline"
