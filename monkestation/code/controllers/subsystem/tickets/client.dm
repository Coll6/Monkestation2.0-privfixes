/client/verb/newmentorhelp()
	set category = "Mentor"
	set name = "newMentorhelp"
	GLOB.mentor_help_ui_handler.ui_interact(mob)
	to_chat(src, span_boldnotice("Mentorhelp failing to open or work? <a href='byond://?src=[REF(src)];tguiless_mentorhelp=1'>Click here</a>"))

GLOBAL_DATUM_INIT(mentor_help_ui_handler, /datum/mentor_help_ui_handler, new)

/datum/mentor_help_ui_handler

/datum/mentor_help_ui_handler/ui_state(mob/user)
	return GLOB.always_state

/datum/mentor_help_ui_handler/ui_data(mob/user)
	. = list()

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
//	var/urgent = !!params["urgent"]
//	var/list/admins = get_admin_counts(R_BAN)
//	if(length(admins["present"]) != 0 || is_banned_from(user_client.ckey, "Urgent Adminhelp"))
//		urgent = FALSE

//	if(user_client.adminhelptimerid)
//		return

	perform_mentorhelp(user_client, message)
	ui.close()

/datum/mentor_help_ui_handler/proc/perform_mentorhelp(client/user_client, message)
	if(GLOB.say_disabled)
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	if(!message)
		return

	//handle muting and automuting
	if(user_client.prefs.muted & MUTE_ADMINHELP)
		to_chat(user_client, span_danger("Error: Admin-PM: You cannot send mentorhelps (Muted)."), confidential = TRUE)
		return
	if(user_client.handle_spam_prevention(message, MUTE_ADMINHELP))
		return

	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Mentorhelp")

	//Figure this out later
	//COOLDOWN_START(src, ahelp_cooldowns[user_client.ckey], CONFIG_GET(number/urgent_ahelp_cooldown) * (1 SECONDS))

	//If this type of help has a ticket open
	//time out verb?
	//ugent sends to tgs
	//else sends to current_ticket.MessageNoRecipient
	//if no ticket make one new admin_help(message, user_client, FALSE, urgent

/client/verb/no_tgui_mentorhelp(message as message)
	set name = "NoTguiMentorhelp"
	set hidden = TRUE

	//if(adminhelptimerid)
	//	return

	message = trim(message)

	GLOB.mentor_help_ui_handler.perform_mentorhelp(src, message, FALSE)
