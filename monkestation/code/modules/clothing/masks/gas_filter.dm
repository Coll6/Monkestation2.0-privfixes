/obj/item/gas_filter/clown
	name = "'enhanced' gas filter"
	desc = "A piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks. This one uses a highly guarded formula to let small amounts of certain gasses through."
	icon_state = "gas_atmos_filter_clown"

	///List of gases with high filter priority
	high_filtering_gases = list(

		)
	///List of gases with medium filter priority
	mid_filtering_gases = list(

		)


/obj/item/gas_filter/clown/reduce_filter_status(datum/gas_mixture/breath)
	breath = ..()
	var/danger_points = 0
	var/const/HIGH_FILTERING_RATIO = 0.001


	filter_status = max(filter_status - danger_points, 0)
	return breath
