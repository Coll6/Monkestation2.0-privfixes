/obj/item/gun/ballistic/rifle
	name = "Bolt Rifle"
	desc = "Some kind of bolt action rifle. You get the feeling you shouldn't have this."
	icon_state = "moistnugget"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "moistnugget"
	worn_icon_state = "moistnugget"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction
	bolt_wording = "bolt"
	bolt_type = BOLT_TYPE_LOCKING
	semi_auto = FALSE
	internal_magazine = TRUE
	fire_sound = 'sound/weapons/gun/rifle/shot.ogg'
	fire_sound_volume = 90
	rack_sound = 'sound/weapons/gun/rifle/bolt_out.ogg'
	bolt_drop_sound = 'sound/weapons/gun/rifle/bolt_in.ogg'
	tac_reloads = FALSE
	gun_flags = GUN_SMOKE_PARTICLES
	/// Does the bolt need to be open to interact with the gun (e.g. magazine interactions)?
	var/need_bolt_lock_to_interact = TRUE

/obj/item/gun/ballistic/rifle/rack(mob/user = null)
	if (bolt_locked == FALSE)
		balloon_alert(user, "bolt opened")
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
		process_chamber(user = user, empty_chamber = FALSE, from_firing = FALSE, chamber_next_round = FALSE)
		bolt_locked = TRUE
		update_appearance()
		return
	drop_bolt(user)

/obj/item/gun/ballistic/rifle/can_shoot()
	if (bolt_locked)
		return FALSE
	return ..()

/obj/item/gun/ballistic/rifle/attackby(obj/item/A, mob/user, params)
	if(need_bolt_lock_to_interact && !bolt_locked && !istype(A, /obj/item/stack/sheet/cloth))
		balloon_alert(user, "[bolt_wording] is closed!")
		return
	return ..()

/obj/item/gun/ballistic/rifle/examine(mob/user)
	. = ..()
	. += "The bolt is [bolt_locked ? "open" : "closed"]."

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/ballistic/rifle/boltaction
	name = "\improper Mosin Nagant"
	desc = "A classic Mosin Nagant. They don't make them like they used to. Well, okay, in all honesty, this one is actually \
		a new refurbished version. So it works just fine! Often found in the hands of underpaid Nanotrasen interns, \
		Russian military LARPers, actual Space Russians, revolutionaries and cargo technicians. Still feels slightly moist."
	sawn_desc = "A sawn-off Mosin Nagant, popularly known as an \"Obrez\". \
		There was probably a reason it wasn't manufactured this short to begin with. \
		This one is still in surprisingly good condition. Often found in the hands \
		of underpaid Nanotrasen interns without a care for company property, Russian military LARPers, \
		actual drunk Space Russians, Tiger Co-op assassins and cargo technicians. <I>Still</I> feels slightly moist."
	weapon_weight = WEAPON_HEAVY
	icon_state = "moistnugget"
	inhand_icon_state = "moistnugget"
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13
	can_be_sawn_off = TRUE
	var/jamming_chance = 20
	var/unjam_chance = 10
	var/jamming_increment = 5
	var/jammed = FALSE
	var/can_jam = FALSE

/obj/item/gun/ballistic/rifle/boltaction/sawoff(mob/user)
	. = ..()
	if(.)
		spread = 36
		can_bayonet = FALSE
		update_appearance()

/obj/item/gun/ballistic/rifle/boltaction/attack_self(mob/user)
	if(can_jam)
		if(jammed)
			if(prob(unjam_chance))
				jammed = FALSE
				unjam_chance = 10
			else
				unjam_chance += 10
				balloon_alert(user, "jammed!")
				playsound(user,'sound/weapons/jammed.ogg', 75, TRUE)
				return FALSE
	..()

/obj/item/gun/ballistic/rifle/boltaction/process_fire(mob/user)
	if(can_jam)
		if(chambered.loaded_projectile)
			if(prob(jamming_chance))
				jammed = TRUE
			jamming_chance += jamming_increment
			jamming_chance = clamp (jamming_chance, 0, 100)
	return ..()

