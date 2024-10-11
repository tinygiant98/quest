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
    QuestNotice("Resetting data: " +
        "\n  PC -> " + PCToString(oPC) +
        "\n  Quest -> " + QuestToString(nQuestID));

    DeletePCQuestProgress(oPC, nQuestID);
    ResetPCQuestData(oPC, nQuestID);
}

string CacheColoredToken(string sToken)
{
    return HexColorString(sToken, COLOR_GREEN_LIGHT);
}

// -----------------------------------------------------------------------------
//                           Discovery Quest Dialog
// -----------------------------------------------------------------------------

const string DISCOVERY_DIALOG      = "DiscoveryDialog";
const string DISCOVERY_PAGE_MAIN   = "Discovery Main Page";
const string DISCOVERY_PAGE_SEQUENTIAL = "Discovery_Sequential";
const string DISCOVERY_PAGE_RANDOM = "Discovery_Random";
const string DISCOVERY_PAGE_BOTH = "Discovery_Both";

void DiscoveryDialog()
{
    object oPC = GetPCSpeaker();
    string sOrdered = "quest_discovery_ordered";
    string sRandom = "quest_discovery_random";

    int nOrderedID = GetQuestID(sOrdered);
    int nRandomID = GetQuestID(sRandom);

    int bHasOrdered = GetPCHasQuest(oPC, sOrdered);
    int bHasRandom = GetPCHasQuest(oPC, sRandom);

    int bOrderedComplete = bHasOrdered ? GetIsPCQuestComplete(oPC, sOrdered) : FALSE;
    int bRandomComplete = bHasRandom ? GetIsPCQuestComplete(oPC, sRandom) : FALSE;

    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            string sPage;

            AddDialogToken("sequential");
            AddDialogToken("random");
            AddDialogToken("stacked");
            AddDialogToken("both");

            CacheDialogToken("sequential", CacheColoredToken("Sequential Order"));
            CacheDialogToken("random", CacheColoredToken("Random Order"));
            CacheDialogToken("stacked", CacheColoredToken("Stacked"));
            CacheDialogToken("both", CacheColoredToken("Sequential and Random"));

            EnableDialogBack();
            EnableDialogEnd();

            SetDialogPage(DISCOVERY_PAGE_MAIN);
            AddDialogPage(DISCOVERY_PAGE_MAIN, "Welcome to the Discovery Quests demonstration area.  Behind this " +
                "sign is a small area with three discovery triggers.  You can assign yourself a quest (or both " +
                "quests) below to try out this quest objective.  For more information, select a Discovery " +
                "Quest type below.");
            AddDialogNode(DISCOVERY_PAGE_MAIN, DISCOVERY_PAGE_SEQUENTIAL, "<sequential> Discovery Quest");
            AddDialogNode(DISCOVERY_PAGE_MAIN, DISCOVERY_PAGE_RANDOM, "<random> Discovery Quest");
            AddDialogNode(DISCOVERY_PAGE_MAIN, DISCOVERY_PAGE_BOTH, "<stacked> Discovery Quests");
            AddDialogNode(DISCOVERY_PAGE_MAIN, DISCOVERY_PAGE_MAIN, HexColorString("Reset All Discovery Quest Progress", COLOR_RED_LIGHT), "reset");
            DisableDialogNode(DLG_NODE_BACK, DISCOVERY_PAGE_MAIN);

            AddDialogPage(DISCOVERY_PAGE_SEQUENTIAL, "This quest requires that you discover each of the three " +
                "discovery triggers located in the area behind this sign.  Its purpose is to demonstrate that " +
                "you can define order in the steps required for a quest to be completed.");
            sPage = AddDialogPage(DISCOVERY_PAGE_SEQUENTIAL, "In this case, the required order is 1 -> 2 -> 3.  If you " +
                "discover the triggers in that order, your quest will progress.  You can also attempt to discover " +
                "the triggers in the incorrect order and see that the quest will not progress.");
            AddDialogNode(sPage, "", "Assign <sequential> Discovery Quest", "ordered");
      
            AddDialogPage(DISCOVERY_PAGE_RANDOM, "This quest requires that you discover each of the three " +
                "discovery triggers, but you can discover them in any order you see fit.  The purpose of this quest " +
                "is to demostrate that you can allow randomness in quest step completion.");
            sPage = AddDialogPage(DISCOVERY_PAGE_RANDOM, "Although all three triggers have to be discovered, you " +
                "can do so in any order and the quest will advance once all three have been discovered.");
            AddDialogNode(sPage, "", "Assign <random> Discovery Quest", "random");

            AddDialogPage(DISCOVERY_PAGE_BOTH, "The quest system has the ability to credit step progression to multiple " +
                "quests if each of the quests requires the same objective and object tag.  In this example, if you have " +
                "both the sequential and random discovery quests assigned, approaching a discovery trigger will " +
                "credit both quests, if applicable.");
            sPage = AddDialogPage(DISCOVERY_PAGE_BOTH, "This capability does not change the order in which steps have to be " +
                "accomplished.  For example, if you disovery trigger #3 first, it will credit only the random quest. " +
                "If you discover trigger #1 first, it will credit both the random and sequential order quests.");
            AddDialogNode(sPage, "", "Assign Both <both> Discovery Quests", "both");
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

                if (bReset)
                    FilterDialogNodes(2);
                else
                    FilterDialogNodes(3);
            }
        } break;

        case DLG_EVENT_NODE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();
            string sNodeData = GetDialogData(sPage, nNode);

            int bHasOrdered = GetPCHasQuest(oPC, sOrdered);
            int bHasRandom = GetPCHasQuest(oPC, sRandom);

            if (sPage == DISCOVERY_PAGE_MAIN)
            {
                if (sNodeData == "reset")
                {
                    if (bHasOrdered)
                        _ResetPCQuestData(oPC, nOrderedID);

                    if (bHasRandom)
                        _ResetPCQuestData(oPC, nRandomID);
                    }
            }
            else
            {
                if (sNodeData == "ordered")
                {
                    if (GetIsQuestAssignable(oPC, "quest_discovery_ordered"))
                        AssignQuestToPC(oPC, sOrdered);
                }
                else if (sNodeData == "random")
                    AssignQuestToPC(oPC, sRandom);
                else if (sNodeData == "both")
                {
                    AssignQuestToPC(oPC, sOrdered);
                    AssignQuestToPC(oPC, sRandom);
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
//                           Kill Protect Quest Dialog
// -----------------------------------------------------------------------------

const string KILL_DIALOG      = "KillDialog";
const string KILL_PAGE_MAIN   = "Kill Main Page";
const string KILL_PAGE_ORDER  = "Kill_Page_Order";
const string KILL_PAGE_RANDOM = "Kill_Page_Random";
const string KILL_PAGE_PROTECT = "Kill_Page_Protect";
const string KILL_PAGE_TIMED = "Kill_Page_Timed";
const string KILL_PAGE_PROTECTONLY = "Kill_Page_ProtectOnly";

void KillDialog()
{
    object oPC = GetPCSpeaker();
    string sOrdered = "quest_kill_ordered";
    string sRandom = "quest_kill_random";
    string sProtect = "quest_kill_protect";
    string sTimed = "quest_kill_timed";
    string sProtectOnly = "quest_protect_only";

    int nOrderedID = GetQuestID(sOrdered);
    int nRandomID = GetQuestID(sRandom);
    int nProtectID = GetQuestID(sProtect);
    int nTimedID = GetQuestID(sTimed);
    int nProtectOnly = GetQuestID(sProtectOnly);

    int bHasOrdered = GetPCHasQuest(oPC, sOrdered);
    int bHasRandom = GetPCHasQuest(oPC, sRandom);
    int bHasProtect = GetPCHasQuest(oPC, sProtect);
    int bHasTimed = GetPCHasQuest(oPC, sTimed);
    int bHasProtectOnly = GetPCHasQuest(oPC, sProtectOnly);

    int bOrderedComplete = bHasOrdered ? GetIsPCQuestComplete(oPC, sOrdered) : FALSE;
    int bRandomComplete = bHasRandom ? GetIsPCQuestComplete(oPC, sRandom) : FALSE;
    int bProtectComplete = bHasProtect ? GetIsPCQuestComplete(oPC, sProtect) : FALSE;
    int bTimedComplete = bHasTimed ? GetIsPCQuestComplete(oPC, sTimed) : FALSE;
    int bProtectOnlyComplete = bHasProtectOnly ? GetIsPCQuestComplete(oPC, sProtectOnly) : FALSE;
    int bReset;

    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            string sPage;

            AddDialogToken("sequential");
            AddDialogToken("random");
            AddDialogToken("protect");
            AddDialogToken("timed");
            AddDialogToken("protect-only");

            CacheDialogToken("sequential", CacheColoredToken("Sequential Order"));
            CacheDialogToken("random", CacheColoredToken("Random Order"));
            CacheDialogToken("protect", CacheColoredToken("NPC Protection"));
            CacheDialogToken("timed", CacheColoredToken("Timed Random Order"));
            CacheDialogToken("protect-only", CacheColoredToken("Protect Only"));

            EnableDialogBack();
            EnableDialogEnd();

            SetDialogPage(KILL_PAGE_MAIN);
            AddDialogPage(KILL_PAGE_MAIN, "The area behind this sign will spawn creatures designed to fulfill " +
                "steps assiciated with kill and protect quests.  If these creature get out of control or overwhelm " +
                "you while you're completing the demonstration, return to this sign and they will return to whence " +
                "they came.\n\n\"Kill Quest\" objective are demonstrated here.  Select a quest type below to learn more.");
            AddDialogNode(KILL_PAGE_MAIN, KILL_PAGE_ORDER, "<sequential> Kill Quest");
            AddDialogNode(KILL_PAGE_MAIN, KILL_PAGE_RANDOM, "<random> Kill Quest");
            AddDialogNode(KILL_PAGE_MAIN, KILL_PAGE_PROTECT, "<protect> Quest");
            AddDialogNode(KILL_PAGE_MAIN, KILL_PAGE_TIMED, "<timed> Kill Quest");
            AddDialogNode(KILL_PAGE_MAIN, KILL_PAGE_PROTECTONLY, "<protect-only> Quest");
            AddDialogNode(KILL_PAGE_MAIN, KILL_PAGE_MAIN, HexColorString("Reset All Kill Quests Progress", COLOR_RED_LIGHT), "reset");
            DisableDialogNode(DLG_NODE_BACK, KILL_PAGE_MAIN);

            AddDialogPage(KILL_PAGE_ORDER, "This quest requires that you kill three goblins, which will appear in a " +
                "specified order and at different waypoints in the encolsure behind this sign.  Although this quest " +
                "uses three of the same tagged creatures for the targets, any creature or other game object can be " +
                "designated as the target.");
            AddDialogPage(KILL_PAGE_ORDER, "If the goblins get out of control, return to this sign and the " +
                "goblins will go to the great beyond.  The quest will progress to the next step each time you kill " +
                "a goblin.");
            sPage = AddDialogPage(KILL_PAGE_ORDER, "This quest also demonstrates the use of \"Message Prewards\", " +
                "so look for the cyan-colored messages in your chat window for information the current quest step.");
            AddDialogNode(sPage, "", "Assign <sequential> Quest", "ordered");

            AddDialogPage(KILL_PAGE_RANDOM, "This quest requires that you kill a goblin, a rat and a bat, which will " +
                "appear at three different locations in the enclosure behind this sign. The purpose of this quest is " +
                "to demonstrate fulfilling quest requirement for kill creatures in a random order.");
            sPage = AddDialogPage(KILL_PAGE_RANDOM, "If the creatures get out of control, return to this sign and the " +
                "they will go to the great beyond.  The quest will complete after you kill all three creatures.");
            AddDialogNode(sPage, "", "Assign <random> Quest", "random");

            AddDialogPage(KILL_PAGE_PROTECT, "This quest requires that you protect the Old Man that will appear at a " +
                "waypoint behind this sign.  What's more noble that protecting the elderly?  The purpose of this quest " +
                "is to show that the Kill Quest objective can be manipulated to define a protection quest.");
            sPage = AddDialogPage(KILL_PAGE_PROTECT, "There are no other objectives except to protect the Old Man, so " +
                "the number of creatures you kill doesn't matter as long as the Old Man remains alive.  Additionally, " +
                "this quest is designed to demonstrate quest failures and the separate rewards that can be provided, so " +
                "don't feel too bad if the Old Man dies.");
            AddDialogNode(sPage, "", "Assign <protect> Quest", "protect");

            AddDialogPage(KILL_PAGE_TIMED, "This quest requires that you kill multiple target creatures, in a random " +
                "order, but within a specified time.  In this case, you'll have to kill at least three goblins that will " +
                "appear at a waypoint in the enclosure behind this sign.  You'll have 30 (real-world) seconds to complete " +
                "this task.");
            sPage = AddDialogPage(KILL_PAGE_TIMED, "In addition to demonstrating timing requirements, this quest also " +
                "demonstrates differing rewards between successfully completing a quest and failing a quest.");
            AddDialogNode(sPage, "", "Assign <timed> Quest", "timed");

            AddDialogPage(KILL_PAGE_PROTECTONLY, "This quest is the test setup for a protect-only quest.");
            sPage = AddDialogPage(KILL_PAGE_PROTECTONLY, "This quest assigns a single step with no other associated " +
                "steps to test whether assigning a protection quest with no other associated objectives will mark " +
                "the quest as complete.");
            AddDialogNode(sPage, "", "Assign <protect-only> Quest", "protect-only");
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

                if (bHasTimed && !bTimedComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(3);
                }

                if (bHasProtectOnly && !bProtectOnlyComplete)
                {
                    bReset = TRUE;
                    FilterDialogNodes(4);
                }

                if (!bReset)
                    FilterDialogNodes(5); 
            }
        } break;

        case DLG_EVENT_NODE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();
            string sNodeData = GetDialogData(sPage, nNode);

            if (sPage == KILL_PAGE_MAIN)
            {
                if (sNodeData == "reset")
                {
                    if (bHasOrdered)
                        _ResetPCQuestData(oPC, nOrderedID);

                    if (bHasRandom)
                        _ResetPCQuestData(oPC, nRandomID);

                    if (bHasProtect)
                        _ResetPCQuestData(oPC, nProtectID);

                    if (bHasTimed)
                        _ResetPCQuestData(oPC, nTimedID);
                }
            }

            if (sNodeData == "ordered")
                AssignQuestToPC(oPC, sOrdered);
            else if (sNodeData == "random")
                AssignQuestToPC(oPC, sRandom);
            else if (sNodeData == "protect")
                AssignQuestToPC(oPC, sProtect);
            else if (sNodeData == "timed")
                AssignQuestToPC(oPC, sTimed);
            else if (sNodeData == "protect-only")
                AssignQuestToPC(oPC, sProtectOnly);
        }
    }
}

