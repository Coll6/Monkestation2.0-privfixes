/datum/outfit/syndicate
	name = "Syndicate Operative - Basic"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/modular_computer/pda/nukeops
	r_pocket = /obj/item/pen/edagger
	id = /obj/item/card/id/advanced/chameleon
	belt = /obj/item/gun/ballistic/automatic/pistol/clandestine

	skillchips = list(/obj/item/skillchip/disk_verifier, /obj/item/skillchip/gorlex)
	box = /obj/item/storage/box/survival/syndie
	/// Amount of TC to automatically store in this outfit's uplink.
	var/tc = 25
	/// Enables big voice on this outfit's headset, used for nukie leaders.
	var/command_radio = FALSE
	/// The type of uplink to be given on equip.
	var/uplink_type = /obj/item/uplink/nuclear

	id_trim = /datum/id_trim/chameleon/operative

	/// Give them an explosive implant.
	var/implant_explosive_implant = TRUE

/datum/outfit/syndicate/plasmaman
	name = "Syndicate Operative - Basic (Plasmaman)"
	head = /obj/item/clothing/head/helmet/space/plasmaman/syndie
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_hand = /obj/item/tank/internals/plasmaman/belt/full

/datum/outfit/syndicate/leader
	name = "Syndicate Leader - Basic"
	command_radio = TRUE

	id_trim = /datum/id_trim/chameleon/operative/nuke_leader

/datum/outfit/syndicate/leader/plasmaman
	name = "Syndicate Leader - Basic (Plasmaman)"
	head = /obj/item/clothing/head/helmet/space/plasmaman/syndie
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_hand = /obj/item/tank/internals/plasmaman/belt/full

/datum/outfit/syndicate/post_equip(mob/living/carbon/human/nukie, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/radio = nukie.ears
	radio.set_frequency(FREQ_SYNDICATE)
	radio.freqlock = RADIO_FREQENCY_LOCKED
	if(command_radio)
		radio.command = TRUE
		radio.use_command = TRUE

	if(ispath(uplink_type, /obj/item/uplink/nuclear) || tc) // /obj/item/uplink/nuclear understands 0 tc
		var/obj/item/uplink = new uplink_type(nukie, nukie.key, tc)
		nukie.equip_to_slot_or_del(uplink, ITEM_SLOT_BACKPACK)

	var/obj/item/implant/weapons_auth/weapons_implant = new/obj/item/implant/weapons_auth(nukie)
	weapons_implant.implant(nukie)
	if(implant_explosive_implant)
		var/obj/item/implant/explosive/explosive_implant = new/obj/item/implant/explosive(nukie)
		explosive_implant.implant(nukie)
	nukie.faction |= ROLE_SYNDICATE
	nukie.update_icons()

/datum/outfit/syndicate/full
	name = "Syndicate Operative - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/mod/control/pre_equipped/nuclear
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/storage/belt/military
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog
	backpack_contents = list(
		/obj/item/gun/ballistic/automatic/pistol/clandestine = 1,
		/obj/item/pen/edagger = 1,
	)

/datum/outfit/syndicate/full/plasmaman
	name = "Syndicate Operative - Full Kit (Plasmaman)"
	back = /obj/item/mod/control/pre_equipped/nuclear/plasmaman
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_pocket = /obj/item/tank/internals/plasmaman/belt/full
	mask = null

/datum/outfit/syndicate/full/plasmaman/New()
	backpack_contents += /obj/item/clothing/head/helmet/space/plasmaman/syndie
	return ..()

/datum/outfit/syndicate/reinforcement
	name = "Syndicate Operative - Reinforcement"
	tc = 0
	backpack_contents = list(
		/obj/item/gun/ballistic/automatic/plastikov = 1,
		/obj/item/ammo_box/magazine/plastikov9mm = 2,
	)
	var/faction = "The Syndicate"

/datum/outfit/syndicate/reinforcement/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	to_chat(H, span_notice("You're an agent of [faction], sent to accompany the nuclear squad on their mission. \
		Support your allies, and remember: Down with Nanotrasen."))

/datum/outfit/syndicate/reinforcement/plasmaman
	name = "Syndicate Operative - Reinforcement (Plasmaman)"
	head = /obj/item/clothing/head/helmet/space/plasmaman/syndie
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_hand = /obj/item/tank/internals/plasmaman/belt/full
	tc = 0

/datum/outfit/syndicate/reinforcement/gorlex
	name = "Syndicate Operative - Gorlex Reinforcement"
	suit = /obj/item/clothing/suit/armor/vest/alt
	head = /obj/item/clothing/head/helmet/swat
	neck = /obj/item/clothing/neck/large_scarf/syndie
	glasses = /obj/item/clothing/glasses/cold
	faction = "the Gorlex Marauders"

/datum/outfit/syndicate/reinforcement/cybersun
	name = "Syndicate Operative - Cybersun Reinforcement"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/jacket/oversized
	gloves = /obj/item/clothing/gloves/fingerless
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/cigarette/cigar
	faction = "Cybersun Industries"

/datum/outfit/syndicate/reinforcement/donk
	name = "Syndicate Operative - Donk Reinforcement"
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/utility/hardhat/orange
	shoes = /obj/item/clothing/shoes/workboots
	glasses = /obj/item/clothing/glasses/meson
	faction = "the Donk Corporation"

/datum/outfit/syndicate/reinforcement/waffle
	name = "Syndicate Operative - Waffle Reinforcement"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet/blueshirt
	glasses = /obj/item/clothing/glasses/welding/up
	faction = "the Waffle Corporation"

/datum/outfit/syndicate/reinforcement/interdyne
	name = "Syndicate Operative - Interdyne Reinforcement"
	uniform = /obj/item/clothing/under/syndicate/scrubs
	suit = /obj/item/clothing/suit/toggle/labcoat/interdyne
	head = /obj/item/clothing/head/beret/medical
	gloves = /obj/item/clothing/gloves/latex
	neck = /obj/item/clothing/neck/stethoscope
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/breath/medical
	faction = "Interdyne Pharmaceutics"

/datum/outfit/syndicate/reinforcement/mi13
	name = "Syndicate Operative - MI13 Reinforcement"
	uniform = /obj/item/clothing/under/syndicate/sniper
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses/big
	faction = "MI13"

/datum/outfit/syndicate/junior
	name = "Syndicate Junior Operative"

	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/storage/backpack/fireproof
	head = /obj/item/clothing/head/helmet/space/syndicate
	suit = /obj/item/clothing/suit/space/syndicate
	suit_store = /obj/item/tank/jetpack/oxygen
	belt = /obj/item/storage/belt/military
	l_pocket = /obj/item/pinpointer/nuke
	r_pocket = null
	id = /obj/item/card/id/advanced/chameleon
	backpack_contents = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m9mm = 1,
		/obj/item/pen/edagger = 1,
	)
	tc = 10
	uplink_type = /obj/item/uplink/old
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/syndicate/junior/post_equip(mob/living/carbon/human/nukie, visualsOnly)
	..()
	var/obj/item/clothing/suit/space/anti_freeze = nukie.wear_suit
	anti_freeze.toggle_spacesuit(nukie)