/obj/item/gun/ballistic/rifle/boltaction/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(!can_jam)
		balloon_alert(user, "can't jam!")
		return

	if(!bolt_locked)
		balloon_alert(user, "bolt closed!")
		return

	if(istype(item, /obj/item/gun_maintenance_supplies) && do_after(user, 10 SECONDS, target = src))
		user.visible_message(span_notice("[user] finishes maintenance of [src]."))
		jamming_chance = initial(jamming_chance)
		qdel(item)

/obj/item/gun/ballistic/rifle/boltaction/blow_up(mob/user)
	. = FALSE
	if(chambered?.loaded_projectile)
		process_fire(user, user, FALSE)
		. = TRUE

/obj/item/gun/ballistic/rifle/boltaction/harpoon
	name = "ballistic harpoon gun"
	desc = "A weapon favored by carp hunters, but just as infamously employed by agents of the Animal Rights Consortium against human aggressors. Because it's ironic."
	icon_state = "speargun"
	inhand_icon_state = "speargun"
	worn_icon_state = "speargun"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/harpoon
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	can_be_sawn_off = FALSE

/obj/item/gun/ballistic/rifle/boltaction/surplus
	desc = "A classic Mosin Nagant, ruined by centuries of moisture. Some Space Russians claim that the moisture \
		is a sign of good luck. A sober user will know that this thing is going to fucking jam. Repeatedly. \
		Often found in the hands of cargo technicians, Russian military LARPers, Tiger Co-Op terrorist cells, \
		cryo-frozen Space Russians, and security personnel with a bone to pick. EXTREMELY moist."
	sawn_desc = "A sawn-off Mosin Nagant, popularly known as an \"Obrez\". \
		There was probably a reason it wasn't manufactured this short to begin with. \
		This one has been ruined by centuries of moisture and WILL jam. Often found in the hands of \
		cargo technicians with a death wish, Russian military LARPers, actual drunk Space Russians, \
		Tiger Co-op assassins, cryo-frozen Space Russians, and security personnel with \
		little care for professional conduct while making 'arrests' point blank in the back of the head \
		until the gun clicks. EXTREMELY moist."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/surplus
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/boltaction/prime
	name = "\improper Regal Nagant"
	desc = "A prized hunting Mosin Nagant. Used for the most dangerous game."
	icon_state = "moistprime"
	inhand_icon_state = "moistprime"
	worn_icon_state = "moistprime"
	can_be_sawn_off = TRUE
	sawn_desc = "A sawn-off Regal Nagant... Doing this was a sin, I hope you're happy. \
		You are now probably one of the few people in the universe to ever hold a \"Regal Obrez\". \
		Even thinking about that name combination makes you ill."

/obj/item/gun/ballistic/rifle/boltaction/prime/sawoff(mob/user)
	. = ..()
	if(.)
		name = "\improper Regal Obrez" // wear it loud and proud

/obj/item/gun/ballistic/rifle/rebarxbow
	name = "heated rebar crossbow"
	desc = "A handcrafted crossbow. \
		   Aside from conventional sharpened iron rods, it can also fire specialty ammo made from the atmos crystalizer - zaukerite, metallic hydrogen, and healium rods all work. \
		   Very slow to reload - you can craft the crossbow with a crowbar to loosen the crossbar, but risk a misfire, or worse..."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "rebarxbow"
	base_icon_state = "rebarxbow"
	inhand_icon_state = "rebarxbow"
	worn_icon_state = "rebarxbow"
	rack_sound = 'sound/weapons/gun/sniper/rack.ogg'
	mag_display = FALSE
	empty_indicator = TRUE
	bolt_type = BOLT_TYPE_OPEN
	semi_auto = FALSE
	internal_magazine = TRUE
	can_modify_ammo = FALSE
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_SUITSTORE
	bolt_wording = "bowstring"
	magazine_wording = "rod"
	cartridge_wording = "rod"
	weapon_weight = WEAPON_HEAVY
	initial_caliber = CALIBER_REBAR
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/normal
	fire_sound = 'sound/items/xbow_lock.ogg'
	can_be_sawn_off = FALSE
	tac_reloads = FALSE
	var/draw_time = 3 SECONDS
	SET_BASE_PIXEL(0, 0)
	need_bolt_lock_to_interact = FALSE

