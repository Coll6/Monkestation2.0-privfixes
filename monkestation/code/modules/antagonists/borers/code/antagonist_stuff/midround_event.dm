/// How many people do we need per borer spawned
#define POP_PER_BORER 30

/datum/round_event_control/antagonist/solo/from_ghosts/cortical_borer
	name = "Cortical Borer Infestation"
	tags = list(TAG_TEAM_ANTAG, TAG_EXTERNAL, TAG_ALIEN, TAG_OUTSIDER_ANTAG)
	typepath = /datum/round_event/ghost_role/cortical_borer
	antag_flag = ROLE_CORTICAL_BORER
	track = EVENT_TRACK_MAJOR
	enemy_roles = list(
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_MEDICAL_DOCTOR,
		JOB_CHEMIST,
		JOB_BRIG_PHYSICIAN,
	)
	required_enemies = 2
	weight = 5 // as rare as a natural blob
	min_players = 20
	max_occurrences = 1 //should only ever happen once
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A cortical borer has appeared on station. It will also attempt to produce eggs, and will attempt to gather willing hosts and learn chemicals through the blood."

/datum/round_event/ghost_role/cortical_borer
	announce_when = 400

/datum/round_event/ghost_role/cortical_borer/setup()
	announce_when = rand(announce_when, announce_when + 50)
	setup = TRUE

/datum/round_event/ghost_role/cortical_borer/announce(fake)
	priority_announce(
		"Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.",
		"Lifesign Alert",
		ANNOUNCER_ALIENS,
	)

/datum/round_event/ghost_role/cortical_borer/start()

/datum/dynamic_ruleset/midround/from_ghosts/cortical_borer
	name = "Cortical Borer Infestation"
	antag_datum = /datum/antagonist/cortical_borer
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_flag = ROLE_CORTICAL_BORER
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
	)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 20
	minimum_players = 10
	/// List of on-station vents
	var/list/vents = list()

/datum/dynamic_ruleset/midround/from_ghosts/cortical_borer/execute()


/datum/dynamic_ruleset/midround/from_ghosts/cortical_borer/generate_ruleset_body(mob/applicant)
	var/obj/vent = pick_n_take(vents)
	var/mob/living/basic/cortical_borer/new_borer = new(vent.loc)
	new_borer.key = applicant.key
	new_borer.move_into_vent(vent)
	message_admins("[ADMIN_LOOKUPFLW(new_borer)] has been made into a borer by the midround ruleset.")
	log_game("DYNAMIC: [key_name(new_borer)] was spawned as a borer by the midround ruleset.")
	return new_borer

#undef POP_PER_BORER
