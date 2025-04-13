/datum/preference/choiced/arachnid_appendages
	savefile_key = "feature_arachnid_appendages"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Arachnid Appendages"
	should_generate_icons = TRUE

/datum/preference/choiced/arachnid_appendages/init_possible_values()
	return SSaccessories.arachnid_appendages_list

/datum/preference/choiced/arachnid_appendages/icon_for(value)
	var/datum/sprite_accessory/arachnid_appendages = SSaccessories.arachnid_appendages_list[value]
	var/icon/final_icon = icon(arachnid_appendages.icon, "m_arachnid_appendages_[arachnid_appendages.icon_state]_BEHIND")
	final_icon.Blend(icon(arachnid_appendages.icon, "m_arachnid_appendages_[arachnid_appendages.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/arachnid_appendages/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arachnid_appendages"] = value

/datum/preference/choiced/arachnid_chelicerae
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "feature_arachnid_chelicerae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Arachnid Chelicerae"
	should_generate_icons = TRUE

/datum/preference/choiced/arachnid_chelicerae/init_possible_values()
	return SSaccessories.arachnid_chelicerae_list

/datum/preference/choiced/arachnid_chelicerae/icon_for(value)
	var/datum/sprite_accessory/arachnid_chelicerae = SSaccessories.arachnid_chelicerae_list[value]
	var/icon/final_icon = icon(arachnid_chelicerae.icon, "m_arachnid_chelicerae_[arachnid_chelicerae.icon_state]_BEHIND")
	final_icon.Blend(icon(arachnid_chelicerae.icon, "m_arachnid_chelicerae_[arachnid_chelicerae.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/tail_avian/icon_for(value)
	var/datum/sprite_accessory/tail_avian = SSaccessories.tails_list_avian[value]
	var/icon/final_icon = icon(tail_avian.icon, "m_tail_avian_[tail_avian.icon_state]_BEHIND")
	final_icon.Blend(icon(tail_avian.icon, "m_tail_avian_[tail_avian.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/arachnid_chelicerae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arachnid_chelicerae"] = value
