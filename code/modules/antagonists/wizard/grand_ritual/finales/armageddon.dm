#define DOOM_SINGULARITY "singularity"
#define DOOM_TESLA "tesla"
#define DOOM_METEORS "meteors"
#define DOOM_EVENTS "events" //monkestation edit: we can get singalos and teslas normally, so im adding a few more
#define DOOM_ANTAGS "threats" //monkestation edit
#define DOOM_ROD "rod" //monkestation edit

/// Kill yourself and probably a bunch of other people
/datum/grand_finale/armageddon
	name = "Annihilation"
	desc = "This crew have offended you beyond the realm of pranks. Make the ultimate sacrifice to teach them a lesson your elders can really respect. \
		YOU WILL NOT SURVIVE THIS."
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "wounded"
	minimum_time = 80 MINUTES // This will probably immediately end the round if it gets finished. //monkestation edit: from 90 to 80 minutes
	ritual_invoke_time = 60 SECONDS // Really give the crew some time to interfere with this one.
	dire_warning = TRUE
	glow_colour = "#be000048"
	/// Things to yell before you die
	var/static/list/possible_last_words = list(
		"Flames and ruin!",
		"Dooooooooom!!",
		"HAHAHAHAHAHA!! AHAHAHAHAHAHAHAHAA!!",
		"Hee hee hee!! Hoo hoo hoo!! Ha ha haaa!!",
		"Ohohohohohoho!!",
		"Cower in fear, puny mortals!",
		"Tremble before my glory!",
		"Pick a god and pray!",
		"It's no use!",
		"If the gods wanted you to live, they would not have created me!",
		"God stays in heaven out of fear of what I have created!",
		"Ruination is come!",
		"All of creation, bend to my will!",
	)

/datum/grand_finale/armageddon/trigger(mob/living/carbon/human/invoker)
	priority_announce(pick(possible_last_words), null, 'sound/magic/voidblink.ogg', sender_override = "[invoker.real_name]", color_override = "purple")
	var/turf/current_location = get_turf(invoker)
	invoker.gib()

	var/static/list/doom_options = list()
	if (!length(doom_options))
//		doom_options = list(DOOM_SINGULARITY, DOOM_TESLA) //monkestation removal
		doom_options = list(DOOM_EVENTS, DOOM_ANTAGS, DOOM_ROD) //monkestation edit
		if (!SSmapping.config.planetary)
			doom_options += DOOM_METEORS

	switch(pick(doom_options))
//monkestation removal start
		/*if (DOOM_SINGULARITY)
			var/obj/singularity/singulo = new(current_location)
			singulo.energy = 300
		if (DOOM_TESLA)
			var/obj/energy_ball/tesla = new (current_location)
			tesla.energy = 200*/
//monkestation removal end
		if (DOOM_METEORS)
			priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", ANNOUNCER_METEORS)
//monkestation edit start
		if (DOOM_EVENTS) //triggers a MASSIVE amount of events pretty quickly
			summon_events() //wont effect the events created directly from this, but it will effect any events that happen after
			var/list/possible_events = list()
			for(var/datum/round_event_control/possible_event as anything in SSevents.control)
				if(possible_event.max_wizard_trigger_potency < 6) //only run the decently big ones
					continue
				possible_events += possible_event
			var/timer_counter = 1
			for(var/i in 1 to 50) //high chance this number needs tweaking, but we do want this to be a round ending amount of events
				var/datum/round_event_control/event = pick(possible_events)
				addtimer(CALLBACK(event, TYPE_PROC_REF(/datum/round_event_control, run_event)), (10 * timer_counter) SECONDS)
				timer_counter++
		if (DOOM_ANTAGS) //so I heard you like antags
			ASYNC //sleeps
				for(var/i in 1 to 4) //spawn 4 midrounds
					sleep(50) //sleep 5 seconds between each one

		if (DOOM_ROD) //spawns a ghost controlled, forced looping rod, only technically less damaging then singaloth or tesloose
			var/obj/effect/immovablerod/rod = new(current_location)
			rod.loopy_rod = TRUE
			rod.can_suplex = FALSE
			rod.deadchat_plays(ANARCHY_MODE, 4 SECONDS)
//monkestation edit end

#undef DOOM_SINGULARITY
#undef DOOM_TESLA
#undef DOOM_METEORS
#undef DOOM_EVENTS //monkestation edit
#undef DOOM_ANTAGS //monkestation edit
#undef DOOM_ROD //monkestation edit
