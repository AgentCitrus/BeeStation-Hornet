/datum/mutant_type
	var/name = "Base"
	var/list/active_abilities = list()
	var/list/passive_effects = list() // Include both strengths and weaknesses
	var/list/special_abilities = list()

/datum/action/innate/mutant
	icon_icon = 'icons/mob/actions/actions_mutant.dmi'
	background_icon_state = "bg_spell"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/mutant/choose_type
	name = "Choose Mutant Type"
	desc = "Choose your set of mutant abilities"
	button_icon_state = "choose_type"

/datum/action/innate/mutant/IsAvailable()
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

	if(isnull(selected_type))
		to_chat(O, "<span class='warning'>You must select a type of mutant!</span>")
		var/datum/action/innate/mutant/C = new /datum/action/innate/mutant/choose_type(src)
		C.Grant(O)
		return

	var/datum/mutant_type/T = possible_types[selected_type]
	M.mutant_type = new T

	for(var/A in M.mutant_type.active_abilities)
		var/obj/effect/proc_holder/spell/ability = new A
		O.mind.AddSpell(ability)

	for(var/T in M.mutant_type.passive_effects)
		ADD_TRAIT(O, T, MUTANT_TRAIT)

/obj/effect/proc_holder/spell/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/targeted/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/targeted/touch/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/aimed/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/aoe_turf/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/aoe_turf/conjure/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE
