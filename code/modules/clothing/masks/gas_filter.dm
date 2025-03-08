///Filtering ratio for high amounts of gas
#define HIGH_FILTERING_RATIO 0.001
///Filtering ratio for min amount of gas
#define LOW_FILTERING_RATIO 0.0005
///Min amount of high filtering gases for high filtering ratio
#define HIGH_FILTERING_MOLES 0.001
///Min amount of mid filtering gases for high filtering ratio
#define MID_FILTERING_MOLES 0.0025
///Min amount of low filtering gases for high filtering ratio
#define LOW_FILTERING_MOLES 0.0005
///Min amount of wear that the filter gets when used
#define FILTERS_CONSTANT_WEAR 0.05

/obj/item/gas_filter
	name = "atmospheric gas filter"
	desc = "A piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_atmos_filter"
	w_class = WEIGHT_CLASS_TINY
	///Amount of filtering points available
	var/filter_status = 100
	///strength of the filter against high filtering gases
	var/filter_strength_high = 10
	///strength of the filter against mid filtering gases
	var/filter_strength_mid = 8
	///strength of the filter against low filtering gases
	var/filter_strength_low = 5
	///General efficiency of the filter (between 0 and 1)
	var/filter_efficiency = 0.5

	///List of gases with high filter priority
	var/list/high_filtering_gases = list(

		)
	///List of gases with medium filter priority
	var/list/mid_filtering_gases = list(

		)
	///List of gases with low filter priority
	var/list/low_filtering_gases = list(

		)

/obj/item/gas_filter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] is at <b>[filter_status]%</b> durability.</span>"

/**
 * called by the gas mask where the filter is installed, lower the filter_status depending on the breath gas composition and by the strength of the filter
 * returns the modified breath gas mixture
 *
 * Arguments:
 * * breath - the current gas mixture of the breathed air
 *
 */
/obj/item/gas_filter/proc/reduce_filter_status(datum/gas_mixture/breath)
	return

/obj/item/gas_filter/damaged
	name = "damaged gas filter"
	desc = "A piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks, it seems damaged."
	filter_status = 50 //override on initialize

/obj/item/gas_filter/damaged/Initialize(mapload)
	. = ..()
	filter_status = rand(35, 65)

/obj/item/gas_filter/plasmaman
	name = "plasmaman atmospheric gas filter"
	high_filtering_gases = list(

		)

#undef HIGH_FILTERING_MOLES
#undef HIGH_FILTERING_RATIO
#undef LOW_FILTERING_MOLES
#undef LOW_FILTERING_RATIO
#undef MID_FILTERING_MOLES
#undef FILTERS_CONSTANT_WEAR
