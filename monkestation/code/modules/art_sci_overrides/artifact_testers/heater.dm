/obj/machinery/atmospherics/components/unary/artifact_heatingpad
	icon = 'goon/icons/obj/networked.dmi'
	icon_state = "pad_norm"

	name = "Heating Pad"
	desc = "Through some science bullcrap, this machine heats artifacts and people on top of it, without heating air, to the temperature of the gas contained. It will, in addition, heat its contents to 20C."
	density = FALSE
	max_integrity = 300

	set_dir_on_move = FALSE

	var/heat_capacity = 0

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/Initialize(mapload)
	. = ..()
	RefreshParts()
	update_appearance()

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/update_icon_state()
	..()

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/update_overlays()
	. = ..()


	// MONKESTATION EDIT END ART_SCI_OVERRIDE

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/RefreshParts()
	. = ..()
	var/calculated_bin_rating = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.tier
	heat_capacity = 5000 * ((calculated_bin_rating - 1) ** 2) //pointless but uhh yeah

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/process_atmos()
	if(panel_open)
		return


/obj/machinery/atmospherics/components/unary/artifact_heatingpad/screwdriver_act(mob/living/user, obj/item/tool)


/obj/machinery/atmospherics/components/unary/artifact_heatingpad/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = TOOL_ACT_TOOLTYPE_SUCCESS


/obj/machinery/atmospherics/components/unary/artifact_heatingpad/default_change_direction_wrench(mob/user, obj/item/item)
	if(!..())
		return FALSE

