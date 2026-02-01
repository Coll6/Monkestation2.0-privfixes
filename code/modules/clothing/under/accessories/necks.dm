/obj/item/clothing/accessory/scryer
	name = "\improper MODlink scryer"
	icon_state = "plasma"
	inhand_icon_state = "" //self deletes if removed from clothing
	desc = "A MODlink Scryer that someone modified to attach to their clothes."
	attachment_slot = NECK

	var/obj/item/clothing/neck/link_scryer/scryer // The scryer that this accessory is imitating.

/obj/item/clothing/accessory/scryer/Initialize(mapload)
	. = ..()
