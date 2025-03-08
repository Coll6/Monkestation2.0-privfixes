/obj/machinery/atmospherics/components/unary/chemical_infuser
	name = "chemical infuser"
	desc = "An afront to both chemists and atmospheric technicans."

	layer = BELOW_OBJ_LAYER

	icon_state = "reaction_chamber"
	icon = 'icons/obj/plumbing/plumbers.dmi'



	var/static/list/chemical_infuser_recipes = list()
	var/datum/chemical_infuser_recipe/chosen_recipe
	var/processing = FALSE

/obj/machinery/atmospherics/components/unary/chemical_infuser/Initialize(mapload)
	. = ..()
	create_reagents(1000, TRANSPARENT)
	AddComponent(/datum/component/plumbing/chemical_infuser)



/obj/machinery/atmospherics/components/unary/chemical_infuser/ui_interact(mob/user, datum/tgui/ui)
	if(!length(chemical_infuser_recipes))
		create_recipes()
	chosen_recipe = tgui_input_list(user, "Choose a recipe to focus on.", name, chemical_infuser_recipes)

/obj/machinery/atmospherics/components/unary/chemical_infuser/proc/create_recipes()
	for(var/datum/chemical_infuser_recipe/new_recipes as anything in subtypesof(/datum/chemical_infuser_recipe))
		chemical_infuser_recipes += new new_recipes

/obj/machinery/atmospherics/components/unary/chemical_infuser/examine(mob/user)
	. = ..()


/obj/machinery/atmospherics/components/unary/chemical_infuser/process_atmos()
	if(!chosen_recipe)
		return

	var/passes_all_chemicals = TRUE
	for(var/datum/reagent/reagent as anything in chosen_recipe.required_reagents)
		var/amount = reagents.get_reagent_amount(reagent)
		if(amount < chosen_recipe.required_reagents[reagent])
			passes_all_chemicals = FALSE
			break
	if(!passes_all_chemicals)
		return

	if(!processing)
		playsound(get_turf(src), 'sound/effects/bubbles2.ogg', 25, TRUE)
		var/list/seen = viewers(4, get_turf(src))
		var/iconhtml = icon2html(src, seen)
		audible_message(span_notice("[iconhtml] The solution bubbles fiercely!"))
		addtimer(CALLBACK(src, PROC_REF(create_recipe)), 7 SECONDS)
		processing = TRUE

/obj/machinery/atmospherics/components/unary/chemical_infuser/proc/create_recipe()
	processing = FALSE


/datum/component/plumbing/chemical_infuser
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/chemical_infuser/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()
	if(!istype(parent, /obj/machinery/atmospherics/components/unary/chemical_infuser))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/chemical_infuser/can_give(amount, reagent, datum/ductnet/net)
	. = ..()
	var/obj/machinery/plumbing/reaction_chamber/reaction_chamber = parent
	if(!. || !reaction_chamber.emptying || reagents.is_reacting == TRUE)
		return FALSE

/datum/component/plumbing/chemical_infuser/send_request(dir)
	var/obj/machinery/atmospherics/components/unary/chemical_infuser/chamber = parent
	if(!chamber.chosen_recipe)
		return

	for(var/required_reagent in chamber.chosen_recipe.required_reagents)
		var/has_reagent = FALSE
		for(var/datum/reagent/containg_reagent as anything in reagents.reagent_list)
			if(required_reagent == containg_reagent.type)
				has_reagent = TRUE
				if(containg_reagent.volume + CHEMICAL_QUANTISATION_LEVEL < chamber.chosen_recipe.required_reagents[required_reagent])
					process_request(min(chamber.chosen_recipe.required_reagents[required_reagent] - containg_reagent.volume, MACHINE_REAGENT_TRANSFER) , required_reagent, dir)
					return
		if(!has_reagent)
			process_request(min(chamber.chosen_recipe.required_reagents[required_reagent], MACHINE_REAGENT_TRANSFER), required_reagent, dir)
			return
