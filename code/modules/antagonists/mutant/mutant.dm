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
	var/list/current_special_abilities = list()

/datum/antagonist/mutant/on_gain()
	choose_type = new /datum/action/innate/mutant/choose_type(src)
	choose_type.Grant(owner.current)
	..()

/datum/antagonist/mutant/on_removal()
	if (choose_type)
		QDEL_NULL(choose_type)
	mutant_type.on_loss(owner.current)
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

/datum/antagonist/mutant/proc/grant_special_ability()
	for(var/I in mutant_type.special_abilities)
		if(!current_special_abilities.Find(I))
			var/obj/effect/proc_holder/spell/S = new I
			current_special_abilities.Add(S)
			owner.AddSpell(S)
			return

/datum/antagonist/mutant/proc/remove_special_ability()
	var/S = pick(current_special_abilities)
	owner.RemoveSpell(S)
	current_special_abilities.Remove(S)

/datum/antagonist/mutant/proc/is_mutant_type(datum/mutant_type/T)
	return mutant_type == T
