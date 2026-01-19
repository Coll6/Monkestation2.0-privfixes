/datum/component/perfect_mimicry
	var/list/allowed_objects = list()

	var/obj/item/mimic_target // The object we are currently mimicking
	var/datum/movement_detector/tracker	// Tracker to keep the mob "glued" to the mimic target

/datum/component/perfect_mimicry/Initialize(list/allowed_objects = list())
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_objects = allowed_objects

	var/datum/action/cooldown/mimic_object/action = new(src)
	action.Grant(parent)

/datum/component/perfect_mimicry/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(block_normal_movement))
	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(block_normal_clicks))

/datum/component/perfect_mimicry/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOB_CLICKON))

/datum/component/perfect_mimicry/proc/is_allowed_object(obj/item/target_item)
	if(!target_item || !isitem(target_item))
		return FALSE
	if(length(allowed_objects) && !is_type_in_typecache(target_item, allowed_objects))
		return FALSE
	return TRUE

/datum/component/perfect_mimicry/proc/block_normal_movement(datum/source, atom/entering_loc)
	SIGNAL_HANDLER
	if(!isnull(mimic_target))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	return

/datum/component/perfect_mimicry/proc/block_normal_clicks(datum/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(!isnull(mimic_target))
		return COMSIG_MOB_CANCEL_CLICKON
	return

/datum/component/perfect_mimicry/proc/mimic_object(obj/item/target_item)
	if(!is_allowed_object(target_item) || !isliving(parent))
		return

	var/mob/living/mimic = parent
	mimic_target = new target_item.type(mimic.loc)
	mimic_target.name = target_item.name
	mimic_target.appearance = target_item.appearance
	mimic_target.copy_overlays(target_item)
	mimic_target.alpha = max(target_item.alpha, 150)
	mimic_target.transform = initial(target_item.transform)
	mimic_target.pixel_x = target_item.base_pixel_x
	mimic_target.pixel_y = target_item.base_pixel_y

	if(ismovable(target_item))
		tracker = new(mimic_target, CALLBACK(src, PROC_REF(sync_mimic_position)))

	mimic.SetInvisibility(INVISIBILITY_MAXIMUM, id=REF(src), priority=INVISIBILITY_PRIORITY_ABSTRACT)
	return mimic_target

/datum/component/perfect_mimicry/proc/return_form()
	if(isnull(mimic_target) || !isliving(parent))
		return FALSE

	var/mob/living/mimic = parent
	mimic_target.transfer_observers_to(mimic)

	mimic.RemoveInvisibility(REF(src))
	QDEL_NULL(mimic_target)
	QDEL_NULL(tracker)
	return TRUE

/datum/component/perfect_mimicry/proc/sync_mimic_position(atom/movable/master, atom/mover, atom/oldloc, direction)
	var/mob/living/mimic = parent
	if(master.loc == oldloc)
		return

	var/turf/newturf = get_turf(master)
	if(!newturf)
		//Handle this condition gracefully
		return

	if(QDELETED(mimic) || mimic.loc == newturf)
		return

	mimic.abstract_move(newturf)

/datum/action/cooldown/mimic_object
	name = "Mimic Object"
	desc = "Take on the appearance and behavior of a nearby object. Use again to reveal yourself."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

	click_to_activate = TRUE
	cooldown_time = 1 SECOND
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'

/datum/action/cooldown/mimic_object/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/perfect_mimicry))
		stack_trace("[name] ([type]) was instantiated on a non-perfect_mimicry target, this doesn't work.")
		qdel(src)
		return

/datum/action/cooldown/mimic_object/PreActivate(atom/target)
	var/datum/component/perfect_mimicry/mimicker = src.target
	if(!isnull(mimicker.mimic_target))
		return ..()
	if(target == owner)
		to_chat(owner, span_notice("You cannot mimic yourself."))
		return
	if(!isturf(target.loc, owner.loc)) // Prevent transformation in/from some inventory
		return
	if(get_dist(owner, target) > 2)
		to_chat(owner, span_notice("Object is too far away."))
		return
	if(!mimicker.is_allowed_object(target))
		to_chat(owner, span_notice("Object is too complex to mimic."))
		return
	return ..()

/datum/action/cooldown/mimic_object/Activate(atom/target)
	var/datum/component/perfect_mimicry/mimicker = src.target
	if(!isnull(mimicker.mimic_target) && mimicker.return_form())
		click_to_activate = TRUE
		StartCooldown()
		return TRUE

	if(mimicker.mimic_object(target))
		click_to_activate = FALSE
		StartCooldown()
		return TRUE

	return FALSE
