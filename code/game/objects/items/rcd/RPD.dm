//RAPID PIPE DISPENSER

#define ATMOS_CATEGORY 0
#define DISPOSALS_CATEGORY 1
#define TRANSIT_CATEGORY 2

#define BUILD_MODE (1<<0)
#define WRENCH_MODE (1<<1)
#define DESTROY_MODE (1<<2)
#define REPROGRAM_MODE (1<<3)

#define PIPE_LAYER(num) (1<<(num-1))

///Sound to make when we use the item to build/destroy something
#define RPD_USE_SOUND 'sound/items/deconstruct.ogg'

GLOBAL_LIST_INIT(atmos_pipe_recipes, list(
	"Pipes" = list(
	),
	"Binary" = list(

	),
	"Devices" = list(

	),
	"Heat Exchange" = list(

	)
))

GLOBAL_LIST_INIT(disposal_pipe_recipes, list(
	"Disposal Pipes" = list(
		new /datum/pipe_info/disposal("Pipe", /obj/structure/disposalpipe/segment, PIPE_BENDABLE),
		new /datum/pipe_info/disposal("Junction", /obj/structure/disposalpipe/junction, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Y-Junction", /obj/structure/disposalpipe/junction/yjunction),
		new /datum/pipe_info/disposal("Sort Junction", /obj/structure/disposalpipe/sorting/mail, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Rotator", /obj/structure/disposalpipe/rotator, PIPE_ONEDIR_FLIPPABLE),
		new /datum/pipe_info/disposal("Trunk", /obj/structure/disposalpipe/trunk),
		new /datum/pipe_info/disposal("Bin", /obj/machinery/disposal/bin, PIPE_ONEDIR),
		new /datum/pipe_info/disposal("Outlet", /obj/structure/disposaloutlet),
		new /datum/pipe_info/disposal("Chute", /obj/machinery/disposal/delivery_chute),
	)
))

GLOBAL_LIST_INIT(transit_tube_recipes, list(
	"Transit Tubes" = list(
		new /datum/pipe_info/transit("Straight Tube", /obj/structure/c_transit_tube, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Straight Tube with Crossing", /obj/structure/c_transit_tube/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Curved Tube", /obj/structure/c_transit_tube/curved, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Diagonal Tube", /obj/structure/c_transit_tube/diagonal, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Diagonal Tube with Crossing", /obj/structure/c_transit_tube/diagonal/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Junction", /obj/structure/c_transit_tube/junction, PIPE_UNARY_FLIPPABLE),
	),
	"Station Equipment" = list(
		new /datum/pipe_info/transit("Through Tube Station", /obj/structure/c_transit_tube/station, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Terminus Tube Station", /obj/structure/c_transit_tube/station/reverse, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Through Tube Dispenser Station", /obj/structure/c_transit_tube/station/dispenser, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Terminus Tube Dispenser Station", /obj/structure/c_transit_tube/station/dispenser/reverse, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Transit Tube Pod", /obj/structure/c_transit_tube_pod, PIPE_ONEDIR),
	)
))

/datum/pipe_info


/datum/pipe_info/proc/get_preview(selected_dir, selected = FALSE)


/datum/pipe_info/pipe/New(label, obj/machinery/atmospherics/path, use_five_layers)




/datum/pipe_info/meter

/datum/pipe_info/meter/New(label)


/datum/pipe_info/disposal/New(label, obj/path, dt=PIPE_UNARY)



/datum/pipe_info/transit/New(label, obj/path, dt=PIPE_UNARY)

/obj/item/pipe_dispenser
	name = "rapid pipe dispenser"
	desc = "A device used to rapidly pipe things."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	worn_icon_state = "RPD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*37.5, /datum/material/glass=SHEET_MATERIAL_AMOUNT*18.75)
	armor_type = /datum/armor/item_pipe_dispenser
	resistance_flags = FIRE_PROOF
	///Sparks system used when changing device in the UI
	var/datum/effect_system/spark_spread/spark_system
	///Direction of the device we are going to spawn, set up in the UI
	var/p_dir = NORTH
	///Initial direction of the smart pipe we are going to spawn, set up in the UI
	var/p_init_dir = ALL_CARDINALS
	///Is the device of the flipped type?
	var/p_flipped = FALSE
	///Color of the device we are going to spawn
	var/paint_color = "green"
	///Speed of building atmos devices
	var/atmos_build_speed = 0.4 SECONDS
	///Speed of building disposal devices
	var/disposal_build_speed = 0.5 SECONDS
	///Speed of building transit devices
	var/transit_build_speed = 0.5 SECONDS
	///Category currently active (Atmos, disposal, transit)
	var/category = ATMOS_CATEGORY
	///All pipe layers we are going to spawn the atmos devices in
	var/pipe_layers = PIPE_LAYER(3)
	///Are we laying multiple layers per click
	var/multi_layer = FALSE
	///Layer for disposal ducts
	var/ducting_layer = DUCT_LAYER_DEFAULT
	///Stores the current device to spawn
	var/datum/pipe_info/recipe
	///Stores the first atmos device
	var/static/datum/pipe_info/first_atmos
	///Stores the first disposal device
	var/static/datum/pipe_info/first_disposal
	///Stores the first transit device
	var/static/datum/pipe_info/first_transit
	///The modes that are allowed for the RPD
	var/mode = BUILD_MODE | DESTROY_MODE | WRENCH_MODE | REPROGRAM_MODE
	/// Bitflags for upgrades
	var/upgrade_flags

/datum/armor/item_pipe_dispenser
	fire = 100
	acid = 50

/obj/item/pipe_dispenser/Initialize(mapload)
	. = ..()
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(!first_atmos)
		first_atmos = GLOB.atmos_pipe_recipes[GLOB.atmos_pipe_recipes[1]][1]
	if(!first_disposal)
		first_disposal = GLOB.disposal_pipe_recipes[GLOB.disposal_pipe_recipes[1]][1]
	if(!first_transit)
		first_transit = GLOB.transit_tube_recipes[GLOB.transit_tube_recipes[1]][1]

	recipe = first_atmos
	register_item_context()

/obj/item/pipe_dispenser/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/pipe_dispenser/examine(mob/user)
	. = ..()
	. += span_notice("You can scroll your <b>mouse wheel</b> to change the piping layer.")
	. += span_notice("You can <b>right click</b> a pipe to set the RPD to its color and layer.")

/obj/item/pipe_dispenser/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		RegisterSignal(user, COMSIG_MOUSE_SCROLL_ON, PROC_REF(mouse_wheeled))
	else
		UnregisterSignal(user,COMSIG_MOUSE_SCROLL_ON)

/obj/item/pipe_dispenser/dropped(mob/user, silent)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/pipe_dispenser/proc/get_active_pipe_layers()
	var/list/layer_nums = list()
	for(var/pipe_layer_number in 1 to 5)
		if(PIPE_LAYER(pipe_layer_number) & pipe_layers)
			layer_nums += pipe_layer_number
	return layer_nums

/obj/item/pipe_dispenser/cyborg_unequip(mob/user)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/pipe_dispenser/attack_self(mob/user)
	ui_interact(user)

/obj/item/pipe_dispenser/pre_attack_secondary(obj/machinery/atmospherics/target, mob/user, params)
	if(!istype(target, /obj/machinery/atmospherics))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/pipe_dispenser/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = ..()

	return CONTEXTUAL_SCREENTIP_SET


/obj/item/pipe_dispenser/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] points the end of the RPD down [user.p_their()] throat and presses a button! It looks like [user.p_theyre()] trying to commit suicide..."))
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	playsound(get_turf(user), RPD_USE_SOUND, 50, TRUE)
	return BRUTELOSS

/obj/item/pipe_dispenser/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/pipes),
	)

