/datum/job/caa
	title = "Corporate Affairs Agent"
	flag = CAA
	department_head = list("Captain")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Central Command"
	selection_color = "#ddddff"
	chat_color = "#50C878"
	exp_requirements = 840
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/caa

	access = list(ACCESS_CAA, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS,
				ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_RESEARCH, ACCESS_CARGO,
				ACCESS_BRIDGE)
	minimal_access = list(ACCESS_CAA, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS,
				ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_RESEARCH, ACCESS_CARGO,
				ACCESS_BRIDGE)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_CAA
	departments = DEPARTMENT_COMMAND | DEPARTMENT_SERVICE
	rpg_title = "Diplomat"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/caa
	)

/datum/outfit/job/caa
	name = "Corporate Affairs Agent"
	jobtype = /datum/job/caa

	id = /obj/item/card/id/job/caa
	belt = /obj/item/pda/caa
	ears = /obj/item/radio/headset/headset_caa
	uniform = /obj/item/clothing/under/suit/black
	suit = /obj/item/clothing/suit/toggle/caa/black
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase/caa
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clipboard
	neck = /obj/item/clothing/neck/tie/black
	glasses = /obj/item/clothing/glasses/sunglasses/advanced

	chameleon_extras = /obj/item/stamp/law

	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/caa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	H.grant_language(/datum/language/uncommon)
