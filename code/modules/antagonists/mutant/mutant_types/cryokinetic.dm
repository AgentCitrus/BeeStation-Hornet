/datum/mutant_type/cryokinetic
	name = "Cryokinetic"
	active_abilities = list(
		/obj/effect/proc_holder/spell/aimed/mutant/ice_knives,
		/obj/effect/proc_holder/spell/aimed/mutant/freezing_sphere,
		/obj/effect/proc_holder/spell/targeted/touch/mutant/chill_touch,
		/obj/effect/proc_holder/spell/targeted/mutant/ice_running,
		/obj/effect/proc_holder/spell/targeted/mutant/shatter,
		/obj/effect/proc_holder/spell/targeted/mutant/cryostasis,
		/obj/effect/proc_holder/spell/cone/staggered/mutant/frost_gust,
		/obj/effect/proc_holder/spell/aoe_turf/mutant/sublimation
	)
	passive_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_HEATWEAKNESS,
		TRAIT_HIGHPRESSUREWEAKNESS,
		TRAIT_NOSLIPICE
	)
	components = list(
		/datum/component/ice_running
	)
	special_abilities = list(

	)

/////////////////////////////////////////
//                                     //
//           ACTIVE ABILITIES          //
//                                     //
/////////////////////////////////////////

/obj/effect/proc_holder/spell/aimed/mutant/ice_knives
	name = "Ice Knives"
	desc = "Throw 4 freezing ice daggers."
	range = 20
	charge_max = 5 SECONDS
	projectile_type = /obj/projectile/temp/cryo/mutant
	base_icon_state = "icicle"
	action_icon_state = "icicle0"
	sound = 'sound/weapons/pierce.ogg'
	active_msg = "You form ice knives between your fingers..."
	deactive_msg = "You let the ice knives melt..."
	projectiles_per_fire = 4
	var/projectile_initial_spread_amount = 10

/obj/effect/proc_holder/spell/aimed/mutant/ice_knives/ready_projectile(obj/projectile/P, atom/target, mob/user, iteration)
	var/rand_spr = rand()
	var/total_angle = projectile_initial_spread_amount * 2
	var/adjusted_angle = total_angle - ((projectile_initial_spread_amount / projectiles_per_fire) * 0.5)
	var/one_fire_angle = adjusted_angle / projectiles_per_fire
	var/current_angle = iteration * one_fire_angle * rand_spr - (projectile_initial_spread_amount / 2)
	P.preparePixelProjectile(target, user, null, current_angle)

/obj/projectile/temp/cryo/mutant
	name = "ice knife"
	icon_state = "ice_3"
	damage_type = BRUTE
	armor_flag = BULLET
	range = 20
	damage = 10
	temperature = -100

/obj/effect/proc_holder/spell/aimed/mutant/freezing_sphere
	name = "Freezing Sphere"
	desc = "Launch a sphere that freezes tiles and people in a radius upon impact."
	range = 20
	charge_max = 20 SECONDS
	projectile_type = /obj/projectile/temp/freezing_sphere
	base_icon_state = "freezing_sphere"
	action_icon_state = "freezing_sphere0"
	active_msg = "You begin concentrating a sphere of cold between your hands..."
	deactive_msg = "You let the freezing energy dissipate..."

/obj/projectile/temp/freezing_sphere
	name = "freezing sphere"
	icon_state = "ice_1"
	hitsound = 'sound/magic/freezing_sphere.ogg'
	hitsound_wall = 'sound/magic/freezing_sphere.ogg'
	range = 20
	damage = 20
	temperature = -300

/obj/projectile/temp/freezing_sphere/on_hit(atom/target, blocked = FALSE)
	. = ..()
	for(var/turf/turf as() in RANGE_TURFS(2, target))
		if(isopenturf(turf))
			var/turf/open/O = turf
			O.freeze_turf()
			for(var/mob/living/L in O)
				L.adjust_bodytemperature(temperature*0.5)
	..()

/obj/projectile/temp/freezing_sphere/on_range()
	for(var/turf/turf as() in RANGE_TURFS(2, src))
		if(isopenturf(turf))
			var/turf/open/O = turf
			O.freeze_turf()
			for(var/mob/living/L in O)
				L.adjust_bodytemperature(temperature*0.5)
	return ..()

