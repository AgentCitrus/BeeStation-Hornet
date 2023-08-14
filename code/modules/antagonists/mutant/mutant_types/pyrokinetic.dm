/datum/mutant_type/pyrokinetic
	name = "Pyrokinetic"
	active_abilities = list(
		/obj/effect/proc_holder/spell/aimed/mutant/flame_dart,
		/obj/effect/proc_holder/spell/aimed/mutant/fireball,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/mutant/create_fire_trap,
		/obj/effect/proc_holder/spell/targeted/touch/mutant/searing_touch,
		/obj/effect/proc_holder/spell/aoe_turf/repulse/scorching_rebuke
	)
	passive_effects = list(
		TRAIT_NOFIRE,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_COLDWEAKNESS,
		TRAIT_LOWPRESSUREWEAKNESS
	)
	special_abilities = list(
		/obj/effect/proc_holder/spell/targeted/fire_sworn/fire_form,
		/obj/effect/proc_holder/spell/aoe_turf/mutant/rain_fire,
		/obj/effect/proc_holder/spell/mutant/blistering_rage
	)

/////////////////////////////////////////
//                                     //
//           ACTIVE ABILITIES          //
//                                     //
/////////////////////////////////////////

/obj/effect/proc_holder/spell/aimed/mutant/flame_dart
	name = "Flame Dart"
	desc = "Fire a dart of... well, flame."
	range = 20
	charge_max = 5 SECONDS
	projectile_type = /obj/projectile/temp/flame_dart
	base_icon_state = "lavabeam"
	action_icon_state = "lavabeam"
	sound = 'sound/weapons/pierce.ogg'
	active_msg = "You begin concentrating heat into your hand..."
	deactive_msg = "You dissipate the heat in your hand..."
	active = FALSE

/obj/projectile/temp/flame_dart
	name = "flame dart"
	icon_state = "lava"
	damage = 20
	temperature = 400
	var/fire_stacks = 4

/obj/projectile/temp/flame_dart/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.IgniteMob()
	..()

/obj/projectile/temp/flame_dart/Move()
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

/obj/effect/proc_holder/spell/aimed/mutant/fireball
	name = "Fireball"
	desc = "Launch a large ball of explosive fire."
	range = 20
	charge_max = 25 SECONDS
	projectile_type = /obj/projectile/magic/fireball/mutant
	base_icon_state = "fireball"
	action_icon_state = "fireball"
	sound = 'sound/magic/fireball.ogg'
	active_msg = "You manifest a blazing inferno between your hands..."
	deactive_msg = "You let the inferno between your hands wither away..."
	active = FALSE

/obj/projectile/magic/fireball/mutant
	exp_heavy = 0
	exp_light = 1
	exp_flash = 2
	exp_fire= 4
	magic = FALSE

/obj/effect/proc_holder/spell/aoe_turf/conjure/mutant/create_fire_trap
	name = "Create Fire Trap"
	desc = "Create a delayed-action fire trap below you, immolating anyone foolish enough to walk over it."
	charge_max = 15 SECONDS
	range = 0
	summon_type = list(/obj/structure/trap/fire/mutant)
	summon_lifespan = 5 MINUTES
	summon_amt = 1
	action_icon_state = "fire_trap"

/obj/effect/proc_holder/spell/aoe_turf/conjure/mutant/create_fire_trap/post_summon(obj/structure/trap/T, mob/user)
	T.immune_minds += user.mind
	T.charges = 1

/obj/structure/trap/fire/mutant
	var/fire_stacks = 4

/obj/structure/trap/fire/mutant/trap_effect(mob/living/L)
	to_chat(L, "<span class='danger'><B>IT BURNS!</B></span>")
	playsound(L, 'sound/weapons/sear.ogg', 100, 1)
	L.apply_damage(30, BURN)
	L.adjust_fire_stacks(fire_stacks)
	L.IgniteMob()

/obj/effect/proc_holder/spell/targeted/touch/mutant/searing_touch
	name = "Searing Touch"
	desc = "Heat that which you touch. Can severely burn things, or melt walls."
	drawmessage = "You channel heat into your hand until it is glowing..."
	dropmessage = "You let your hand cool once more..."
	hand_path = /obj/item/melee/touch_attack/searing_touch
	charge_max = 10 SECONDS
	base_icon_state = "searing_touch"
	action_icon_state = "searing_touch"

/obj/item/melee/touch_attack/searing_touch
	name = "searing touch"
	desc = "You feel nothing but a pleasant warmth in your hand as it glows."
	catchphrase = null
	icon_state = "searing_touch"
	item_state = "searing_touch"
	on_use_sound = 'sound/weapons/sear.ogg'
	damtype = BURN
	force = 25

	var/fire_stacks = 4

