/datum/ai_controller/basic_controller/honey_bee
	blackboard = list(
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home/honeybee,
	)

/datum/ai_controller/basic_controller/queen_honey_bee
	blackboard = list(
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home/honeybee,
		//datum/ai_planning_subtree/enter_exit_home/hqueen,
	)

/datum/ai_planning_subtree/find_valid_home/honeybee

/datum/ai_planning_subtree/find_valid_home/honeybee/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/current_home = controller.blackboard[BB_CURRENT_HOME] /// These bees treat their homes as rally points.
	if(QDELETED(current_home))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/hbee_hive, BB_CURRENT_HOME, /obj/structure/hbeebox)
		return

	if(!istype(current_home, /obj/structure/hbeebox) || (controller.pawn in current_home.contents))
		return

	controller.queue_behavior(/datum/ai_behavior/inhabit_honeyhive, BB_CURRENT_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING
