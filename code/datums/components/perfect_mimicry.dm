/datum/component/perfect_mimicry
	var/obj/item/mimic_target

/datum/component/perfect_mimicry/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/perfect_mimicry/RegisterWithParent()
	. = ..()

/datum/component/perfect_mimicry/UnregisterFromParent()
	. = ..()
