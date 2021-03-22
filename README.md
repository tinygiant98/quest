
Note: The quest system files will not function without other utility includes from squattingmonk's
sm-utils.  These utilities can be sourced from this repo under the 'utils' folder.  However, when this
system reaches its final resting place, you might have to visit squattingmonk's nwn-core-framework or
sm-utils repo to obtain these files.

Specificially, the following files are required:  util_i_color.nss, util_i_csvlists.nss,
util_i_debug.nss, util_i_math.nss, util_i_string.nss

>*** WARNING *** This documentation is still a work-in-progress.  If anything in this documentation
    doesn't work the way you expect, refer to the code or find me on the Neverwinter Vault Discord...

## Description:
This system is designed to allow builders/scripters to fully define quests within script without
the need for game journal editing.  The greatest use of this utility comes from pairing it
with NWNX journal functions, which completely obviates the need for editing journal entries
in the toolset.  Since there are many modules that cannot or will not use NWNX, I've included
functionality for interfacing with the game's journal system.

***NOTE***   The base game currently contains a bug that prevents NWN journal entries from being
        persistently stored on the PC.  In order to re-apply journal quests on the PC after login,
        run `UpdateJournalQuestEntries(oPC)`.

***NOTE***   NWNX functions have not yet been implemented due to some idosynchrasies in the code
        and how it interfaces with the game.  When those wrinkles have been ironed out, NWNX
        functionality will be added.  ETA is unknown, so all references to NWNX journal functionality
        below is future-growth.

***NOTE***   This system makes extensive use of Quest IDs, which are defined and used internally.  You
    never need to know a Quest's ID number to utilize this system.  All QuestIDs are associate with a
    user-supplied Quest Tag (sQuestTag) which is provided when a quest is added.  All user-facing function
    use this quest tag to identify the appropriate quest for modification.

```c
AddQuest("myQuestTag", "This is the title of my quest");
```

Because each Quest Tag must be unique, the quest system can internally convert between QuestID
and Quest Tag when required.  If a user absolutely requires the conversion for other uses, two
functions are provided:
```c
    string GetQuestTag(int nQuestID)  // will return the Quest Tag associated with nQuestID
    int GetQuestID(string sQuestTag)  // will return the Quest ID associated with sQuestTag
```

***WARNING*** All non-PC quest data is held in volatile memory and will be lost on server
    reset.  Do not save QuestIDs persistently as they may change in the future with no
    ability to associate a changed ID with a Quest Tag.  If you must save persistent quest
    data, identify it via the Quest Tag, not the QuestID.

NWN Journal Entries:
    This utility can be used with either the standard NWN or NWNX journal functions.  If you
    elect to use the standard NWN journal functions, you must build the quests within the
    game's journal editor and then enter the quest's properties into the build properties
    for each quest in the system.  Examples of how to do this, as well as use NWNX journal
    functions, are included below.

Reserved Words and Characters:
    - NONE

## Usage Notes:
This system makes extensive use of NWN's organic sqlite capability.  All static quest data is held
in volatile memory in the module object's sqlite database.  All persistent quest data associated with
individual player-characters are stored in the PC's persistent sqlite database, which is saved to
the character's .bic file.
    
The text entries in this system can store colorized text, however, there are no functions included in
this utility to accomplish colorized text.  If you wish to have your journal titles or journal entries
colored, the text must be pre-processed before storing the values on the quest or quest step.  The
utility script util_i_color has several functions to accomplish this.

This primary functionality of this utility resides in the ability to set various properties on quests
and quest steps.  These properties include quest prerequisites, step rewards, step prewards and step
objectives.  Most properties can be "stacked" (more than one added).  Examples of this will follow.
    
## Custom Quest-Assocated Variables:
There are several functions that allow the user to associate Int and String variables with any
quest.  These variables are stored in the volatile module-associated sqlite database in a separate
table and referenced to the associated quest by questID.  These functions allow for a convenient
place to store custom quest-associated variables and can be accessed by any module script as long
as util_i_quest is included.

