/*
 * Traitors have been refactored into minor antagonists so they can
 * be used alongside other compatible gamemodes with ease.
 * This code is what creates them.
 */

/datum/special_role/traitor
	attached_antag_datum = /datum/antagonist/traitor
	spawn_mode = SPAWNTYPE_ROUNDSTART
	probability = 15	//15% chance to be plopped ontop
	proportion = 0.07	//Quite a low amount since we are going alongside other gamemodes.
	max_amount = 5
	allowAntagTargets = TRUE
	latejoin_allowed = TRUE
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	role_name = "Traitor"
	preference_type = /datum/role_preference/antagonist/traitor
	use_antag_rep = TRUE

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off

/datum/special_role/traitor/higher_chance
	probability = 60

/datum/special_role/traitor/add_antag_status_to(datum/mind/M)
	addtimer(CALLBACK(src, PROC_REF(reveal_antag_status), M), rand(10,100))

/datum/special_role/traitor/proc/reveal_antag_status(datum/mind/M)
	M.special_role = role_name
	var/datum/antagonist/special/A = M.add_antag_datum(new attached_antag_datum())
	A.forge_objectives(M)
	A.equip()
	return A