/obj/effect/proc_holder/spell/targeted/touch/mutant/chill_touch
	name = "Chill Touch"
	desc = "Concentrate freezing energy into your hand, encasing those you grasp in an ice cube or freezing tiles around you."
	drawmessage = "You focus on cooling your hand until it is freezing..."
	dropmessage = "You let heat enter your hand once more..."
	hand_path = /obj/item/melee/touch_attack/chill_touch
	charge_max = 10 SECONDS
	base_icon_state = "chill_touch"
	action_icon_state = "chill_touch"

/obj/item/melee/touch_attack/chill_touch
	name = "chill touch"
	desc = "Your hand feels delightfully cool, despite its subzero temperature."
	catchphrase = null
	icon_state = "chill_touch"
	item_state = "chill_touch"
	hitsound = 'sound/magic/freeze.ogg'
	on_use_sound = 'sound/magic/freeze.ogg'

/obj/item/melee/touch_attack/chill_touch/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity)
		return
	if(isliving(target))
		var/mob/living/T = target
		T.visible_message("<span class='danger'>[user] freezes [T]!</span>","<span class='userdanger'>[user] freezes you!</span>")
		T.apply_status_effect(STATUS_EFFECT_FROZEN)
		use_charge(user)
		return ..()
	else if(isopenturf(target))
		for(var/turf/open/OT as() in RANGE_TURFS(2, target))
			if(isopenturf(OT))
				OT.freeze_turf()
		use_charge(user)
		return ..()
	else
		return

/obj/effect/proc_holder/spell/targeted/mutant/ice_running
	name = "Ice Running"
	desc = "Freeze the floor around you as you run, slipping others and allowing you to move faster."
	base_icon_state = "ice_running"
	action_icon_state = "ice_running"
	range = -1
	charge_max = 45 SECONDS
	include_user = TRUE

	var/duration = 15 SECONDS
	var/freeze_duration = 1 SECONDS
	var/mob/current_user
	var/is_freezing_area = FALSE

