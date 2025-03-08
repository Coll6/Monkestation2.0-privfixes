#define DAMAGED_LUBRICANT_SYSTEM (1<<0)

//node2, air2, network2 correspond to input
//node1, air1, network1 correspond to output

/obj/machinery/atmospherics/components/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon = 'goon/icons/teg.dmi'
	icon_state = "circ1-off"

	density = TRUE
	circuit = /obj/item/circuitboard/machine/circulator

	var/active = FALSE
	var/last_pressure_delta = 0
	var/flipped = 0
	///Which circulator mode we are on, the generator requires one of each to work.
	var/mode = CIRCULATOR_HOT
	///The generator we are connected to.
	var/obj/machinery/power/thermoelectric_generator/generator

	///our reagent buffer
	var/reagent_buffer = 400
	///our list of reagents and how good they are as lubricant (this is independant of viscosity as it can be changed by teg states)
	var/list/liked_lubricants = list(
		/datum/reagent/fuel/oil = 1,
		/datum/reagent/lube = 1.2,
		/datum/reagent/lube/superlube = 1.4
	)
	///our list of bad reagents (these damage the lubrication system)
	var/list/bad_reagents = list(
		/datum/reagent/toxin/acid = 10,
		/datum/reagent/toxin/acid/fluacid = 10,
		/datum/reagent/toxin/acid/nitracid = 10,
	)
	///our lubrication multiplier
	var/lubricated_multiplier = 1
	///our current circulator flags
	var/circulator_flags = NONE
	///this is the amount of reagent loss we have per lube check
	var/lubricant_loss = 0
	///process count for lube checks (maybe timer in the future?)
	var/lube_processes = 0
	///how many lube processes we have left
	var/lube_process_count = 0

/obj/machinery/atmospherics/components/binary/circulator/Initialize(mapload)
	. = ..()
	create_reagents(reagent_buffer)
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))
	reagents.add_reagent(/datum/reagent/fuel/oil, 200)

//default cold circ for mappers
/obj/machinery/atmospherics/components/binary/circulator/cold
	icon_state = "circ2-off"
	flipped = 1
	mode = CIRCULATOR_COLD

/obj/machinery/atmospherics/components/binary/circulator/Destroy()
	if(generator)
		disconnectFromGenerator()
	return ..()

/obj/machinery/atmospherics/components/binary/circulator/proc/on_reagent_change(datum/reagents/incoming_reagents, ...)
	var/recalculated_lubricant_multiplier = 0

	if(!reagents.total_volume)
		recalculated_lubricant_multiplier = 0.5
	else
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			if(reagent.type in liked_lubricants)
				recalculated_lubricant_multiplier += (reagent.volume / reagents.total_volume) * liked_lubricants[reagent.type]
			else
				recalculated_lubricant_multiplier += (reagent.volume / reagents.total_volume) * (0.2 * reagent.viscosity + 0.75)
	lubricated_multiplier = recalculated_lubricant_multiplier


/obj/machinery/atmospherics/components/binary/circulator/proc/return_transfer_air()



/obj/machinery/atmospherics/components/binary/circulator/proc/reagent_effects(datum/gas_mixture/removed)
	if(!reagents.total_volume)
		return

	var/temperature_change = 0

	if(!(circulator_flags & DAMAGED_LUBRICANT_SYSTEM)) //if we aren't damaged check our lubricant storage for bad lubricants
		var/total_reagents = 0
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			if(!(reagent.type in bad_reagents))
				continue
			if(reagent.volume >= bad_reagents[reagent.type])
				total_reagents += reagent.volume
		if(total_reagents && prob(10 * (total_reagents * 0.1))) //100 units of reagents will surely break your shit
			circulator_flags |= DAMAGED_LUBRICANT_SYSTEM
			lubricant_loss = reagent_buffer * 0.2
			lube_processes = 1

	if(!removed)
		return

	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		reagent.circulator_process(src, removed)

	if(reagents.has_reagent(/datum/reagent/cryostylane))
		temperature_change -= 200
		if(prob(3))
			visible_message(span_warning("You notice a thin layer of frost form on the [src]!"))

	if(reagents.has_reagent(/datum/reagent/pyrosium))
		temperature_change += 200
		if(prob(3))
			visible_message(span_warning("You notice the [src] looks to be briefly covered in haze!"))



/obj/machinery/atmospherics/components/binary/circulator/process_atmos()
	update_appearance()

/obj/machinery/atmospherics/components/binary/circulator/update_icon_state()
	if(!is_operational)
		icon_state = "circ[flipped+1]-p"
		return ..()
	if(last_pressure_delta > 0)
		if(last_pressure_delta > ONE_ATMOSPHERE)
			icon_state = "circ[flipped+1]-run"
		else
			icon_state = "circ[flipped+1]-slow"
		return ..()

	icon_state = "circ[flipped+1]-off"
	return ..()

/obj/machinery/atmospherics/components/binary/circulator/update_overlays()
	. = ..()
	if(active)
		.+= emissive_appearance(icon, "[icon_state]-emissive", src)

/obj/machinery/atmospherics/components/binary/circulator/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open the panel!")
		return
	var/turf/open/turf = get_turf(get_step(src, NORTH))
	if(!isopenturf(turf))
		return
	balloon_alert(user, "You drain the lubricant tank.")
	turf.add_liquid_from_reagents(reagents)
	reagents.remove_all(reagent_buffer)

/obj/machinery/atmospherics/components/binary/circulator/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		balloon_alert(user, "open the panel!")
		return
	set_anchored(!anchored)
	I.play_tool_sound(src)
	if(generator)
		disconnectFromGenerator()
	balloon_alert(user, "[anchored ? "secure" : "unsecure"]")

	return TRUE





/obj/machinery/atmospherics/components/binary/circulator/multitool_act(mob/living/user, obj/item/I)
	if(generator)
		disconnectFromGenerator()
	mode = !mode
	if(mode)
		flipped = TRUE
	else
		flipped = FALSE
	balloon_alert(user, "set to [mode ? "cold" : "hot"]")
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/screwdriver_act(mob/user, obj/item/I)
	if(!anchored)
		balloon_alert(user, "anchor it down!")
		return
	toggle_panel_open()
	I.play_tool_sound(src)
	balloon_alert(user, "panel [panel_open ? "open" : "closed"]")
	if(panel_open)
		reagents.flags |= (TRANSPARENT | OPENCONTAINER)
	else
		reagents.flags &= ~(TRANSPARENT | OPENCONTAINER)
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/obj/machinery/atmospherics/components/binary/circulator/on_deconstruction()
	if(generator)
		disconnectFromGenerator()

/obj/machinery/atmospherics/components/binary/circulator/proc/disconnectFromGenerator()
	if(mode)
		generator.cold_circ = null
	else
		generator.hot_circ = null
	generator.update_appearance()
	generator = null


