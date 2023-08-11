/datum/mutant_type
	var/name = "Base"
	var/list/active_abilities = list()
	var/list/passive_effects = list() // Include both strengths and weaknesses
	var/list/special_abilities = list()

/datum/action/innate/mutant
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	background_icon_state = "bg_spell"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/mutant/choose_type
	name = "Choose Mutant Type"
	desc = "Choose your set of mutant abilities"
	button_icon_state = "blink"

/datum/action/innate/mutant/choose_type/IsAvailable()
	if(!owner.mind.has_antag_datum(/datum/antagonist/mutant))
		return FALSE
	return ..()

/datum/action/innate/mutant/choose_type/Activate()
	var/mob/O = owner
	Remove(owner)

	var/datum/antagonist/mutant/M = O.mind.has_antag_datum(/datum/antagonist/mutant)

	var/list/possible_types = list()
	for(var/I in subtypesof(/datum/mutant_type))
		var/datum/mutant_type/J = I
		var/type_name = initial(J.name)
		possible_types[type_name] = J
	var/selected_type = input(O, "Select your type of mutant.", "Mutant Types") as null|anything in possible_types

	var/datum/mutant_type/T = possible_types[selected_type]
	M.mutant_type = new T

	for(var/A in M.mutant_type.active_abilities)
		var/obj/effect/proc_holder/spell/ability = new A
		O.mind.AddSpell(ability)

	for(var/T in M.mutant_type.passive_effects)
		ADD_TRAIT(O, T, MUTANT_TRAIT)