/obj/item/melee/touch_attack/searing_touch/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity)
		return
	if(isliving(target))
		target.visible_message("<span class='danger'>[user] sears [target]!</span>","<span class='userdanger'>[user] sears you!</span>")
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.adjust_fire_stacks(fire_stacks)
			M.IgniteMob()
		use_charge(user)
		return ..()
	else if(iswallturf(target))
		var/turf/wall = target
		playsound(wall, 'sound/weapons/sear.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You begin melting the [wall] with your hand...</span>")
		if(do_after(user, 10 SECONDS, wall))
			to_chat(user, "<span class='notice'>You melt the [wall] with your hand!</span>")
			wall = wall.Melt()
			wall.burn_tile()
			use_charge(user)
			return ..()
		else
			to_chat(user, "<span class='notice'>You fail to melt the wall with your hand.</span>")
	else if(!isopenturf(target) || !isitem(target))
		use_charge()

/obj/effect/proc_holder/spell/aoe_turf/repulse/scorching_rebuke
	name = "Scorching Rebuke"
	desc = "Unleash a burst of flame, setting those nearby alight and throwing them out of your way."
	sound = 'sound/magic/repulse.ogg'
	range = 2
	invocation_type = INVOCATION_NONE
	charge_max = 15 SECONDS
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	action_icon_state = "scorching_rebuke"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	anti_magic_check = FALSE
	sparkle_path = /obj/effect/temp_visual/fire

	var/fire_stacks = 2

/obj/effect/proc_holder/spell/aoe_turf/repulse/scorching_rebuke/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/atom/movable/AM in T)
			if(isliving(AM))
				var/mob/living/L = AM
				L.adjust_fire_stacks(fire_stacks)
				L.IgniteMob()
	..(targets, user, 0)

/////////////////////////////////////////
//                                     //
//          SPECIAL ABILITIES          //
//                                     //
/////////////////////////////////////////

/obj/effect/proc_holder/spell/targeted/fire_sworn/fire_form
	name = "Fire Form"
	desc = "Meld flesh and flame temporarily, engulfing yourself and those nearby in fire."
	requires_heretic_focus = FALSE
	invocation = ""
	invocation_type = INVOCATION_NONE
	action_icon = 'icons/mob/actions/actions_mutant.dmi'
	action_icon_state = "fire_ring"
	action_background_icon_state = "bg_spell"
	duration = 30 SECONDS
	charge_max = 1 MINUTES
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/aoe_turf/mutant/rain_fire
	name = "Rain Fire"
	desc = "Create fire above, and rain hell on those below."
	range = 2
	charge_max = 20 SECONDS
	action_icon_state = "fire_rain"
	action_background_icon_state = "bg_spell"
	var/waves = 5

/obj/effect/proc_holder/spell/aoe_turf/mutant/rain_fire/cast(list/targets, mob/user = usr)
	for(var/i = 1 to waves)
		for(var/turf in RANGE_TURFS(2, user))
			var/turf/T = turf
			if(prob(30))
				new /obj/effect/temp_visual/target/mutant(T)
		sleep(12)

/obj/effect/temp_visual/target/mutant/fall(list/flame_hit)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, 1)
	new /obj/effect/temp_visual/fireball(T)
	sleep(duration)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.gets_drilled()
	playsound(T, "explosion", 80, 1)
	new /obj/effect/hotspot(T)
	T.hotspot_expose(700, 50, 1)
	for(var/mob/living/L in T.contents)
		if(L.mind?.has_antag_datum(/datum/antagonist/mutant))
			continue
		if(islist(flame_hit) && !flame_hit[L])
			L.adjustFireLoss(40)
			to_chat(L, "<span class='userdanger'>You're hit by raining fire!</span>")
			flame_hit[L] = TRUE
		else
			L.adjustFireLoss(10) //if we've already hit them, do way less damage

/obj/effect/proc_holder/spell/mutant/blistering_rage
	name = "Blistering Rage"
	desc = "Channel your anger into determination, using fire to mend yourself slightly and gaining a temporary speed boost."
	action_icon_state = "fire_trap"
	charge_max = 30 SECONDS

/obj/effect/proc_holder/spell/mutant/blistering_rage/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/U = user
	U.adjustBruteLoss(-10, FALSE)
	U.adjustFireLoss(-10, FALSE)
	U.adjustToxLoss(-10, FALSE)
	U.adjustOxyLoss(-10, FALSE)
	U.add_movespeed_modifier(MOVESPEED_ID_PYRO_RAGE, update=TRUE, priority=100, multiplicative_slowdown=-0.2, blacklisted_movetypes=(FLYING|FLOATING))
	addtimer(CALLBACK(U, TYPE_PROC_REF(/mob, remove_movespeed_modifier), MOVESPEED_ID_PYRO_RAGE, TRUE), 10 SECONDS)
