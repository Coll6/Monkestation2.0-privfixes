#define DISGUISED TRUE
#define UNDISGUISED FALSE

/datum/component/perfect_mimicry
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/list/allowed_objects = list() // typecache of allowed objects to mimic
	var/list/applied_traits = list()

	var/currently_disguised = UNDISGUISED // Simple flag to track if we are disguised or not
	var/obj/item/mimic_target // The object we are currently mimicking
	var/datum/movement_detector/tracker	// Tracker to keep the mob "glued" to the mimic target

//if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)

/datum/component/perfect_mimicry/Initialize(list/allowed_objects = list())
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_objects = typecacheof(allowed_objects)
	//var/datum/action/cooldown/mimic_object/action = new(src)
	//action.Grant(parent)

/datum/component/perfect_mimicry/Destroy(force)
	stop_mimicry()
	allowed_objects = null
	applied_traits = null
	return ..()

/datum/component/perfect_mimicry/RegisterWithParent()
	. = ..()
	//RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(block_normal_movement))
	//RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(block_normal_clicks))

/datum/component/perfect_mimicry/UnregisterFromParent()
	. = ..()
	//UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOB_CLICKON))

/datum/component/perfect_mimicry/proc/is_allowed_object(obj/item/target_item)
	if(!isitem(target_item))
		return FALSE
	if(length(allowed_objects) && !is_type_in_typecache(target_item, allowed_objects))
		return FALSE
	return TRUE

/datum/component/perfect_mimicry/proc/start_mimicry(obj/item/target_item)
	if(QDELETED(parent) || !isliving(parent))
		return
	if(currently_disguised == DISGUISED)
		return // Already disguised
	if(!is_allowed_object(target_item))
		return // Not an allowed object

	//make new mimic target
	//Handle object specific cases like emptying reagents

/datum/component/perfect_mimicry/proc/stop_mimicry()
	if(QDELETED(parent) || !isliving(parent))
		QDEL_NULL(tracker)
		if(!QDELETED(mimic_target))
			// unreg signals from mimic target
			QDEL_NULL(mimic_target)
		return FALSE
	if(!isnull(mimic_target))
		QDEL_NULL(tracker)
		// unreg signals from mimic target
		QDEL_NULL(mimic_target)

	if(currently_disguised == UNDISGUISED)
		return FALSE // Already undisguised

/*
 * Signal handlers
 */
/datum/component/perfect_mimicry/proc/block_normal_movement(datum/source, atom/entering_loc)
	SIGNAL_HANDLER
	if(currently_disguised == DISGUISED)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	return

/datum/component/perfect_mimicry/proc/block_normal_clicks(datum/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(currently_disguised == DISGUISED)
		return COMSIG_MOB_CANCEL_CLICKON
	return

/*
 * Tracker callback
 */
/datum/component/perfect_mimicry/proc/sync_mimic_position(atom/movable/master, atom/mover, atom/oldloc, direction)

/*
 * Mimicry actions
 */
/datum/action/cooldown/mimic_ability
	name = "Base Mimic Ability"
	desc = "You should not be seeing this. This is an error alert developers."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

// These abilities require a perfect_mimicry component otherwise they are useless.
/datum/action/cooldown/mimic_ability/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/perfect_mimicry))
		stack_trace("[name] ([type]) was instantiated on a non-perfect_mimicry target, this doesn't work.")
		qdel(src)
		return

/datum/action/cooldown/mimic_ability/mimic_object
	name = "Mimic Object"
	desc = "Take on the appearance and behavior of a nearby object. Use again to reveal yourself."

	click_to_activate = TRUE
	cooldown_time = 1 SECOND
	var/cooldown_after_use = 3 SECONDS // Cooldown after mimicry ends
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'

/datum/action/cooldown/mimic_ability/throw_self

#undef DISGUISED
#undef UNDISGUISED
