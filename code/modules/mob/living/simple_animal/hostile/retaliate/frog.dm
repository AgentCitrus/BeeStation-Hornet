/mob/living/simple_animal/hostile/retaliate/frog
	name = "frog"
	desc = "It seems a little sad."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("ribbit","croak")
	speak_language = /datum/language/metalanguage
	emote_see = list("hops in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	maxHealth = 15
	health = 15
	melee_damage = 5
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "pokes"
	response_disarm_simple = "poke"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	faction = list(FACTION_HOSTILE)
	attack_sound = 'sound/effects/reee.ogg'
	butcher_results = list(/obj/item/food/nugget = 1)
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	var/stepped_sound = 'sound/effects/huuu.ogg'

/mob/living/simple_animal/hostile/retaliate/frog/Initialize(mapload)
	. = ..()
	if(prob(1))
		name = "rare frog"
		desc = "It seems a little smug."
		icon_state = "rare_frog"
		icon_living = "rare_frog"
		icon_dead = "rare_frog_dead"
		butcher_results = list(/obj/item/food/nugget = 5)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/hostile/retaliate/frog/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER

	if(!stat && isliving(AM))
		var/mob/living/L = AM
		if(L.mob_size > MOB_SIZE_TINY)
			playsound(src, stepped_sound, 50, 1)
