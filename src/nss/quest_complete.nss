
#include "quest_i_main"
#include "quest_support"

void main()
{
    object oPC = OBJECT_SELF;
    string sCurrentQuest = GetCurrentQuest();

    // nCurrentStep will only be valid for quest advance scripts. never for accept,
    // compete or fail
    if (sCurrentQuest == "quest_kill_ordered" ||
        sCurrentQuest == "quest_kill_random" ||
        sCurrentQuest == "quest_kill_protect" ||
        sCurrentQuest == "quest_kill_timed")
        SetImmortal(oPC, FALSE);
    else if (sCurrentQuest == "quest_gather_ordered" ||
             sCurrentQuest == "quest_gather_random" ||
             sCurrentQuest == "quest_gather_deliver")
        ResetGatherQuestArea(oPC);
}
