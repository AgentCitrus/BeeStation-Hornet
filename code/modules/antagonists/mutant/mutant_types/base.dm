/datum/mutant_type
	var/name = "Base"
	var/list/active_abilities = list()
	var/list/passive_traits = list() // Include both strengths and weaknesses
	var/list/components = list() // If any components are necessary
	var/list/special_abilities = list()

/datum/mutant_type/proc/on_gain(mob/living/user)
	return

/datum/mutant_type/proc/on_loss(mob/living/user)

	for(var/A in active_abilities)
		user.mind.RemoveSpell(A)

	for(var/T in passive_traits)
		REMOVE_TRAIT(user, T, MUTANT_TRAIT)

	for(var/C in components)
		qdel(user.GetComponent(C))

	return

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

	for(var/T in M.mutant_type.passive_traits)
		ADD_TRAIT(O, T, MUTANT_TRAIT)

	for(var/C in M.mutant_type.components)
		O.AddComponent(C)

	M.mutant_type.on_gain(O)

/obj/effect/proc_holder/spell/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/targeted/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/targeted/touch/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/aimed/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/aoe_turf/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/aoe_turf/conjure/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/cone/staggered/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE

/obj/effect/proc_holder/spell/self/mutant
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	still_recharging_msg = "<span class='notice'>The ability is still recharging.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = INVOCATION_NONE
