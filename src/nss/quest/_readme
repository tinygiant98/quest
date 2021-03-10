/*
Note: The quest system files  will not function without other utility includes from squattingmonk's
sm-utils.  These utilities can be obtained from
https://github.com/squattingmonk/nwn-core-framework/tree/master/src/utils.

Specificially, the following files are required:  util_i_color.nss, util_i_csvlists.nss,
util_i_debug.nss, util_i_math.nss, util_i_string.nss, util_i_time.nss

*** WARNING *** This documentation is still a work-in-progress.  If anything in this documentation
    doesn't work the way you expect, refer to the code or find me on Discord...

Description:
    This utility is designed to allow builders/scripters to fully define quests within script without
    the need for game journal editing.  The greatest use of this utility comes from pairing it
    with NWNX journal functions, which completely obviates the need for editing journal entries
    in the toolset.  Since there are many modules that cannot or will not use NWNX, I've included
    functionality for interfacing with the game's journal system.

    *** NOTE *** NWNX functions have not yet been implemented due to some idosynchrasies in the code
        and how it interfaces with the game.  When those wrinkles have been ironed out, NWNX
        functionality will be added.  ETA is unknown, so all references to NWNX journal functionality
        below is future-growth.

    *** NOTE *** The primary functions of this system use QuestID numbers to identify various
        quests.  However, you need never know an actual QuestID number to use this successfully.
        All user-facing functions will only accept QuestID numbers if the system will supply the
        number for the user.  For example, using AddQuest() will return the QuestID, which can then
        be used to create various quest properties that accept the QuestID:

            int nQuestID = AddQuest("myQuest");
            SetQuestPrerequisiteLevelMin(nQuestID, 1);

        All other user-facing functions will accept the quest-tag instead of the QuestID.  For example,
        to determine if a PC has met all prerequisites and assign a specific quest:

            if GetIsQuestAssignable(oPC, "myQuest")
                AssignQuest(oPC, "myQuest");

        Because each Quest Tag must be unique, the quest system can internally convert between QuestID
        and Quest Tag when required.  If a user absolutely requires the conversion for other uses, two
        functions are provided:
            string GetQuestTag(int nQuestID)  will return the Quest Tag associated with nQuestID
            int GetQuestID(string sQuestTag)  will return the QuestID associated with sQuestTag

            *** WARNING *** All non-PC quest data is held in volatile memory and will be lost on server
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

Usage Notes:
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
    

    TODO Move Warnings and Notes for Time Usage here.

Custom Quest-Assocated Variables:
    There are several functions that allow the user to associated Int and String variables with any
    quest.  These variables are stored in the volatile module-associated sqlite database in a separate
    table and referenced to the associated quest by QuestID.  These functions allow for a convenient
    place to store custom quest-associated variables and can be accessed by any module script as long
    as util_i_quest is included.

        GetQuestInt()
        SetQuestInt()
        DeleteQuestInt()

        GetQuestString()
        SetQuestString()
        DeleteQuestString()

Property Descriptions:

    Quest-Level Properties - each quest contains the following properties.  Not all properties are required.
        Active - Whether the quest is currently active.  If a quest is inactive, the quest cannot be
            assigned and PCs cannot progress in the quest.  FALSE by default, this value can be set to
            TRUE at any time.  This property allows builders to control when quests are available for 
            assignment or redemption.  For example, you can use an hourly event to only allow specific
            quests to be progressed during night hours.
        Title - The quest title.  This is the text that will appear as the title of the quest in
            the player's journal.  If you are using NWNX, you can color this text.  If you are using
            the game's journal editor, you must abide by the editor's capabilities and limitations for
            displaying text.  For NWN journals, this property is not used.
        Repetitions - The number of times a PC can complete the quest.  Generally, quests are one-time or
            repeatable.  Setting this value to 0 (zero) allows the quest to be repeated an infinite number
            of times.  Setting this value to any positive integer will limit the number of times a PC
            can accomplish this quest.  The default value is 1.
        Scripts - Actions to run for quest events.  Quests have four primary events: OnAccept, OnAdvance, 
            OnComplete and OnFail.  The script assigned to OnAccept will run when the quest is assigned to the player.
            The OnAdvance script will run before the first step and then again every time the PC successfully
            completes a step.  The OnComplete script will run when the player successfully completes all steps 
            in a given quest.  The OnFail script will run when the player meets a defined failure condition,
            such as taking too much time to complete a quest or killing a creature that required protection.
            The scripts will be run with the PC as OBJECT_SELF.
        Step Order - The order in which the steps must be accomplished.  Quests steps can be accomplished
            in sequential order or non-sequentially.  Sequential quests will allow the player to move from
            one step to the next only after completing the previous step.  Non-sequential quests allows the
            player to complete quests steps in any order.
        Time Limit - The total in-game time a PC has to complete a quest from the time the quest is assigned to
            the PC.  Failure to complete the quest within the required time will result in unassignment of the
            quest and removal of all prewards.  Rewards for completing steps will be kept by the PC.

            *** WARNING *** Timing functions require consistent server time.  If you are running a single player
                server or your persistent world time is not consistent across resets, timing functions will
                not work correctly and should be avoided.

            *** Note *** Timing functions use the util_i_time include, which stores all times as string.  If you
                use different time control and storage methods, you'll have to modify these functions to fit your
                methodologies.  To make this easier, the following functions have been included and are meant
                for custom methodologies:
                    // TODO create convenience functions for time management

        Prerequisites - Requirements a PC must meet before a quest can be assigned.  You can add any number of
            prerequisites to each quest to narrow down which PCs can be assigned specific quests.  All
            prerequisites are checked when requested and the PC must pass all required checks before being
            assigned a quest.  Party Member characteristics cannot be used to satisfy quest prerequisites.

            ALIGNMENT:
                SetQuestPrerequisiteAlignment(int nQuestID, int nKey, int nValue = FALSE)
                    nQuestID   -> Quest ID
                    nKey   -> ALIGNMENT_* Constant
                    nValue -> Neutrality Flag

                This property can be stacked.  There should be one call for each alignment.  The PC must meet ALL
                of the prerequisitve alignments in order to pass this check.  Since the ALIGNMENT_NEUTRAL constant
                cannot denote which axis it lies on (Good-Evil or Law-Chaos), you can set nValue to TRUE to denote
                a requirements for neutrality on the desired axis.

                This example shows prerequisites for lawful-good alignments:
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_GOOD);
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_LAWFUL);

                This example shows prerequisites for true neutral:
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_GOOD, TRUE);
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_LAWFUL, TRUE);

                This example shows a prerequisite for evil characters:
                    SetQuestPrerequisityAlignment(nQuestID, ALIGNMENT_EVIL);

            CLASS:
                SetQuestPrerequisiteClass(int nQuestID, int nKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nKey   -> CLASS_TYPE_* Constant
                    nValue -> Class Levels Requirements

                This property can be stacked.  Class prerequisites are treated as OR, so the PC must meet
                AT LEAST ONE of the prerequisites, but does not have to meet all of them.  If a level-requirement
                is passed to nValue for the specified class, the PC must also meet the required number of levels
                in that class to pass this check.  Omitting the class level requirement assumes that any number
                of levels in that class satisfies the requirement.  Passing a class level requirement of 0 (zero)
                excludes any PCs that have any number of levels in that class.

                This example shows a requirement for at least 8 levels of Druid OR any number of Fighter levels:
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_DRUID, 8);
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_FIGHTER);

                This example shows a requirement for at least 2 levels of Fighter, but any PC with any levels of
                Paladin are excluded:
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_FIGHTER, 2);
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_PALADIN, 0);

            GOLD:
                SetQuestPrerequisiteGold(int nQuestID, int nValue)
                    nQuestID -> Quest ID
                    nValue -> Gold Amount

                This property cannot be stacked.  This check passes if the PC has the required amount of gold in their
                inventory and fails if they do not.

            ITEM:
                SetQuestPrerequisiteItem(int nQuestID, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    sKey   -> Tag of Required Item
                    nValue -> Quantity of Required Item

                This property can be stacked.  Item prerequisites are treated as AND, so all item prerequisites must
                be met by the PC in order to pass this check.  nValues greater than 0 create an inclusive requirement and
                the PC must have the required number of each item to pass this check.  An nValue of 0 creates an exclusive
                requirement and any PC that has that referenced item in inventory will fail the check.

                This example shows a requirement to have 4 flowers and any number of vases in your inventory, but the PC
                cannot have any graveyard dirt:
                    SetQuestPrerequisiteItem(nQuestID, "item_flower", 4);
                    SetQuestPrerequisiteItem(nQuestID, "item vase");
                    SetQuestPrerequisiteItem(nQuestID, "item_gravedirt", 0);

            LEVEL_MAX:
                SetQuestPrerequisteLevelMax(int nQuestID, int nValue)
                    nQuestID -> Quest ID
                    nValue -> Maximum Total Character Levels

                This property cannot be stacked.  This check passes if the PC total character levels are less than or equal
                to nValue, and fails otherwise.

            LEVEL_MIN:
                SetQuestPrerequisiteLevelMin(int nQuestID, int nValue)
                    nQuestID -> Quest ID
                    nValue -> Minimum Total Character Levels

                This property cannot be stacked.  This check passes if the PC total character levels are more than or equal
                to nValue, and fails otherwise.

            QUEST:
                SetQuestPrerequisiteQuest(int nQuestID, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    sKey   -> Quest Tag of Prerequisite Quest
                    nValue -> Number of Prerequisite Quest Completions

                This property can be stacked.  Quest prerequisites are treated as AND, so all quest prerequisites must
                be met by the PC in order to pass this check.  An nValue greater than 0 creates an inclusive requirement and
                the PC must have completed each quest at least that number of times to pass the check.  An nValue of 0 creates
                an exclusive requirement and any PC that has completed that quest will fail this check.

                This example shows a requirement to have completed the flower collection quest at least once, but to never
                have completed the rat-killing quest:
                    SetQuestPrerequisiteQuest(nQuestID, "questFlowers");
                    SetQuestPrerequisiteQuest(nQuestID, "questRats", 0);

            QUEST_STEP:
                SetQuestPrerequisiteQuestStep(int nQuestID, string sKey, int nValue)
                    nQuestID -> Quest ID
                    sKey     -> Quest Tag of the Prerequisite Quest
                    nValue   -> Required minimum step number of the prerequisite quest

                This property can be stacked.  Quest step prerequisites are treated as AND, so all quest prerequisites must
                be met by the PC in order to pass this check.  The PC must have the prerequisite quest assigned, but not
                have completed it, in order to pass this check.

                This example shows a requirement to be on at least the second step of the prerequisite quest:
                    SetQuestPrerequisiteQuestStep(nQuestID, "myPrerequisiteQuestTag", 2);

            RACE:
                SetQuestPrerequisiteRace(int nQuestID, int nKey, int nValue = TRUE)
                    nQuestID   -> Quest ID
                    nKey   -> RACIAL_TYPE_* Constant
                    nValue -> Inclusion/Exclusion Flag

                This property can be stacked.  Race prerequisites are treated as OR, so the PC must meet AT LEAST ONE
                of the prerequisites to pass this check.  An nValue of TRUE creates an inclusive requirement and the PC
                must be of at least one of the races listed.  An nvalue of FALSE cretes an exclusive requirement and the
                PC cannot be of any of the races listed.  Unlike other properties, combining inclusive and exclusive requirements
                on the same quest does not make sense and should be avoided as it could create undefined behavior.

                This example shows a requirement for either a dwarf, a human or a halfling:
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_DWARF);
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HUMAN);
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HALFLING);

                This examples show a requirement for any race except a human:
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HUMAN, FALSE);

    Quest Step-Level Properties - each quest step contains the following properties.  Not all properties are required.
        Journal Entry - This is the text that will appear as the body of the quest journal entry in the player's
            in-game quest journal.  If you are using NWNX, you can color this text.  If you are using
            the game's journal editor, you must abide by the editor's capabilities and limitations for
            displaying text.
        Party Completion - This property allows party members to help complete quest steps.  In some cases, it
            may be necessary to allow someone other than the PC that holds the quest to complete a step.  For example,
            if a step's objective is to kill a target and the target is killed by a member of the player's party
            while the player is present, the player would normally be able to get quest credit for the kill.
        Time Limit - The total in-game time a PC has to complete a quest step from the time the previous step is
            successfully accomplished.  Failure to complete the quest step within  the required time will result
            in reversion of the quest to the previous step and removal of all prewards for the lost step.

            *** WARNING *** Timing functions require consistent server time.  If you are running a single player
                server or your persistent world time is not consistent across resets, timing functions will
                not work correctly and should be avoided.

        Prerequisites - Prerequisites cannot be assigned to invdividual steps.  It is assumed that the prerequisite
            for a sequential quest is the completion of all steps in-order.  For non-sequential quests, there are no
            step-level prerequisits and the PC can complete the steps in any order.
        Objectives - These properties define the purpose of each step in a quest.  Final steps in a quest for either
            success or failure should not have objectives assigned to them.
        
            *** WARNING *** It is possible to assign more than one objective to a quest step, however, only one type
                of objective can be assigned.  For example, you can use SetQuestStepObjectiveKill() multiple times on a
                single step, but using SetQuestStepObjectiveKill() and SetQuestObjectiveGather() on the same quest
                step will result in the first objective type being evaluated and the second objective type being ignored.

                So ... this is ok:
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_orc", 7);
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_princess", 0);

                This ... is not:
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_orc", 7);
                    SetQuestStepObjectiveGather(nQuestID, 1, "orc_ears", 0);

            KILL:
                SetQuestStepObjectiveKill(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object

                This property can be stacked.  Kill targets are treated as AND, so the PC must kill the required number
                of each assigned target object to fulfill this quest step.  A positive nValue creates an inclusive requirement
                and the PC must kill at least that many targets to fulfill the requirement.  An nValue of 0 creates an exclusive
                requirement and the PC cannot kill any of the specified target objects or the quest step will fail.

                This example shows a requirement to kill at least seven orcs, but to not kill the princess.  There is no
                penalty if a non-party member kills the target object.
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_orc", 7);
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_princess", 0);

            GATHER:
                SetQuestStepObjectiveGather(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object

                This property can be stacked.  Gather targets are treated as AND, so the PC must gather the required number
                of each assigned target object to fulfill this quest step.  This property is inclusive only.

                This examples shows a requirement to gather at least seven flower bouquets and one vase:
                    SetQuestStepObjectiveGather(nQuestID, 1, "item_bouquet", 7);
                    SetQuestStepObjectiveGather(nQuestID, 1, "item_vase");

            DELIVER:
                SetQuestStepObjectiveDeliver(int nQuestID, int nStep, string sKey, int nValue = 1)
                
                TODO - NEED TO FLESH THIS REQUIREMENT OUT A BIT -> It might need more than sKey and nValue to work right.

            DISCOVER:
                SetQuestStepObjectiveDiscover(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object
                
                This property can be stacked.  Discover targets are treated as AND, so the PC must discover the required number
                of each assigned target object to fulfill this quest step.  This property is inclusive only.  Generally, the
                target objects will be triggers or areas to allow for easy identification, but any object with an assigned event
                can be used.

                This example shows a requirement to discover two different locations:
                    SetQuestStepObjectiveDiscover(nQuestID, 1, "trigger_fishing");
                    SetQuestStepObjectiveDiscover(nQuestID, 1, "area_hollow");

            SPEAK:
                SetQuestStepObjectiveSpeak(int nQuestID, int nStep, string sKey)

                This property can be stacked.  Speak targets are treated as AND, so the PC must speak to each of the assigned target
                objects to fulfill this quest step.  This property is inclusive only.

                This example shows a requirement to converse with a store keep NPC:
                    SteQuestStepObjectiveSpeak(nQuestID, 1, "creature_StoreKeep");

        Prewards - these are game objects or characteristics that are given or assigned to a PC at the beginning of a quest
            step.  They can be used as a reward system for simply accepting a difficult quest (i.e. gold and xp to prepare
            a PC for a difficult journey), to give the PC an item to deliver to another NPC or as a method to modify PC
            characteristics (i.e. changing the PC's alignment when they accept an assassination quest).
        Reward - these are game objects or characteristics that are give or assigned to a PC at the end of a quest step.
            Rewards and prewards share the same types.  The primary difference between rewards and prewards is when they
            are allotted.  Any other minor differences are noted in the descriptions below.

            *** Note *** Generally, for prewards and rewards that involves quantities, such as items, gold, xp, etc.,
                will credit the desired quantity if the passed value is greater than zero, or debit the desired
                quantity if the value is less than zero.  This allows, for example, items, gold, etc. to be removed
                from the PC should they fail to complete the quest within the required parameters.

            ALIGNMENT:
                SetQuestStepPrewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
                SetQuestStepRewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    nKey   -> ALIGNMENT_* Constant
                    nValue -> Alignment Shift Value

                This property can be stacked.  There should be one call for each alignment.  The PC will be awarded all
                alignment shifts listed.  For details on how alignment shifts work, see the NWN Lexicon entry for
                AdjustAlignment().

                This example shows an alignment preward for accepting an assassination quest:
                    SetQuestStepPrewardAlignment(nQuestID, 1, ALIGNMENT_EVIL, 20);

                This example show an alignment reward for completing a quest step that protects the local farmer's stock:
                    SetQuestStepRewardAlignment(nQuestID, 2, ALIGNMENT_GOOD, 20);
                    SetQuestStepRewardAlignment(nQuestID, 2, ALIGNMENT_LAWFUL, 20);

            GOLD:
                SetQuestStepPrewardGold(int nQuestID, int nStep, int nKey)
                SetQuestStepRewardGold(int nQuestID, int nStep, int nKey)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    nKey   -> Gold Amount

                This property cannot be stacked.  An nKey greater than zero denotes that a PC will receive the specified
                amount of gold.  An nKey less than zero denotes that the PC will lose the specified amount of gold.

                This example shows the PC paying 5000 gold to gain access to specified quest:
                    SetQuestStepPrewardGold(nQuestID, 1, -5000);

            ITEM:
                SetQuestStepPrewardItem(int nQuestID, int nStep, string sKey, int nValue = 1)
                SetQuestStepRewardItem(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of [P]reward Item
                    nValue -> Quantity of [P]reward Item

                This property can be stacked.  An nValue of greater than zero denotes that the PC will receive the designated
                number of items when the quest [p]rewards are allotted.  An nValue of less than zero denotes that the PC will
                lose the designated number of items.  Gained and lost items can be stacked.

                This example shows the PC receiving a reward of several items, but losing a prewarded item, upon completion of
                a quest step:
                    SetQuestStepRewardItem(nQuestID, 3, "item_cakes", 2);
                    SetQuestStepRewardItem(nQuestID, 3, "item_flour", -1);

            MESSAGE:
                SetQuestStepPrewardMessage(int nQuestID, int nStep, string sValue);
                SetQuestStepRewardMessage(int nQuestID, int nStep, string sValue);
                    nQuestID -> Quest ID
                    nStep    -> Quest Step Number
                    sValue   -> The message to display to the PC

                This property can be stacked.  This property allows you to send a message to the PC either at the beginning of
                a quest step or at the end of a quest step.  This property will be useful for smaller, randomized quests that
                may not merit full NWN journal entries, but still need to interface with the PC for information purposes.

                This example shows the PC receiving a message at the end of the specified step:
                    SetQuestStepRewardMessage(nQuestID, nStep, "Thanks for helping us keep the road clear of bandits.");

            QUEST:
                SetQuestStepRewardQuest(int nQuestID, int nStep, string sKey, int nValue = TRUE)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Reward Quest Tag
                    nValue -> Assignment Flag

                This property can be stacked.  An nValue of TRUE denotes that the quest should be assigned to the PC.  An nValue
                of FALSE denotes that the quest should be removed from the PC.  By adding a quest as a reward for completing a
                quest, quest chaining is implemented.

                *** NOTE *** For rewarded quests, prerequistes are NOT checked.  It is assumed that if you are awarding a quest
                as a reward, accomplishing the associated step is the prerequisite for the reward.

                This example show the PC receiving a reward of the next quest in the quest chain and having the current quest
                removed completely:
                    SetQuestStepRewardQuest(nQuestID, 4, "questTag2");
                    SetQuestStepRewardQuest(nQuestID, 4, nQuestID, FALSE);

            XP:
                SetQuestStepPrewardXP(int nQuestID, int nStep, int nKey)
                SetquestStepRewardXP(int nQuestID, int nStep, int nKey)
                    nQuestID  -> Quest ID
                    nStep -> Quest Step Number
                    nKey  -> XP Amount

                This property cannot be stacked.  An nValue greater than zero denotes that a PC will receive the specified
                amount of XP.  An nKey value less than zero denotes that the PC will lose the specified amount of XP.

Usage Example:

    Following is a complete usage example for creating a sequential three-step quest that:
        - Requires the PC to be a 3rd-level halfling rogue
        - Requires the PC to break into three houses
        - Requires the PC collect two maps
        - Limits the PC to 24 hours of game time
        - Provides the PC with a set of advanced lockpicks after the find the maps
        - Rewards the PC with Gold, XP and Alignment Shift upon completion
        - Requires the PC report back to the NPC that assigned the quest

    *** Note *** In the scripts below, nStep values are assumed to be sequential, however, if
        the step id values in the NWN journal entries are not sequential, you can supply your
        own step ids.  The only requirement is that the step ids increase as steps are added.
        Additionally, each quest MUST have an AddStepResolutionSuccess().  All other steps are
        optional.  A quest with only a resolution step could be used to display quests in the
        journal that don't have completion steps, such as a module update note, or general
        module familiarity/instructions for the PC.  This type of quest can be used, for
        example, in the start area for new PCs, giving them an instructional quest entry as
        well as a few starting items/gold/xp.

    void DefineRogueQuest()
    {
        int nQuestId, nStep;

        // Create the quest database entry
        nQuestID = AddQuest("quest_rogue");

        SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HALFLING);
        SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_ROGUE, 3);
        SetQuestTimeLimit(nQuestID, CreateDifferenceVector(0, 0, 0, 24, 0, 0));

        // Step 1 - Find Maps
        nStep = AddQuestStep(nQuestID);
        SetQuestObjectiveGather(nQuestID, nStep, "map_rogue1");
        SetQuestObjectiveGather(nQuestID, nStep, "map_rogue2");

        // Step 2 - Break into the houses
        nStep = AddQuestStep(nQuestID);
        SetQuestStepObjectiveDiscover(nQuestID, nStep, "trigger_house1");
        SetQuestStepObjectiveDiscover(nQuestID, nStep, "trigger_house2");
        SetQuestStepObjectiveDiscover(nQuestID, nStep, "trigger_house3");
        SetQuestStepPrewardItem(nQuestID, nStep, "lockpicks_10", 3);

        // Step 3 - Go tell the guild
        nStep = AddQuestStep(nQuestID, sJournalEntry);
        SetQuestStepObjectiveSpeak(nQuestID, nStep, "guild_master");
        
        // Create a step for successful completion and rewards
        nStep = AddQuestResolutionSuccess(nQuestID);
        SetQuestStepRewardGold(nQuestID, nStep, 1000);
        SetQuestStepRewardXP(nQuestID, nStep, 500);
        SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_CHAOS, 10);

        // Since there is a failure condition, create a step for quest failure
        nStep = AddQuestResolutionFail(nQuestID);
        SetQuestStepRewardGold(nQuestID, nStep, -500);
        SetQuestStepRewardXP(nquestID, nStep, 100);
    }

    In order to make this quest work, an event of some type has to call the quest system to
    check if the PC correctly accomplished the steps.  In the Rogue Quest example above,
    it would be necessary to have checks for OnAcquireItem (for the maps), OnTriggerEnter
    (for breaking into the houses) and OnCreatureConversation (for speaking with the NPC);

    This is accomplished by sending a Quest Step Advance Request to the quest system through
    the SignalQuestStepProgress() function.  If you want to do any pre-processing before calling
    this function, the events are the correct scripts to do that in.  For example, if you set
    a quest step objective to kill a creature, but you only want to count it if that creature is
    killed with a specific weapon or weapon type, you would check those custom prerequisites in
    your script before calling SignalQuestStepProgress().

    This is a simple example of requesting a quest step advance from the quest system when a creature
    is killed:

    // In the OnCreatureDeath script
    void main()
    {
        SignalQuestStepProgress(GetLastKiller(), OBJECT_SELF, QUEST_OBJECTIVE_KILL);
    }

    GetLastKiller() will be a PC or any creature in the PC's party.  If an associate scored the kill,
    the quest system will determine who the master PC is and work from there.  OBJECT_SELF is the
    creature that was killed (or, for other objective types, the focus creature or object).
    QUEST_OBJECTIVE_KILL is the type of objective to satisfy with this call.  This is required to
    prevent non-linked objectives from being credited.  For example, if there's one quest where a
    PC must speak to "TownWizard", but another where the PC must kill the "TownWizard", the system
    must be able to differentiate.  It does this by passing the objective type.  If this signal
    can satisfy more than one quest for the PC, it will with this one call.

    The quest system will then evaluate whether the PC has fulfilled the requirements to move forward
    in the quest.  If so, the quest is advanced.  If not, the kill is noted, but the quest does not
    advance.  If the PC has fulfilled a failure condition, such as killing a protected creature, the
    quest will immediately fail and go to the Failure Resolution step, if it exists.

    The system can also run scripts for each quest event type -> Accept, Advance, Complete and Fail.
    Before the script is run, two variables are stored on the module:  the current quest tag and the
    current quest step.  You can retrieve these by using GetCurrentQuest() and GetCurrentQuestStep().
    These values will allow builder's to run quest-specific code.  Here's a short example that creates
    a single goblin creature at waypoint "quest_test" when the PC reaches the first step of the
    quest with the tag "myFirstQuest".

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

                SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
                SetLocalString(oTarget, CREATURE_EVENT_ON_DEATH, "test_goblindeath");
            }
        }
    }
*/