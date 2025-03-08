/proc/init_sm_gas()
	var/list/gas_list = list()
	for (var/sm_gas_path in subtypesof(/datum/sm_gas))
		var/datum/sm_gas/sm_gas = new sm_gas_path
		gas_list[sm_gas.gas_path] = sm_gas
	return gas_list

/// Return a list info of the SM gases.
/// Can only run after init_sm_gas
/proc/sm_gas_data()
	var/list/data = list()
	for (var/gas_path in GLOB.sm_gas_behavior)
		var/datum/sm_gas/sm_gas = GLOB.sm_gas_behavior[gas_path]
		var/list/singular_gas_data = list()
		singular_gas_data["desc"] = sm_gas.desc

		// Positive is true if more of the amount is a good thing.
		var/list/numeric_data = list()
		if(sm_gas.power_transmission)
			numeric_data += list(list(
				"name" = "Power Transmission",
				"amount" = sm_gas.power_transmission,
				"positive" = TRUE,
			))
		if(sm_gas.heat_modifier)
			numeric_data += list(list(
				"name" = "Waste Multiplier",
				"amount" = sm_gas.heat_modifier,
				"positive" = FALSE,
			))
		if(sm_gas.heat_resistance)
			numeric_data += list(list(
				"name" = "Heat Resistance",
				"amount" = sm_gas.heat_resistance,
				"positive" = TRUE,
			))
		if(sm_gas.heat_power_generation)
			numeric_data += list(list(
				"name" = "Heat Power Gain",
				"amount" = sm_gas.heat_power_generation,
				"positive" = TRUE,
			))
		if(sm_gas.powerloss_inhibition)
			numeric_data += list(list(
				"name" = "Power Decay Negation",
				"amount" = sm_gas.powerloss_inhibition,
				"positive" = TRUE,
			))
		singular_gas_data["numeric_data"] = numeric_data
		data[gas_path] = singular_gas_data
	return data

/// Assoc of sm_gas_behavior[/datum/gas (path)] = datum/sm_gas (instance)
GLOBAL_LIST_INIT(sm_gas_behavior, init_sm_gas())

/// Contains effects of gases when absorbed by the sm.
/// If the gas has no effects you do not need to add another sm_gas subtype,
/// We already guard for nulls in [/obj/machinery/power/supermatter_crystal/proc/calculate_gases]
/datum/sm_gas
	/// Path of the [/datum/gas] involved with this interaction.
	var/gas_path

	/// Influences zap power without interfering with the crystal's own energy.
	var/power_transmission = 0
	/// How much more waste heat and gas the SM generates.
	var/heat_modifier = 0
	/// How extra hot the SM can run before taking damage
	var/heat_resistance = 0
	/// Lets the sm generate extra power from heat. Yeah...
	var/heat_power_generation = 0
	/// How much powerloss do we get rid of.
	var/powerloss_inhibition = 0
	/// Give a short description of the gas if needed. If the gas have extra effects describe it here.
	var/desc

/datum/sm_gas/proc/extra_effects(obj/machinery/power/supermatter_crystal/sm)
	return

/datum/sm_gas/oxygen
	power_transmission = 0.15
	heat_power_generation = 1

/datum/sm_gas/nitrogen
	heat_modifier = -2.5
	heat_power_generation = -1

/datum/sm_gas/carbon_dioxide
	heat_modifier = 1
	heat_power_generation = 1
	powerloss_inhibition = 1
	desc = "When absorbed by the Supermatter and exposed to oxygen, Pluoxium will be generated."

/// Can be on Oxygen or CO2, but better lump it here since CO2 is rarer.
/datum/sm_gas/carbon_dioxide/extra_effects(obj/machinery/power/supermatter_crystal/sm)


/datum/sm_gas/plasma

	heat_modifier = 14
	power_transmission = 0.4
	heat_power_generation = 1

/datum/sm_gas/water_vapor

	heat_modifier = 11
	power_transmission = -0.25
	heat_power_generation = 1

/datum/sm_gas/hypernoblium

	heat_modifier = -14
	power_transmission = 0.3
	heat_power_generation = -1

/datum/sm_gas/nitrous_oxide

	heat_resistance = 5

/datum/sm_gas/tritium

	heat_modifier = 9
	power_transmission = 3
	heat_power_generation = 1

/datum/sm_gas/bz
	heat_modifier = 4
	power_transmission = -0.2
	heat_power_generation = 1
	desc = "Will emit nuclear particles at compositions above 40%"

/// Start to emit radballs at a maximum of 30% chance per tick
/datum/sm_gas/bz/extra_effects(obj/machinery/power/supermatter_crystal/sm)


/datum/sm_gas/pluoxium

	heat_modifier = -1.5
	power_transmission = -0.5
	heat_power_generation = -1

/datum/sm_gas/miasma

	heat_power_generation = 0.5
	desc = "Will be consumed by the Supermatter to generate power."

///Miasma is really just microscopic particulate. It gets consumed like anything else that touches the crystal.
/datum/sm_gas/miasma/extra_effects(obj/machinery/power/supermatter_crystal/sm)


/datum/sm_gas/freon

	heat_modifier = -9
	power_transmission = -3
	heat_power_generation = -1

/datum/sm_gas/hydrogen

	heat_modifier = 9
	power_transmission = 2.5
	heat_resistance = 1
	heat_power_generation = 1

/datum/sm_gas/healium

	heat_modifier = 3
	power_transmission = 0.24
	heat_power_generation = 1

/datum/sm_gas/proto_nitrate

	heat_modifier = -4
	power_transmission = 1.5
	heat_resistance = 4
	heat_power_generation = 1

/datum/sm_gas/zauker

	heat_modifier = 7
	power_transmission = 2
	heat_power_generation = 1
	desc = "Will generate electrical zaps."

/datum/sm_gas/zauker/extra_effects(obj/machinery/power/supermatter_crystal/sm)

	playsound(sm.loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
	sm.supermatter_zap(
		sm,
		range = 6,
		zap_str = clamp(sm.internal_energy * 2, 4000, 20000),
		zap_flags = ZAP_MOB_STUN,
		zap_cutoff = sm.zap_cutoff,
		power_level = sm.internal_energy,
		zap_icon = sm.zap_icon
	)

/datum/sm_gas/antinoblium

	heat_modifier = 14
	power_transmission = -0.5
	heat_power_generation = 1
