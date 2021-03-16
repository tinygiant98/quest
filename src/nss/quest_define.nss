
#include "quest_i_main"

// If required, OBJECT_SELF is GetModule();

void SetQuestScripts(int nQuestID)
{
    SetQuestScriptOnAdvance(nQuestID, "quest_advance");
    SetQuestScriptOnAccept(nQuestID, "quest_accept");
    SetQuestScriptOnComplete(nQuestID, "quest_complete");
    SetQuestScriptOnFail(nQuestID, "quest_fail");
}

void DefineOrderedDiscoveryQuest()
{
    // Sample discovery quest (ordered)
    // Levels 1-3
    // Step 1: Find and enter quest_trigger_1
    // Step 2: Find and enter quest_trigger_2
    // Step 3: Find and enter quest_trigger_3

    int nQuestID, nStep;
    
    nQuestID = AddQuest("quest_discovery_ordered");
    SetQuestPrerequisiteLevelMin(nQuestID, 1);
    SetQuestPrerequisiteLevelMax(nQuestID, 3);

    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepObjectiveDiscover(nQuestID, nStep, "quest_trigger_1");
    SetQuestStepPrewardMessage(nQuestID, nStep, "You've been assigned the Ordered Discovery Quest");
    SetQuestStepRewardMessage(nQuestID, nStep, "You've discovered Discovery Trigger #1");
    SetQuestStepRewardXP(nQuestID, nStep, 5);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepObjectiveDiscover(nQuestID, nStep, "quest_trigger_2");
    SetQuestStepRewardMessage(nQuestID, nStep, "You've discovered Discovery Trigger #2");
    SetQuestStepRewardXP(nQuestID, nStep, 5);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepObjectiveDiscover(nQuestID, nStep, "quest_trigger_3");
    SetQuestStepRewardMessage(nQuestID, nStep, "You've discovered Discovery Trigger #3");
    SetQuestStepRewardXP(nQuestID, nStep, 5);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Congratulations, you've completed the Ordered Discovery sample quest");
    SetQuestStepRewardGold(nQuestID, nStep, 50);
    SetQuestStepRewardXP(nQuestID, nStep, 50);
}

void DefineRandomDiscoveryQuest()
{
    // Sample discovery quest (random)
    // Levels 1-3
    // Step 1: Find and enter quest_trigger_1
    //         Find and enter quest_trigger_2
    //         Find and enter quest_trigger_3

    int nQuestID, nStep;
    
    nQuestID = AddQuest("quest_discovery_random");
    SetQuestPrerequisiteLevelMin(nQuestID, 1);
    SetQuestPrerequisiteLevelMax(nQuestID, 3);

    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "You've been assigned the Random Discovery Quest");
    SetQuestStepObjectiveCount(nQuestID, nStep, 1);
    SetQuestStepObjectiveDiscover(nQuestID, nStep, "quest_trigger_2");
    SetQuestStepObjectiveDiscover(nQuestID, nStep, "quest_trigger_3");
    SetQuestStepObjectiveDiscover(nQuestID, nStep, "quest_trigger_1");

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Congratulations, you've completed the Random Discovery sample quest");
    SetQuestStepRewardGold(nQuestID, nStep, 50);
    SetQuestStepRewardXP(nQuestID, nStep, 50);
}

void DefineOrderedKillQuest()
{
    // Sample kill quest (ordered)
    // Levels 1-5
    // Quest prerequisite - quest_discovery_ordered
    // Step 1: Kill a single goblin
    // Step 2: Kill another goblin
    // Step 3: Oh no, there's another one

    int nQuestID, nStep;

    nQuestID = AddQuest("quest_kill_ordered");
    SetQuestPrerequisiteLevelMin(nQuestID, 1);
    SetQuestPrerequisiteLevelMax(nQuestID, 5);
    SetQuestPrerequisiteQuest(nQuestID, "quest_discovery_ordered", 1);

    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "There's a mighty horde of goblin over there.  You do you.");
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_goblina", 1);
    
    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Thank you so much, but look out, there be another one behind you!");
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_goblina", 1);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Phew, that was clo... Look out!");
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_goblina", 1);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Thank you so much adventurer.  I don't know how we would survive without you.");
    SetQuestStepRewardGold(nQuestID, nStep, 50);
    SetQuestStepRewardXP(nQuestID, nStep, 50);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_GOOD, 20);
}

