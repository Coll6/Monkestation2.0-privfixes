/obj/structure/hbeebox
	name = "honey box"
	desc = ""
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "beebox"
	anchored = TRUE
	density = TRUE

	var/mob/living/basic/honey_bee/queen/queen_bee = null

/obj/structure/beebox/Destroy()
	..()
	queen_bee = null

/obj/structure/hbeebox/proc/get_max_bees()
	. = 5
	//. = get_max_honeycomb() * BEES_RATIO

/obj/structure/hbeebox/proc/habitable(mob/living/basic/target)
	if(!istype(target, /mob/living/basic/honey_bee))
		return FALSE

	var/mob/living/basic/honey_bee/citizen = target
	if(citizen.is_queen)
		if(QDELETED(queen_bee))
			return TRUE
		if(citizen == queen_bee)
			return TRUE
		return FALSE

	if(QDELETED(queen_bee) || length(queen_bee.bees) >= get_max_bees()) //citizen.reagent_incompatible(queen_bee)
		return FALSE
	return TRUE
