/datum/round_event_control/antagonist/solo/from_ghosts/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/antagonist/solo/ghost/alien_infestation
	weight = 3
	max_occurrences = 1
	min_players = 35 //monkie edit: 10 to 35 (tg what the fuck)

	earliest_start = 60 MINUTES //monkie edit: 20 to 90
	//dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A xenomorph larva spawns on a random vent."

/datum/round_event_control/antagonist/solo/from_ghosts/alien_infestation/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE) //MONKESTATION ADDITION: fake_check = FALSE
	. = ..()
	if(!.)
		return .

	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			return FALSE

/datum/round_event/antagonist/solo/ghost/alien_infestation
	announce_when = 400
	fakeable = TRUE


/datum/round_event/antagonist/solo/ghost/alien_infestation/setup()
	announce_when = rand(announce_when, announce_when + 50)

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent

	if(!length(vents))
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return MAP_ERROR


	setup = TRUE //MONKESTATION ADDITION

/datum/round_event/antagonist/solo/ghost/alien_infestation/announce(fake)
	var/living_aliens = FALSE
	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			living_aliens = TRUE

	if(living_aliens || fake)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)
