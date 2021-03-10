// -----------------------------------------------------------------------------
//    File: dlg_l_demo.nss
//  System: Dynamic Dialogs (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This library contains some example dialogs that show the features of the Core
// Dialogs system. You can use it as a model for your own dialog libraries.
// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"

#include "quest_support"
#include "quest_i_main"
#include "quest_i_database"

void _ResetPCQuestData(object oPC, int nQuestID)
{
    Notice("Resetting data: " +
        "\n  oPC -> " + GetName(oPC) +
        "\n  Quest ID -> " + IntToString(nQuestID));

    DeletePCQuestProgress(oPC, nQuestID);
    ResetPCQuestData(oPC, nQuestID);
}

// -----------------------------------------------------------------------------
//                           Discovery Quest Dialog
// -----------------------------------------------------------------------------

const string DISCOVERY_DIALOG      = "DiscoveryDialog";
const string DISCOVERY_PAGE_MAIN   = "Discovery Main Page";

void DiscoveryDialog()
{
    object oPC = GetPCSpeaker();
    string sOrdered = "quest_discovery_ordered";
    string sRandom = "quest_discovery_random";

    int nOrderedID = GetQuestID(sOrdered);
    int nRandomID = GetQuestID(sRandom);

    int bHasOrdered = GetPCHasQuest(oPC, sOrdered);
    int bHasRandom = GetPCHasQuest(oPC, sRandom);

    int bOrderedComplete = bHasOrdered ? GetIsPCQuestComplete(oPC, nOrderedID) : FALSE;
    int bRandomComplete = bHasRandom ? GetIsPCQuestComplete(oPC, nRandomID) : FALSE;

    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            EnableDialogEnd();
            SetDialogPage(DISCOVERY_PAGE_MAIN);
            AddDialogPage(DISCOVERY_PAGE_MAIN, "The area behind this sign contains triggers which can satisfy " +
                "any quest that requires discovering a specific area.  There are three triggers and their " +
                "labels are on the signs.  If you need to discover a specific trigger, walk up to the sign " +
                "that have the trigger's name and it will be logged into your quest progression.  If you don't " +
                "have a quest that requires discovering a trigger, nothing will happen when you approach the " +
                "signs.\n\nYou can assign yourself a DISCOVERY quest by selecting an option below.");
            AddDialogNode(DISCOVERY_PAGE_MAIN, "", HexColorString("Sequential Order", COLOR_GREEN_LIGHT) + " Discovery Quest", "ordered");
            AddDialogNode(DISCOVERY_PAGE_MAIN, "", HexColorString("Random Order", COLOR_GREEN_LIGHT) + " Discovery Quest", "random");
            AddDialogNode(DISCOVERY_PAGE_MAIN, DISCOVERY_PAGE_MAIN, HexColorString("Reset All Discovery Quest Progress", COLOR_RED_LIGHT), "reset");
            EnableDialogEnd();
        } break;

        case DLG_EVENT_PAGE:
        {
            string sPage = GetDialogPage();
            int bReset, nNode = GetDialogNode();

            if (sPage == DISCOVERY_PAGE_MAIN)
            {
                if (bHasOrdered && !bOrderedComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(0);
                }

                if (bHasRandom && !bRandomComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(1);
                }

                if (!bReset)
                    FilterDialogNodes(2);
            }
        } break;

        case DLG_EVENT_NODE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();
            string sNodeData = GetDialogData(sPage, nNode);

            int bHasOrdered = GetPCHasQuest(oPC, sOrdered);
            int bHasRandom = GetPCHasQuest(oPC, sRandom);

            if (sNodeData == "ordered")
                AssignQuestToPC(oPC, sOrdered);
            else if (sNodeData == "random")
                AssignQuestToPC(oPC, sRandom);
            else if (sNodeData == "reset")
            {
                if (bHasOrdered)
                    _ResetPCQuestData(oPC, nOrderedID);

                if (bHasRandom)
                    _ResetPCQuestData(oPC, nRandomID);
            }
        }
    }
}

