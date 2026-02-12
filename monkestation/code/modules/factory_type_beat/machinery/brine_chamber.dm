/obj/structure/brine_chamber
	name = "brine chamber"
	desc = "A large structure for a pool of water. Its large open surface area allows water to evaporate leaving behind, salts creating a very salty brine solution."
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "brine_chamber"

/obj/structure/brine_chamber/controller
	icon_state = "brine_chamber_controller"

	/// Pack to return when deconstructed with crowbar.
	var/obj/item/flatpacked_machine/ore_processing/machine = /obj/item/flatpacked_machine/ore_processing/brine_chamber

/obj/structure/brine_chamber/controller/Destroy()
	machine = null
	return ..()
