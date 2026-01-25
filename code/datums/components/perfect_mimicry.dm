#define DISGUISED TRUE
#define UNDISGUISED FALSE

/datum/component/perfect_mimicry
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/list/allowed_objects = list() // typecache of allowed objects to mimic
	var/list/applied_traits = list() // List of traits applied to mob when mimicking to make it "intangible".
	/// List of /datum/action instance that we've registered `COMSIG_ACTION_TRIGGER` on.
	//var/list/datum/action/registered_actions

	var/currently_disguised = UNDISGUISED // Simple flag to track if we are disguised or not
	var/obj/item/mimic_target // The object we are currently mimicking
	var/datum/movement_detector/tracker	// Tracker to keep the mob "glued" to the mimic target

//if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)

/datum/component/perfect_mimicry/Initialize(list/allowed_objects = list())
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_objects = typecacheof(allowed_objects)

/datum/component/perfect_mimicry/Destroy(force)
	stop_mimicry()
	allowed_objects = null
	applied_traits = null
	return ..()

/datum/component/perfect_mimicry/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(block_normal_movement))
	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(block_normal_clicks))

	var/datum/action/cooldown/mimic_ability/mimic_object/action = new(src)
	action.Grant(parent)

/datum/component/perfect_mimicry/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE))
	UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOB_CLICKON))

/datum/component/perfect_mimicry/proc/is_allowed_object(obj/item/target_item)
	if(!isitem(target_item))
		return FALSE
	if(length(allowed_objects) && !is_type_in_typecache(target_item, allowed_objects))
		return FALSE
	return TRUE

// Handle special cases for certain object types (Eg. emptying reagents from beakers)
/datum/component/perfect_mimicry/proc/handle_special_types(obj/item/mimic_item)

/datum/component/perfect_mimicry/proc/start_mimicry(obj/item/target_item)
	if(QDELETED(parent) || !isliving(parent))
		return
	if(currently_disguised == DISGUISED)
		return // Already disguised
	if(!is_allowed_object(target_item))
		return // Not an allowed object

	var/mob/living/mimic = parent
	mimic_target = new target_item.type(mimic.loc)
	handle_special_types(mimic_target)
	mimic_target.name = target_item.name
	mimic_target.appearance = target_item.appearance
	mimic_target.copy_overlays(target_item)
	mimic_target.alpha = max(target_item.alpha, 150)
	mimic_target.transform = initial(target_item.transform)
	mimic_target.pixel_x = target_item.base_pixel_x
	mimic_target.pixel_y = target_item.base_pixel_y

	if(QDELETED(mimic_target))
		mimic_target = null
		return // Failed to create mimic target
	RegisterSignal(mimic_target, COMSIG_QDELETING, PROC_REF(mimic_target_deleted))
	if(ismovable(target_item))
		tracker = new(mimic_target, CALLBACK(src, PROC_REF(sync_mimic_position)))
	ADD_TRAIT(mimic, TRAIT_UNDENSE, REF(src))
	mimic.SetInvisibility(INVISIBILITY_MAXIMUM, id=REF(src), priority=INVISIBILITY_PRIORITY_ABSTRACT)
	currently_disguised = DISGUISED
	return mimic_target

/datum/component/perfect_mimicry/proc/stop_mimicry()
	if(QDELETED(parent) || !isliving(parent))
		QDEL_NULL(tracker)
		if(!QDELETED(mimic_target))
			UnregisterSignal(mimic_target, COMSIG_QDELETING)
			QDEL_NULL(mimic_target)
		return FALSE
	var/mob/living/mimic = parent
	var/drop_loc
	if(!isnull(mimic_target))
		QDEL_NULL(tracker)
		UnregisterSignal(mimic_target, COMSIG_QDELETING)
		mimic_target.transfer_observers_to(parent)
		drop_loc = mimic_target.drop_location()
		if(!get_turf(drop_loc))
			drop_loc = mimic.loc
		if(!QDELETED(mimic_target))
			QDEL_NULL(mimic_target)

	if(currently_disguised == UNDISGUISED)
		return FALSE // Already undisguised
	if(!isnull(drop_loc))
		mimic.abstract_move(drop_loc)
	REMOVE_TRAIT(mimic, TRAIT_UNDENSE, REF(src))
	mimic.RemoveInvisibility(REF(src))
	currently_disguised = UNDISGUISED
	return TRUE

/*
 * Signal handlers
 */
/datum/component/perfect_mimicry/proc/block_normal_movement(datum/source, atom/entering_loc)
	SIGNAL_HANDLER
	if(currently_disguised == DISGUISED)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/perfect_mimicry/proc/block_normal_clicks(datum/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(currently_disguised == DISGUISED)
		return COMSIG_MOB_CANCEL_CLICKON

/datum/component/perfect_mimicry/proc/mimic_target_deleted(datum/source, force)
	SIGNAL_HANDLER
	stop_mimicry()
	if(!QDELETED(parent) && isliving(parent))
		var/mob/living/mimic = parent
		for(var/datum/action/cooldown/mimic_ability/mimic_object/A in mimic.actions)
			A.click_to_activate = TRUE
			A.StartCooldown(A.cooldown_after_use)

/*
 * Tracker callback
 */
/datum/component/perfect_mimicry/proc/sync_mimic_position(atom/movable/master, atom/mover, atom/oldloc, direction)
	var/mob/living/mimic = parent
	if(master.loc == oldloc)
		return

	var/turf/newturf = get_turf(master)
	if(!newturf)
		mimic.abstract_move(oldloc)
		QDEL_NULL(master)
		return

	if(QDELETED(mimic) || mimic.loc == newturf)
		return

	mimic.abstract_move(newturf)
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

/datum/action/cooldown/mimic_ability/mimic_object/PreActivate(atom/target)
	var/datum/component/perfect_mimicry/mimicker = src.target
	if(!istype(mimicker))
		return
	if(mimicker.currently_disguised == DISGUISED)
		return ..()
	if(target == owner)
		to_chat(owner, span_notice("You cannot mimic yourself."))
		return
	//if(!isturf(target.loc, owner.loc)) // Prevent transformation in/from some inventory
	//	return
	if(get_dist(owner, target) > 2)
		to_chat(owner, span_notice("[target.name] is too far away."))
		return
	if(!mimicker.is_allowed_object(target))
		to_chat(owner, span_notice("[target.name] is too complex to mimic."))
		return
	return ..()

/datum/action/cooldown/mimic_ability/mimic_object/Activate(atom/target)
	var/datum/component/perfect_mimicry/mimicker = src.target
	if(!istype(mimicker))
		return FALSE

	if((mimicker.currently_disguised == DISGUISED) && mimicker.stop_mimicry())
		click_to_activate = TRUE
		StartCooldown(cooldown_after_use)
		return TRUE

	if((mimicker.currently_disguised == UNDISGUISED) && mimicker.start_mimicry(target))
		click_to_activate = FALSE
		StartCooldown()
		return TRUE

	return FALSE

/datum/action/cooldown/mimic_ability/throw_self

#undef DISGUISED
#undef UNDISGUISED