// -----------------------------------------------------------------------------
//                           Kill Protect Quest Dialog
// -----------------------------------------------------------------------------

const string KILL_DIALOG      = "KillDialog";
const string KILL_PAGE_MAIN   = "Kill Main Page";

void KillDialog()
{
    object oPC = GetPCSpeaker();
    string sOrdered = "quest_kill_ordered";
    string sRandom = "quest_kill_random";
    string sProtect = "quest_kill_protect";
    string sTimed = "quest_kill_timed";

    int nOrderedID = GetQuestID(sOrdered);
    int nRandomID = GetQuestID(sRandom);
    int nProtectID = GetQuestID(sProtect);
    int nTimedID = GetQuestID(sTimed);

    int bHasOrdered = GetPCHasQuest(oPC, sOrdered);
    int bHasRandom = GetPCHasQuest(oPC, sRandom);
    int bHasProtect = GetPCHasQuest(oPC, sProtect);
    int bHasTimed = GetPCHasQuest(oPC, sTimed);

    int bOrderedComplete = bHasOrdered ? GetIsPCQuestComplete(oPC, nOrderedID) : FALSE;
    int bRandomComplete = bHasRandom ? GetIsPCQuestComplete(oPC, nRandomID) : FALSE;
    int bProtectComplete = bHasProtect ? GetIsPCQuestComplete(oPC, nProtectID) : FALSE;
    int bTimedComplete = bHasTimed ? GetIsPCQuestComplete(oPC, nTimedID) : FALSE;
    int bReset;

    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            EnableDialogEnd();
            SetDialogPage(KILL_PAGE_MAIN);
            AddDialogPage(KILL_PAGE_MAIN, "The area behind this sign will spawn creatures designed to fulfill " +
                "steps assiciated with kill and protect quests.  Their lives are forfeit before they set foot " +
                " on this Earth.\n\nYou can assign yourself a KILL or PROTECT quest by selecting an option below.");
            AddDialogNode(KILL_PAGE_MAIN, "", "Sequential Order Kill Quest", "ordered");
            AddDialogNode(KILL_PAGE_MAIN, "", "Random Order Kill Quest", "random");
            AddDialogNode(KILL_PAGE_MAIN, "", "NPC Protection Quest", "protect");
            AddDialogNode(KILL_PAGE_MAIN, "", "Timed Random Order Kill Quest", "timed");
            AddDialogNode(KILL_PAGE_MAIN, "", "Reset All Kill Quests", "reset");
            EnableDialogEnd();
        } break;

        case DLG_EVENT_PAGE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();

            if (sPage == KILL_PAGE_MAIN)
            {
                if (bHasOrdered && !bOrderedComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(0);
                }

                if (bHasRandom && !bRandomComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(1);
                }

                if (bHasProtect && !bProtectComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(2);
                }

                if (bHasTimed && !bProtectComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(3);
                }

                if (!bReset)
                    FilterDialogNodes(4); 
            }
        } break;

        case DLG_EVENT_NODE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();
            string sNodeData = GetDialogData(sPage, nNode);

            if (bHasOrdered) _ResetPCQuestData(oPC, nOrderedID);
            if (bHasRandom) _ResetPCQuestData(oPC, nRandomID);
            if (bHasProtect) _ResetPCQuestData(oPC, nProtectID);
            if (bHasTimed) _ResetPCQuestData(oPC, nTimedID);

            if (sNodeData == "ordered")
                AssignQuestToPC(oPC, sOrdered);
            else if (sNodeData == "random")
                AssignQuestToPC(oPC, sRandom);
            else if (sNodeData == "protect")
                AssignQuestToPC(oPC, sProtect);
            else if (sNodeData == "timed")
                AssignQuestToPC(oPC, sTimed);
        }
    }
}

// -----------------------------------------------------------------------------
//                           Gather Quest Dialog
// -----------------------------------------------------------------------------

