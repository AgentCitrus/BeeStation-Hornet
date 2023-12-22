/obj/item/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	custom_price = 10
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=20)
	actions_types = list(/datum/action/item_action/toggle_light)
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 1
	light_on = FALSE
	var/on = FALSE
	var/sound_on = 'sound/items/flashlight_on.ogg'
	var/sound_off = 'sound/items/flashlight_off.ogg'


/obj/item/flashlight/Initialize(mapload)
	. = ..()
	if(icon_state == "[initial(icon_state)]-on")
		on = TRUE
	update_brightness()

/obj/item/flashlight/proc/update_brightness(mob/user)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(sound_on)
			playsound(src, sound_on, 25, 1)
	else
		icon_state = initial(icon_state)
		if(sound_off)
			playsound(src, sound_off, 25, 1)
	set_light_on(on)
	if(light_system == STATIC_LIGHT)
		update_light()


/obj/item/flashlight/attack_self(mob/user)
	on = !on
	update_brightness(user)
	update_action_buttons()
	return 1

/obj/item/flashlight/suicide_act(mob/living/carbon/human/user)
	if (user.is_blind())
		user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on... but [user.p_theyre()] blind!</span>")
		return SHAME
	user.visible_message("<span class='suicide'>[user] is putting [src] close to [user.p_their()] eyes and turning it on! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return FIRELOSS

/obj/item/flashlight/attack(mob/living/carbon/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	if (!istype(M) || !on || !user.is_zone_selected(BODY_ZONE_HEAD, precise = FALSE))
		return ..()

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))	//too dumb to use flashlight properly
		return ..()	//just hit them in the head

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(!M.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, "<span class='warning'>[M] doesn't have a head!</span>")
		return

	if(light_power < 1)
		to_chat(user, "<span class='warning'>\The [src] isn't bright enough to see anything!</span> ")
		return

	user.visible_message("<span class='notice'>[user] shines the light at [M]!</span>", ignored_mobs = list(user))

	var/list/results = list()

	results += "<span class='notice'><b>You shine the light at [M]...</b></span>"

	/**
	 * Handle mouth
	 */

	if(M.is_mouth_covered())
		results += "<span class='notice'>[M.p_their()] mouth is covered by [(M.head && M.head.flags_cover & HEADCOVERSMOUTH) ? "a helmet" : "a mask"].</span>"
	else
		var/their = M.p_their()

		var/list/mouth_organs = new
		for(var/obj/item/organ/O in M.internal_organs)
			if(O.zone == BODY_ZONE_PRECISE_MOUTH)
				mouth_organs.Add(O)
		var/organ_list = ""
		var/organ_count = LAZYLEN(mouth_organs)
		if(organ_count)
			for(var/I in 1 to organ_count)
				if(I > 1)
					if(I == mouth_organs.len)
						organ_list += ", and "
					else
						organ_list += ", "
				var/obj/item/organ/O = mouth_organs[I]
				organ_list += (O.gender == "plural" ? O.name : "\an [O.name]")

		var/pill_count = 0
		for(var/datum/action/item_action/hands_free/activate_pill/AP in M.actions)
			pill_count++

		if(M == user)
			var/can_use_mirror = FALSE
			if(isturf(user.loc))
				var/obj/structure/mirror/mirror = locate(/obj/structure/mirror, user.loc)
				if(mirror)
					switch(user.dir)
						if(NORTH)
							can_use_mirror = mirror.pixel_y > 0
						if(SOUTH)
							can_use_mirror = mirror.pixel_y < 0
						if(EAST)
							can_use_mirror = mirror.pixel_x > 0
						if(WEST)
							can_use_mirror = mirror.pixel_x < 0

			if(!can_use_mirror)
				to_chat(user, "<span class='notice'>You can't see anything without a mirror.</span>")
				return
			if(organ_count)
				results += "<span class='notice'>Inside your mouth [organ_count > 1 ? "are" : "is"] [organ_list].</span>"
			else
				results += "<span class='notice'>There's nothing inside your mouth.</span>"
			if(pill_count)
				results += "<span class='notice'>You have [pill_count] implanted pill[pill_count > 1 ? "s" : ""].</span>"

		else
			user.visible_message("<span class='notice'>[user] directs [src] to [M]'s mouth.</span>",\
									"<span class='notice'>You direct [src] to [M]'s mouth.</span>")
			if(organ_count)
				results += "<span class='notice'>Inside [their] mouth [organ_count > 1 ? "are" : "is"] [organ_list].</span>"
			else
				results += "<span class='notice'>[M] doesn't have any organs in [their] mouth.</span>"
			if(pill_count)
				results += "<span class='notice'>[M] has [pill_count] pill[pill_count > 1 ? "s" : ""] implanted in [their] teeth.</span>"

	/**
	 * Handle eyes
	 */

	var/obj/item/organ/eyes/E = M.getorganslot(ORGAN_SLOT_EYES)

	if((M.head && M.head.flags_cover & HEADCOVERSEYES) || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSEYES) || (M.glasses && M.glasses.flags_cover & GLASSESCOVERSEYES))
		results += "<span class='notice'>[M.p_their()] eyes are covered by [(M.head && M.head.flags_cover & HEADCOVERSEYES) ? "a helmet" : (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSEYES) ? "a mask": "some glasses"].</span>"
	else if(!E)
		results += "<span class='danger'>[M.p_they()] doesn't have any eyes!</span>"
	else if(M == user)
		//they're using it on themselves, give less of a report
		if(M.flash_act(visual = 1))
			to_chat(user, "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
		else
			to_chat(user, "<span class='notice'>You wave the light in front of your eyes.</span>")
		return
	else
		if(M.stat == DEAD || (M.is_blind()) || !M.flash_act(visual = 1)) //mob is dead or fully blind
			results += "<span class='warning'>[M.p_their(TRUE)] pupils don't react to the light!</span>"
		else if(M.has_dna() && M.dna.check_mutation(XRAY))	//mob has X-ray vision
			results += "<span class='danger'>[M.p_their(TRUE)] pupils give an eerie glow!</span>"
		else //they're okay!
			results += "<span class='notice'>[M.p_their(TRUE)] pupils narrow.</span>"

	to_chat(user, EXAMINE_BLOCK(jointext(results, "\n")))

/obj/item/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff. It can also be used to create a hologram to alert people of incoming medical assistance."
	icon_state = "penlight"
	item_state = ""
	flags_1 = CONDUCT_1
	light_range = 2
	var/holo_cooldown = 0

/obj/item/flashlight/pen/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		if(holo_cooldown > world.time)
			to_chat(user, "<span class='warning'>[src] is not ready yet!</span>")
			return
		var/T = get_turf(target)
		if(locate(/mob/living) in T)
			new /obj/effect/temp_visual/medical_holosign(T,user) //produce a holographic glow
			holo_cooldown = world.time + 100
			return

/obj/effect/temp_visual/medical_holosign
	name = "medical holosign"
	desc = "A small holographic glow that indicates a medic is coming to treat a patient."
	icon_state = "medi_holo"
	duration = 30

/obj/effect/temp_visual/medical_holosign/Initialize(mapload, creator)
	. = ..()
	playsound(loc, 'sound/machines/ping.ogg', 50, 0) //make some noise!
	if(creator)
		visible_message("<span class='danger'>[creator] created a medical hologram!</span>")


/obj/item/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	item_state = "seclite"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 9 // Not as good as a stun baton.
	light_range = 5 // A little better than the standard flashlight.
	hitsound = 'sound/weapons/genhit1.ogg'

// the desk lamps are a bit special
/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	light_range = 5
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	custom_materials = null
	on = TRUE


// green-shaded desk lamp
/obj/item/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"



/obj/item/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

//Bananalamp
/obj/item/flashlight/lamp/bananalamp
	name = "banana lamp"
	desc = "Only a clown would think to make a ghetto banana-shaped lamp. Even has a goofy pullstring."
	icon_state = "bananalamp"
	item_state = "bananalamp"

// FLARES

/obj/item/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	w_class = WEIGHT_CLASS_SMALL
	light_range = 7 // Pretty bright.
	icon_state = "flare"
	item_state = "flare"
	actions_types = list()
	/// How many seconds of fuel we have left
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	heat = 1000
	light_color = LIGHT_COLOR_FLARE
	grind_results = list(/datum/reagent/sulfur = 15)
	sound_on = 'sound/items/matchstick_lit.ogg'
	sound_off = null

/obj/item/flashlight/flare/Initialize(mapload)
	. = ..()
	fuel = rand(1600, 2000)

/obj/item/flashlight/flare/process(delta_time)
	open_flame(heat)
	fuel = max(fuel -= delta_time, 0)
	if(fuel <= 0 || !on)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty"
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/ignition_effect(atom/A, mob/user)
	if(fuel && on)
		. = "<span class='notice'>[user] lights [A] with [src] like a real \
			badass.</span>"
	else
		. = ""

/obj/item/flashlight/flare/proc/turn_off()
	on = FALSE
	force = initial(src.force)
	damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

	remove_emitter("spark")
	remove_emitter("smoke")

/obj/item/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(fuel <= 0)
		if(user)
			balloon_alert(user, "out of fuel!")
		return
	if(on)
		if(user)
			balloon_alert(user, "already lit!")
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] lights \the [src].</span>", "<span class='notice'>You light \the [src]!</span>")
		force = on_damage
		damtype = BURN
		if(!istype(src, /obj/item/flashlight/flare/torch))
			add_emitter(/obj/emitter/sparks/flare, "spark", 10)
			add_emitter(/obj/emitter/flare_smoke, "smoke", 9)
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/is_hot()
	return on * heat