/obj/item/pipe_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidPipeDispenser", name)
		ui.open()

/obj/item/pipe_dispenser/ui_static_data(mob/user)
	var/list/data = list("paint_colors" = GLOB.pipe_paint_colors)
	return data

/obj/item/pipe_dispenser/ui_data(mob/user)
	var/list/data = list(
		"category" = category,
		"multi_layer" = multi_layer,
		"pipe_layers" = pipe_layers,
		"ducting_layer" = ducting_layer,
		"categories" = list(),
		"selected_color" = paint_color,
		"mode" = mode,
	)

	//currently selected category (atmos, disposal or transit)
	var/list/selected_major_category
	switch(category)
		if(ATMOS_CATEGORY)
			selected_major_category = GLOB.atmos_pipe_recipes
		if(DISPOSALS_CATEGORY)
			selected_major_category = GLOB.disposal_pipe_recipes
		if(TRANSIT_CATEGORY)
			selected_major_category = GLOB.transit_tube_recipes
	//selected subcategory (e.g. pipes/binary/devices/heat exchange for atmos)
	for(var/subcategory in selected_major_category)
		var/list/subcategory_recipes = selected_major_category[subcategory]
		var/list/available_recipe = list()
		for(var/i in 1 to subcategory_recipes.len)
			var/datum/pipe_info/info = subcategory_recipes[i]

			available_recipe += list(list(
				"pipe_index" = i,
				"previews" = info.get_preview(p_dir, info == recipe)
			))
			if(info == recipe)
				data["selected_category"] = subcategory

		data["categories"] += list(list("cat_name" = subcategory, "recipes" = available_recipe))

	var/list/init_directions = list("north" = FALSE, "south" = FALSE, "east" = FALSE, "west" = FALSE)
	for(var/direction in GLOB.cardinals)
		if(p_init_dir & direction)
			init_directions[dir2text(direction)] = TRUE
	data["init_directions"] = init_directions
	return data

