/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Plumbing"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Plumbing") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Power") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	var/list/results = list()

	for (var/datum/powernet/PN in SSmachines.powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				results += "Powernet with no nodes! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]"

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				results += "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]"

	for(var/turf/T in world.contents)
		var/cable_layers //cache all cable layers (which are bitflags) present
		for(var/obj/structure/cable/C in T.contents)
			if(cable_layers & C.cable_layer)
				results += "Doubled wire at [ADMIN_VERBOSEJMP(C)]"
			else
				cable_layers |= C.cable_layer
		var/obj/machinery/power/terminal/term = locate(/obj/machinery/power/terminal) in T.contents
		if(term)
			var/obj/structure/cable/C = locate(/obj/structure/cable) in T.contents
			if(!C)
				results += "Unwired terminal at [ADMIN_VERBOSEJMP(term)]"
	to_chat(usr, "[results.Join("\n")]", confidential = TRUE)
