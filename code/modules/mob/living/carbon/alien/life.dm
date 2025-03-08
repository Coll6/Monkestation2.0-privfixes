/mob/living/carbon/alien/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	findQueen()
	return..()

/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return


	if(health <= HEALTH_THRESHOLD_CRIT)
		adjustOxyLoss(2)


	var/plas_detect_threshold = 0.02

	//Partial pressure of the plasma in our breath
	var/Plasma_pp

	if(Plasma_pp > plas_detect_threshold) // Detect plasma in air

		throw_alert(ALERT_XENO_PLASMA, /atom/movable/screen/alert/alien_plas)



	else
		clear_alert(ALERT_XENO_PLASMA)

	//Breathe in plasma and out oxygen




	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

/mob/living/carbon/alien/adult/Life(seconds_per_tick, times_fired)
	. = ..()
	handle_organs(seconds_per_tick, times_fired)
