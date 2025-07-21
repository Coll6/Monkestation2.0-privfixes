SUBSYSTEM_DEF(tickets)
	name = "Tickets"
	init_order = INIT_ORDER_TICKETS
	wait = 300
	priority = FIRE_PRIORITY_TICKETS
	flags = SS_BACKGROUND

/datum/controller/subsystem/tickets/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tickets/fire()
