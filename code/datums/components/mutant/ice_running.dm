/datum/component/ice_running
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/mob/runner
	var/run_multiplier

/datum/component/ice_running/Initialize(speed = -1)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE), PROC_REF(update_movement))
	runner = parent
	run_multiplier = speed

/datum/component/ice_running/proc/update_movement()
	SIGNAL_HANDLER

	var/turf/open/T = get_turf(runner)
	var/datum/component/wet_floor/WF = T.GetComponent(/datum/component/wet_floor)
	if(isopenturf(T) && WF && (WF.lube_flags & FROZEN_TURF))
		runner.add_movespeed_modifier(MOVESPEED_ID_ICE_RUNNING, update=TRUE, priority=100, multiplicative_slowdown=run_multiplier, movetypes=GROUND)
	else
		runner.remove_movespeed_modifier(MOVESPEED_ID_ICE_RUNNING)

/datum/component/ice_running/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE))

/datum/component/ice_running/_RemoveFromParent()
	runner.remove_movespeed_modifier(MOVESPEED_ID_ICE_RUNNING)
	return ..()