/obj/item/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some leaves and a log."
	w_class = WEIGHT_CLASS_BULKY
	light_range = 4
	icon_state = "torch"
	item_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	light_color = LIGHT_COLOR_ORANGE
	on_damage = 10
	slot_flags = null

/obj/item/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	item_state = "lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	desc = "A mining lantern."
	light_range = 6			// luminosity when on

/obj/item/flashlight/lantern/heirloom_moth
	name = "old lantern"
	desc = "An old lantern that has seen plenty of use."
	light_range = 4

/obj/item/flashlight/lantern/syndicate
	name = "suspicious lantern"
	desc = "A suspicious looking lantern."
	icon_state = "syndilantern"
	item_state = "syndilantern"
	light_range = 10

/obj/item/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "Extract from a yellow slime. It emits a strong light when squeezed."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "slime"
	item_state = "slime"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = null
	light_range = 6 //luminosity when on

/obj/item/flashlight/emp
	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_timer = 0
	/// How many seconds between each recharge
	var/charge_delay = 20

/obj/item/flashlight/emp/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/flashlight/emp/process(delta_time)
	charge_timer += delta_time
	if(charge_timer < charge_delay)
		return FALSE
	charge_timer -= charge_delay
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE

/obj/item/flashlight/emp/attack(mob/living/M, mob/living/user)
	if(on && (user.is_zone_selected(BODY_ZONE_PRECISE_EYES, precise_only = TRUE) || user.is_zone_selected(BODY_ZONE_PRECISE_MOUTH, precise_only = TRUE))) // call original attack when examining organs
		..()
	return

