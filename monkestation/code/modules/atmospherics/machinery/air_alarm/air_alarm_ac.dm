#define AC_MIN_TEMP			T20C - 5
#define AC_MAX_TEMP			T20C + 10
#define AC_DEFAULT_TARGET	T20C
#define AC_TARGET_SKEW		2
#define AC_SWITCH_COOLDOWN	5 SECONDS
#define AC_DEFAULT_INC		1.5
#define AC_ADJACENT_MUL		0.6

/obj/machinery/airalarm
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	/// Whether air conditioning is enabled or not.
	var/air_conditioning = TRUE
	/// Whether the air alarm is currently trying to actively regulate the temperature.
	var/ac_active = FALSE
	/// The amount of temperature (in K) the air conditioner will "push" towards the target temperature, per tick.
	var/ac_temp_inc = AC_DEFAULT_INC
	/// The minimum target temperature the air conditioner can be set to.
	var/ac_temp_min = AC_MIN_TEMP
	/// The maximum target temperature the air conditioner can be set to.
	var/ac_temp_max = AC_MAX_TEMP
	/// The target temperature the air conditioner is trying to reach, if active.
	var/ac_temp_target = AC_DEFAULT_TARGET
	/// The multiplier to [ac_temp_target] for tiles adjacent to the alarm.
	var/ac_adjacent_mul = AC_ADJACENT_MUL
	VAR_PRIVATE/cached_target_min = AC_DEFAULT_TARGET - AC_TARGET_SKEW
	VAR_PRIVATE/cached_target_max = AC_DEFAULT_TARGET + AC_TARGET_SKEW
	/// Cooldown for the air conditioning (de)activating, to prevent spam.
	COOLDOWN_DECLARE(ac_switch_cooldown)

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	if(air_conditioning)
		SSair.start_processing_machine(src)

/obj/machinery/airalarm/Destroy()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/airalarm/examine(mob/user)
	. = ..()
	var/status = air_conditioning ? (ac_active ? "active" : "idle") : "disabled"
	. += span_notice("A small light indicates that the air conditioning is [span_bold(status)].")

/obj/machinery/airalarm/ui_data(mob/user)
	. = ..()
	.["ac"] = list(
		"enabled" = air_conditioning,
		"active" = ac_active,
		"target" = ac_temp_target,
		"min" = ac_temp_min,
		"max" = ac_temp_max
	)

/obj/machinery/airalarm/proc/set_ac_target(new_target = AC_DEFAULT_TARGET)
	if(new_target == ac_temp_target || !isnum(new_target) || !ISINRANGE(new_target, ac_temp_min, ac_temp_max))
		return
	ac_temp_target = new_target
	cached_target_min = ac_temp_target - AC_TARGET_SKEW
	cached_target_max = ac_temp_target + AC_TARGET_SKEW

/obj/machinery/airalarm/proc/start_ac()
	air_conditioning = TRUE
	ac_active = FALSE
	update_use_power(IDLE_POWER_USE)
	SSair.start_processing_machine(src)

/obj/machinery/airalarm/proc/stop_ac()
	air_conditioning = FALSE
	ac_active = FALSE
	update_use_power(IDLE_POWER_USE)
	SSair.stop_processing_machine(src)

/obj/machinery/airalarm/process_atmos()
	if(panel_open || (machine_stat & (NOPOWER | BROKEN)))
		return
	if(!air_conditioning)
		stop_ac()
		return PROCESS_KILL
	var/turf/open/location = get_turf(src)
	if(!istype(location) || QDELING(location))
		update_use_power(IDLE_POWER_USE)
		ac_active = FALSE
		return
	var/datum/gas_mixture/environment = location.return_air()
	if(QDELETED(environment))
		update_use_power(IDLE_POWER_USE)
		ac_active = FALSE
		return
	var/current_temp
	if(COOLDOWN_FINISHED(src, ac_switch_cooldown))
		var/previous_active = ac_active
		ac_active = !ISINRANGE_EX(current_temp, cached_target_min, cached_target_max)
		if(previous_active != ac_active)
			visible_message(span_notice("[src] makes a quiet click as it [ac_active ? "starts trying to regulate" : "stops regulating"] the area's temperature."), blind_message = span_hear("You hear a silent click."), vision_distance = 3)
			playsound(src, 'sound/machines/terminal_on.ogg', vol = 30, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)
			update_use_power(ac_active ? ACTIVE_POWER_USE : IDLE_POWER_USE)
		COOLDOWN_START(src, ac_switch_cooldown, AC_SWITCH_COOLDOWN)


#undef AC_ADJACENT_MUL
#undef AC_DEFAULT_INC
#undef AC_SWITCH_COOLDOWN
#undef AC_TARGET_SKEW
#undef AC_DEFAULT_TARGET
#undef AC_MAX_TEMP
#undef AC_MIN_TEMP
