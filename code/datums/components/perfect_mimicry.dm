/datum/component/perfect_mimicry
	var/obj/item/mimic_target
	var/list/allowed_objects = list()

/datum/component/perfect_mimicry/Initialize(list/allowed_objects = list())
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_objects = allowed_objects

	var/datum/action/cooldown/mimic_object/action = new(src)
	action.Grant(parent)

/datum/component/perfect_mimicry/RegisterWithParent()
	. = ..()

/datum/component/perfect_mimicry/UnregisterFromParent()
	. = ..()

/datum/component/perfect_mimicry/proc/is_allowed_object(obj/item/target_item)
	if(!target_item || !isitem(target_item))
		return FALSE
	if(length(allowed_objects) && !is_type_in_typecache(target_item, allowed_objects))
		return FALSE
	return TRUE

/datum/component/perfect_mimicry/proc/mimic_object(obj/item/target_item)
	if(!is_allowed_object(target_item))
		return FALSE

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
	if(target == owner)
		to_chat(owner, span_notice("You cannot mimic yourself."))
		return
	if(!isturf(target.loc, owner)) // Prevent transformation in/from some inventory
		return
	if(get_dist(owner, target) > 2)
		to_chat(owner, span_notice("Object is too far away."))
		return
	if(!mimicker.is_allowed_object(target))
		to_chat(owner, span_notice("Object is too complex to mimic."))
		return
	return ..()

/datum/action/cooldown/mimic_object/Activate(atom/target)
	StartCooldown()
	return TRUE
