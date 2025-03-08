#define BASE_EVAPORATION_MULTIPLIER 10

/datum/round_event_control/scrubber_overflow
	shared_occurence_type = SHARED_SCRUBBERS

/datum/round_event/scrubber_overflow
	reagents_amount = 100
	var/evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER

/datum/round_event/scrubber_overflow/start()

/datum/round_event/scrubber_overflow/threatening
	reagents_amount = 150
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 1.5

/datum/round_event/scrubber_overflow/catastrophic
	reagents_amount = 200
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 2

/datum/round_event/scrubber_overflow/every_vent
	reagents_amount = 150
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 1.5

#undef BASE_EVAPORATION_MULTIPLIER
