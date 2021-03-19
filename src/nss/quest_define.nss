
#include "quest_i_main"

// If required, OBJECT_SELF is GetModule();

void SetQuestScripts()
{
    SetQuestScriptOnAdvance("quest_advance");
    SetQuestScriptOnAccept("quest_accept");
    SetQuestScriptOnComplete("quest_complete");
    SetQuestScriptOnFail("quest_fail");
}

void DefineOrderedDiscoveryQuest()
{
    // Sample discovery quest (ordered)
    // Levels 1-3
    // Step 1: Find and enter quest_trigger_1
    // Step 2: Find and enter quest_trigger_2
    // Step 3: Find and enter quest_trigger_3
    
    AddQuest("quest_discovery_ordered");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(3);

    SetQuestScripts();

    //AddQuestStep(nQuestID);
    AddQuestStep();
    SetQuestStepObjectiveDiscover("quest_trigger_1");
    SetQuestStepPrewardMessage("You've been assigned the Ordered Discovery Quest");
    SetQuestStepRewardMessage("You've discovered Discovery Trigger #1");
    SetQuestStepRewardXP(5);

    AddQuestStep();
    SetQuestStepObjectiveDiscover("quest_trigger_2");
    SetQuestStepRewardMessage("You've discovered Discovery Trigger #2");
    SetQuestStepRewardXP(5);

    AddQuestStep();
    SetQuestStepObjectiveDiscover("quest_trigger_3");
    SetQuestStepRewardMessage("You've discovered Discovery Trigger #3");
    SetQuestStepRewardXP(5);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Congratulations, you've completed the Ordered Discovery sample quest");
    SetQuestStepRewardGold(50);
    SetQuestStepRewardXP(50);
}

void DefineRandomDiscoveryQuest()
{
    // Sample discovery quest (random)
    // Levels 1-3
    // Step 1: Find and enter quest_trigger_1
    //         Find and enter quest_trigger_2
    //         Find and enter quest_trigger_3
    
    AddQuest("quest_discovery_random");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(3);

    SetQuestScripts();
    SetQuestJournalHandler(QUEST_JOURNAL_NONE);

    AddQuestStep();
    SetQuestRepetitions(0);
    SetQuestStepPrewardMessage("You've been assigned the Random Discovery Quest and must do this");
    
    SetQuestStepObjectiveDiscover("quest_trigger_2");
    SetQuestStepObjectiveDescriptor("Quest Discovery Trigger 2");
    SetQuestStepObjectiveDescription("and skip around it");
    
    SetQuestStepObjectiveDiscover("quest_trigger_3");
    SetQuestStepObjectiveDescriptor("Quest Discovery Trigger 3");

    SetQuestStepObjectiveDiscover("quest_trigger_1");
    SetQuestStepObjectiveDescriptor("Quest Discovery Trigger 1");
    
    SetQuestStepObjectiveRandom(2);
    SetQuestStepObjectiveMinimum(1);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Congratulations, you've completed the Random Discovery sample quest");
    SetQuestStepRewardGold(50);
    SetQuestStepRewardXP(50);
}

void DefineOrderedKillQuest()
{
    // Sample kill quest (ordered)
    // Levels 1-5
    // Quest prerequisite - quest_discovery_ordered
    // Step 1: Kill a single goblin
    // Step 2: Kill another goblin
    // Step 3: Oh no, there's another one

    AddQuest("quest_kill_ordered");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(5);
    SetQuestPrerequisiteQuest("quest_discovery_ordered", 1);

    SetQuestScripts();

    AddQuestStep();
    SetQuestStepPrewardMessage("There's a mighty horde of goblin over there.  You do you.");
    SetQuestStepObjectiveKill("nw_goblina", 1);
    
    AddQuestStep();
    SetQuestStepPrewardMessage("Thank you so much, but look out, there be another one behind you!");
    SetQuestStepObjectiveKill("nw_goblina", 1);

    AddQuestStep();
    SetQuestStepPrewardMessage("Phew, that was clo... Look out!");
    SetQuestStepObjectiveKill("nw_goblina", 1);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Thank you so much adventurer.  I don't know how we would survive without you.");
    SetQuestStepRewardGold(50);
    SetQuestStepRewardXP(50);
    SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 20);
}

void DefineRandomKillQuest()
{
    // Sample kill quest (random)
    // Levels 1-5
    // Quest prerequisite - quest_discovery_random
    // Step 1: Kill a single goblin
    //         Kill a single rat
    //         Kill a single bat

    AddQuest("quest_kill_random");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(5);
    SetQuestPrerequisiteQuest("quest_discovery_random", -1);

    SetQuestScripts();

    AddQuestStep();
    SetQuestStepPrewardMessage("Help, rodents!");
    SetQuestStepObjectiveKill("nw_goblina", 1);
    SetQuestStepObjectiveKill("nw_rat001", 1);
    SetQuestStepObjectiveKill("nw_bat", 1);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Thank you so much adventurer.  I don't know how we would survive without you.");
    SetQuestStepRewardGold(50);
    SetQuestStepRewardXP(50);
    SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 20);
}

