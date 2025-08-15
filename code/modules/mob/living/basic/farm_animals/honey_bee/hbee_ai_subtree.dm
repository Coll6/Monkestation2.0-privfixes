/datum/ai_controller/basic_controller/honey_bee
	blackboard = list(
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/return_to_rally,
		/datum/ai_planning_subtree/find_valid_home/honeybee,
		/datum/ai_planning_subtree/find_and_hunt_target/hpollinate
	)

/datum/ai_controller/basic_controller/queen_honey_bee
	blackboard = list(
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home/honeybee,
		/datum/ai_planning_subtree/return_to_rally/queen,
	)

/datum/ai_planning_subtree/find_valid_home/honeybee

/datum/ai_planning_subtree/find_valid_home/honeybee/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return

	var/atom/current_home = controller.blackboard[BB_CURRENT_HOME] /// These bees treat their homes as rally points.
	if(QDELETED(current_home))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/hbee_hive, BB_CURRENT_HOME, /obj/structure/hbeebox)
		return

	var/atom/return_point = null
	if(istype(current_home, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = current_home
		if(controller.pawn in queen.bees)
			return
		return_point = queen.rally_point
	else
		return_point = current_home

	if(!istype(return_point, /obj/structure/hbeebox) || (controller.pawn in current_home.contents))
		return

	controller.queue_behavior(/datum/ai_behavior/inhabit_honeyhive, BB_CURRENT_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/return_to_rally
	///chance we go back home
	var/flyback_chance = 15
	///chance we exit the home
	var/exit_chance = 35

/datum/ai_planning_subtree/return_to_rally/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/current_home = controller.blackboard[BB_CURRENT_HOME]
	if(QDELETED(current_home))
		return

	var/mob/living/bee_pawn = controller.pawn
	var/atom/return_point = null
	if(istype(current_home, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = current_home
		return_point = queen.rally_point
	else
		return_point = current_home

	var/action_prob = 0
	if(istype(return_point, /obj/structure/hbeebox))
		action_prob =  (bee_pawn in return_point.contents) ? exit_chance : flyback_chance
	else
		action_prob =  (get_dist(bee_pawn, return_point) > 3) ? exit_chance : 0

	if(!SPT_PROB(action_prob, seconds_per_tick))
		return

	controller.queue_behavior(/datum/ai_behavior/rally_to_point, BB_CURRENT_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING

//the queen spend more time in the hive
/datum/ai_planning_subtree/return_to_rally/queen
	flyback_chance = 85
	exit_chance = 5

/datum/ai_planning_subtree/find_and_hunt_target/hpollinate
	target_key = BB_TARGET_HYDRO
	hunting_behavior = /datum/ai_behavior/hunt_target/hpollinate
	finding_behavior = /datum/ai_behavior/find_hunt_target/hpollinate
	hunt_targets = list(/obj/machinery/growing)
	hunt_range = 10
	hunt_chance = 85

/datum/ai_planning_subtree/find_and_hunt_target/hpollinate/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return

	var/atom/current_home = controller.blackboard[BB_CURRENT_HOME]
	if(QDELETED(current_home))
		return

	var/atom/return_point = null
	if(istype(current_home, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = current_home
		return_point = queen.rally_point
	else
		return_point = current_home

	if(istype(return_point, /obj/structure/hbeebox))
		return ..()