```c
    GetQuestInt("myQuestTag", "myVariableName")
    SetQuestInt("myQuestTag", "myVariableName", myIntegerValue)
    DeleteQuestInt("myQuestTag", "myVariableName")

    GetQuestString("myQuestTag", "myVariableName")
    SetQuestString("myQuestTag", "myVariableName", "myStsringValue")
    DeleteQuestString("myQuestTag", "myVariableName")
```

## Quest-Level Properties:

Each quest contains the following properties.  Not all properties are required.

*    **Quest Tag** - The primary identification method for the quest.  This tag will be used in the vast
        majority of interactions between the module and the quest system.  Once set, it should never be
        changed.
*    **Journal Title** - The title that will be displayed in the journal title bar.  This is only required
        for NWNX implementions, which has yet to be accomplished.
*    **Active** - Whether the quest is currently active.  If a quest is inactive, the quest cannot be
        assigned and PCs cannot progress in the quest.  TRUE by default, this value can be set to
        FALSE at any time.  This property allows builders to control when quests are available for 
        assignment or redemption.  For example, you can use an hourly event to only allow specific
        quests to be progressed during night hours.  PCs with quests assigned cannot progress the quest
        while the quest is marked inactive.  Additionally, `GetIsQuestAssignable()` will return FALSE
        if the quest is inactive.
*    **Title** - The quest title.  This is the text that will appear as the title of the quest in
        the player's journal.  If you are using NWNX, you can color this text.  If you are using
        the game's journal editor, you must abide by the editor's capabilities and limitations for
        displaying text.  For NWN journals, this property is not used.
*    **Repetitions** - The number of times a PC can complete the quest.  Generally, quests are one-time or
        repeatable.  Setting this value to 0 (zero) allows the quest to be repeated an infinite number
        of times.  Setting this value to any positive integer will limit the number of times a PC
        can accomplish this quest.  The default value is 1.
*    **Scripts** - Actions to run for quest events.  Quests have four primary events: OnAccept, OnAdvance, 
        OnComplete and OnFail.  The script assigned to OnAccept will run when the quest is assigned to the player.
        The OnAdvance script will run before the first step and then again every time the PC successfully
        completes a step.  The OnComplete script will run when the player successfully completes all steps 
        in a given quest.  The OnFail script will run when the player meets a defined failure condition,
        such as taking too much time to complete a quest or killing a creature that required protection.
        The scripts will be run with the PC as OBJECT_SELF.
*    **Time Limit** - The total real-world time a PC has to complete a quest from the time the quest is assigned to
        the PC.  Failure to complete the quest within the required time will result in quest failure.
        Rewards for completing steps prior to the failure will be kept by the PC.
*    **Cooldown Time** - The total real-world time a PC must wait after completing a quest (whether that
        attempt was a success or failure) before that quest can be assigned again.
*    **Journal Handler** - The primary handler for journal entries for the referenced quest.  This value is set to
        QUEST_JOURNAL_NWN by default, but can be set to any of the following values:
        * QUEST_JOURNAL_NONE - Journal entries will be suppressed
        * QUEST_JOURNAL_NWN - The quest system will use the NWN journal as the journal entry source.  All step numbers
            and quest tags assigned during the creation process **MUST MATCH** the quest tags and id set in the module's
            journal.
        * QUEST_JOURNAL_NWNX - All journal entries for this quest will be handled by NWNX and the module journal entries,
            if they exist, will be overwritten by NWNX entries.  This feature is not yet implemented.
*    **Remove Journal On Completion** - Completely removes the journal entry from the player's journal when the quest
        is complete (success or failure).  FALSE by default.
*    **Allow Precollected Items** - Allows items currently in the player's inventory to satisfy quest step requirements
        when they reach a step that requires items they may have already collected.  TRUE by default.

        >***WARNING*** Timing functions are "real-time" using SQL-based time.  These are not game/server times.