void DefineProtectKillQuest()
{
    // Sample kill quest (protect)
    // Levels 1-5
    // Step 1: Kill 5 goblins
    //         Protect the NPC

    AddQuest("quest_kill_protect");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(5);

    SetQuestScripts();

    AddQuestStep();
    SetQuestStepPrewardMessage("The goblins are going to kill the old man, protect him!");
    SetQuestStepObjectiveKill("nw_goblina", 5);
    SetQuestStepObjectiveKill("nw_oldman", 0);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Yay, you saved him!  Good job, adventurer!");
    SetQuestStepRewardXP(100);
    SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 10);
    SetQuestStepRewardAlignment(ALIGNMENT_LAWFUL, 10);

    AddQuestResolutionFail();
    SetQuestStepRewardMessage("Boooo!  You suck!");
    SetQuestStepRewardXP(-10);
    SetQuestStepRewardAlignment(ALIGNMENT_CHAOTIC, 5);
}

void DefineTimedKillQuest()
{
    // Sample kill quest (timed kill)
    // Levels 1-5
    // Time: 30 seconds
    // Step 1: Kill three goblins

    AddQuest("quest_kill_timed");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(5);

    SetQuestScripts();

    AddQuestStep();
    SetQuestStepPrewardMessage("The mayor has lost control!  You have 30 seconds to kill these little bastards!");
    SetQuestStepTimeLimit("0,0,0,0,0,30");
    SetQuestStepObjectiveKill("nw_goblina", 3);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Yay, you saved us! Good job, adventurer!");
    SetQuestStepRewardXP(100);
    SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 10);
    SetQuestStepRewardAlignment(ALIGNMENT_LAWFUL, 10);

    AddQuestResolutionFail();
    SetQuestStepRewardMessage("Boooo! You suck!");
    SetQuestStepRewardXP(-10);
    SetQuestStepRewardAlignment(ALIGNMENT_CHAOTIC, 5);
}

void DefineOrderedGatherQuest()
{
    AddQuest("quest_gather_ordered");
    SetQuestScripts();

    AddQuestStep();
    SetQuestStepPrewardMessage("Please collect the armor you see lying about (three)");
    SetQuestStepObjectiveGather("quest_gather_armor", 3);

    AddQuestStep();
    SetQuestStepPrewardMessage("Please collect the shields you see lying about (three)");
    SetQuestStepObjectiveGather("quest_gather_shield", 3);

    AddQuestStep();
    SetQuestStepPrewardMessage("Please collect the helmets you see lying about (three)");
    SetQuestStepObjectiveGather("quest_gather_helmet", 3);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("The equipment mess has been cleaned up.  Return to the sign for more " +
        "sample gather quests.");
    SetQuestStepRewardGold(15);
}

void DefineRandomGatherQuest()
{
    AddQuest("quest_gather_random");
    SetQuestScripts();

    AddQuestStep();
    SetQuestStepPrewardMessage("Please collect all the armor, shields and helmets you see " +
        "strewn about; there should be three of each kind");
    SetQuestStepObjectiveGather("quest_gather_armor", 3);
    SetQuestStepObjectiveGather("quest_gather_shield", 3);
    SetQuestStepObjectiveGather("quest_gather_helmet", 3);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("The equipment mess has been cleaned up.  Return to the sign for more " +
        "sample gather quests.");
    SetQuestStepRewardGold(15);
}

void DefineDeliveryQuest()
{
    AddQuest("quest_gather_deliver");
    SetQuestScripts();

    AddQuestStep();
    SetQuestStepPrewardMessage("Please collect all the armor you see strewn about");
    SetQuestStepObjectiveGather("quest_gather_helmet", 3);
    SetQuestStepObjectiveGather("quest_gather_shield", 3);
    SetQuestStepObjectiveGather("quest_gather_armor", 3);

    AddQuestStep();
    SetQuestStepPrewardMessage("Wow, you're awesome.  Ok, can you put all that in the wagon, please?");
    SetQuestStepObjectiveDeliver("quest_deliver_wagon", "quest_gather_helmet", 3);
    SetQuestStepObjectiveDeliver("quest_deliver_wagon", "quest_gather_shield", 3);
    SetQuestStepObjectiveDeliver("quest_deliver_wagon", "quest_gather_armor", 3);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Thanks for cleaning up the mess!");
    SetQuestStepRewardGold(15);
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