/client/verb/adminhelp2()
	set category = "Admin"
	set name = "New Admin Help"
	//GLOB.admin_help_ui_handler.ui_interact(mob)
	//to_chat(src, span_boldnotice("Adminhelp failing to open or work? <a href='byond://?src=[REF(src)];tguiless_adminhelp=1'>Click here</a>"))

/client/verb/mentorhelp2()
	set category = "Mentor"
	set name = "New Mentor Help"
	GLOB.mentor_help_ui_handler.ui_interact(mob)
	to_chat(src, span_boldnotice("Mentorhelp failing to open or work? <a href='byond://?src=[REF(src)];tguiless_mentorhelp=1'>Click here</a>"))

/client/verb/no_tgui_mentorhelp(message as message)
	set name = "NoTguiMentorhelp"
	set hidden = TRUE

	message = trim(message)

	GLOB.mentor_help_ui_handler.perform_mentorhelp(src, message)
