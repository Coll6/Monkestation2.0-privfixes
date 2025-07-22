/*Goals
 * Initialize restore tickets from previous round.
 * admin_help/New(msg_raw, client/C, is_bwoink, urgent = FALSE) - make new ticket
 * /datum/admin_help/Destroy() - basically delete ticket
 * proc/format_embed_discord(message) returns formated message if a lot of things.
 * some how sends messages to tgs? send_message_to_tgs(message, urgent = FALSE)
 * /proc/send2adminchat_webhook(message_or_embed, urgent)
 * /datum/admin_help/AddInteraction(message, player_message, for_admins = FALSE, ckey = null) - honestly no idea
 * /datum/admin_help/proc/TimeoutVerb - removes admin help verb, then restores on a timer.
 * /datum/admin_help/proc/FullMonty(ref_src) - get full name of subject of ticket?
 * /datum/admin_help/proc/ClosureLinks(ref_src) - get all href links to change ticket status
 * /datum/admin_help/proc/LinkedReplyName(ref_src) - not sure
 * /datum/admin_help/proc/TicketHref(msg, ref_src, action = "ticket") - not sure
 * /datum/admin_help/proc/MessageNoRecipient(msg, urgent = FALSE) - sends message about ticket when no target
 * /datum/admin_help/proc/reply_to_admins_notification(message) - gives player message with link to respond to admin message
 * /datum/admin_help/proc/Reopen() - reopen a ticket
 * /datum/admin_help/proc/RemoveActive() - makes ticket inactive? sends signal SEND_SIGNAL(src, COMSIG_ADMIN_HELP_MADE_INACTIVE)
 * /datum/admin_help/proc/Close(key_name = key_name_admin(usr), silent = FALSE) - closes ticket closed/meme
 * /datum/admin_help/proc/Resolve(key_name = key_name_admin(usr), silent = FALSE) - //Mark open ticket as resolved/legitimate, returns ahelp verb
 * /datum/admin_help/proc/Reject(key_name = key_name_admin(usr)) - Close and return ahelp verb, use if ticket is incoherent
 * /datum/admin_help/proc/ICIssue(key_name = key_name_admin(usr))
 * /datum/admin_help/proc/TicketPanel()
 * /datum/admin_help/proc/ticket_status()
 * /datum/admin_help/proc/Retitle()
 * /datum/admin_help/proc/Action(action) - Forwarded action from admin/Topic
 * /datum/admin_help/proc/player_ticket_panel()

  old sub system has 3 lists for the status of each ticket
 * /datum/admin_help_tickets/proc/TicketByID(id)
 * /datum/admin_help_tickets/proc/TicketsByCKey(ckey)
 * /datum/admin_help_tickets/proc/ListInsert(datum/admin_help/new_ticket)
 * /datum/admin_help_tickets/proc/BrowseTickets(state)
 * /datum/admin_help_tickets/proc/stat_entry() - adds information about the manager to the stat panel
 * /datum/admin_help_tickets/proc/ClientLogin(client/C) - //Reassociate still open ticket if one exists
 * /datum/admin_help_tickets/proc/ClientLogout(client/C) - //Dissasociate ticket
 * /datum/admin_help_tickets/proc/CKey2ActiveTicket(ckey) - //Get a ticket given a ckey
*/

SUBSYSTEM_DEF(tickets)
	name = "Tickets"
	init_order = INIT_ORDER_TICKETS
	wait = 300
	priority = FIRE_PRIORITY_TICKETS
	flags = SS_BACKGROUND

/datum/controller/subsystem/tickets/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tickets/fire()