/obj/item/pipe_dispenser/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/playeffect = TRUE
	switch(action)
		if("color")
			paint_color = params["paint_color"]
		if("category")
			category = text2num(params["category"])
			switch(category)
				if(DISPOSALS_CATEGORY)
					recipe = first_disposal
				if(ATMOS_CATEGORY)
					recipe = first_atmos
				if(TRANSIT_CATEGORY)
					recipe = first_transit
			p_dir = NORTH
			playeffect = FALSE
		if("pipe_layers")
			var/selected_layers = text2num(params["pipe_layers"])
			var/valid_layer = FALSE
			for(var/pipe_layer_number in 1 to 5)
				if(!(PIPE_LAYER(pipe_layer_number) & selected_layers))
					continue
				valid_layer = TRUE
			if(!valid_layer)
				return
			if(multi_layer)
				if(pipe_layers != selected_layers)
					pipe_layers ^= selected_layers
			else
				pipe_layers = selected_layers
			playeffect = FALSE
		if("toggle_multi_layer")
			if(multi_layer)
				pipe_layers = PIPE_LAYER(max(get_active_pipe_layers()))
			multi_layer = !multi_layer
		if("ducting_layer")
			ducting_layer = text2num(params["ducting_layer"])
			playeffect = FALSE
		if("pipe_type")
			var/static/list/recipes
			if(!recipes)
				recipes = GLOB.disposal_pipe_recipes + GLOB.atmos_pipe_recipes + GLOB.transit_tube_recipes
			recipe = recipes[params["category"]][text2num(params["pipe_type"])]
			p_dir = NORTH
		if("setdir")
			p_dir = text2dir(params["dir"])
			p_flipped = text2num(params["flipped"])
			playeffect = FALSE
		if("mode")
			var/selected_mode = text2num(params["mode"])
			mode ^= selected_mode
		if("init_dir_setting")
			var/target_dir = p_init_dir ^ text2dir(params["dir_flag"])
			// Refuse to create a smart pipe that can only connect in one direction (it would act weirdly and lack an icon)
			if (ISNOTSTUB(target_dir))
				p_init_dir = target_dir
			else
				to_chat(usr, span_warning("\The [src]'s screen flashes a warning: Can't configure a pipe to only connect in one direction."))
				playeffect = FALSE
		if("init_reset")
			p_init_dir = ALL_CARDINALS
	if(playeffect)
		spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, FALSE)
	return TRUE

/obj/item/pipe_dispenser/pre_attack(atom/atom_to_attack, mob/user, params)
	if(!ISADVANCEDTOOLUSER(user) || istype(atom_to_attack, /turf/open/space/transit))
		return ..()

	if(istype(atom_to_attack, /obj/item/rpd_upgrade))
		install_upgrade(atom_to_attack, user)
		return TRUE

	var/atom/attack_target = atom_to_attack

	//So that changing the menu settings doesn't affect the pipes already being built.
	var/queued_pipe_dir = p_dir
	var/queued_pipe_flipped = p_flipped

	//Unwrench pipe before we build one over/paint it, but only if we're not already running a do_after on it already to prevent a potential runtime.
	if((mode & DESTROY_MODE) && (upgrade_flags & RPD_UPGRADE_UNWRENCH) && istype(attack_target, /obj/machinery/atmospherics) && !(DOING_INTERACTION_WITH_TARGET(user, attack_target)))
		attack_target = attack_target.wrench_act(user, src)
		if(!isatom(attack_target)) //can return null, FALSE if do_after() fails see /obj/machinery/atmospherics/wrench_act()
			return TRUE

	if(istype(attack_target, /obj/machinery/atmospherics) && (mode & BUILD_MODE))
		attack_target = get_turf(attack_target)

	var/can_make_pipe = check_can_make_pipe(attack_target)

	. = TRUE

	if((mode & DESTROY_MODE) && istype(attack_target, /obj/item/pipe) || istype(attack_target, /obj/structure/disposalconstruct) || istype(attack_target, /obj/structure/c_transit_tube) || istype(attack_target, /obj/structure/c_transit_tube_pod) || istype(attack_target, /obj/item/pipe_meter) || istype(attack_target, /obj/structure/disposalpipe/broken))
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
		playsound(get_turf(src), RPD_USE_SOUND, 50, TRUE)
		qdel(attack_target)
		return


			// Something else could have changed the target's state while we were waiting in do_after
			// Most of the edge cases don't matter, but atmos components being able to have live connections not described by initializable directions sounds like a headache at best and an exploit at worst

			// Double check to make sure that nothing has changed. If anything we were about to change was connected during do_after, abort

			// Grab the current initializable directions, which may differ from old_init_dir if someone else was working on the same pipe at the same time

			// Access p_init_dir directly. The RPD can change target layer and initializable directions (though not pipe type or dir) while working to dispense and connect a component,
			// and have it reflected in the final result. Reprogramming should be similarly consistent.

			// Don't make a smart pipe with only one connection

			// We're now reconfigured.
			// We can never disconnect from existing connections, but we can connect to previously unconnected directions, and should immediately do so

				// We're allowed to connect in new directions. Recompute our nodes
				// Disconnect from everything that is currently connected

				// Get our new connections

				// Connect to our new connections

			// Finally, update our internal state - update_pipe_icon also updates dir and connections


		// If this is an unplaced smart pipe, try to reprogram it


	if(mode & BUILD_MODE)
		switch(category) //if we've gotten this var, the target is valid
			if(ATMOS_CATEGORY) //Making pipes
				if(!do_pipe_build(attack_target, user, params))
					return ..()

			if(DISPOSALS_CATEGORY) //Making disposals pipes
				if(!can_make_pipe)
					return ..()
				attack_target = get_turf(attack_target)
				if(isclosedturf(attack_target))
					balloon_alert(user, "target is blocked!")
					return
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
				if(do_after(user, disposal_build_speed, target = attack_target))
					var/obj/structure/disposalconstruct/new_disposals_segment = new (attack_target, null, queued_pipe_dir, queued_pipe_flipped)

					if(!new_disposals_segment.can_place())
						balloon_alert(user, "not enough room!")
						qdel(new_disposals_segment)
						return

					playsound(get_turf(src), RPD_USE_SOUND, 50, TRUE)

					new_disposals_segment.add_fingerprint(usr)
					new_disposals_segment.update_appearance()
					if(mode & WRENCH_MODE)
						new_disposals_segment.wrench_act(user, src)
					return

			if(TRANSIT_CATEGORY) //Making transit tubes
				if(!can_make_pipe)
					return ..()
				attack_target = get_turf(attack_target)
				if(isclosedturf(attack_target))
					balloon_alert(user, "something in the way!")
					return

				var/turf/target_turf = get_turf(attack_target)
				if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
					balloon_alert(user, "something in the way!")
					return

				playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)

			else
				return ..()

