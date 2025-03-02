/datum/controller/subsystem/job
	/// Assoc list of new players keyed to the type of job they will currently get
	var/list/assigned_players_by_job = list()
	/// Nested assoc list of job types with values of lists of players who are viable for that job, keyed to what priority level that player has the job set to in their prefs
	var/list/assignable_by_job = list()

/// Handle all the stuff for temp assignments at round start job selection
/datum/controller/subsystem/job/proc/handle_temp_assignments(mob/dead/new_player/player, datum/job/job)
	if(!player ||!player.mind || !job)
		return FALSE

	unassigned -= player
	if(!assigned_players_by_job[job.type])
		assigned_players_by_job[job.type] = list()

	if(player.temp_assignment)
		assigned_players_by_job[player.temp_assignment.type] -= player
		player.temp_assignment.current_positions--

	assigned_players_by_job[job.type] += player
	player.temp_assignment = job
	job.current_positions++
	JobDebug("h_t_a pass, Player: [player], Job: [job]")
	return TRUE

/// Handle antags as well as assigning people to their jobs
/datum/controller/subsystem/job/proc/handle_final_setup()
	var/sanity = 0
	var/max_sane_loops = length(subtypesof(/datum/round_event_control/antagonist/solo) - typesof(/datum/round_event_control/antagonist/solo/from_ghosts)) //not exact, but its close enough
	pick_desired_roundstart()
	while(!handle_roundstart_antags() && !sanity >= max_sane_loops)
		sanity++
		pick_desired_roundstart()
		CHECK_TICK

	for(var/job in assigned_players_by_job)
		for(var/mob/dead/new_player/player in assigned_players_by_job[job])
			AssignRole(player, GetJobType(job), do_eligibility_checks = FALSE)
			assigned_players_by_job[job] -= player

	assigned_players_by_job = list()
	assignable_by_job = list()
	log_storyteller("h_f_s pass")

/datum/controller/subsystem/job/proc/handle_roundstart_antags()


/// Try and reassign the job of input player and return based on if we succeed or not, if need_new_enemy is passed then we will return FALSE if we cant find someone else to be an enemy
/datum/controller/subsystem/job/proc/try_reassign_job(mob/dead/new_player/player, list/enemy_jobs = list(), list/restricted_jobs = list(), need_new_enemy = FALSE, list/enemy_players)
	if(!GiveRandomJob(player, TRUE, enemy_jobs + restricted_jobs) && !handle_temp_assignments(player, GetJobType(overflow_role)))
		log_storyteller("t_r_j failed, we were unable to give the reassigned player a new job, Player: [player]")
		return FALSE

	if(need_new_enemy)
		var/mob/dead/new_player/new_enemy_player
		for(var/datum/job/enemy_job in enemy_jobs)
			if(new_enemy_player)
				break
			if(!assignable_by_job[enemy_job.type])
				continue
			for(var/level in level_order)
				if(new_enemy_player)
					break
				var/list/antag_mobs = list()
				for(var/mob/dead/new_player/possible_enemy in shuffle(assignable_by_job[enemy_job.type]["[level]"] - antag_mobs - enemy_players))
					new_enemy_player = possible_enemy
					handle_temp_assignments(new_enemy_player, enemy_job)
					break
		if(!new_enemy_player)
			log_storyteller("t_r_j failed, we were unable to find someone to replace the enemy role of the reassigned player, Player: [player]")
			return FALSE
	return TRUE

//// Attempt to pick a roundstart ruleset to be our desired ruleset
/datum/controller/subsystem/job/proc/pick_desired_roundstart()

	var/static/list/valid_rolesets
	if(!valid_rolesets)
		valid_rolesets = list()

	log_storyteller("p_d_r valid_rolesets", list("rolesets" = english_list(valid_rolesets)))
	var/player_count = 0
	for(var/job in assigned_players_by_job)
		player_count += length(assigned_players_by_job[job])

	var/list/actual_valid_rolesets = list()
	for(var/datum/round_event_control/antagonist/solo/roleset in valid_rolesets)

	valid_rolesets = actual_valid_rolesets
	log_storyteller("p_d_r actual_valid_rolesets", list("rolesets" = english_list(actual_valid_rolesets)))


	if(!length(valid_rolesets))
		log_storyteller("p_d_r failed, no valid_rolesets")
		return

///trys to free up a job slot via the rank
/datum/controller/subsystem/job/proc/FreeRole(rank)
	if(!rank)
		return
	JobDebug("Freeing role: [rank]")
	var/datum/job/job = GetJob(rank)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)