## Quest Prerequisites
Requirements a PC must meet before a quest can be assigned.  You can add any number of
prerequisites to each quest to narrow down which PCs can be assigned specific quests.  All
prerequisites are checked when requested and the PC must pass all required checks before being
assigned a quest.  Party Member characteristics cannot be used to satisfy quest prerequisites.

*    **ALIGNMENT**:
        ```c
        SetQuestPrerequisiteAlignment(int nAlignmentAxis, int bNeutral = FALSE)
        // nAlignmentAxis -> ALIGNMENT_* Constant
        // bNeutral       -> Neutrality Flag
        ```

        This property can be stacked.  There should be one call for each alignment.  The PC must meet ALL
        of the prerequisitve alignments in order to pass this check.  Since the ALIGNMENT_NEUTRAL constant
        cannot denote which axis it lies on (Good-Evil or Law-Chaos), you can set nValue to TRUE to denote
        a requirement for neutrality on the desired axis.

        This example shows prerequisites for lawful-good alignments:
        ```c
            SetQuestPrerequisiteAlignment(ALIGNMENT_GOOD);
            SetQuestPrerequisiteAlignment(ALIGNMENT_LAWFUL);
        ```

        This example shows prerequisites for true neutral:
        ```c
            SetQuestPrerequisiteAlignment(ALIGNMENT_GOOD, TRUE);
            SetQuestPrerequisiteAlignment(ALIGNMENT_LAWFUL, TRUE);
        ```

        This example shows a prerequisite for evil characters:
        ```c
            SetQuestPrerequisiteAlignment(ALIGNMENT_EVIL);
        ```

*    **CLASS**:
        ```c
        SetQuestPrerequisiteClass(int nClass, int nLevels = 1)
        // nClass  -> CLASS_TYPE_* Constant
        // nLevels -> Class Levels Requirements
        ```

        This property can be stacked.  Class prerequisites are treated as **OR**, so the PC must meet
        AT LEAST ONE of the prerequisites, but does not have to meet all of them.  If a level-requirement
        is passed to nValue for the specified class, the PC must also meet the required number of levels
        in that class to pass this check.  Omitting the class level requirement assumes that any number
        of levels in that class satisfies the requirement.  Passing a class level requirement of 0 (zero)
        excludes any PCs that have any number of levels in that class.

        This example shows a requirement for at least 8 levels of Druid **OR** any number of Fighter levels:
        ```c
            SetQuestPrerequisiteClass(CLASS_TYPE_DRUID, 8);
            SetQuestPrerequisiteClass(CLASS_TYPE_FIGHTER);
        ```

        This example shows a requirement for at least 2 levels of Fighter, but any PC with any levels of
        Paladin are excluded:
        ```c
            SetQuestPrerequisiteClass(CLASS_TYPE_FIGHTER, 2);
            SetQuestPrerequisiteClass(CLASS_TYPE_PALADIN, 0);
        ```

*    **GOLD**:
        ```c
        SetQuestPrerequisiteGold(int nGold = 1)
        // nGold -> Gold Amount
        ```

        This property cannot be stacked.  This check passes if the PC has at least the required amount of gold in their
        inventory and fails if they do not.  If this prerequisite is set twice for a single quest, the latest
        nGold value will overwrite any previous value.

*    **ITEM**:
        ```c
        SetQuestPrerequisiteItem(string sItemTag, int nQuantity = 1)
        // sItemTag  -> Tag of Required Item
        // nQuantity -> Quantity of Required Item
        ```

        This property can be stacked.  Item prerequisites are treated as **AND**, so all item prerequisites must
        be met by the PC in order to pass this check.  nQuantity greater than 0 creates an inclusive requirement and
        the PC must have the required number of each item to pass this check.  An nQuantity of 0 creates an exclusive
        requirement and any PC that has any of the referenced sItemTag in inventory will fail the check.

        This example shows a requirement to have 4 flowers and any number of vases in your inventory, but the PC
        cannot have any graveyard dirt:
        ```c
            SetQuestPrerequisiteItem("item_flower", 4);
            SetQuestPrerequisiteItem("item vase");
            SetQuestPrerequisiteItem("item_gravedirt", 0);
        ```

