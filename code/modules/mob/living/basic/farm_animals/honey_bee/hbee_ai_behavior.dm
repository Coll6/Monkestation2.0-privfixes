/datum/ai_behavior/hunt_target/hpollinate
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/hpollinate/target_caught(mob/living/hunter, atom/movable/hydro_target)
	var/datum/callback/callback = CALLBACK(hunter, TYPE_PROC_REF(/mob/living/basic/honey_bee, pollinate), hydro_target)
	callback.Invoke()

/datum/ai_behavior/find_hunt_target/hpollinate

/datum/ai_behavior/find_hunt_target/hpollinate/valid_dinner(mob/living/source, atom/movable/dinner, radius)
	if(SEND_SIGNAL(dinner, COMSIG_GROWER_CHECK_POLLINATED))
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_behavior/rally_to_point
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/rally_to_point/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	var/atom/return_point = null
	if(istype(target, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = target
		return_point = queen.rally_point

	!isnull(return_point) ? set_movement_target(controller, return_point) : set_movement_target(controller, target)

/datum/ai_behavior/rally_to_point/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/current_home = controller.blackboard[target_key]
	var/mob/living/bee_pawn = controller.pawn

	var/atom/return_point = null
	if(istype(current_home, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = current_home
		return_point = queen.rally_point
	else
		return_point = current_home

	if(istype(return_point, /obj/structure/hbeebox))
		var/datum/callback/callback = CALLBACK(bee_pawn, TYPE_PROC_REF(/mob/living/basic/honey_bee, handle_habitation), return_point)
		callback.Invoke()
	finish_action(controller, TRUE)

/datum/ai_behavior/inhabit_honeyhive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/inhabit_honeyhive/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	var/atom/return_point = null
	if(istype(target, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = target
		return_point = queen.rally_point

	!isnull(return_point) ? set_movement_target(controller, return_point) : set_movement_target(controller, target)

/datum/ai_behavior/inhabit_honeyhive/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]

	var/atom/return_point = null
	if(istype(target, /mob/living/basic/honey_bee/queen))
		var/mob/living/basic/honey_bee/queen/queen = target
		return_point = queen.rally_point
	else
		return_point = target

	var/obj/structure/hbeebox/potential_home = return_point
	if(!istype(potential_home))
		finish_action(controller, FALSE, target_key)

	var/mob/living/bee_pawn = controller.pawn
	if(!potential_home.habitable(bee_pawn)) //the house become full before we get to it
		finish_action(controller, FALSE, target_key)
		return

	var/datum/callback/callback = CALLBACK(bee_pawn, TYPE_PROC_REF(/mob/living/basic/honey_bee, handle_habitation), potential_home)
	callback.Invoke()
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/inhabit_honeyhive/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key) //failed to make it our home so find another

/datum/ai_behavior/find_and_set/hbee_hive
	action_cooldown = 10 SECONDS

/datum/ai_behavior/find_and_set/hbee_hive/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	if(!istype(controller.pawn, /mob/living/basic/honey_bee))
		return
	var/list/valid_hives = list()
	var/mob/living/basic/honey_bee/bee_pawn = controller.pawn

	if(istype(bee_pawn.loc, /obj/structure/hbeebox))
		valid_hives = bee_pawn.loc
	else
		for(var/obj/structure/hbeebox/potential_home in oview(search_range, bee_pawn))
			if(!potential_home.habitable(bee_pawn))
				continue
			valid_hives += potential_home

	if(length(valid_hives))
		if(bee_pawn.is_queen)
			return pick(valid_hives)
		else
			var/obj/structure/hbeebox/current_box = pick(valid_hives)
			return current_box.queen_bee