// -----------------------------------------------------------------------------
//                           Gather Quest Dialog
// -----------------------------------------------------------------------------

const string GATHER_DIALOG      = "GatherDialog";
const string GATHER_PAGE_MAIN   = "Gather Main Page";
const string GATHER_PAGE_ORDER  = "Gather_Page_Order";
const string GATHER_PAGE_RANDOM = "Gather_Page_Random";
const string GATHER_PAGE_DELIVER = "Gather_Page_Deliver";

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

    int bOrderedComplete = bHasOrdered ? GetIsPCQuestComplete(oPC, sOrdered) : FALSE;
    int bRandomComplete = bHasRandom ? GetIsPCQuestComplete(oPC, sRandom) : FALSE;
    int bDeliverComplete = bHasDeliver ? GetIsPCQuestComplete(oPC, sDeliver) : FALSE;
    int bReset;

    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            string sPage;

            AddDialogToken("sequential");
            AddDialogToken("random");
            AddDialogToken("deliver");

            CacheDialogToken("sequential", CacheColoredToken("Sequential Order"));
            CacheDialogToken("random", CacheColoredToken("Random Order"));
            CacheDialogToken("deliver", CacheColoredToken("Delivery"));

            EnableDialogBack();
            EnableDialogEnd();

            SetDialogPage(GATHER_PAGE_MAIN);
            AddDialogPage(GATHER_PAGE_MAIN, "The area behind this sign contains items and a placeable designed " +
                "to demonstrate variations of the Gather Quest.  The sample quests below demonstrate the " +
                "the ability to required ordered gathering, allow random gathering and to deliver specified " +
                "objects to another specified object.  Select a quest type below to learn more.");
            AddDialogNode(GATHER_PAGE_MAIN, GATHER_PAGE_ORDER, "<sequenital> Gather Quest");
            AddDialogNode(GATHER_PAGE_MAIN, GATHER_PAGE_RANDOM, "<random> Gather Quest");
            AddDialogNode(GATHER_PAGE_MAIN, GATHER_PAGE_DELIVER, "<deliver> Quest");
            AddDialogNode(GATHER_PAGE_MAIN, GATHER_PAGE_MAIN, HexColorString("Reset All Gather Quests Progress", COLOR_RED_LIGHT), "reset_quest");
            AddDialogNode(GATHER_PAGE_MAIN, GATHER_PAGE_MAIN, HexColorString("Reset Gather Quest Area", COLOR_RED_LIGHT), "reset_area");
            DisableDialogNode(DLG_NODE_BACK, GATHER_PAGE_MAIN);

            AddDialogPage(GATHER_PAGE_ORDER, "An ordered gather quest requires that one or more items be " +
                "collected by the PC in a specified order.  The quest will not progress until each item " +
                "assigned to that step is collected.  In the Sequential Order Gather Quest, you'll need " +
                "to collect three pieces of armor, then three shield, then three helmets.");
            sPage = AddDialogPage(GATHER_PAGE_ORDER, "This quest also demonstrates quest regression.  If you " +
                "acquire a quest-related item, then unacquire that item before the quest step that requires " +
                "it is complete, the quest will regress and you will not have credit for the lost items.  " +
                "Assign yourself the Sequential Order Gather Quest below.");
            AddDialogNode(sPage, "", "Assign <sequential> Discovery Quest", "ordered");

            AddDialogPage(GATHER_PAGE_RANDOM, "A random order gather quest requires that one or more items be " +
                "collected by the PC, but not in any specified order.  The quest will not progress until " +
                "all items assigned to that step are collected.  In the random order sample quest, you'll need to " +
                "collect all of the armor pieces in the quest area (nine pieces total), but the order you collect " +
                "them does not matter.  You will receive credit once all pieces are collected.");
            sPage = AddDialogPage(GATHER_PAGE_RANDOM, "This quest also demonstrates quest regression.  If you " +
                "acquire a quest-related item, then unacquire that item before the quest step that requires " +
                "it is complete, the quest will regress and you will not have credit for the lost items.  " +
                "Assign yourself the Random Order Gather Quest below.");
            AddDialogNode(sPage, "", "Assign <random> Discovery Quest", "random");

            AddDialogPage(GATHER_PAGE_DELIVER, "A delivery quest is an extension of the gather quest.  In this case, " +
                "you must obtain a specified number of items and take them to a specified object.  For the sample " +
                "quest, that means collecting all nine pieces of armor, in any order, and placing them all in the " +
                "cart.");
            sPage = AddDialogPage(GATHER_PAGE_DELIVER, "This quest also demonstrates a combination of a random " +
                "order gather quest as well as a delivery requirement.  There are no rewards provided for collecting the " +
                "items but there will be a message in the chat window stating that you need to take the items to the " +
                "cart.  Although this quest uses a placeable, the quest can also require the items be taken to any other " +
                "game object, such as a creature or a trigger.");
            AddDialogNode(sPage, "", "Assign <deliver> Discovery Quest", "deliver");
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

            if (sPage == KILL_PAGE_MAIN)
            {
                if (sNodeData == "reset_quest")
                {
                    if (bHasOrdered)
                        _ResetPCQuestData(oPC, nOrderedID);

                    if (bHasRandom)
                        _ResetPCQuestData(oPC, nRandomID);

                    if (bHasDeliver)
                        _ResetPCQuestData(oPC, nDeliverID);
                }
                else if (sNodeData == "reset_area")
                    ResetGatherQuestArea(oPC);
            }

            if (sNodeData == "ordered")
                AssignQuestToPC(oPC, sOrdered);
            else if (sNodeData == "random")
                AssignQuestToPC(oPC, sRandom);
            else if (sNodeData == "deliver")
                AssignQuestToPC(oPC, sDeliver);
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