*    **LEVEL_MAX**:
        ```c
        SetQuestPrerequisteLevelMax(int nLevelMax)
        // nLevelMax -> Maximum Total Character Levels
        ```

        This property cannot be stacked.  This check passes if the PC total character levels are less than or equal
        to nLevelMax, and fails otherwise.

*    **LEVEL_MIN**:
        ```c
        SetQuestPrerequisiteLevelMin(int nLevelMin)
        // nLevelMin -> Minimum Total Character Levels
        ```

        This property cannot be stacked.  This check passes if the PC total character levels are more than or equal
        to nLevelMin, and fails otherwise.

*    **QUEST**:
        ```c
        SetQuestPrerequisiteQuest(string sQuestTag, int nCompletionCount = 1)
        // sQuestTag        -> Quest Tag of Prerequisite Quest
        // nCompletionCount -> Number of Prerequisite Quest Completions
        ```

        This property can be stacked.  Quest prerequisites are treated as **AND**, so all quest prerequisites must
        be met by the PC in order to pass this check.  An nCompletionCount greater than 0 creates an inclusive requirement and
        the PC must have completed each quest at least that number of times to pass the check.  An nCompletionCount of 0 creates
        an exclusive requirement and any PC that has completed that quest will fail this check.

        This example shows a requirement to have completed the flower collection quest at least once, but to never
        have completed the rat-killing quest:
        ```c
            SetQuestPrerequisiteQuest("questFlowers");
            SetQuestPrerequisiteQuest("questRats", 0);
        ```

*    **QUEST_STEP**:
        ```c
        SetQuestPrerequisiteQuestStep(string sQuestTag, int nStep)
        // sQuestTag -> Quest Tag of the Prerequisite Quest
        // nStep     -> Required minimum step number of the prerequisite quest
        ```

        This property can be stacked.  Quest step prerequisites are treated as **AND**, so all quest prerequisites must
        be met by the PC in order to pass this check.  The PC must have the prerequisite quest assigned, but not
        have completed it, in order to pass this check.

        This example shows a requirement to be on at least the second step of the prerequisite quest:
        ```c
            SetQuestPrerequisiteQuestStep("myPrerequisiteQuestTag", 2);
        ```

*    **RACE**:
        ```c
        SetQuestPrerequisiteRace(int nRace, int bAllowed = TRUE)
        // nRace    -> RACIAL_TYPE_* Constant
        // bAllowed -> Inclusion/Exclusion Flag
        ```

        This property can be stacked.  Race prerequisites are treated as **OR**, so the PC must meet AT LEAST ONE
        of the prerequisites to pass this check.  An bAllowed of TRUE creates an inclusive requirement and the PC
        must be of at least one of the races listed.  An bAllowed of FALSE cretes an exclusive requirement and the
        PC cannot be of any of the races listed.  Unlike other properties, combining inclusive and exclusive requirements
        on the same quest does not make sense and should be avoided as it could create undefined behavior.

        This example shows a requirement for either a dwarf, a human or a halfling:
        ```c
            SetQuestPrerequisiteRace(RACIAL_TYPE_DWARF);
            SetQuestPrerequisiteRace(RACIAL_TYPE_HUMAN);
            SetQuestPrerequisiteRace(RACIAL_TYPE_HALFLING);
        ```

        This examples show a requirement for any race except a human:
        ```c
            SetQuestPrerequisiteRace(RACIAL_TYPE_HUMAN, FALSE);
        ```

## Quest Step-Level Properties
Each quest step contains the following properties.  Not all properties are required.

