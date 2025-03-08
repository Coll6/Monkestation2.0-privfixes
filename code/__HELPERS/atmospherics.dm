/*
/proc/molar_cmp_less_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (a < (b + epsilon))

/proc/molar_cmp_greater_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return ((a + epsilon) > b)

/proc/molar_cmp_equals(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (((a + epsilon) > b) && ((a - epsilon) < b))
*/
/** A simple rudimentary gasmix to information list converter. Can be used for UIs.
 * Args:
 * * gasmix: [/datum/gas_mixture]
 * * name: String used to name the list, optional.
 * Returns: A list parsed_gasmixes with the following structure:
 * - parsed_gasmixes    Value: Assoc List     Desc: The thing we return
 * -- Key: name         Value: String         Desc: Gasmix Name
 * -- Key: temperature  Value: Number         Desc: Temperature in kelvins
 * -- Key: volume       Value: Number         Desc: Volume in liters
 * -- Key: pressure     Value: Number         Desc: Pressure in kPa
 * -- Key: ref          Value: String         Desc: The reference for the instantiated gasmix.
 * -- Key: gases        Value: Numbered list  Desc: List of gasses in our gasmix
 * --- Key: 1           Value: String         Desc: gas id var from the gas
 * --- Key: 2           Value: String         Desc: Human readable gas name.
 * --- Key: 3           Value: Number         Desc: Mol amount of the gas.
 * -- Key: gases        Value: Numbered list  Desc: Assoc list of reactions that occur inside.
 * --- Key: 1           Value: String         Desc: reaction id var from the gas.
 * --- Key: 2           Value: String         Desc: Human readable reaction name.
 * --- Key: 3           Value: Number         Desc: The number associated with the reaction.
 * Returned list should always be filled with keys even if value are nulls.
 */
/proc/gas_mixture_parser(datum/gas_mixture/gasmix, name)
	. = list(
		"gases" = list(),
		"reactions" = list(),
		"name" = format_text(name),
		"total_moles" = null,
		"temperature" = null,
		"volume"= null,
		"pressure"= null,
		"reference" = null,
	)
	if(!gasmix)
		return

GLOBAL_LIST_EMPTY(reaction_handbook)
GLOBAL_LIST_EMPTY(gas_handbook)

/// Automatically populates gas_handbook and reaction_handbook. They are formatted lists containing information regarding gases and reactions they participate in.
/// Structure can be found in TS form at AtmosHandbook.tsx
/proc/atmos_handbooks_init()
	if(length(GLOB.reaction_handbook))
		GLOB.reaction_handbook = list()
	if(length(GLOB.gas_handbook))
		GLOB.gas_handbook = list()

	/// Final product is a numbered list, this one is assoc just so we can generate the "reactions" entry easily.

/// Returns an assoc list of the gas handbook and the reaction handbook.
/// For UIs, simply do data += return_atmos_handbooks() to use.
/proc/return_atmos_handbooks()
	return list("gasInfo" = GLOB.gas_handbook, "reactionInfo" = GLOB.reaction_handbook)

/proc/extract_id_tags(list/objects)
	var/list/tags = list()

	for (var/obj/object as anything in objects)
		tags += object.id_tag

	return tags

/proc/find_by_id_tag(list/objects, id_tag)
	for (var/obj/object as anything in objects)
		if (object.id_tag == id_tag)
			return object

	return null

/**
 * A simple helped proc that checks if the contents of a list of gases are within acceptable terms.
 *
 * Arguments:
 * * gases: The list of gases which contents are being checked
 * * gases to check: An associated list of gas types and acceptable boundaries in moles. e.g. /datum/gas/oxygen = list(16, 30)
 * * * if the assoc list is null, then it'll be considered a safe gas and won't return FALSE.
 * * extraneous_gas_limit: If a gas not in gases is found, this is the limit above which the proc will return FALSE.
 */
/proc/check_gases(list/gases, list/gases_to_check, extraneous_gas_limit = 0.1)
	gases_to_check = gases_to_check.Copy()
	for(var/id in gases)
		var/gas_moles = gases[id][MOLES]
		if(!(id in gases_to_check))
			if(gas_moles > extraneous_gas_limit)
				return FALSE
			continue
		var/list/boundaries = gases_to_check[id]
		if(boundaries && !ISINRANGE(gas_moles, boundaries[1], boundaries[2]))
			return FALSE
		gases_to_check -= id
	///Check that gases absent from the turf have a lower boundary of zero or none at all, otherwise return FALSE
	for(var/id in gases_to_check)
		var/list/boundaries = gases_to_check[id]
		if(boundaries && boundaries[1] > 0)
			return FALSE
	return TRUE
