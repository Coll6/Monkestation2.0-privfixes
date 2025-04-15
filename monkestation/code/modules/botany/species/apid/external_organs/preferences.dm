/datum/preference/choiced/apid_wings
	savefile_key = "feature_apid_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Apid wings"
	should_generate_icons = TRUE

/datum/preference/choiced/apid_wings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.moth_wings_list)

/datum/preference/choiced/apid_wings/icon_for(value)
	var/datum/sprite_accessory/apid_wings = SSaccessories.moth_wings_list[value]
	var/icon/final_icon = icon(apid_wings.icon, "m_apid_wings_[apid_wings.icon_state]_BEHIND")
	final_icon.Blend(icon(apid_wings.icon, "m_apid_wings_[apid_wings.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/apid_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_wings"] = value
/*
/datum/preference/choiced/apid_antenna
	savefile_key = "feature_apid_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Apid Antennae"
	should_generate_icons = TRUE

/datum/preference/choiced/apid_antenna/init_possible_values()
	return null //assoc_to_keys_features(SSaccessories.apid_antennae_list)

/datum/preference/choiced/apid_antenna/icon_for(value)
/*
	var/static/icon/apid_head

	if (isnull(apid_head))
		apid_head = icon('icons/mob/species/moth/bodyparts.dmi', "moth_head")
		apid_head.Blend(icon('icons/mob/species/human/human_face.dmi', "motheyes_l"), ICON_OVERLAY)
		apid_head.Blend(icon('icons/mob/species/human/human_face.dmi', "motheyes_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/antennae = SSaccessories.apid_antennae_list[value]

	var/icon/icon_with_antennae = new(apid_head)
	icon_with_antennae.Blend(icon(antennae.icon, "m_apid_antenna_[antennae.icon_state]_ADJ"), ICON_OVERLAY)
	icon_with_antennae.Scale(64, 64)
	icon_with_antennae.Crop(15, 64, 15 + 31, 64 - 31)

	return icon_with_antennae
*/

/datum/preference/choiced/apid_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_antenna"] = value
*/