*    **Journal Entry** - This is the text that will appear as the body of the quest journal entry in the player's
        in-game quest journal.  If you are using NWNX, you can color this text.  If you are using
        the game's journal editor, you must abide by the editor's capabilities and limitations for
        displaying text.
*    **Party Completion** - This property allows party members to help complete quest steps.  In some cases, it
        may be necessary to allow someone other than the PC that holds the quest to complete a step.  For example,
        if a step's objective is to kill a target and the target is killed by a member of the player's party
        while the player is present, the player would normally be able to get quest credit for the kill.
*    **Time Limit** - The total real-world time a PC has to complete a quest step from the time the previous step is
        successfully accomplished.  Failure to complete the quest step within  the required time will result
        in reversion of the quest to the previous step and removal of all prewards for the lost step.

## Quest Step-Level Prerequisites
Prerequisites cannot be assigned to invdividual steps.

*    **Objectives** - These properties define the purpose of each step in a quest.  Final steps in a quest for either
        success or failure should not have objectives assigned to them.
        
        **KILL**:
        ```c
            SetQuestStepObjectiveKill(string sTarget, int nQuantity = 1)
            // sTarget   -> Tag or Resref of the Target Object
            // nQuantity -> Quantity of Target Object
        ```

        This property can be stacked.  Kill targets are treated as **AND**, so the PC must kill the required number
        of each assigned target object to fulfill this quest step.  A positive nQuantity creates an inclusive requirement
        and the PC must kill at least that many targets to fulfill the requirement.  An nQuantity of 0 creates an exclusive
        requirement and the PC cannot kill any of the specified target objects or the quest step will fail.

        This example shows a requirement to kill at least seven orcs, but to not kill the princess.  There is no
        penalty if a non-party member kills the target object.
        ```c
            SetQuestStepObjectiveKill("creature_orc", 7);
            SetQuestStepObjectiveKill("creature_princess", 0);
        ```

        **GATHER**:
        ```c
            SetQuestStepObjectiveGather(string sTarget, int nQuantity = 1)
            // sTarget   -> Tag or Resref of the Target Object
            // nQuantity -> Quantity of Target Object
        ```

        This property can be stacked.  Gather targets are treated as AND, so the PC must gather the required number
        of each assigned target object to fulfill this quest step.  This property is inclusive only.

        This examples shows a requirement to gather at least seven flower bouquets and one vase:
        ```c
            SetQuestStepObjectiveGather("item_bouquet", 7);
            SetQuestStepObjectiveGather("item_vase");
        ```

        **DELIVER**:
            SetQuestStepObjectiveDeliver(int nQuestID, int nStep, string sKey, int nValue = 1)
            
            TODO - NEED TO FLESH THIS REQUIREMENT OUT A BIT -> It might need more than sKey and nValue to work right.

        **DISCOVER**:
        ```c
            SetQuestStepObjectiveDiscover(string sTarget, int nQuantity = 1)
            // sTarget   -> Tag or Resref of the Target Object
            // nQuantity -> Quantity of Target Object
        ```
            
        This property can be stacked.  Discover targets are treated as AND, so the PC must discover the required number
        of each assigned target object to fulfill this quest step.  This property is inclusive only.  Generally, the
        target objects will be triggers or areas to allow for easy identification, but any object with an assigned event
        can be used.

        This example shows a requirement to discover two different locations:
        ```c
            SetQuestStepObjectiveDiscover("trigger_fishing");
            SetQuestStepObjectiveDiscover("area_hollow");
        ```

        **SPEAK**:
        ```c
            SetQuestStepObjectiveSpeak(string sTarget)
            // sTarget   -> Tag or Resref of the Target Object
            // nQuantity -> Quantity of Target Object
        ```

            This property can be stacked.  Speak targets are treated as AND, so the PC must speak to each of the assigned target
            objects to fulfill this quest step.  This property is inclusive only.

            This example shows a requirement to converse with a store keep NPC:
                SteQuestStepObjectiveSpeak(nQuestID, 1, "creature_StoreKeep");

