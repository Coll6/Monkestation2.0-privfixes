/datum/species/darkspawn
	name = "Darkspawn"
	id = "darkspawn"
	//limbs_id = "darkspawn"
	sexes = FALSE
	//nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	siemens_coeff = 0
	brutemod = 0.9
	heatmod = 1.5
	no_equip_flags = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE, ITEM_SLOT_HEAD)
	inherent_traits = list(
		TRAIT_NOBLOOD,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NOFLASH,
		TRAIT_NOGUNS,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		// monkestation addition: pain system
		TRAIT_ABATES_SHOCK,
		TRAIT_ANALGESIA,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_NO_SHOCK_BUILDUP,
		// monkestation end
	)
	//mutanteyes = /obj/item/organ/eyes/night_vision/alien
	var/list/upgrades = list()
	//species_traits = list(NOEYESPRITES)

/datum/species/darkspawn/on_species_gain(mob/living/carbon/curr_species, datum/species/old_species)
	. = ..()
	curr_species.real_name = "[pick(GLOB.nightmare_names)]"
	curr_species.name = curr_species.real_name
	if(curr_species.mind)
		curr_species.mind.name = curr_species.real_name
	curr_species.dna.real_name = curr_species.real_name

/datum/species/darkspawn/on_species_loss(mob/living/carbon/losing_species)
	. = ..()

/datum/species/darkspawn/spec_life(mob/living/carbon/human/dark_spawn)
	. = ..() //MONKEDIT It should process other spec life stuff like everything else.
	//dark_spawn.bubble_icon = "darkspawn"
	var/turf/Turf = dark_spawn.loc
	if(istype(Turf))
		var/light_amount = Turf.get_lumcount()
		if(light_amount < DARKSPAWN_DIM_LIGHT) //rapid healing and stun reduction in the darkness
			var/healing_amount = DARKSPAWN_DARK_HEAL
			if(upgrades["dark_healing"])
				healing_amount *= 1.25
			//Might need to adjust these values due to monkestation health and stamina changes. Confirm/change then remove this line.
			dark_spawn.adjustBruteLoss(-healing_amount)
			dark_spawn.adjustFireLoss(-healing_amount * 0.5)
			dark_spawn.adjustToxLoss(-healing_amount)
			dark_spawn.stamina.adjust(-healing_amount * 20)
			dark_spawn.AdjustStun(-healing_amount * 4)
			dark_spawn.AdjustKnockdown(-healing_amount * 4)
			dark_spawn.AdjustUnconscious(-healing_amount * 4)
			dark_spawn.SetSleeping(0)
			dark_spawn.setOrganLoss(ORGAN_SLOT_BRAIN,0)
			dark_spawn.setCloneLoss(0)
		else if(light_amount < DARKSPAWN_BRIGHT_LIGHT && !upgrades["light_resistance"]) //not bright, but still dim
			dark_spawn.adjustFireLoss(1)
		//else if(light_amount > DARKSPAWN_BRIGHT_LIGHT && !H.has_status_effect(STATUS_EFFECT_CREEP))
		else if(light_amount > DARKSPAWN_BRIGHT_LIGHT) //but quick death in the light
			if(upgrades["spacewalking"] && isspaceturf(Turf))
				return
			else if(!upgrades["light_resistance"])
				to_chat(dark_spawn, "<span class='userdanger'>The light burns you!</span>")
				dark_spawn.playsound_local(dark_spawn, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
				dark_spawn.adjustFireLoss(DARKSPAWN_LIGHT_BURN)
			else
				to_chat(dark_spawn, "<span class='userdanger'>The light singes you!</span>")
				dark_spawn.playsound_local(dark_spawn, 'sound/weapons/sear.ogg', max(30, 50 * light_amount), TRUE)
				dark_spawn.adjustFireLoss(DARKSPAWN_LIGHT_BURN * 0.5)

/datum/species/darkspawn/spec_death(gibbed, mob/living/carbon/human/deadspawn)
	//playsound(deadspawn, 'yogstation/sound/creatures/darkspawn_death.ogg', 50, FALSE)

/datum/species/darkspawn/proc/handle_upgrades(mob/living/carbon/human/dark_spawn)
/*
	var/datum/antagonist/darkspawn/darkspawn
	if(H.mind)
		darkspawn = H.mind.has_antag_datum(/datum/antagonist/darkspawn)
		if(darkspawn)
			upgrades = darkspawn.upgrades
*/
