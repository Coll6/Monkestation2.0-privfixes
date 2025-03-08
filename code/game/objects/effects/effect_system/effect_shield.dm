/obj/effect/shield
	name = "shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave2"
	layer = ABOVE_NORMAL_TURF_LAYER
	flags_1 = PREVENT_CLICK_UNDER_1
	anchored = TRUE
	var/old_heat_capacity

/obj/effect/shield/Initialize(mapload)
	. = ..()


/obj/effect/shield/Destroy()

	return ..()

/obj/effect/shield/singularity_act()
	return

/obj/effect/shield/singularity_pull(S, current_size)
	return

