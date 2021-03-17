#include "util_i_debug"
#include "util_i_csvlists"
#include "util_i_chat"
#include "util_i_libraries"
#include "quest_i_main"

#include "event_control"
#include "dlg_i_dialogs"

void SetObjectEvents()
{
    string sSigns = "sign,sign_trigger_1,sign_trigger_2,sign_trigger_3";

    int n, nCount = CountList(sSigns);
    for (n = 0; n < nCount; n++)
    {
        string sSign = "discovery_quest_" + GetListItem(sSigns, n);
        object oSign = GetObjectByTag(sSign);
        StripPlaceableEvents(oSign);
    }

    object oSign = GetObjectByTag("kill_quest_sign");
    StripPlaceableEvents(oSign);

    oSign = GetObjectByTag("gather_quest_sign");
    StripPlaceableEvents(oSign);

    object oTrigger = GetObjectByTag("kill_quest_trigger_reset");
    StripTriggerEvents(oTrigger);

    object oWagon = GetObjectByTag("quest_deliver_wagon");
    StripPlaceableEvents(oWagon);
    SetEventScript(oWagon, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, "hook_placeable02");
    
    // Setup Dialogs
    SetLocalString(GetObjectByTag("discovery_quest_sign"), "*Dialog", "DiscoveryDialog");
    SetLocalString(GetObjectByTag("kill_quest_sign"), "*Dialog", "KillDialog");
    SetLocalString(GetObjectByTag("gather_quest_sign"), "*Dialog", "GatherDialog");
}

void main()
{
    string sEvent = GetLocalString(GetModule(), "CURRENT_EVENT");

    if (sEvent == "OnModuleLoad")
    {
        Notice("Running MODULE LOAD");

        SetDebugLevel(DEBUG_LEVEL_DEBUG, GetModule());
        SetDebugLogging(DEBUG_LOG_ALL);
        
        LoadLibrary("quest_l_dialog");

        SetObjectEvents();

        CreateModuleQuestTables(TRUE);
        ExecuteScript("quest_define", GetModule());
    }
    else if (sEvent == "OnClientEnter")
    {
        object oPC = GetEnteringObject();
        CreatePCQuestTables(oPC);
        //CleanPCQuestTables(oPC);
        UpdateJournalQuestEntries(oPC);
    }
    else if (sEvent == "OnPlayerChat")
    {
        object oPC = GetPCChatSpeaker();

        string sMessage = GetPCChatMessage();
        if (ParseCommandLine(oPC, sMessage))
        {
            SetPCChatMessage();

            string sCommand = GetChatCommand(oPC);

            if (sCommand == "quest")
                ExecuteScript("quest_i_chat", oPC);
            else if (sCommand == "debug")
            {
                int nCurrentLevel = GetDebugLevel(GetModule());

                if (nCurrentLevel == DEBUG_LEVEL_DEBUG)
                {
                    SetDebugLevel(DEBUG_LEVEL_NOTICE, GetModule());
                    Notice(HexColorString("Debug Verbosity Decreased (Level: NOTICE)", COLOR_PINK));
                }
                else
                {
                    SetDebugLevel(DEBUG_LEVEL_DEBUG, GetModule());
                    Notice(HexColorString("Debug Verbosity Decreased (Level: DEBUG)", COLOR_PINK));
                }
            }
        }
    }
    else if (sEvent == "OnAcquireItem")
    {
        object oItem = GetModuleItemAcquired();
        object oPC = GetModuleItemAcquiredBy();

        if (GetIsPC(oPC))
            SignalQuestStepProgress(oPC, oItem, QUEST_OBJECTIVE_GATHER);
    }
    else if (sEvent == "OnUnAcquireItem")
    {
        object oItem = GetModuleItemLost();
        object oPC = GetModuleItemLostBy();

        if (GetIsPC(oPC))
            SignalQuestStepRegress(oPC, oItem, QUEST_OBJECTIVE_GATHER);
    }
    else if (sEvent == "OnCreatureConversation")
    {

    }
    else if (sEvent == "OnCreatureDeath")
    {
        object oVictim = OBJECT_SELF;
        object oPC = GetLastKiller();

        if (!GetIsPC(oPC))
            oPC = GetLocalObject(oVictim, "QUEST_PROTECTOR");


        if (GetIsObjectValid(oPC) && GetIsPC(oPC))
            SignalQuestStepProgress(oPC, oVictim, QUEST_OBJECTIVE_KILL);
    }
    else if (sEvent == "OnCreatureSpawn")
    {

    }
    else if (sEvent == "OnTriggerEnter")
    {
        object oTrigger = OBJECT_SELF;
        object oPC = GetEnteringObject();

        if (GetTag(oTrigger) == "kill_quest_trigger_reset")
        {
            if (!GetIsPC(oPC) && (!GetIsPC(GetMaster(oPC))))
                DestroyObject(oPC);

            return;
        }

        SignalQuestStepProgress(oPC, oTrigger, QUEST_OBJECTIVE_DISCOVER);
    }
    else if (sEvent == "OnPlaceableUsed")
    {
        object oPlaceable = OBJECT_SELF;
        object oPC = GetLastUsedBy();

        string sDialog = GetLocalString(oPlaceable, "*Dialog");
        if (sDialog != "")
            StartDialog(oPC, oPlaceable, sDialog, FALSE, TRUE, TRUE);
    }
    else if (sEvent == "OnPlaceableClose")
    {
        object oPlaceable = OBJECT_SELF;
        object oPC = GetLastClosedBy();

        if (GetTag(oPlaceable) == "quest_deliver_wagon")
        {
            object oItem = GetFirstItemInInventory(oPlaceable);
            while (GetIsObjectValid(oItem))
            {
                SignalQuestStepProgress(oPC, oPlaceable, QUEST_OBJECTIVE_DELIVER, GetTag(oItem));
                DestroyObject(oItem);

                oItem = GetNextItemInInventory(oPlaceable);
            }
        }
    }
}
