/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "singularity_hammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_string = "LORD SINGULOTH HIMSELF"
	total_mass = TOTAL_MASS_MEDIEVAL_WEAPON
	var/charged = 5
	var/wielded = FALSE // track wielded status on item

/obj/item/singularityhammer/New()
	..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	START_PROCESSING(SSobj, src)

/obj/item/singularityhammer/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_multiplier=4, icon_wielded="singularity_hammer1")

/// triggered on wield of two handed item
/obj/item/singularityhammer/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/singularityhammer/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/singularityhammer/update_icon_state()
	icon_state = "singularity_hammer0"

/obj/item/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/singularityhammer/process()
	if(charged < 5)
		charged++
	return

/obj/item/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/X in orange(5,pull))
		if(ismovable(X))
			var/atom/movable/A = X
			if(A == wielder)
				continue
			if(A && !A.anchored && !ishuman(X))
				step_towards(A,pull)
				step_towards(A,pull)
				step_towards(A,pull)
			else if(ishuman(X))
				var/mob/living/carbon/human/H = X
				if(istype(H.shoes, /obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						continue
				H.apply_effect(20, EFFECT_KNOCKDOWN, 0)
				step_towards(H,pull)
				step_towards(H,pull)
				step_towards(H,pull)

/obj/item/singularityhammer/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(wielded)
		if(charged == 5)
			charged = 0
			if(istype(A, /mob/living/))
				var/mob/living/Z = A
				Z.take_bodypart_damage(20,0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target,user)

/obj/item/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	total_mass = TOTAL_MASS_MEDIEVAL_WEAPON
	var/wielded = FALSE // track wielded status on item

/obj/item/mjollnir/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/mjollnir/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_multiplier=5, icon_wielded="mjollnir1", attacksound="sparks")

/// triggered on wield of two handed item
/obj/item/mjollnir/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/mjollnir/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/mjollnir/update_icon_state()
	icon_state = "mjollnir0"

/obj/item/mjollnir/proc/shock(mob/living/target)
	target.Stun(60)
	var/datum/effect_system/lightning_spread/s = new /datum/effect_system/lightning_spread
	s.set_up(5, 1, target.loc)
	s.start()
	target.visible_message("<span class='danger'>[target.name] was shocked by [src]!</span>", \
		"<span class='userdanger'>You feel a powerful shock course through your body sending you flying!</span>", \
		"<span class='italics'>You hear a heavy electrical crack!</span>")
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)
	return

/obj/item/mjollnir/attack(mob/living/M, mob/user)
	..()
	if(wielded)
		shock(M)

/obj/item/mjollnir/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		shock(hit_atom)