*    **Prewards** - these are game objects or characteristics that are given or assigned to a PC at the beginning of a quest
            step.  They can be used as a reward system for simply accepting a difficult quest (i.e. gold and xp to prepare
            a PC for a difficult journey), to give the PC an item to deliver to another NPC or as a method to modify PC
            characteristics (i.e. changing the PC's alignment when they accept an assassination quest).
*    **Rewards** - these are game objects or characteristics that are give or assigned to a PC at the end of a quest step.
            Rewards and prewards share the same types.  The primary difference between rewards and prewards is when they
            are allotted.  Any other minor differences are noted in the descriptions below.

        >***Note*** Generally, for prewards and rewards that involve quantities, such as items, gold, xp, etc.,
            the system will credit the desired quantity if the passed value is greater than zero, or debit the desired
            quantity if the value is less than zero.  This allows, for example, items, gold, etc. to be removed
            from the PC should they fail to complete the quest within the required parameters.

        **ALIGNMENT**:
        ```c
            SetQuestStepPrewardAlignment(int nAlignmentAxis, int nValue)
            SetQuestStepRewardAlignment(int nAlignmentAxis, int nValue)
            // nAlignmentAxis -> ALIGNMENT_* Constant
            // nValue         -> Alignment Shift Value
        ```

        This property can be stacked.  There should be one call for each alignment.  The PC will be awarded all
        alignment shifts listed.  For details on how alignment shifts work, see the NWN Lexicon entry for
        AdjustAlignment().

        This example shows an alignment preward for accepting an assassination quest:
        ```c
            SetQuestStepPrewardAlignment(ALIGNMENT_EVIL, 20);
        ```

        This example show an alignment reward for completing a quest step that protects the local farmer's stock:
        ```c
            SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 20);
            SetQuestStepRewardAlignment(ALIGNMENT_LAWFUL, 20);
        ```

        **GOLD**:
        ```c
            SetQuestStepPrewardGold(int nGold)
            SetQuestStepRewardGold(int nGold)
            // nGold -> Gold Amount
        ```

        This property cannot be stacked.  An nGold greater than zero denotes that a PC will receive the specified
        amount of gold.  An nGold less than zero denotes that the PC will lose the specified amount of gold.

        This example shows the PC paying 5000 gold to gain access to specified quest:
        ```c
            SetQuestStepPrewardGold(-5000);
        ```

        **ITEM**:
        ```c
            SetQuestStepPrewardItem(string sItemResref, int nQuantity = 1)
            SetQuestStepRewardItem(string sItemResref, int nQuantity = 1)
            // sItemResref -> Resref of [P]reward Item
            // nQuantity   -> Quantity of [P]reward Item
        ```

        This property can be stacked.  An nQuantity of greater than zero denotes that the PC will receive the designated
        number of items when the quest [p]rewards are allotted.  An nQuantity of less than zero denotes that the PC will
        lose the designated number of items.  Gained and lost items can be stacked.

        This example shows the PC receiving a reward of several items, but losing a prewarded item, upon completion of
        a quest step:
        ```c
            SetQuestStepRewardItem("item_cakes", 2);
            SetQuestStepRewardItem("item_flour", -1);
        ```

        **MESSAGE**:
        ```c
            SetQuestStepPrewardMessage(string sMessage);
            SetQuestStepRewardMessage(string sMessage);
            // sMessage -> The message to display to the PC
        ```

        This property can be stacked.  This property allows you to send a message to the PC either at the beginning of
        a quest step or at the end of a quest step.  This property will be useful for smaller, randomized quests that
        may not merit full NWN journal entries, but still need to interface with the PC for information purposes.

        This example shows the PC receiving a message at the end of the specified step:
        ```c
            SetQuestStepRewardMessage("Thanks for helping us keep the road clear of bandits.");
        ```

        **QUEST**:
        ```c
            SetQuestStepRewardQuest(string sQuestTag, int bGive = TRUE)
            // sQuestTag -> Reward Quest Tag
            // bGive     -> Assignment Flag
        ```

        This property can be stacked.  An bGive of TRUE denotes that the quest should be assigned to the PC.  An bGive
        of FALSE denotes that the quest should be removed from the PC.  By adding a quest as a reward for completing a
        quest, quest chaining can be implemented.

        ***NOTE*** For rewarded quests, prerequistes are NOT checked.  It is assumed that if you are awarding a quest
        as a reward, accomplishing the associated step is the prerequisite for the reward.

        **XP**:
        ```c
            SetQuestStepPrewardXP(int nXP)
            SetquestStepRewardXP(int nXP)
            // nXP -> XP Amount
        ```

        This property cannot be stacked.  An nXP greater than zero denotes that a PC will receive the specified
        amount of XP.  An nXP value less than zero denotes that the PC will lose the specified amount of XP.

# Definining Quests

## Tactics, Techniques and Procedures (TTPs)

* During the quest definition process, Quest IDs, Step IDs and Objective IDs are held in memory for use throughout the process.
    This means all quest properties for one quest must be set before moving on to the next.  The same is true for quest steps
    and quest step objectives.  

* Most quest properties have default values.  No action is required if the default value is desired.

* Quests that have multiple steps have the presumption that these steps must be completed in the order they are presented.  If you'd
    like to have several objectives that can be completed concurrently, assign them all to the same quest step.  For example, if you 
    need a PC to collect 3 different items, and order doesn't matter, assign all three items to the same step

* You can combine sequential and random order steps by assigning single objectives to some steps and multiple objectives to other
    steps.

* If you create a failure condition (such as a time limit or protection requirement), you should add a Failure Resolution Step with
    a matching journal entry and appropriate rewards.

* Quest resolution steps (`AddStepResolutionSuccess()` and `AddStepResolutionFail()`) only award rewards, not prewards.

## Definition Example:

Following is a complete usage example for creating a sequential three-step quest that:
    - Requires the PC to be a 3rd-level halfling rogue
    - Requires the PC to break into three houses
    - Requires the PC collect two maps
    - Limits the PC to 24 hours of real-world time
    - Provides the PC with a set of advanced lockpicks after the find the maps
    - Rewards the PC with Gold, XP and Alignment Shift upon completion
    - Requires the PC report back to the NPC that assigned the quest

>***Note*** In the scripts below, nStep values are assumed to be sequential, however, if
    the step id values in the NWN journal entries are not sequential, you can supply your
    own step ids.  The only requirement is that the step ids increase as steps are added.
    Additionally, each quest MUST have an `AddStepResolutionSuccess()`.  All other steps are
    optional.  A quest with only a resolution step could be used to display quests in the
    journal that don't have completion steps, such as a module update note, or general
    module familiarity/instructions for the PC.  This type of quest can be used, for
    example, in the start area for new PCs, giving them an instructional quest entry as
    well as a few starting items/gold/xp.

```c
void DefineRogueQuest()
{
    // Create the quest and set the tag
    AddQuest("quest_rogue");

    // Set the quest prerequisites
    SetQuestPrerequisiteRace(RACIAL_TYPE_HALFLING);
    SetQuestPrerequisiteClass(CLASS_TYPE_ROGUE, 3);
    SetQuestTimeLimit(CreateTimeVector(0, 0, 0, 24, 0, 0));

    // Step 1 - Find Maps
    AddQuestStep();
    SetQuestObjectiveGather("map_rogue1");
    SetQuestObjectiveGather("map_rogue2");
    // Note these maps can be gathered in any order, but both maps must be found before
    // the step is complete

    // Step 2 - Break into the houses
    AddQuestStep();
    SetQuestStepObjectiveDiscover("trigger_house1");
    SetQuestStepObjectiveDiscover("trigger_house2");
    SetQuestStepObjectiveDiscover("trigger_house3");
    // Like Step 1 above, these triggers can be discovered in any order, but all three
    // must be discovered before the step is considered complete

    SetQuestStepPrewardItem("lockpicks_10", 3);
    // Since this item is a preward, it will be given to the PC as soon as this step
    // is reached.

    // Step 3 - Go tell the guild
    AddQuestStep();
    SetQuestStepObjectiveSpeak("guild_master");
    
    // Create a step for successful completion and rewards
    AddQuestResolutionSuccess();
    SetQuestStepRewardGold(1000);
    SetQuestStepRewardXP(500);
    SetQuestStepRewardAlignment(ALIGNMENT_CHAOS, 10);
    // If successfull, the PC will receive 1000gp, 500xp and an alignment change

    // Since there is a failure condition, create a step for quest failure
    AddQuestResolutionFail();
    SetQuestStepRewardGold(-500);
    SetQuestStepRewardXP(100);
    // If not successful, the PC will lost 500gp, but gain a small amount of XP
}
```

In order to make this quest work, an event of some type has to signal the quest system to
check if the PC correctly accomplished the steps.  In the Rogue Quest example above,
it would be necessary to have checks for OnAcquireItem (for the maps), OnTriggerEnter
(for breaking into the houses) and OnCreatureConversation (for speaking with the NPC);

This is accomplished by sending a signal to the to the quest system through
the `SignalQuestStepProgress()` function.  If you want to do any pre-processing before calling
this function, the events are the correct scripts to do that in.  For example, if you set
a quest step objective to kill a creature, but you only want to count it if that creature is
killed with a specific weapon or weapon type, you would check those custom prerequisites in
your script before calling `SignalQuestStepProgress()`.

This is a simple example of requesting a quest step advance from the quest system when a creature
is killed:

```c
// In the OnCreatureDeath script
void main()
{
    SignalQuestStepProgress(GetLastKiller(), GetTag(OBJECT_SELF), QUEST_OBJECTIVE_KILL);
}

// The first parameter should reference the PC.  The quest system will never trigger off of an
//   NPC or associate, but if one is passed, the system will attempt to identify its master PC
//   before continuing, so users can safely use internal NWN functions such as GetLastKiller().

// The second parameter identifies the triggering object, in this case the slain monster.  The data
//   that is passed here must match the data use when defining the quest, but it does not matter
//   if that was the object's tag, resref, or any other method of identification.

// The third parameter is the objective type.  In this case, a kill is signalled.  This is requried
//   because the quest system attempts to match as many quests as possible that reference the string
//   from the second parameter, but must be able to differentiate between speaking to a specified
//   object or killing the same object.

```

The quest system will then evaluate whether the PC has fulfilled the requirements to move forward
in the quest.  If so, the quest is advanced.  If not, the kill is noted, but the quest does not
advance.  If the PC has fulfilled a failure condition, such as killing a protected creature, the
quest will immediately fail and go to the Failure Resolution step, if it exists.

The system can also run scripts for each quest event type -> Accept, Advance, Complete and Fail.
Before the script is run, up to three variables are stored on the module:  the current quest tag, the
current quest step and the current quest event. You can retrieve these by using `GetCurrentQuest()`,
`GetCurrentQuestStep()` and `GetCurrentQuestEvent()`.  These values will allow builder's to run 
quest-specific code.  Additionally, OBJECT_SELF in all run scripts is the PC.

Here's a short example that creates a single goblin creature at waypoint "quest_test" when the PC
reaches the first step of the quest with the tag "myFirstQuest".

```c
void quest_OnAdvance()
{
    string sCurrentQuest = GetCurrentQuest();
    int nCurrentStep = GetCurrentQuestStep();

    if (sCurrentQuest == "myFirstQuest")
    {
        if (nCurrentStep == 1)
        {
            object oWP = GetWaypointByTag("quest_test");
            location lWP = GetLocation(oWP);
            object oTarget = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP);
        }
    }
}
```