/// Test to make sure the pressure pumping proc used by things like portable pumps, pressure pumps, etc actually work.
/datum/unit_test/atmospheric_gas_transfer

/datum/unit_test/atmospheric_gas_transfer/Run()
	for (var/hot_test in list(1e4, 1e6, 1e8, 1e10, 1e12))
		nob_to_trit(hot_test, hot_test, 50, T20C, max(2500, hot_test/100))
	for (var/cold_test in list(1, 1e-2, MOLAR_ACCURACY))
		nob_to_trit(5000, T20C, cold_test, cold_test)
	nob_to_trit(5000, T20C, 100, T20C, 1)

/**
 * Proc to transfer x moles of x temp nob to x moles of x temp trit.
 *
 * Arguments:
 * * nob_moles: Moles for the nob (origin)
 * * nob_temp: Temp for the nob (origin)
 * * trit_moles: Moles for the trit (target)
 * * nob_temp: Temp for the nob (target)
 * * additional_pressure: Optional proc, if unfilled transfer will be 10% of pressure.
 */
/datum/unit_test/atmospheric_gas_transfer/proc/nob_to_trit(nob_moles, nob_temp, trit_moles, trit_temp, additional_pressure)
	var/datum/gas_mixture/first_mix = allocate(/datum/gas_mixture)
	var/datum/gas_mixture/second_mix = allocate(/datum/gas_mixture)


	// A fixed number would mean transfer is too small for high temps. So we make it scaled.

	if(isnull(additional_pressure))


	/* ERROR MARGIN CALCULATION
	 * We calculate how much would the pressure change if MOLAR_ACCURACY amount of hothotgas is imparted on the cold mix.
	 * This number gets really big for very high temperatures so it's somewhat meaningless, but our main goal is to ensure the code doesn't break.
	 */
