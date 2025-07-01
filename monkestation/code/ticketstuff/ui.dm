GLOBAL_DATUM_INIT(mentor_help_ui_handler, /datum/mentor_help_ui_handler, new)

/datum/mentor_help_ui_handler

/datum/mentor_help_ui_handler/ui_state(mob/user)
	return GLOB.always_state

/datum/mentor_help_ui_handler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mentorhelp")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/mentor_help_ui_handler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/client/user_client = usr.client
	var/message = sanitize_text(trim(params["message"]))

	perform_mentorhelp(user_client, message)
	ui.close()

/datum/mentor_help_ui_handler/proc/perform_mentorhelp(client/user_client, message)
	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	if(!message)
		return

	//handle muting and automuting
	if(user_client.prefs.muted & MUTE_ADMINHELP)
		to_chat(user_client,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<span class='danger'>Error: MentorPM: You are muted from Mentorhelps. (muted).</span>",
			confidential = TRUE)
		return
	if(user_client.handle_spam_prevention(message, MUTE_ADMINHELP))
		return

	BLACKBOX_LOG_MENTOR_VERB("Mentorhelp")
	//make new ticket thing here