/obj/item/gun/ballistic/rifle/rebarxbow/rack(mob/user = null)
	if (bolt_locked)
		drop_bolt(user)
		return
	balloon_alert(user, "bowstring loosened")
	playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	handle_chamber(empty_chamber =  FALSE, from_firing = FALSE, chamber_next_round = FALSE)
	bolt_locked = TRUE
	update_appearance()

/obj/item/gun/ballistic/rifle/rebarxbow/drop_bolt(mob/user = null)
	if(!do_after(user, draw_time, target = src))
		return
	playsound(src, bolt_drop_sound, bolt_drop_sound_volume, FALSE)
	balloon_alert(user, "bowstring drawn")
	chamber_round()
	bolt_locked = FALSE
	update_appearance()

/obj/item/gun/ballistic/rifle/rebarxbow/shoot_live_shot(mob/living/user)
	..()
	rack()

/obj/item/gun/ballistic/rifle/rebarxbow/can_shoot()
	if (bolt_locked)
		return FALSE
	return ..()

/obj/item/gun/ballistic/rifle/rebarxbow/shoot_with_empty_chamber(mob/living/user)
	if(chambered || !magazine || !length(magazine.contents))
		return ..()
	drop_bolt(user)

/obj/item/gun/ballistic/rifle/rebarxbow/examine(mob/user)
	. = ..()
	. += "The crossbow is [bolt_locked ? "not ready" : "ready"] to fire."

/obj/item/gun/ballistic/rifle/rebarxbow/update_overlays()
	. = ..()
	if(!magazine)
		. += "[base_icon_state]" + "_empty"
	if(!bolt_locked)
		. += "[base_icon_state]" + "_bolt_locked"

/obj/item/gun/ballistic/rifle/rebarxbow/forced
	name = "stressed rebar crossbow"
	desc = "Some idiot decided that they would risk shooting themselves in the face if it meant they could have a draw this crossbow a bit faster. Hopefully, it was worth it."
	// Feel free to add a recipe to allow you to change it back if you would like, I just wasn't sure if you could have two recipes for the same thing.
	can_misfire = TRUE
	draw_time = 1.5
	misfire_probability = 25
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/force

/obj/item/gun/ballistic/rifle/rebarxbow/syndie
	name = "syndicate rebar crossbow"
	desc = "The syndicate liked the bootleg rebar crossbow NT engineers made, so they showed what it could be if properly developed. \
			Holds three shots without a chance of exploding, and features a built in scope. Compatible with all known crossbow ammunition."
	base_icon_state = "rebarxbowsyndie"
	icon_state = "rebarxbowsyndie"
	inhand_icon_state = "rebarxbowsyndie"
	worn_icon_state = "rebarxbowsyndie"
	w_class = WEIGHT_CLASS_NORMAL
	initial_caliber = CALIBER_REBAR
	draw_time = 1
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/syndie

/obj/item/gun/ballistic/rifle/rebarxbow/syndie/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2) //enough range to at least be useful for stealth

/obj/item/gun/ballistic/rifle/boltaction/pipegun
	name = "pipegun"
	desc = "An excellent weapon for flushing out tunnel rats and enemy assistants, but its rifling leaves much to be desired."
	icon_state = "musket"
	inhand_icon_state = "musket"
	worn_icon_state = "musket"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/pipegun
	initial_caliber = CALIBER_SHOTGUN
	alternative_caliber = CALIBER_A762
	initial_fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	alternative_fire_sound = 'sound/weapons/gun/shotgun/shot.ogg'
	can_modify_ammo = TRUE
	can_misfire = FALSE
	can_bayonet = TRUE
	knife_y_offset = 11
	can_be_sawn_off = FALSE
	projectile_damage_multiplier = 0.75

/obj/item/gun/ballistic/rifle/boltaction/pipegun/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	. = ..()
	do_sparks(1, TRUE, src)