const string GATHER_DIALOG      = "GatherDialog";
const string GATHER_PAGE_MAIN   = "Gather Main Page";

void GatherDialog()
{
    object oPC = GetPCSpeaker();
    string sOrdered = "quest_gather_ordered";
    string sRandom = "quest_gather_random";
    string sDeliver = "quest_gather_deliver";

    int nOrderedID = GetQuestID(sOrdered);
    int nRandomID = GetQuestID(sRandom);
    int nDeliverID = GetQuestID(sDeliver);

    int bHasOrdered = GetPCHasQuest(oPC, sOrdered);
    int bHasRandom = GetPCHasQuest(oPC, sRandom);
    int bHasDeliver = GetPCHasQuest(oPC, sDeliver);

    int bOrderedComplete = bHasOrdered ? GetIsPCQuestComplete(oPC, nOrderedID) : FALSE;
    int bRandomComplete = bHasRandom ? GetIsPCQuestComplete(oPC, nRandomID) : FALSE;
    int bDeliverComplete = bHasDeliver ? GetIsPCQuestComplete(oPC, nDeliverID) : FALSE;
    int bReset;

    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            EnableDialogEnd();
            SetDialogPage(GATHER_PAGE_MAIN);
            AddDialogPage(GATHER_PAGE_MAIN, "It appears there was some kind of accident behind this sign and " +
                "a dwarven caravan has lost some of their wares.  Looks like they'll need some help getting it " +
                "all cleaned up.\n\nIf you want to help, you can assign yourself a GATHER or DELIVER quest by " +
                "selecting an option below.");
            AddDialogNode(GATHER_PAGE_MAIN, "", "Sequential Order Gather Quest", "ordered");
            AddDialogNode(GATHER_PAGE_MAIN, "", "Random Order Gather Quest", "random");
            AddDialogNode(GATHER_PAGE_MAIN, "", "Delivery Quest", "deliver");
            AddDialogNode(GATHER_PAGE_MAIN, GATHER_PAGE_MAIN, "Unassign All Gather Quests", "unassign");
            AddDialogNode(GATHER_PAGE_MAIN, GATHER_PAGE_MAIN, "Reset Gather Quest Area", "reset");
            EnableDialogEnd();
        } break;

        case DLG_EVENT_PAGE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();

            if (sPage == GATHER_PAGE_MAIN)
            {
                if (bHasOrdered && !bOrderedComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(0);
                }

                if (bHasRandom && !bRandomComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(1);
                }

                if (bHasDeliver && !bDeliverComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(2);
                }

                if (!bReset)
                    FilterDialogNodes(3); 
            }
        } break;

        case DLG_EVENT_NODE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();
            string sNodeData = GetDialogData(sPage, nNode);

            if (bHasOrdered) _ResetPCQuestData(oPC, nOrderedID);
            if (bHasRandom) _ResetPCQuestData(oPC, nRandomID);
            if (bHasDeliver) _ResetPCQuestData(oPC, nDeliverID);

            if (sNodeData == "ordered")
                AssignQuestToPC(oPC, sOrdered);
            else if (sNodeData == "random")
                AssignQuestToPC(oPC, sRandom);
            else if (sNodeData == "deliver")
                AssignQuestToPC(oPC, sDeliver);
            else if (sNodeData == "reset")
                ResetGatherQuestArea(oPC);
        }
    }
}

void OnLibraryLoad()
{
    RegisterLibraryScript(DISCOVERY_DIALOG);
    RegisterDialogScript (DISCOVERY_DIALOG);

    RegisterLibraryScript(KILL_DIALOG);
    RegisterDialogScript (KILL_DIALOG);

    RegisterLibraryScript(GATHER_DIALOG);
    RegisterDialogScript (GATHER_DIALOG);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (sScript == DISCOVERY_DIALOG) DiscoveryDialog();
    else if (sScript == KILL_DIALOG) KillDialog();
    else if (sScript == GATHER_DIALOG) GatherDialog();
}
