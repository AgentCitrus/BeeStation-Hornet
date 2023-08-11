/datum/antagonist/mutant
	name = "Mutant"
	roundend_category = "mutants"
	antagpanel_category = "Mutant"
	banning_key = ROLE_MUTANT
	required_living_playtime = 4
	antag_moodlet = /datum/mood_event/focused

	// Mutant stuff
	var/datum/mutant_type/mutant_type
	var/datum/action/innate/mutant/choose_type

/datum/antagonist/mutant/on_gain()
	choose_type = new /datum/action/innate/mutant/choose_type(src)
	choose_type.Grant(owner.current)
	..()

/datum/antagonist/mutant/on_removal()
	if (choose_type)
		QDEL_NULL(choose_type)
	..()

/datum/antagonist/mutant/apply_innate_effects(mob/living/mob_override)
	update_mutant_icons_added()

/datum/antagonist/mutant/remove_innate_effects(mob/living/mob_override)
	update_mutant_icons_removed()

/datum/antagonist/mutant/proc/update_mutant_icons_added()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_MUT]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "mutant")

/datum/antagonist/mutant/proc/update_mutant_icons_removed()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_MUT]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)
