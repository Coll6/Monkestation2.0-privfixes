/obj/item/gun/syringe
	name = "medical syringe gun"
	desc = "A spring loaded gun designed to fit syringes, used to incapacitate unruly patients from a distance."
	icon = 'icons/obj/weapons/guns/syringegun.dmi'
	icon_state = "medicalsyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_icon_state = "medicalsyringegun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throw_speed = 3
	throw_range = 7
	force = 6
	base_pixel_x = -4
	pixel_x = -4
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	var/load_sound = 'sound/weapons/gun/shotgun/insert_shell.ogg'
	var/list/syringes = list()
	var/max_syringes = 1 ///The number of syringes it can store.
	var/has_syringe_overlay = TRUE ///If it has an overlay for inserted syringes. If true, the overlay is determined by the number of syringes inserted into it.
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/syringe/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/syringegun(src)
	recharge_newshot()

/obj/item/gun/syringe/apply_fantasy_bonuses(bonus)
	. = ..()
	max_syringes = modify_fantasy_variable("max_syringes", max_syringes, bonus, minimum = 1)

/obj/item/gun/syringe/remove_fantasy_bonuses(bonus)
	max_syringes = reset_fantasy_variable("max_syringes", max_syringes)
	return ..()

/obj/item/gun/syringe/handle_atom_del(atom/A)
	. = ..()
	if(A in syringes)
		syringes.Remove(A)

/obj/item/gun/syringe/recharge_newshot()
	if(!syringes.len)
		return
	chambered.newshot()

/obj/item/gun/syringe/can_shoot()
	return syringes.len

/obj/item/gun/syringe/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	if(chambered && !chambered.loaded_projectile) //we just fired
		recharge_newshot()
	update_appearance()

/obj/item/gun/syringe/examine(mob/user)
	. = ..()
	if(has_syringe_overlay)
		. += "Can hold [max_syringes] syringe\s. Has [syringes.len] syringe\s remaining."

/obj/item/gun/syringe/attack_self(mob/living/user)
	if(!syringes.len)
		balloon_alert(user, "it's empty!")
		return FALSE

	var/obj/item/reagent_containers/syringe/S = syringes[syringes.len]

	if(!S)
		return FALSE
	user.put_in_hands(S)

	syringes.Remove(S)
	balloon_alert(user, "[S.name] unloaded")
	update_appearance()

	return TRUE

/obj/item/gun/syringe/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/reagent_containers/syringe))
		if(syringes.len < max_syringes)
			if(!user.transferItemToLoc(A, src))
				return FALSE
			balloon_alert(user, "[A.name] loaded")
			syringes += A
			recharge_newshot()
			update_appearance()
			playsound(loc, load_sound, 40)
			return TRUE
		else
			balloon_alert(user, "it's already full!")
	return FALSE

/obj/item/gun/syringe/update_overlays()
	. = ..()
	if(!has_syringe_overlay)
		return
	var/syringe_count = syringes.len
	. += "[initial(icon_state)]_[syringe_count ? clamp(syringe_count, 1, initial(max_syringes)) : "empty"]"

/obj/item/gun/syringe/rapidsyringe
	name = "compact rapid syringe gun"
	desc = "A modification of the syringe gun design to be more compact and use a rotating cylinder to store up to six syringes."
	icon_state = "rapidsyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "syringegun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	max_syringes = 6
	force = 4

/obj/item/gun/syringe/syndicate
	name = "dart pistol"
	desc = "A small spring-loaded sidearm that functions identically to a syringe gun."
	icon_state = "dartsyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "gun" //Smaller inhand
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	force = 2 //Also very weak because it's smaller
	suppressed = TRUE //Softer fire sound
	can_unsuppress = FALSE //Permanently silenced
	syringes = list(new /obj/item/reagent_containers/syringe())

/obj/item/gun/syringe/dna
	name = "modified compact syringe gun"
	desc = "A syringe gun that has been modified to be compact and fit DNA injectors instead of normal syringes."
	icon_state = "dnasyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "syringegun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	force = 4

/obj/item/gun/syringe/dna/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/dnainjector(src)

/obj/item/gun/syringe/dna/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/dnainjector))
		var/obj/item/dnainjector/D = A
		if(D.used)
			balloon_alert(user, "[D.name] is used up!")
			return
		if(syringes.len < max_syringes)
			if(!user.transferItemToLoc(D, src))
				return FALSE
			balloon_alert(user, "[D.name] loaded")
			syringes += D
			recharge_newshot()
			update_appearance()
			playsound(loc, load_sound, 40)
			return TRUE
		else
			balloon_alert(user, "it's already full!")
	return FALSE

/obj/item/gun/syringe/blowgun
	name = "blowgun"
	desc = "Fire syringes at a short distance."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "blowgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "blowgun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	has_syringe_overlay = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	force = 4
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	pinless = TRUE

/obj/item/gun/syringe/blowgun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	visible_message(span_danger("[user] shoots the blowgun!"))

	user.stamina.adjust(-20)
	user.adjustOxyLoss(20)
	return ..()

//Prepare thy coders for a PSYCHIC ATTACK.

/obj/item/gun/syringe/shot_gun
	name = "double-barreled 'shot' gun"
	desc = "Fuck yeah, cheers bro! \n\nThis bad-boy is loaded with shot glasses! Just make sure they're full unless you want your patrons swallowing shards of broken glass."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "dshotgun"
	inhand_icon_state = "shotgun_db"
	fire_sound = 'sound/weapons/gun/shotgun/shot.ogg'
	has_syringe_overlay = FALSE
	max_syringes = 2 // Technically makes it a better syringe gun, but at least you have to work for this one.
	has_manufacturer = FALSE

/obj/item/gun/syringe/shot_gun/attackby(obj/item/A, mob/user, params, show_msg = TRUE) // Needs to be overridden so it can be loaded w/ shotglasses instead.
	if(istype(A, /obj/item/reagent_containers/cup/glass/drinkingglass/shotglass))
		if(syringes.len < max_syringes)
			if(!user.transferItemToLoc(A, src))
				return FALSE
			balloon_alert(user, "[A.name] loaded")
			syringes += A
			recharge_newshot()
			playsound(loc, load_sound, 40)
			return TRUE
		else
			balloon_alert(user, "it's already full!")
	return FALSE

/obj/item/gun/syringe/shot_gun/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE) // Exclusively overridden so it doesn't update appearance.
	if(chambered && !chambered.loaded_projectile)
		recharge_newshot()

/datum/crafting_recipe/shot_gun // Crafting recipe to make the dumb gun. Could be modified to require more annoying materials or a recipe book if people complain.
	name = "'Shot' gun"
	result = /obj/item/gun/syringe/shot_gun
	reqs = list(
		/obj/item/gun/ballistic/shotgun/doublebarrel = 1,
		/obj/item/stack/sticky_tape = 1,
		/obj/item/pipe = 3,
		/obj/item/stack/sheet/iron = 5,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_DRILL, TOOL_CROWBAR, TOOL_WELDER, TOOL_SAW)
	time = 15 SECONDS
	category = CAT_WEAPON_RANGED