/obj/item/flashlight/emp/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(emp_cur_charges > 0)
		emp_cur_charges -= 1

		if(ismob(A))
			var/mob/M = A
			log_combat(user, M, "attacked", "EMP-light")
			M.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].", \
								"<span class='userdanger'>[user] blinks \the [src] at you.")
		else
			A.visible_message("<span class='danger'>[user] blinks \the [src] at \the [A].")
		to_chat(user, "\The [src] now has [emp_cur_charges] charge\s.")
		A.emp_act(EMP_HEAVY)
	else
		to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")
	return

/obj/item/flashlight/emp/debug //for testing emp_act()
	name = "debug EMP flashlight"
	emp_max_charges = 100
	emp_cur_charges = 100

// Glowsticks, in the uncomfortable range of similar to flares,
// but not similar enough to make it worth a refactor
/obj/item/flashlight/glowstick
	name = "glowstick"
	desc = "A military-grade glowstick."
	custom_price = 10
	w_class = WEIGHT_CLASS_SMALL
	light_range = 4
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	item_state = "glowstick"
	grind_results = list(/datum/reagent/phenol = 15, /datum/reagent/hydrogen = 10, /datum/reagent/oxygen = 5) //Meth-in-a-stick
	var/burn_pickup = FALSE	//If true, fuel will only decrease after being picked up or used in hand (Useful for mapping)
	var/fuel = 0 // How many seconds of fuel we have left


/obj/item/flashlight/glowstick/Initialize(mapload)
	fuel = rand(3200, 4000)
	set_light_color(color)
	. = ..()

/obj/item/flashlight/glowstick/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/flashlight/glowstick/process(delta_time)
	fuel = max(fuel - delta_time, 0)
	if(fuel <= 0)
		turn_off()
		STOP_PROCESSING(SSobj, src)
		update_icon()

/obj/item/flashlight/glowstick/proc/turn_off()
	on = FALSE
	update_icon()

