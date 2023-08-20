/datum/mutant_type/geokinetic
	name = "Geokinetic"
	active_abilities = list(
		/obj/effect/proc_holder/spell/targeted/mutant/toggle_stoneskin
	)
	special_abilities = list(

	)
	passive_traits = list(
		TRAIT_NOGUNS
	)

/datum/mutant_type/geokinetic/on_gain(mob/living/user)
	. = ..()
	user.metabolism_modifier = 0.5
	user.mob_biotypes.Remove(MOB_ORGANIC)
	if(!user.mob_biotypes.Find(MOB_INORGANIC))
		user.mob_biotypes.Add(MOB_INORGANIC)

/datum/mutant_type/geokinetic/on_loss(mob/living/user)
	user.metabolism_modifier = initial(user.metabolism_modifier)
	user.mob_biotypes = initial(user.mob_biotypes)

	..()

/////////////////////////////////////////
//                                     //
//           ACTIVE ABILITIES          //
//                                     //
/////////////////////////////////////////

/obj/effect/proc_holder/spell/targeted/mutant/toggle_stoneskin
	name = "Toggle Stoneskin"
	desc = "Embrace stone, becoming stronger and more hardy, but slower."
	action_icon_state = "stoneskin"
	range = -1
	include_user = TRUE
	charge_max = 5 SECONDS
	sound = 'sound/magic/fleshtostone.ogg'

/obj/effect/proc_holder/spell/targeted/mutant/toggle_stoneskin/cast(list/targets, mob/user)
	. = ..()
	if(!isliving(user))
		to_chat(user, "<span class-'warning'>You cannot enter stone form!</span>")
		return

	to_chat(user, "<span class-'notice'>You begin morphing your skin...</span>")
	if(do_after(user, 5 SECONDS))
		var/mob/living/U = user
		if(!U.has_status_effect(STATUS_EFFECT_STONESKIN))
			to_chat(U, "<span class-'notice'>You become one with stone!</span>")
			U.apply_status_effect(STATUS_EFFECT_STONESKIN)
		else
			to_chat(U, "<span class-'notice'>You return to your flesh!</span>")
			U.remove_status_effect(STATUS_EFFECT_STONESKIN)
	else
		to_chat(user, "<span class-'warning'>You get interrupted!</span>")

/obj/effect/proc_holder/spell/targeted/touch/mutant/rock_fist
	name = "Rock Hammer"
	desc = "Form your hand into a heavy hammer of rock."

/obj/effect/proc_holder/spell/mutant/form_tile_shield
	name = "Form Shield"
	desc = "Form your hand into a shield using a tile on the ground below."

/obj/effect/proc_holder/spell/targeted/forcewall/create_rock_barrier
	name = "Create Rock Barrier"
	desc = "Rise a rock barrier from the ground."

/obj/effect/proc_holder/spell/aimed/mutant/throw_boulder
	name = "Throw Boulder"
	desc = "Manifest a boulder and launch it at an enemy."

/////////////////////////////////////////
//                                     //
//          SPECIAL ABILITIES          //
//                                     //
/////////////////////////////////////////

/obj/effect/proc_holder/spell/spike_stomp
	name = "Spike Stomp"
	desc = "Stomp on the ground, raising spikes of rock around you."