/obj/effect/proc_holder/spell/targeted/mutant/ice_running/cast(list/targets, mob/user)
	. = ..()
	current_user = user
	is_freezing_area = TRUE
	addtimer(CALLBACK(src, PROC_REF(remove), user), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/proc_holder/spell/targeted/mutant/ice_running/proc/remove()
	is_freezing_area = FALSE
	current_user = null

/obj/effect/proc_holder/spell/targeted/mutant/ice_running/process(delta_time)
	. = ..()
	if(!is_freezing_area)
		return
	if(current_user.stat == DEAD)
		remove()
		return
	if(!isturf(current_user.loc))
		return

	var/list/turfs_to_freeze = list(get_step(current_user, turn(current_user.dir, 180)), get_turf(current_user), get_step(current_user, current_user.dir))
	for(var/turf/open/T as() in turfs_to_freeze)
		if(isopenturf(T))
			T.freeze_turf(freeze_duration)

/obj/effect/proc_holder/spell/targeted/mutant/shatter
	name = "Shatter"
	desc = "Shatter a target, dealing additional damage based on how cold the target is."
	charge_max = 45 SECONDS
	range = 7
	selection_type = "range"
	base_icon_state = "chill_touch"
	action_icon_state = "chill_touch"
	var/max_damage = 50

/obj/effect/proc_holder/spell/targeted/mutant/shatter/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		revert_cast()
		return

	var/mob/living/target = targets[1]

	if(!isliving(target))
		to_chat(user, "<span class='notice'>You are unable to shatter [target]!</span>")
		revert_cast()
		return

	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>[target.p_theyre(TRUE)] too far away!</span>")
		revert_cast()
		return

	if(target.bodytemperature >= BODYTEMP_NORMAL)
		to_chat(user, "<span class='notice'>[target] isn't cold enough to be shattered!</span>")
		revert_cast()
		return

	var/damage_taken = min((BODYTEMP_NORMAL - target.bodytemperature) * 0.25, max_damage)

	target.visible_message("<span class='danger'>A sickening crack is heard from [target]!</span>", \
						   "<span class='danger'>You hear a sickening crack from within you as you feel both intense cold and intense pain!</span>")
	target.emote("scream")
	playsound(target, 'sound/effects/glassbr3.ogg', 100, 1)

	target.apply_damage(damage_taken, BRUTE)
	if(target.has_status_effect(STATUS_EFFECT_FROZEN))
		target.remove_status_effect(STATUS_EFFECT_FROZEN)

/////////////////////////////////////////
//                                     //
//          SPECIAL ABILITIES          //
//                                     //
/////////////////////////////////////////

/obj/effect/proc_holder/spell/targeted/mutant/cryostasis
	name = "Cryo Stasis"
	desc = "Manifest an ice cube around you, healing you but leaving you vulnerable."
	charge_max = 2 MINUTES
	base_icon_state = "cryo_stasis"
	action_icon_state = "cryo_stasis"
	range = -1
	include_user = TRUE

	var/duration = 30 SECONDS
	var/is_healing = FALSE
	var/mob/living/current_user

/obj/effect/proc_holder/spell/targeted/mutant/cryostasis/cast(list/targets, mob/user)
	. = ..()
	current_user = user
	is_healing = TRUE
	current_user.apply_status_effect(STATUS_EFFECT_FROZEN_CRYOSTASIS)
	addtimer(CALLBACK(src, PROC_REF(remove), user), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/proc_holder/spell/targeted/mutant/cryostasis/proc/remove()
	is_healing = FALSE
	current_user = null

/obj/effect/proc_holder/spell/targeted/mutant/cryostasis/process(delta_time)
	. = ..()
	if(!is_healing)
		return
	if(current_user.stat == DEAD)
		remove()
		return
	if(!current_user.has_status_effect(STATUS_EFFECT_FROZEN_CRYOSTASIS))
		remove()
		return

	current_user.adjustBruteLoss(-2*delta_time)
	current_user.adjustFireLoss(-2*delta_time)
	current_user.adjustToxLoss(-2*delta_time)
	current_user.adjustOxyLoss(-2*delta_time)

/obj/effect/proc_holder/spell/cone/staggered/mutant/frost_gust
	name = "Frost Gust"
	desc = "Let loose a gust of bitterly cold wind, freezing anything caught in its path."
	action_icon_state = "frost_gust"
	sound = 'sound/magic/frost_gust.ogg'
	charge_max = 30 SECONDS
	cone_levels = 5
	respect_density = TRUE

	var/freeze_duration = 10 SECONDS

/obj/effect/proc_holder/spell/cone/staggered/mutant/frost_gust/cast(list/targets,mob/user = usr)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/frost_gust(get_step(user,user.dir), user.dir)

/obj/effect/proc_holder/spell/cone/staggered/mutant/frost_gust/do_turf_cone_effect(turf/target_turf, level)
	. = ..()
	if(isopenturf(target_turf))
		var/turf/open/OT = target_turf
		OT.freeze_turf(freeze_duration, TRUE)

/obj/effect/proc_holder/spell/cone/staggered/mutant/frost_gust/do_mob_cone_effect(mob/living/target_mob, level)
	. = ..()
	if(target_mob == usr)
		return
	target_mob.apply_status_effect(STATUS_EFFECT_FROZEN)

/obj/effect/proc_holder/spell/cone/staggered/mutant/frost_gust/calculate_cone_shape(current_level)
	if(current_level == cone_levels)
		return 5
	else if(current_level == cone_levels-1)
		return 3
	else
		return 2

/obj/effect/temp_visual/dir_setting/frost_gust
	icon = 'icons/effects/160x160.dmi'
	icon_state = "frost_gust"
	duration = 3 SECONDS

/obj/effect/temp_visual/dir_setting/frost_gust/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

/obj/effect/proc_holder/spell/aoe_turf/mutant/sublimation
	name = "Sublimation"
	desc = "Instantly evaporate all ice turfs in view, burning those on top of them."
	action_icon_state = "sublimation"
	sound = 'sound/magic/smoke.ogg'
	charge_max = 30 SECONDS

	var/sublimation_damage = 30

/obj/effect/proc_holder/spell/aoe_turf/mutant/sublimation/cast(list/targets, mob/user)
	. = ..()
	for(var/turf/open/T as() in targets)
		var/datum/component/wet_floor/WF = T.GetComponent(/datum/component/wet_floor)
		if(isopenturf(T) && WF && (WF.lube_flags & FROZEN_TURF))
			T.MakeDry(TURF_WET_PERMAFROST, TRUE)
			new /obj/effect/temp_visual/sublimation(T)
			for(var/mob/living/L in T)
				playsound(L, 'sound/weapons/sear.ogg', 100, 1)
				L.visible_message("<span class='danger'>[L] is caught in a cloud of steam!</span>", \
								  "<span class='danger'>You are caught in a cloud of hot steam! It burns!</span>")
				L.adjustFireLoss(sublimation_damage)

/obj/effect/temp_visual/sublimation
	icon = 'icons/obj/mutant.dmi'
	icon_state = "steam"
	layer = FLY_LAYER
	duration = 1.6 SECONDS
	mouse_opacity = 0