/obj/item/pipe_dispenser/proc/check_can_make_pipe(atom/target_of_attack)
	//make sure what we're clicking is valid for the current category
	var/static/list/make_pipe_whitelist = typecacheof(list(/obj/structure/lattice, /obj/structure/girder, /obj/item/pipe, /obj/structure/window, /obj/structure/grille))
	var/can_we_make_pipe = (isturf(target_of_attack) || is_type_in_typecache(target_of_attack, make_pipe_whitelist))
	return can_we_make_pipe

/obj/item/pipe_dispenser/proc/do_pipe_build(atom/atom_to_target, mob/user, params)
	//So that changing the menu settings doesn't affect the pipes already being built.
	var/can_make_pipe = check_can_make_pipe(atom_to_target)
	var/list/pipe_layer_numbers = get_active_pipe_layers()
	var/continued_build = FALSE
	for(var/pipe_layer_num in 1 to length(pipe_layer_numbers))
		var/layer_to_build = pipe_layer_numbers[pipe_layer_num]
		if(layer_to_build != pipe_layer_numbers[1])
			continued_build = TRUE
		if(!layer_to_build)
			return FALSE
		if(!can_make_pipe)
			return FALSE
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, vary = TRUE)
		if(!continued_build && !do_after(user, atmos_build_speed, target = atom_to_target))
			return FALSE

		playsound(get_turf(src), RPD_USE_SOUND, 50, TRUE)
		if(recipe.type == /datum/pipe_info/meter)
			var/obj/item/pipe_meter/new_meter = new /obj/item/pipe_meter(get_turf(atom_to_target))
			new_meter.setAttachLayer(layer_to_build)
			if(mode & WRENCH_MODE)
				new_meter.wrench_act(user, src)
	return TRUE

/obj/item/pipe_dispenser/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/rpd_upgrade))
		install_upgrade(item, user)
		return TRUE
	return ..()

/// Installs an upgrade into the RPD after checking if it is already installed
/obj/item/pipe_dispenser/proc/install_upgrade(obj/item/rpd_upgrade/rpd_disk, mob/user)
	// Check if the upgrade's already present
	if(rpd_disk.upgrade_flags & upgrade_flags)
		balloon_alert(user, "already installed!")
		return
	// Adds the upgrade from the disk and then deletes the disk
	upgrade_flags |= rpd_disk.upgrade_flags
	playsound(loc, 'sound/machines/click.ogg', 50, vary = TRUE)
	balloon_alert(user, "upgrade installed")
	qdel(rpd_disk)

///Changes the piping layer when the mousewheel is scrolled up or down.
/obj/item/pipe_dispenser/proc/mouse_wheeled(mob/source_mob, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	if(multi_layer)
		balloon_alert(source_mob, "turn off multi layer!")
		return
	if(source_mob.incapacitated(IGNORE_RESTRAINTS|IGNORE_STASIS))
		return
	if(source_mob.get_active_held_item() != src)
		return

	if(delta_y < 0)
		pipe_layers = min(PIPE_LAYER(5), pipe_layers << 1)
	else if(delta_y > 0)
		pipe_layers = max(PIPE_LAYER(1), pipe_layers >> 1)
	else //mice with side-scrolling wheels are apparently a thing and fuck this up
		return
	SStgui.update_uis(src)
	balloon_alert(source_mob, "set pipe layer to [get_active_pipe_layers()[1]]")


/obj/item/rpd_upgrade
	name = "RPD advanced design disk"
	desc = "It seems to be empty."
//	icon = 'icons/obj/devices/circuitry_n_data.dmi' // MONKESTATION EDIT CHANGE OLD // REQUIRES PR #80025
	icon = 'icons/obj/module.dmi' // MONKESTATION EDIT CHANGE NEW
	icon_state = "datadisk3"
	/// Bitflags for upgrades
	var/upgrade_flags

/obj/item/rpd_upgrade/unwrench
	desc = "Adds reverse wrench mode to the RPD. Attention, due to budget cuts, the mode is hard linked to the destroy mode control button."
	upgrade_flags = RPD_UPGRADE_UNWRENCH

#undef ATMOS_CATEGORY
#undef DISPOSALS_CATEGORY
#undef TRANSIT_CATEGORY

#undef BUILD_MODE
#undef DESTROY_MODE
#undef WRENCH_MODE
#undef REPROGRAM_MODE

#undef PIPE_LAYER

#undef RPD_USE_SOUND