/obj/item/gun/ballistic/rifle/boltaction/pipegun/prime
	name = "regal pipegun"
	desc = "Older, territorial assistants typically possess more valuable loot."
	icon_state = "musket_prime"
	inhand_icon_state = "musket_prime"
	worn_icon_state = "musket_prime"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/pipegun/prime
	projectile_damage_multiplier = 1

/// MAGICAL BOLT ACTIONS + ARCANE BARRAGE? ///

/obj/item/gun/ballistic/rifle/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/enchanted
	can_be_sawn_off = FALSE

/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	fire_sound = 'sound/weapons/emitter.ogg'
	pin = /obj/item/firing_pin/magic
	icon_state = "arcane_barrage"
	inhand_icon_state = "arcane_barrage"
	slot_flags = null
	can_bayonet = FALSE
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NOBLUDGEON
	flags_1 = NONE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	show_bolt_icon = FALSE //It's a magic hand, not a rifle

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/arcane_barrage

/obj/item/gun/ballistic/rifle/enchanted/dropped()
	. = ..()
	guns_left = 0
	magazine = null
	chambered = null

/obj/item/gun/ballistic/rifle/enchanted/proc/discard_gun(mob/living/user)
	user.throw_item(pick(oview(7,get_turf(user))))

/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage/discard_gun(mob/living/user)
	qdel(src)

/obj/item/gun/ballistic/rifle/enchanted/attack_self()
	return

/obj/item/gun/ballistic/rifle/enchanted/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	if(guns_left)
		var/obj/item/gun/ballistic/rifle/enchanted/gun = new type
		gun.guns_left = guns_left - 1
		discard_gun(user)
		user.swap_hand()
		user.put_in_hands(gun)
	else
		user.dropItemToGround(src, TRUE)

// SNIPER //

/obj/item/gun/ballistic/rifle/sniper_rifle
	name = "anti-materiel sniper rifle"
	desc = "A boltaction anti-materiel rifle, utilizing .50 BMG cartridges. While technically outdated in modern arms markets, it still works exceptionally well as \
		an anti-personnel rifle. In particular, the employment of modern armored MODsuits utilizing advanced armor plating has given this weapon a new home on the battlefield. \
		It is also able to be suppressed....somehow."
	icon_state = "sniper"
	weapon_weight = WEAPON_HEAVY
	inhand_icon_state = "sniper"
	worn_icon_state = null
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	fire_sound_volume = 90
	load_sound = 'sound/weapons/gun/sniper/mag_insert.ogg'
	rack_sound = 'sound/weapons/gun/sniper/rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	recoil = 2
	accepted_magazine_type = /obj/item/ammo_box/magazine/sniper_rounds
	internal_magazine = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	mag_display = TRUE
	tac_reloads = TRUE
	rack_delay = 1 SECONDS
	can_suppress = TRUE
	can_unsuppress = TRUE
	suppressor_x_offset = 3
	suppressor_y_offset = 3

/obj/item/gun/ballistic/rifle/sniper_rifle/examine(mob/user)
	. = ..()
	. += span_warning("<b>It seems to have a warning label:</b> Do NOT, under any circumstances, attempt to 'quickscope' with this rifle.")

/obj/item/gun/ballistic/rifle/sniper_rifle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 7) //enough range to at least make extremely good use of the penetrator rounds

/obj/item/gun/ballistic/rifle/sniper_rifle/reset_semicd()
	. = ..()
	if(suppressed)
		playsound(src, 'sound/machines/eject.ogg', 25, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	else
		playsound(src, 'sound/machines/eject.ogg', 50, TRUE)

/obj/item/gun/ballistic/rifle/sniper_rifle/syndicate
	desc = "A boltaction anti-materiel rifle, utilizing .50 BMG cartridges. While technically outdated in modern arms markets, it still works exceptionally well as \
		an anti-personnel rifle. In particular, the employment of modern armored MODsuits utilizing advanced armor plating has given this weapon a new home on the battlefield. \
		It is also able to be suppressed....somehow. This one seems to have a little picture of someone in a blood-red MODsuit stenciled on it, pointing at a green floppy disk. \
		Who knows what that might mean."
	pin = /obj/item/firing_pin/implant/pindicate
