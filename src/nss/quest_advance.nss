
#include "event_control"
#include "quest_i_main"

void main()
{
    object oPC = OBJECT_SELF;
    string sCurrentQuest = GetCurrentQuest();
    int nCurrentStep = GetCurrentQuestStep();

    // nCurrentStep will only be valid for quest advance scripts. never for accept,
    // compete or fail

    if (sCurrentQuest == "quest_kill_ordered")
    {
        if (nCurrentStep == 1)
            SetImmortal(oPC, TRUE);

        object oWP = GetWaypointByTag("quest_kill_" + IntToString(nCurrentStep));
        location lWP = GetLocation(oWP);
        object oTarget = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP);
        
        StripCreatureEvents(oTarget);
    }
    else if (sCurrentQuest == "quest_kill_random")
    {
        if (nCurrentStep == 1)
            SetImmortal(oPC, TRUE);

        object oWP = GetWaypointByTag("quest_kill_1");
        location lWP = GetLocation(oWP);
        object oTarget1 = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP);
        object oTarget2 = CreateObject(OBJECT_TYPE_CREATURE, "nw_rat001", lWP);
        object oTarget3 = CreateObject(OBJECT_TYPE_CREATURE, "nw_bat", lWP);
        
        SetEventScript(oTarget1, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
        SetEventScript(oTarget2, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
        SetEventScript(oTarget3, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
    }
    else if (sCurrentQuest == "quest_kill_protect")
    {
        if (nCurrentStep == 1)
            SetImmortal(oPC, TRUE);

        object oWP1 = GetWaypointByTag("quest_kill_1");
        location lWP1 = GetLocation(oWP1);
    
        object oWP3 = GetWaypointByTag("quest_kill_3");
        location lWP3 = GetLocation(oWP3);

        int n = 0;
        for (n = 0; n < 5; n++)
        {
            object oTarget = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP1);
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
        }

        object oProtect = CreateObject(OBJECT_TYPE_CREATURE, "nw_oldman", lWP3);
        SetEventScript(oProtect, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
        SetLocalObject(oProtect, "QUEST_PROTECTOR", oPC);
    }
    else if (sCurrentQuest == "quest_kill_timed")
    {
        if (nCurrentStep == 1)
            SetImmortal(oPC, TRUE);
    
        object oWP2 = GetWaypointByTag("quest_kill_2");
        location lWP2 = GetLocation(oWP2);

        int n = 0;
        for (n = 0; n < 5; n++)
        {
            object oTarget = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP2);
            SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
        }
    }
    else if (sCurrentQuest == "quest_discovery_ordered" || sCurrentQuest == "quest_discovery_random")
    {
        StripTriggerEvents(GetObjectByTag("quest_trigger_1"));
        StripTriggerEvents(GetObjectByTag("quest_trigger_2"));
        StripTriggerEvents(GetObjectByTag("quest_trigger_3"));
    }
    else if (sCurrentQuest == "quest_protect_only")
    {
        object oProtect = CreateObject(OBJECT_TYPE_CREATURE, "nw_oldman", GetLocation(oPC));
        SetEventScript(oProtect, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
        SetLocalObject(oProtect, "QUEST_PROTECTOR", oPC);
    }
}
