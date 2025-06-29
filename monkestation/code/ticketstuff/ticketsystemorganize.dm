/client/verb/adminhelp2()
	set category = "Admin"
	set name = "New Admin Help"
	//GLOB.admin_help_ui_handler.ui_interact(mob)
	//to_chat(src, span_boldnotice("Adminhelp failing to open or work? <a href='byond://?src=[REF(src)];tguiless_adminhelp=1'>Click here</a>"))

/client/verb/mentorhelp2()
	set category = "Mentor"
	set name = "New Mentor Help"

	if(usr?.client?.prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<span class='danger'>Error: MentorPM: You are muted from Mentorhelps. (muted).</span>",
			confidential = TRUE)
		return
	//GLOB.mentor_help_ui_handler.ui_interact(mob)
	//to_chat(src, span_boldnotice("Adminhelp failing to open or work? <a href='byond://?src=[REF(src)];tguiless_adminhelp=1'>Click here</a>"))
