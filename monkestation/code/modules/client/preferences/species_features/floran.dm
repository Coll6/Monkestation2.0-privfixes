/datum/preference/choiced/floran_leaves
	savefile_key = "feature_floran_leaves"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Floran Leaves"
	should_generate_icons = TRUE

/datum/preference/choiced/floran_leaves/init_possible_values()
	return assoc_to_keys_features(SSaccessories.floran_leaves_list)

/datum/preference/choiced/floran_leaves/icon_for(value)
	var/datum/sprite_accessory/floran_leaves = SSaccessories.floran_leaves_list[value]
	var/icon/final_icon = icon(floran_leaves.icon, "m_floran_leaves_[floran_leaves.icon_state]_ADJ")
	return final_icon

/datum/preference/choiced/floran_leaves/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["floran_leaves"] = value
