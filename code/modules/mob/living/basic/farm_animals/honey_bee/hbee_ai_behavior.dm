/datum/ai_behavior/inhabit_honeyhive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/inhabit_honeyhive/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/inhabit_honeyhive/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/structure/hbeebox/potential_home = controller.blackboard[target_key]
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
	var/list/valid_hives = list()
	var/mob/living/bee_pawn = controller.pawn

	if(istype(bee_pawn.loc, /obj/structure/hbeebox))
		return bee_pawn.loc //for premade homes

	for(var/obj/structure/hbeebox/potential_home in oview(search_range, bee_pawn))
		if(!potential_home.habitable(bee_pawn))
			continue
		valid_hives += potential_home

	if(length(valid_hives))
		return pick(valid_hives)
