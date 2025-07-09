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

	var/icon_base = "bee" ///our icon base
	var/dead_icon_base = "dead_bee"
	var/is_queen = FALSE

/mob/living/basic/honey_bee/queen
	name = "queen honey bee"
	desc = ""
	icon_base = "queen"
	dead_icon_base = "dead_queen_bee"
	is_queen = TRUE /// the bee is a queen?
	ai_controller = /datum/ai_controller/basic_controller/queen_honey_bee

/mob/living/basic/honey_bee/Initialize(mapload)
	. = ..()
	generate_bee_visuals()

/mob/living/basic/honey_bee/examine(mob/user)
	. = ..()

/mob/living/basic/honey_bee/Destroy()
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

#undef BEE_DEFAULT_COLOUR