void DefineRandomKillQuest()
{
    // Sample kill quest (random)
    // Levels 1-5
    // Quest prerequisite - quest_discovery_random
    // Step 1: Kill a single goblin
    //         Kill a single rat
    //         Kill a single bat

    int nQuestID, nStep;

    nQuestID = AddQuest("quest_kill_random");
    SetQuestPrerequisiteLevelMin(nQuestID, 1);
    SetQuestPrerequisiteLevelMax(nQuestID, 5);
    SetQuestPrerequisiteQuest(nQuestID, "quest_discovery_random", -1);

    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Help, rodents!");
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_goblina", 1);
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_rat001", 1);
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_bat", 1);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Thank you so much adventurer.  I don't know how we would survive without you.");
    SetQuestStepRewardGold(nQuestID, nStep, 50);
    SetQuestStepRewardXP(nQuestID, nStep, 50);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_GOOD, 20);
}

void DefineProtectKillQuest()
{
    // Sample kill quest (protect)
    // Levels 1-5
    // Step 1: Kill 5 goblins
    //         Protect the NPC

    int nQuestID, nStep;

    nQuestID = AddQuest("quest_kill_protect");
    SetQuestPrerequisiteLevelMin(nQuestID, 1);
    SetQuestPrerequisiteLevelMax(nQuestID, 5);

    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "The goblins are going to kill the old man, protect him!");
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_goblina", 5);
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_oldman", 0);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Yay, you saved him!  Good job, adventurer!");
    SetQuestStepRewardXP(nQuestID, nStep, 100);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_GOOD, 10);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_LAWFUL, 10);

    nStep = AddQuestResolutionFail(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Boooo!  You suck!");
    SetQuestStepRewardXP(nQuestID, nStep, -10);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_CHAOTIC, 5);
}

void DefineTimedKillQuest()
{
    // Sample kill quest (timed kill)
    // Levels 1-5
    // Time: 30 seconds
    // Step 1: Kill three goblins

    int nQuestID, nStep;

    nQuestID = AddQuest("quest_kill_timed");
    SetQuestPrerequisiteLevelMin(nQuestID, 1);
    SetQuestPrerequisiteLevelMax(nQuestID, 5);

    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "The mayor has lost control!  You have 30 seconds to kill these little bastards!");
    SetQuestStepTimeLimit(nQuestID, nStep, "0,0,0,0,0,30");
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_goblina", 3);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Yay, you saved us! Good job, adventurer!");
    SetQuestStepRewardXP(nQuestID, nStep, 100);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_GOOD, 10);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_LAWFUL, 10);

    nStep = AddQuestResolutionFail(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Boooo! You suck!");
    SetQuestStepRewardXP(nQuestID, nStep, -10);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_CHAOTIC, 5);
}

void DefineOrderedGatherQuest()
{
    int nQuestID, nStep;

    nQuestID = AddQuest("quest_gather_ordered");
    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Please collect the armor you see lying about (three)");
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_armor", 3);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Please collect the shields you see lying about (three)");
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_shield", 3);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Please collect the helmets you see lying about (three)");
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_helmet", 3);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "The equipment mess has been cleaned up.  Return to the sign for more " +
        "sample gather quests.");
    SetQuestStepRewardGold(nQuestID, nStep, 15);
}

void DefineRandomGatherQuest()
{
    int nQuestID, nStep;

    nQuestID = AddQuest("quest_gather_random");
    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Please collect all the armor, shields and helmets you see " +
        "strewn about; there should be three of each kind");
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_armor", 3);
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_shield", 3);
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_helmet", 3);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "The equipment mess has been cleaned up.  Return to the sign for more " +
        "sample gather quests.");
    SetQuestStepRewardGold(nQuestID, nStep, 15);
}

void DefineDeliveryQuest()
{
    int nQuestID, nStep;

    nQuestID = AddQuest("quest_gather_deliver");
    SetQuestScripts(nQuestID);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Please collect all the armor you see strewn about");
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_helmet", 3);
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_shield", 3);
    SetQuestStepObjectiveGather(nQuestID, nStep, "quest_gather_armor", 3);

    nStep = AddQuestStep(nQuestID);
    SetQuestStepPrewardMessage(nQuestID, nStep, "Wow, you're awesome.  Ok, can you put all that in the wagon, please?");
    SetQuestStepObjectiveDeliver(nQuestID, nStep, "quest_deliver_wagon", "quest_gather_helmet", 3);
    SetQuestStepObjectiveDeliver(nQuestID, nStep, "quest_deliver_wagon", "quest_gather_shield", 3);
    SetQuestStepObjectiveDeliver(nQuestID, nStep, "quest_deliver_wagon", "quest_gather_armor", 3);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Thanks for cleaning up the mess!");
    SetQuestStepRewardGold(nQuestID, nStep, 15);
}

void main()
{
    DefineOrderedDiscoveryQuest();
    DefineRandomDiscoveryQuest();
    DefineOrderedKillQuest();
    DefineRandomKillQuest();
    DefineProtectKillQuest();
    DefineTimedKillQuest();
    DefineOrderedGatherQuest();
    DefineRandomGatherQuest();
    DefineDeliveryQuest();
}