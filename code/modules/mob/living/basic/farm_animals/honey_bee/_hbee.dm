#define BEE_DEFAULT_COLOUR "#e5e500" //! the colour we make the stripes of the bee if our reagent has no colour (or we have no reagent)

/mob/living/basic/honey_bee
	name = "honey bee"
	desc = ""
	icon_state = ""
	icon_living = ""
	icon = 'monkestation/icons/mob/simple/bees.dmi' //monkestation edit
	gender = FEMALE
	speak_emote = list("buzzes")

	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_verb_continuous = "stings"
	attack_verb_simple = "sting"
	response_help_continuous = "shoos"
	response_help_simple = "shoo"
	response_disarm_continuous = "swats away"
	response_disarm_simple = "swat away"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"

	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/bee = 1 )

	mob_size = MOB_SIZE_TINY
	transform = list(0.75, 0, 0, 0, 0.75, 0)

	pixel_x = -16
	base_pixel_x = -16

	speed = 1
	maxHealth = 10
	health = 10
	melee_damage_lower = 1
	melee_damage_upper = 1
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | PASSMACHINE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	density = FALSE
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	ai_controller = /datum/ai_controller/basic_controller/honey_bee
	/// Rally point for the bee, can be a beehome or queen.
	var/atom/rally_point = null

	var/icon_base = "bee" ///our icon base
	var/dead_icon_base = "dead_bee"
	var/is_queen = FALSE

/mob/living/basic/honey_bee/Initialize(mapload)
	. = ..()
	generate_bee_visuals()

/mob/living/basic/honey_bee/examine(mob/user)
	. = ..()

	if(isnull(rally_point))
		. += span_warning("This [is_queen ? "queen bee" : "bee"] is homeless!")

/mob/living/basic/honey_bee/Destroy()
	if(!isnull(rally_point))
		if(!is_queen)
			var/mob/living/basic/honey_bee/queen/queen_bee = rally_point
			if(istype(queen_bee) && (src in queen_bee.bees))
				queen_bee.bees -= src
		rally_point = null
	..()

/mob/living/basic/honey_bee/proc/generate_bee_visuals()
	cut_overlays()

	var/bee_color = BEE_DEFAULT_COLOUR
	icon_state = "[icon_base]_base"
	add_overlay("[icon_base]_base")

	var/static/mutable_appearance/greyscale_overlay
	greyscale_overlay = greyscale_overlay || mutable_appearance('monkestation/icons/mob/simple/bees.dmi')
	greyscale_overlay.icon_state = "[icon_base]_grey"
	greyscale_overlay.color = bee_color
	add_overlay(greyscale_overlay)

	add_overlay("[icon_base]_wings")

/mob/living/basic/honey_bee/proc/handle_habitation(obj/structure/hbeebox/hive)
	var/return_point = null
	if(istype(rally_point, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = rally_point
		return_point = queen.rally_point
	else
		return_point = rally_point

	if(hive == return_point) //if its our home, we enter or exit it
		var/drop_location = (src in hive.contents) ? get_turf(hive) : hive
		forceMove(drop_location)
		return

	if(!isnull(hive.queen_bee) && is_queen) //if we are queen and house already have a queen, dont inhabit
		return

	if(!hive.habitable(src) || !isnull(return_point)) //if not habitable or we already have a home
		return

	if(!is_queen)
		rally_point = hive.queen_bee
		hive.queen_bee.bees += src

	else if(is_queen)
		rally_point = hive
		hive.queen_bee = src

/mob/living/basic/honey_bee/queen
	name = "queen honey bee"
	desc = ""
	icon_base = "queen"
	dead_icon_base = "dead_queen_bee"
	is_queen = TRUE /// the bee is a queen?
	var/list/mob/living/basic/honey_bee/bees = list() /// Bees that the queen can command.

	ai_controller = /datum/ai_controller/basic_controller/queen_honey_bee

/mob/living/basic/honey_bee/queen/Destroy()
	for(var/mob/living/basic/honey_bee/bee in bees)
		// Should anger bees here if destruction caused by someone or just anyone in area
		rally_point = null
	..()

#undef BEE_DEFAULT_COLOUR