/datum/outfit/syndicate/junior/plasmaman
	name = "Syndicate Junior Operative (Plasmaman)"
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_hand = /obj/item/tank/internals/plasmaman/belt/full
	internals_slot = ITEM_SLOT_HANDS


/datum/outfit/syndicate/junior/plasmaman/New()
	backpack_contents += /obj/item/clothing/head/helmet/space/plasmaman/syndie
	return ..()

/datum/outfit/syndicate/commando
	name = "Syndicate Commando Operative"

	shoes = /obj/item/clothing/shoes/combat/swat
	belt = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/pinpointer/area_pinpointer
	r_pocket = /obj/item/reagent_containers/pill/patch/advanced
	backpack_contents = list(
		/obj/item/syndicate_voucher/kit = 1,
	)
	tc = 0

	uplink_type = null

	implant_explosive_implant = FALSE

/datum/outfit/syndicate/commando/plasmaman
	name = "Syndicate Commando Operative (Plasmaman)"
	head = /obj/item/clothing/head/helmet/space/plasmaman/syndie
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_hand = /obj/item/tank/internals/plasmaman/belt/full

/datum/outfit/syndicate/commando/leader
	name = "Syndicate Commando Operative Leader"
	command_radio = TRUE

	belt = /obj/item/gun/ballistic/automatic/pistol
	head = /obj/item/clothing/head/hats/hos/beret/syndicate
	id_trim = /datum/id_trim/chameleon/operative/nuke_leader
	backpack_contents = list(
		/obj/item/syndicate_voucher/leader = 1,
		/obj/item/syndicate_voucher/kit = 1,
		/obj/item/choice_beacon/commando_support = 1,
		/obj/item/disk/nuclear/nukie = 1,
		/obj/item/nuke_recaller = 1,
	)

/datum/outfit/syndicate/commando/leader/plasmaman
	name = "Syndicate Commando Operative Leader (Plasmaman)"
	head = /obj/item/clothing/head/helmet/space/plasmaman/syndie
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_hand = /obj/item/tank/internals/plasmaman/belt/full