/obj/item/flashlight/glowstick/update_icon()
	item_state = "glowstick"
	cut_overlays()
	if(fuel <= 0)
		icon_state = "glowstick-empty"
		cut_overlays()
		set_light_on(FALSE)
	else if(on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		add_overlay(glowstick_overlay)
		item_state = "glowstick-on"
		set_light_on(TRUE)
	else
		icon_state = "glowstick"
		cut_overlays()

/obj/item/flashlight/glowstick/pickup(mob/user)
	..()
	if(burn_pickup && on)
		burn_pickup = FALSE
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/glowstick/attack_self(mob/user)
	if(fuel <= 0)
		to_chat(user, "<span class='notice'>[src] is spent.</span>")
		return
	if(on)
		to_chat(user, "<span class='notice'>[src] is already lit.</span>")
		return

	. = ..()
	if(.)
		user.visible_message("<span class='notice'>[user] cracks and shakes [src].</span>", "<span class='notice'>You crack and shake [src], turning it on!</span>")
		START_PROCESSING(SSobj, src)
		burn_pickup = FALSE

/obj/item/flashlight/glowstick/suicide_act(mob/living/carbon/human/user)
	if(!fuel)
		user.visible_message("<span class='suicide'>[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but it's empty!</span>")
		return SHAME
	var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		user.visible_message("<span class='suicide'>[user] is trying to squirt [src]'s fluids into [user.p_their()] eyes... but [user.p_they()] don't have any!</span>")
		return SHAME
	user.visible_message("<span class='suicide'>[user] is squirting [src]'s fluids into [user.p_their()] eyes! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	fuel = 0
	return FIRELOSS

/obj/item/flashlight/glowstick/red
	name = "red glowstick"
	color = LIGHT_COLOR_RED

/obj/item/flashlight/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE

/obj/item/flashlight/glowstick/cyan
	name = "cyan glowstick"
	color = LIGHT_COLOR_CYAN

/obj/item/flashlight/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE

/obj/item/flashlight/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_YELLOW

/obj/item/flashlight/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK

/obj/effect/spawner/lootdrop/glowstick
	name = "random colored glowstick"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "random_glowstick"

/obj/effect/spawner/lootdrop/glowstick/Initialize(mapload)
	loot = typesof(/obj/item/flashlight/glowstick)
	. = ..()

/obj/effect/spawner/lootdrop/glowstick/lit/Initialize(mapload)
	. = ..()
	var/obj/item/flashlight/glowstick/found = locate() in get_turf(src)
	if(!found)
		return
	found.on = TRUE
	found.update_icon()
	found.update_brightness()

	for(var/X in found.actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	found.burn_pickup = TRUE

/obj/item/flashlight/spotlight //invisible lighting source
	name = "disco light"
	desc = "Groovy..."
	icon_state = null
	light_system = STATIC_LIGHT
	light_range = 4
	light_power = 10
	alpha = 0
	layer = 0
	on = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///Boolean that switches when a full color flip ends, so the light can appear in all colors.
	var/even_cycle = FALSE
	///Base light_range that can be set on Initialize to use in smooth light range expansions and contractions.
	var/base_light_range = 4


/obj/item/flashlight/spotlight/Initialize(mapload, _light_range, _light_power, _light_color)
	. = ..()
	if(!isnull(_light_range))
		base_light_range = _light_range
		set_light_range(_light_range)
	if(!isnull(_light_power))
		set_light_power(_light_power)
	if(!isnull(_light_color))
		set_light_color(_light_color)


/obj/item/flashlight/flashdark
	name = "flashdark"
	desc = "A strange device manufactured with mysterious elements that somehow emits darkness. Or maybe it just sucks in light? Nobody knows for sure."
	icon_state = "flashdark"
	item_state = "flashdark"
	light_system = STATIC_LIGHT //The overlay light component is not yet ready to produce darkness.
	light_range = 0
	///Variable to preserve old lighting behavior in flashlights, to handle darkness.
	var/dark_light_range = 2.5
	///Variable to preserve old lighting behavior in flashlights, to handle darkness.
	var/dark_light_power = -3


/obj/item/flashlight/flashdark/update_brightness(mob/user)
	. = ..()
	if(on)
		set_light(dark_light_range, dark_light_power)
	else
		set_light(0)


/obj/item/flashlight/eyelight
	name = "eyelight"
	desc = "This shouldn't exist outside of someone's head, how are you seeing this?"
	light_range = 15
	light_power = 1
	flags_1 = CONDUCT_1
	item_flags = DROPDEL
	actions_types = list()
