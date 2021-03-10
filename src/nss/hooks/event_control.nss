
void StripCreatureEvents(object oCreature)
{
    // Strip the ones we're not going to use
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");

    // Keep the one's we're using
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "hook_creature03");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
}

void StripTriggerEvents(object oTrigger)
{
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT, "");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT, "");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_USER_DEFINED_EVENT, "");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_TRAPTRIGGERED, "");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_DISARMED, "");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_CLICKED, "");

    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER, "hook_trigger02");
}

void StripPlaceableEvents(object oPlaceable)
{
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DISARM, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LOCK, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_OPEN, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED_EVENT, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DIALOGUE, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "");

    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USED, "hook_placeable12");
}

