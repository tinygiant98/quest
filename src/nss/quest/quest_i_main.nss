// -----------------------------------------------------------------------------
//    File: quest_i_main.nss
//  System: Quest Persistent World Subsystem (core)
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Changelog:
//
// 20210301:
//      Initial Release

// -----------------------------------------------------------------------------
//                          Database Function Prototypes
// -----------------------------------------------------------------------------

/*
    The following prototype are listed separately from the primary quest system
    prototypes because they are database-related direct-access functions.  These
    functions are available for general use by including quest_i_database.
*/

// ---< CreateModuleQuestTables >---
// Creates the required database tables in the volatile module sqlite database.  If
// bReset == TRUE, this function will attempt to drop all database tables before
// creating new tables.  Call this in the OnModuleLoad event.
void CreateModuleQuestTables(int bReset = FALSE);

// ---< CreatePCQuestTables >---
// Creates the required database table on oPC.  If bReset == TRUE, this function will
// attempt to drop all database tables before creating new tables.  Call this in
// the OnClientEnter event.
void CreatePCQuestTables(object oPC, int bReset = FALSE);

// ---< GetQuestTag >---
// Returns the quest tag associated with nQuestID.
string GetQuestTag(int nQuestID);

// ---< GetQuesTID >---
// Returns the quest ID associated with sQuestTag.
int GetQuestID(string sQuestTag);

// ---< CountActiveQuestSteps >---
// Returns the number of quest steps assigned to quest sQuestTag,
// exclusive of any resolution steps.
int CountActiveQuestSteps(string sQuestTag);

// ---< CountQuestPrerequisites >---
// Counts the number or prerequisites assigned to quest sQuestTag.
int CountQuestPrerequisites(string sQuestTag);

// ---< GetPCHasQuest >---
// Returns TRUE if oPC has quest sQuestTag assigned.
int GetPCHasQuest(object oPC, string sQuestTag);

// ---< GetIsPCQuestComplete >---
// Returns TRUE if oPC has completed quest sQuestTag at least once
int GetIsPCQuestComplete(object oPC, string sQuestTag);

// ---< GetPCQuestCompletions >---
// Returns the total number of times oPC has completed quest sQuestTag
int GetPCQuestCompletions(object oPC, string sQuestTag);

// ---< GetPCQuestStep >---
// Returns the current step oPC is on for quest sQuestTag.
int GetPCQuestStep(object oPC, string sQuestTag);

// ---< GetNextPCQuestStep >---
// Returns the step number of the next step in quest sQuestTag for oPC.
int GetNextPCQuestStep(object oPC, string sQuestTag);

#include "util_i_csvlists"
#include "util_i_debug"
#include "util_i_time"

#include "quest_i_const"
#include "quest_i_debug"
#include "quest_i_database"

#include "nwnx_player"

// -----------------------------------------------------------------------------
//                          Quest System Function Prototypes
// -----------------------------------------------------------------------------

// ---< CleanPCQuestTables >---
// Clears PC quest tables of all quest data if a matching quest tag is not found
// in the module's quest database.  If this is called before quest definitions are
// loaded, all PC quest data will be erased.  Usually called in the OnClientEnter
// event.  Checks the quest version against the quest version in the module database
// and applies a QuestVersionAction, if required.
void CleanPCQuestTables(object oPC);

// ---< AddQuest >---
// Adds a new quest with tag sTag and Journal Entry Title sTitle.  sTag is required;
// the Journal Entry title can be added later with SetQuestTitle().  sTitle is usable
// only with NWNX for journal entries, however it can be retireved with GetQuestTitle()
// to be used for other purposes.
int AddQuest(string sTag, string sTitle = "");

// ---< GetQuestActive >---
// Returns the active status of quest sQuestTag.
int GetQuestActive(string sQuestTag);

// ---< SetQuestActive >---
// Sets quest sQuestTag statust to Active.  If used during the quest definition process,
// sQuestTag is an optional parameter.
void SetQuestActive(string sQuestTag = "");

// ---< GetQuestActive >---
// Sets quest sQuestTag statust to Inactive.  Inactive quests cannot neither assigned
// nor progressed until made active.  If used during the quest definition process, sQuestTag
// is an optional parameter.
void SetQuestInactive(string sQuestTag = "");

// ---< GetQuestTitle >---
// Returns the title of quest sQuestTag as set in AddQuest() or SetQuestTitle().  If using NWNX,
// sTitle will be displayed as the journal entry title.
string GetQuestTitle(string sQuestTag);

// ---< SetQuestTitle >---
// Sets the title of the quest sQuestTag.  Not meant for use outside the quest definition process.
void SetQuestTitle(string sTitle);

// ---< GetQuestRepetitions >---
// Returns the maximum number of times a PC is allowed to complete quest sQuestTag.
int GetQuestRepetitions(string sQuestTag); 

// ---< SetQuestRepetitions >---
// Sets the maximum number of times a PC is allowed to complete the quest currently being defined.
// Not meant for use outside the quest definition process.
void SetQuestRepetitions(int nRepetitions = 1);

// ---< GetQuestScriptOnAccept >---
// Returns the script associated with sQuestTag's OnAccept event.
string GetQuestScriptOnAccept(string sQuestTag);

// ---< GetQuestScriptOnAdvance >---
// Returns the script associated with sQuestTag's OnAdvance event.
string GetQuestScriptOnAdvance(string sQuestTag);

// ---< GetQuestScriptOnComplete >---
// Returns the script associated with sQuestTag's OnComplete event.
string GetQuestScriptOnComplete(string sQuestTag);

// ---< GetQuestScriptOnFail >---
// Returns the script associated with sQuestTag's OnFail event.
string GetQuestScriptOnFail(string sQuestTag);

// ---< SetQuestScriptOnAccept >---
// Sets the script associated with the OnAccept event for the quest currently
// being defined.  Not meant for use outside the quest definition process.
void SetQuestScriptOnAccept(string sScript);

// ---< SetQuestScriptOnAdvance >---
// Sets the script associated with the OnAdvance event for the quest currently
// being defined.  Not meant for use outside the quest definition process.
void SetQuestScriptOnAdvance(string sScript);

// ---< SetQuestScriptOnComplete >---
// Sets the script associated with the OnComplete event for the quest currently
// being defined.  Not meant for use outside the quest definition process.
void SetQuestScriptOnComplete(string sScript);

// ---< SetQuestScriptOnFail >---
// Sets the script associated with the OnFail event for the quest currently
// being defined.  Not meant for use outside the quest definition process.
void SetQuestScriptOnFail(string sScript);

// ---< SetQuestScriptOnAll >---
// Sets the script associated with all quest events for the quest currently
// being defined.  Not meant for use outside the quest definition process.
void SetQuestScriptOnAll(string sScript);

// ---< RunQuestScript >---
// Runs the assigned quest script for quest nQuestID and nScriptType with oPC
// as OBJECT_SELF.  Primarily an internal function, it is exposed to allow more
// options to the builder.
void RunQuestScript(object oPC, string sQuestTag, int nScriptType);

// ---< GetQuestTimeLimit >---
// Returns the time limit associated with quest sQuestTag as a six-element ``time
// vector`` -> (Y,M,D,H,M,S).
string GetQuestTimeLimit(string sQuestTag);

// ---< SetQuestTimeLimit >---
// Sets time vector sTimeVector as the time limit associated with the quest currently
// being defined.  A properly formatted time vector can be built using the
// CreateTimeVector() function.  Not meant for use outside the quest definition process.
void SetQuestTimeLimit(string sTimeVector);

// ---< GetQuestCooldown >---
// Returns the cooldown time associated with quest sQuestTag as a six-element
// ``time vector`` -> (Y,M,D,H,M,S).
string GetQuestCooldown(string sQuestTag);

// ---< SetQuestCooldown >---
// Sets time vector sTimeVector as the minimum amount of time that must pass after a PC
// completes a quest (success or failure) before that quest can be assigned again.  A
// properly formatted time vector can be built using the CreateTimeVector() function.
// Not meant for use outside the quest definition process.
void SetQuestCooldown(string sTimeVector);

// ---< GetQuestJournalHandler >---
// Returns the journal handler for quest sQuestTag as a QUEST_JOURNAL_* constant.
// QUEST_JOURNAL_NONE   Journal entries are suppressed for this quest
// QUEST_JOURNAL_NWN    Journal entries are handled by the game's journal system
// QUEST_JOURNAL_NWNX   Journal entries are handled by NWNX
int GetQuestJournalHandler(string sQuestTag);

// ---< SetQuestJournalHandler >---
// Sets the journal handler for the quest currently being defined to nJournalHandler.
// Default value is QUEST_JOURNAL_NWN.  Not mean for use outside the quest definition process.
// QUEST_JOURNAL_NONE   Journal entries are suppressed for this quest
// QUEST_JOURNAL_NWN    Journal entries are handled by the game's journal system
// QUEST_JOURNAL_NWNX   Journal entries are handled by NWNX
void SetQuestJournalHandler(int nJournalHandler = QUEST_JOURNAL_NWN);

// ---< GetQuestJournalDeleteOnComplete >---
// Returns whether journal entries for quest sQuestTag will be removed from the journal
// upon quest completion.
int GetQuestJournalDeleteOnComplete(string sQuestTag);

// ---< DeleteQuestJournalEntriesOnCompletion >---
// Sets whether journal entries for quest currently being defined will be removed from 
// the journal upon quest completion.  Setting this property will not delete the quest
// from the PC on quest completion.  To set that property, see SetQuestDeleteOnComplete().
// Default value it to keep journal entries on quest completion, so this does not normally
// need to be called.  Not meant for use outside the quest defintion process.
void DeleteQuestJournalEntriesOnCompletion();

// ---< RetainQuestJournalEntriesOnCompletion >---
// Sets whether journal entries for quest currently being defined will be removed from 
// the journal upon quest completion.  Setting this property will not delete the quest
// from the PC on quest completion.  To set that property, see SetQuestDeleteOnComplete().
// Default value it to keep journal entries on quest completion, so this does not normally
// need to be called.  Not meant for use outside the quest defintion process.
void RetainQuestJournalEntriesOnCompletion();

// ---< GetQuestAllowPrecollectedItems >---
// Returns whether quest sQuestTag will credit items toward quest completion if those
// items are already in the PC's inventory when the quest is assigned.  Default value
// is TRUE.
int GetQuestAllowPrecollectedItems(string sQuestTag);

// ---< SetQuestAllowPrecollectedItems >---
// Sets whether the quest currently being defined will credit items toward quest completion
// if those items are already in the PC's inventory when the quest is assigned.  Default value
// is TRUE.  Not meant to be used outside the quest defintion process.
void SetQuestAllowPrecollectedItems(int nAllow = TRUE);

// ---< GetQuestDeleteOnComplete >---
// Returns whether quest sQuestTag is retained in the PC's persistent sqlite database
// after quest completion.  Default value is TRUE.
int GetQuestDeleteOnComplete(string sQuestTag);

// ---< SetQuestDeleteOnComplete >---
// Sets whether the quest currently being defined will be retained in the PC's persistent
// sqlite database after quest completion.  Default value is TRUE.  If set to FALSE, all
// current and historic quest data for this quest will be removed from the PC's persistent
// database and cannot be recovered.  Not meant for use outside the quest defintion process.
void SetQuestDeleteOnComplete(int bDelete = TRUE);

// ---< SetQuestVersion >---
// Sets the quest version of the quest currently being defined.  This allows for identification
// of stale quests on PCs that are logging in.  Used in conjunction with SetQuestVersionAction*
// functions and CleanPCQuestTables().  Not meant for use outside the quest definition process.
void SetQuestVersion(int nVersion);

// ---< SetQuestVersionActionReset >---
// Sets the version action for the quest currently being defined to `Reset`.  If a PC logs in
// with a stale quest version, the PC's quest will be reset to the first step.  Not mean for
// use outside the quest definition process.
void SetQuestVersionActionReset();

// ---< SetQuestVersionActionDelete >---
// Sets the version action for the quest currently being defined to `Delete`.  If a PC logs in
// with a stale quest version, the PC's quest will be deleted from the PC database.  Not mean for
// use outside the quest definition process.
void SetQuestVersionActionDelete();

// ---< SetQuestVersionActionNone >---
// Sets the version action for the quest currently being defined to `None`.  If a PC logs in
// with a stale quest version, no action will be taken.  This is the default value for
// version action.  Not mean for use outside the quest definition process.
void SetQuestVersionActionNone();

// ---< SetQuestPrerequisite[Alignment|Class|Gold|Item|LevelMax|LevelMin|Quest|QuestStep|Race|XP|Skill|Ability] >---
// Sets a prerequisite for a PC to be able to be assigned a quest.  Prerequisites are used by
//  GetIsQuestAssignable() to determine if a PC is eligible to be assigned quest sTag

// ---< SetQuestPrerequisiteAlignment >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have an alignment values that equals nAlignmentAxis.  If bNeutral is TRUE, the
// PC's alignment must be Neutral on the nAlignmentAxis axis.  Not meant for use outside
// the quest definition process.
void SetQuestPrerequisiteAlignment(int nAlignmentAxis, int bNeutral = FALSE);

// ---< SetQuestPrerequisiteClass >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have at least nLevels of nClass.  nClass is an NWN CLASS_TYPE_* constant.  nLevels
// should be one of the following values:
//   >= 1 : Any number of levels in nClass is allowed
//    = 0 : nClass is excluded
// The default logic is to check the PC class >= nLevels.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteClass(int nClass, int nLevels = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< SetQuestPrerequisiteGold >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have at least nGold amount of gold pieces in their inventory at quest assignment.
// The default logic is to check the PC gold >= nGold.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteGold(int nGold = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< SetQuestPrerequisiteItem >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have at least nQuantity amount of sItemTag items in their inventory at quest assignment.
// The default logic is to check the PC item count >= nQuantity.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteItem(string sItemTag, int nQuantity = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< SetQuestPrerequisiteLevelMax >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC total levels be less than or equal to nLevelMax at quest assignment.
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteLevelMax(int nLevelMax);

// ---< SetQuestPrerequisiteLevelMin >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC total levels be greater than or equal to nLevelMin at quest assignment.
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteLevelMin(int nLevelMin);

// ---< SetQuestPrerequisiteQuest >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC meet the required status for a specified quest sQuestTag.  If nCompletionCount > 0,
// The PC must have completed sQuestTag at least nCompletionCount times.  If nCompletionCount
// = 0, the PC must have sQuestTag assigned, but not have completed it yet.  To exclude
// sQuestTag complete, set nCompletionCount to 0 and sOperator to LESS_THAN, or set
// nCompletionCount to any negative number.
// The default logic is to check the PC item count >= nQuantity.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteQuest(string sQuestTag, int nCompletionCount = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< SetQuestPrerequisiteRace >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC be of specified race nRace, with is an NWN RACEIAL_TYPE_* constant.  Leaving
// bAllowed as TRUE ensures nRace is an authorized race to satisfy this prerequisite.
// Setting bAllowed to false will exclude nRace.  Not meant for use outside the quest 
// definition process.
void SetQuestPrerequisiteRace(int nRace, int bAllowed = TRUE);

// ---< SetQuestPrerequisiteXP >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have at least nXP amount of XP at quest assignment.
// The default logic is to check the PC XP >= nXP.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteXP(int nXP, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< SetQuestPrerequisiteSkill >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have at least nRank in nSkill.  nSkill is an NWN SKILL_* constant.  Custom
// values from 2da files can also be used, but may not display correctly in debugging
// messages.
// The default logic is to check the PC skill rank >= nRank.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteSkill(int nSkill, int nRank, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< SetQuestPrerequisiteAbility >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have at least nScore in nScore.  nScore is an NWN ABILITY_* constant.
// The default logic is to check the PC skill rank >= nRank.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteAbility(int nScore, int nScore, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< SetQuestPrerequisiteReputation >---
// Adds a quest prerequisite to the quest currently being defined which requires the
// PC have at least nScore in nScore.  nScore is an NWN ABILITY_* constant.
// The default logic is to check the PC skill rank >= nRank.  If you want a different logical
// operator to be used, change sOperator to one of the following constants:
//   GREATER_THAN
//   GREATER_THAN_OR_EQUAL_TO
//   LESS_THAN
//   LESS_THAN_OR_EQUAL_TO
//   EQUAL_TO
// Not meant for use outside the quest definition process.
void SetQuestPrerequisiteReputation(string sFaction, int nStanding, string sOperator = GREATER_THAN_OR_EQUAL_TO);

// ---< AddQuestStep >---
// Adds a new quest step to the quest currently being defined.  If defining steps in
// sequential order, nStep is not required.  If use NWN as the quest's journal handler
// and the step IDs are not sequential, nStep must be supplied and must exactly match
// the step IDs in the game's journal.  Not meant for use outside the quest definition
// process.
int AddQuestStep(int nStep = -1);

// ---< GetQuestStepJournalEntry >---
// Returns the journal entry text for quest sQuestTag, step nStep.
string GetQuestStepJournalEntry(string sQuestTag, int nStep);

// ---< SetQuestStepJournalEntry >---
// Sets the journal entry text for the active step of the quest currently being
// defined.  This property is only required if using NWNX as the journal handler, however
// it can be set and retrieved for other uses.  Not meant for use outside the quest
// definition process.
void SetQuestStepJournalEntry(string sJournalEntry);

// ---< GetQuestStepTimeLimit >---
// Returns the time limit associated with quest sQuestTag, step nStep as a six-
// element ``time vector`` -> (Y,M,D,H,M,S).
string GetQuestStepTimeLimit(string sQuestTag, int nStep);

// ---< SetQuestStepTimeLimit >---
// Sets time vector sTimeVector as the time limit associated with the active step of
// the quest currently being defined.  A properly formatted time vector can be built
// using the CreateTimeVector() function.  Not meant for use outside the quest
// definition process.
void SetQuestStepTimeLimit(string sTimeVector);

// ---< GetQuestStepPartyCompletion >---
// Returns whether the quest sQuestTag, step nStep has been marked as completable
// by any party member in addition to the assigned PC.
int GetQuestStepPartyCompletion(string sQuestTag, int nStep);

// ---< SetQuestStepPartyCompletion >---
// Sets whether the active step of the quest currently being defined will allow party
// member to fulfill the requirements of the quest step.  Not meant for use outside
// the quest definition process.
void SetQuestStepPartyCompletion(int bPartyCompletion = TRUE);

// ---< GetQuestStepProximity >---
// When a quest step is marked as PartyCompletion, returns whether party members must
// be within the same area as the PC in order to receive credit.  This property has
// no effect if PartyCompletion = FALSE.
int GetQuestStepProximity(string sQuestTag, int nStep);

// ---< SetQuestStepProximity >---
// Sets whether the active step of the quest currently being defined will allow party
// members to recieve credit only if they are within the same area as the PC triggering
// quest progression.  Not meant for use outside the quest definition process.
void SetQuestStepProximity(int bProximity = TRUE);

// ---< GetQuestStepObjectiveMinimum >---
// For quest sQuestTag, step nStep, returns the minimum number of objectives that must be
// met by the PC for the quest step to be considered complete.
int GetQuestStepObjectiveMinimum(string sQuestTag, int nStep);

// ---< SetQuestStepObjectiveMinimum >---
// Sets the minimum number of objectives that have to be met on nStep for the
// step to be considered complete.  The default value is "all steps", however setting
// a specified number here allow the user to create a quest step that can be used
// by many PCs while still allowing some variety (for example, PCs of different classes
// have to speak to different NPCs to complete their quest -- you can list each of those
// NPCs as a speak objective and set the minimum to 1, so each PC can still complete the
// step with different NPCs while still using the same quest).  Not meant to be used 
// outside the quest definition process.
void SetQuestStepObjectiveMinimum(int nMinimum);

// ---< SetQuestStepObjectiveRandom >---
// Returns the number of objectives set on quest sQuestTag, step nStep that will be assigned
// to the PC during the quest assignment process.
int GetQuestStepObjectiveRandom(string sQuestTag, int nStep);

// ---< SetQuestStepObjectiveRandom >---
// Sets a random number of quest step objectives to be used when assigning this quest
// step.  This allows for semi-randomized quest creation.  Users can list multiple quest
// objectives and then set this value to a number less than the number of overall objectives.
// The system will randomly select nObjectiveCount objectives and assign them to the PC
// on quest assignment (instead of assigning all available objectives).
// Not meant to be used outside the quest definition process.
void SetQuestStepObjectiveRandom(int nObjectiveCount);

// ---< SetQuestStepObjectiveDescriptor >---
// Sets the descriptor for the active objective of the active step of the quest
// currently being defined.  Descriptors are only used when SetQuestStepObjectiveRandom()
// is set to a number of objectives less than the total.  See the system README for more
// instructions on this function.  Not meant to be used outside the quest definition process.
void SetQuestStepObjectiveDescriptor(string sDescriptor);

// ---< SetQuestStepObjectiveDescription >---
// Sets the description for the active objectives of the active step of the quest
// currently being defined.  Descriptions are only used when SetQuestStepObjectiveRandom()
// is set to a number of objectives less than the total.  See the system README for more
// instructions on this function.  Not meant for use outside the quest definition process.
void SetQuestStepObjectiveDescription(string sDescription);

// TODO
string GetQuestStepObjectiveFeedback(int nQuestID, int nObjectiveID);
void SetQuestStepObjectiveFeedback(string sFeedback);

// ---< AddQuestResolutionSuccess >---
// A wrapper for AddQuestStep(), adds a step specifically designated for quest success.  This
// is the only step that is required for every quest.  If using NWN as the quest's journal
// handler, this must match a "completion" step as it will mark the quest completed in the
// PC's quest database.  If nStep is not passed, the next sequential number will be used.
// Rewards can be assigned to this step as overall quest rewards.  Resolution steps do not
// provide preward allotments.  Not meant for use outside the quest definition process.
int AddQuestResolutionSuccess(int nStep = -1);

// ---< AddQuestResolutionFail >---
// A wrapper for AddQuestStep(), adds a step specifically designated for quest failure.
// If using NWN as the quest's journal handler, this must match a "completion" step as 
// it will mark the quest completed in the PC's quest database.  If nStep is not passed, 
// the next sequential number will be used. Rewards can be assigned to this step as 
// overall quest rewards.  Resolution steps do not provide preward allotments.  Not meant
// for use outside the quest definition process.
int AddQuestResolutionFail(int nStep = -1);

// ---< SetQuestStepObjectiveKill >---
// Assign a KILL objective to the active step of the quest currently being defined.  The
// target is identified by sTargetTag and the quantity to fulfill the step requirements
// is nQuantity.  Setting nQuantity to a number greater than zero requires the PC (or
// the PC's party, if PartyCompletable) to kill at least that number of targets.  If
// nQuantity is set to zero, this objective is considered a PROTECTION objective and the
// quest will fail if the target is killed (by any method) before the quest step is
// complete.  Set nMax to a number greater than nQuantity to create a range from which
// a quantity will be selected upon quest assignment.  For PROTECTION quests where
// nQuantity = 0, set nMax to a negative number denoting how many of sTargetTag can be
// killed before the quest is considered failed.  Not meant for use outside the 
// quest definition process.
void SetQuestStepObjectiveKill(string sTargetTag, int nQuantity = 1, int nMax = 0);

// ---< SetQuestStepObjectiveGather >---
// Assign a GATHER objective to the active step of the quest currently being defined.  The
// target is identified by sTargetTag and the quantity to fulfill the step requirements
// is nQuantity.  Setting nQuantity to a number greater than zero requires the PC (or
// the PC's party, if PartyCompletable) to collect at least that number of targets.  If
// nQuantity is set to zero, this objective is ignored.  Set nMax to a number greater than
// nQuantity to create a range from which a quantity will be selected upon quest
// assignment.  Not meant for use outside the quest definition process.
void SetQuestStepObjectiveGather(string sTargetTag, int nQuantity = 1, int nMax = 0);

// ---< SetQuestStepObjectiveDeliver >---
// Assign a DELIVER objective to the active step of the quest currently being defined.  This
// objective requires the PC (or party members) to deliver nQuantity sItemTags to sTargetTag
// to fulfill the step requirements.  Setting nQuantity to a number greater than zero requires
// the PC (or the PC's party, if PartyCompletable) to deliver at least that number of targets.  If
// nQuantity is set to zero, this objective is ignored.  Set nMax to a number greater than
// nQuantity to create a range from which a quantity will be selected upon quest
// assignment.  Not meant for use outside the quest definition process.
void SetQuestStepObjectiveDeliver(string sTargetTag, string sItemTag, int nQuantity = 1, int nMax = 0);

// ---< SetQuestStepObjectiveDiscover >---
// Assign a DISCOVER objective to the active step of the quest currently being defined.  This
// objective requires the PC (or party members) to find nQuantity sTargetTags
// to fulfill the step requirements.  Setting nQuantity to a number greater than zero requires
// the PC (or the PC's party, if PartyCompletable) to deliver at least that number of targets.  If
// nQuantity is set to zero, this objective is ignored.  Set nMax to a number greater than
// nQuantity to create a range from which a quantity will be selected upon quest
// assignment.  Not meant for use outside the quest definition process.
void SetQuestStepObjectiveDiscover(string sTargetTag, int nQuantity = 1, int nMax = 0);

// ---< SetQuestStepObjectiveSpeak >---
// Assign a SPEAK objective to the active step of the quest currently being defined.  This
// objective requires the PC (or party members) to speak to nQuantity sTargetTags
// to fulfill the step requirements.  Setting nQuantity to a number greater than zero requires
// the PC (or the PC's party, if PartyCompletable) to deliver at least that number of targets.  If
// nQuantity is set to zero, this objective is ignored.  Set nMax to a number greater than
// nQuantity to create a range from which a quantity will be selected upon quest
// assignment. Not meant for use outside the quest definition process.
void SetQuestStepObjectiveSpeak(string sTargetTag, int nQuantity = 1, int nMax = 0);

// ---< SetQuestStepPrewardAlignment >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will provide an alignment change to
// the assigned PC along nAlignmentAxis (ALIGNMENT_* constant) of value nValue.  nValue
// should always be positive.  Not meant to be used outside the quest definition process.
void SetQuestStepPrewardAlignment(int nAlignmentAxis, int nValue, int bParty = FALSE);

// ---< SetQuestStepPrewardGold >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will provide nGold gold pieces to
// the assigned PC.  Amounts greater than zero will be provided to the PC.  Amounts less
// than zero will be taken from the PC.  Not meant to be used outside the quest definition process.
void SetQuestStepPrewardGold(int nGold, int bParty = FALSE);

// ---< SetQuestStepPrewardItem >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will provide nQuantity sResrefs to
// the assigned PC.  Amounts greater than zero will be provided to the PC.  Amounts less
// than zero will be taken from the PC, if they exists.  Not meant to be used outside 
// the quest definition process.
void SetQuestStepPrewardItem(string sResref, int nQuantity = 1, int bParty = FALSE);

// ---< SetQuestStepPrewardQuest >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will assign sQuestTag to 
// the assigned PC.  If bAssign is TRUE, the quest will be assigned.  If bAssign is FALSE,
// the quest will be deleted.  Not meant to be used outside the quest definition process.
void SetQuestStepPrewardQuest(string sQuestTag, int bAssign = TRUE, int bParty = FALSE);

// ---< SetQuestStepPrewardXP >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will provide nXP experience points to
// the assigned PC.  Amounts greater than zero will be provided to the PC.  Amounts less
// than zero will be taken from the PC.  Not meant to be used outside the quest definition process.
void SetQuestStepPrewardXP(int nXP, int bParty = FALSE);

// ---< SetQuestStepPrewardMessage >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will display a pre-defined message to
// the assigned PC.  Not meant to be used outside the quest definition process.
void SetQuestStepPrewardMessage(string sMessage, int bParty = FALSE);

// ---< SetQuestStepPrewardRepuation >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will modify the reputation of the 
// assigned PC toward sFaction by nChange points.  sFaction is the tag of the game object
// representing the faction to modify the reputation for.  Not meant to be used outside 
// the quest definition process.
void SetQuestStepPrewardReputation(string sFaction, int nChange, int bParty = FALSE);

// ---< SetQuestStepPrewardVariableInt >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will create, modify or delete a specified
// local variable on the PC object.  This function is considered advance usage and the
// system README should be consulted before using.
void SetQuestStepPrewardVariableInt(string sVarName, string sOperator, int nValue, int bParty = FALSE);

// ---< SetQuestStepPrewardVariableInt >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will create, modify or delete a specified
// local variable on the PC object.  This function is considered advance usage and the
// system README should be consulted before using.
void SetQuestStepPrewardVariableString(string sVarName, string sOperator, string sValue, int bParty = FALSE);

// ---< SetQuestStepRewardAlignment >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will provide an alignment change to
// the assigned PC along nAlignmentAxis (ALIGNMENT_* constant) of value nValue.  nValue
// should always be positive.  Not meant to be used outside the quest definition process.
void SetQuestStepRewardAlignment(int nAlignmentAxis, int nValue, int bParty = FALSE);

// ---< SetQuestStepRewardGold >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will provide nGold gold pieces to
// the assigned PC.  Amounts greater than zero will be provided to the PC.  Amounts less
// than zero will be taken from the PC.  Not meant to be used outside the quest definition process.
void SetQuestStepRewardGold(int nGold, int bParty = FALSE);

// ---< SetQuestStepRewardItem >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will provide nQuantity sResrefs to
// the assigned PC.  Amounts greater than zero will be provided to the PC.  Amounts less
// than zero will be taken from the PC, if they exists.  Not meant to be used outside 
// the quest definition process.
void SetQuestStepRewardItem(string sResref, int nQuantity = 1, int bParty = FALSE);

// ---< SetQuestStepRewardQuest >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will assign sQuestTag to 
// the assigned PC.  If bAssign is TRUE, the quest will be assigned.  If bAssign is FALSE,
// the quest will be deleted.  Not meant to be used outside the quest definition process.
void SetQuestStepRewardQuest(string sQuestTag, int bAssign = TRUE, int bParty = FALSE);

// ---< SetQuestStepRewardXP >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will provide nXP experience points to
// the assigned PC.  Amounts greater than zero will be provided to the PC.  Amounts less
// than zero will be taken from the PC.  Not meant to be used outside the quest definition process.
void SetQuestStepRewardXP(int nXP, int bParty = FALSE);

// ---< SetQuestStepRewardMessage >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will display a pre-defined message to
// the assigned PC.  Not meant to be used outside the quest definition process.
void SetQuestStepRewardMessage(string sMessage, int bParty = FALSE);

// ---< SetQuestStepRewardReputation >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will modify the reputation of the 
// assigned PC toward sFaction by nChange points.  sFaction is the tag of the game object
// representing the faction to modify the reputation for.  Not meant to be used outside 
// the quest definition process.
void SetQuestStepRewardReputation(string sFaction, int nChange, int bParty = FALSE);

// ---< SetQuestStepRewardVariableInt >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will create, modify or delete a specified
// local variable on the PC object.  This function is considered advance usage and the
// system README should be consulted before using.
void SetQuestStepRewardVariableInt(string sVarName, string sOperator, int nValue, int bParty = FALSE);

// ---< SetQuestStepRewardVariableString >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will create, modify or delete a specified
// local variable on the PC object.  This function is considered advance usage and the
// system README should be consulted before using.
void SetQuestStepRewardVariableString(string sVarName, string sOperator, string sValue, int bParty = FALSE);

// ---< GetIsQuestAssignable >---
// Returns whether oPC meets all prerequisites for quest sQuestTag.  Quest prerequisites can only
// be satisfied by the PC object, not party members.
int GetIsQuestAssignable(object oPC, string sQuestTag);

// ---< AssignQuest >---
// Assigns quest sQuestTag to player object oPC.  Does not check for quest elgibility. 
// GetIsQuestAssignable() should be run before calling this procedure to ensure the PC
// meets all prerequisites for quest assignment.
void AssignQuest(object oPC, string sQuestTag);

// ---< UnassignQuest >---
// Unassigns quest sQuestTag from player object oPC.  Does not delete the quest from the PC 
// database, but resets the quest to Step 0 and prevents the PC from progressing further until
// the quest is reassigned.
void UnassignQuest(object oPC, string sQuestTag);

// ---< SignalQuestStepProgress >---
// Called from module/game object scripts to signal the quest system to advance the quest, if
// the PC has completed all required objectives for the current step.
int SignalQuestStepProgress(object oPC, string sTargetTag, int nObjectiveType, string sData = "");

// ---< SignalQuestStepRegress >---
// Called from module/game object scripts to signal th equest system to regress the quest.  This
// would be used, for example, during a GATHER quest when the PC drops an items to reduce the
// collected count and prevent some types of player attempts to cheat the system.
int SignalQuestStepRegress(object oPC, string sTargetTag, int ObjectiveType, string sData = "");

// ---< GetCurrentQuest >---
// Global accessor to retrieve the current quest tag for all quest events.
string GetCurrentQuest();

// ---< GetCurrentQuest >---
// Global accessor to retrieve the current quest step for the OnAdvance quest event.
int GetCurrentQuestStep();

// ---< GetCurrentQuest >---
// Global accessor to retrieve the current quest event constant for all quest events.
int GetCurrentQuestEvent();

// ---< GetQuestInt >---
// Returns an integer value set into the volatile module database by SetQuestInt().
int GetQuestInt(string sQuestTag, string sVarName);

// ---< SetQuestInt >---
// Sets an integer value into the volatile module database and associated the value with a specific quest.
void SetQuestInt(string sQuestTag, string sVarName, int nValue);

// ---< DeleteQuestInt >---
// Deletes an integer value from the volatile module database.
void DeleteQuestInt(string sQuestTag, string sVarName);

// ---< GetQuestString >---
// Returns an string value set into the volatile module database by SetQuestInt().
string GetQuestString(string sQuestTag, string sVarName);

// ---< SetQuestString >---
// Sets an string value into the volatile module database and associated the value with a specific quest.
void SetQuestString(string sQuestTag, string sVarName, string sValue);

// ---< DeleteQuestString >---
// Deletes an string value from the volatile module database.
void DeleteQuestString(string sQuestTag, string sVarName);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

string _GetPCQuestData(object oPC, int nQuestID, string sField)
{
    string sResult, sQuestTag = GetQuestTag(nQuestID);

    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_pc_data " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    if (SqlStep(sql))
        sResult = SqlGetString(sql, 0);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:retrieve-field", IntToString(nQuestID),
            sField, PCToString(oPC), sResult);

    return sResult;
    //return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

void _SetPCQuestData(object oPC, int nQuestID, string sField, string sValue)
{
    string sResult, sQuestTag = GetQuestTag(nQuestID);
    string sQuery = "UPDATE quest_pc_data " +
                    "SET " + sField + " = @value " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@value", sValue);
    SqlBindString(sql, "@tag", sQuestTag);
    
    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-field", IntToString(nQuestID),
            sField, PCToString(oPC), sValue);
}

void _SetQuestData(string sField, string sValue, int nQuestID = -1)
{
    if (nQuestID == -1)
        nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);

    if (nQuestID == -1 || nQuestID == -1)
    {
        QuestError("_SetQuestData():  Attempt to set quest data when quest does not exist" +
              "\n  Quest ID -> " + ColorValue(IntToString(nQuestID)) +
              "\n  Field    -> " + ColorValue(sField) +
              "\n  Value    -> " + ColorValue(sValue));
        return;
    }

    string sQuery = "UPDATE quest_quests " +
                    "SET " + sField + " = @sValue " +
                    "WHERE id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sValue", sValue);
    SqlBindInt(sql, "@id", nQuestID);
    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-field", IntToString(nQuestID),
            sField, "module", sValue);
}

string _GetQuestData(int nQuestID, string sField)
{
    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_quests " +
                    "WHERE id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    string sResult;
    if (SqlStep(sql))
        sResult = SqlGetString(sql, 0);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:retrieve-field", IntToString(nQuestID),
            sField, "module", sResult);

    return sResult;
    //return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

void _SetQuestVariable(int nQuestID, string sType, string sVarName, string sValue)
{
    // Don't create the table unless we need it
    if (GetLocalInt(GetModule(), QUEST_VARIABLE_TABLES_INITIALIZED) == FALSE)
        CreateQuestVariablesTable();

    string sQuery = "INSERT INTO quest_variables (quests_id, sType, sName, sValue) " +
                    "VALUES (@id, @type, @name, @value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

string _GetQuestVariable(int nQuestID, string sType, string sVarName)
{
    string sQuery = "SELECT sValue FROM quest_variables " +
                    "WHERE quests_id = @id " +
                        "AND sType = @type " +
                        "AND sName = @name;";

    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

void _DeleteQuestVariable(int nQuestID, string sType, string sVarName)
{
    string sQuery = "DELETE FROM quest_variables " +
                    "WHERE quests_id = @id " +
                        "AND sPropertyType = @type " +
                        "AND sPropertyName = @name;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);

    SqlStep(sql);
}

string _GetPCQuestVariable(object oPC, string sQuestTag, string sType, string sVarName, int nStep = 0)
{
    if (GetTableExists(oPC, "quest_pc_variables") == FALSE)
    {
        QuestDebug("Attempted to obtain variable from quest_pc_variables, but table does not " +
            "exist on " + PCToString(oPC) +
            "\n  sQuestTag -> " + ColorValue(sQuestTag) +
            "\n  sVarName -> " + ColorValue(sVarName) +
            "\n  nStep -> " + ColorValue(IntToString(nStep), TRUE));
        return "";
    }        

    string sQuery = "SELECT sValue FROM quest_pc_variables " +
                    "WHERE quest_tag = @quest_tag " +
                        "AND sType = @type " +
                        "AND sName = @name " +
                        "AND nStep = @step;";

    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);
    SqlBindInt(sql, "@step", nStep);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

void _SetPCQuestVariable(object oPC, string sQuestTag, string sType, string sVarName, string sValue, int nStep = 0)
{
    CreatePCVariablesTable(oPC);

    string sQuery = "INSERT INTO quest_pc_variables (quest_tag, nStep, sType, sName, sValue) " +
                    "VALUES (@quest_tag, @step, @type, @name, @value);";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    SqlBindInt(sql, "@step", nStep);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
}

void _DeletePCQuestVariable(object oPC, string sQuestTag, string sType, string sVarName, int nStep = 0)
{
    if (GetTableExists(oPC, "quest_pc_variables") == FALSE)
        return;

    sQuery = "DELETE FROM quest_pc_variables " +
             "WHERE quest_tag = @quest_tag " +
                "AND sType = @type " +
                "AND sName = @name " +
                "AND nStep = @step;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);
    SqlBindInt(sql, "@step", nStep);

    SqlStep(sql);
}

void SetQuestInt(string sQuestTag, string sVarName, int nValue)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == -1 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "INT", sVarName, IntToString(nValue));
}

int GetQuestInt(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == -1 || sVarName == "")
        return 0;

    return StringToInt(_GetQuestVariable(nQuestID, "INT", sVarName));
}

void DeleteQuestInt(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == -1 || sVarName == "")
        return;

    _DeleteQuestVariable(nQuestID, "INT", sVarName);
}

void SetQuestString(string sQuestTag, string sVarName, string sValue)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == -1 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "STRING", sVarName, sValue);
}

string GetQuestString(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == -1 || sVarName == "")
        return "";

    return _GetQuestVariable(nQuestID, "STRING", sVarName);
}

void DeleteQuestString(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == -1 || sVarName == "")
        return;

    _DeleteQuestVariable(nQuestID, "STRING", sVarName);
}

void SetPCQuestString(object oPC, string sQuestTag, string sVarName, string sValue, int nStep = 0)
{
    _SetPCQuestVariable(oPC, sQuestTag, "STRING", sVarName, sValue, nStep);
}

string GetPCQuestString(object oPC, string sQuestTag, string sVarName, int nStep = 0)
{
    return _GetPCQuestVariable(oPC, sQuestTag, "STRING", sVarName, nStep);
}

void DeletePCQuestString(object oPC, string sQuestTag, string sVarName, int nStep = 0)
{
    _DeletePCQuestVariable(oPC, sQuestTag, "STRING", sVarName, nStep);
}

void SetPCQuestInt(object oPC, string sQuestTag, string sVarName, int nValue, int nStep = 0)
{
    string sValue = IntToString(nValue);
    _SetPCQuestVariable(oPC, sQuestTag, "INT", sVarName, sValue, nStep);
}

int GetPCQuestInt(object oPC, string sQuestTag, string sVarName, int nStep = 0)
{
    return StringToInt(_GetPCQuestVariable(oPC, sQuestTag, "INT", sVarName, nStep));    
}

void DeletePCQuestInt(object oPC, string sQuestTag, string sVarName, int nStep = 0)
{
    _DeletePCQuestVariable(oPC, sQuestTag, "INT", sVarName, nStep);
}

void _SetQuestStepData(string sField, string sValue)
{
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    int nStep = GetLocalInt(GetModule(), QUEST_BUILD_STEP);

    string sQuery = "UPDATE quest_steps " +
                    "SET " + sField + " = @value " +
                    "WHERE quests_id = @id " +
                        "AND nStep = @nStep;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-step", IntToString(nQuestID),
            IntToString(nStep), sField, sValue);
}

string _GetQuestStepData(int nQuestID, int nStep, string sField)
{
    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_steps " +
                    "WHERE quests_id = @id " +
                        "AND nStep = @step;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);
    
    string sResult;
    if (SqlStep(sql))
        sResult = SqlGetString(sql, 0);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:retrieve-step", IntToString(nQuestID),
            IntToString(nStep), sField, sResult);

    return sResult;
    //return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

void DisplayPCQuestData(object oPC, object oDestination, string sQuestTag = "", int bVerbose = FALSE)
{
    if (GetIsPC(oPC) == FALSE)
        return;

    string sMessage;

    sqlquery sql = GetPCQuestData(oPC, sQuestTag);
    while (SqlStep(sql))
    {   
        if (GetStringLength(sMessage) > 0)
            sMessage += "\n";

        sQuestTag = SqlGetString(sql, 0);
        int nStep = SqlGetInt(sql, 1);
        string sCompletions = SqlGetString(sql, 2);
        string sFailures = SqlGetString(sql, 3);

        int nQuestID = GetQuestID(sQuestTag);
        string sQuestTitle = _GetQuestData(nQuestID, QUEST_TITLE);

        sMessage += ColorHeading("* ") + QuestToString(nQuestID) + " " + StepToString(nStep) + " " + 
            (sQuestTitle == "" ? HexColorString("[Title Not Assigned]", COLOR_RED_LIGHT) : ColorHeading("[Title] ") + ColorValue(sQuestTitle));

        sqlquery sqlData = GetPCQuestStepData(oPC, sQuestTag);
        while (SqlStep(sqlData))
        {
            int nObjectiveType = SqlGetInt(sqlData, 1);
            string sTargetTag = SqlGetString(sqlData, 2);
            string sTargetData = SqlGetString(sqlData, 3);
            string sRequired = SqlGetString(sqlData, 4);
            string sAcquired = SqlGetString(sqlData, 5);

            sMessage += "\n   " + ColorHeading("> Objective Type -> ") + ColorValue(ObjectiveTypeToString(nObjectiveType));

            if (nObjectiveType == QUEST_OBJECTIVE_DELIVER)
            {
                sMessage += "\n      " + ColorHeading("- Destination Tag -> ") + ColorValue(sTargetTag) +
                            "\n      " + ColorHeading("- Target Tag -> ") + ColorValue(sTargetData);
            }
            else
                sMessage += "\n      "+ ColorHeading("- Objective Tag -> ") + ColorValue(sTargetTag);

            sMessage += "\n      " + ColorHeading("- Objective Status -> ") + ColorValue(sAcquired + "/" + sRequired);
        }
    }

    sMessage = HexColorString("Current quest status for ", COLOR_CYAN) + PCToString(oPC) + "\n" + sMessage;

    if (GetIsPC(oDestination))
        SendMessageToPC(oDestination, sMessage);
    else
        WriteTimestampedLogEntry(UnColorString(sMessage));
}

void CleanPCQuestTables(object oPC)
{
    QuestDebug("Cleaning PC Quest Tables for " + PCToString(oPC));
    QuestDebug("Checking quest versions for stale quests ...");

    int nStale;

    sQuery = "SELECT quest_tag, nQuestVersion " +
             "FROM quest_pc_data;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    while (SqlStep(sql))
    {
        string sQuestTag = SqlGetString(sql, 0);
        int nQuestVersion = SqlGetInt(sql, 1);
        int nQuestID = GetQuestID(sQuestTag);

        sQuery = "SELECT nQuestVersion " +
                 "FROM quest_quests " +
                 "WHERE sTag = @tag;";
        sqlquery sqlVersion = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlBindString(sqlVersion, "@tag", sQuestTag);

        if (SqlStep(sqlVersion))
        {
            if (nQuestVersion != SqlGetInt(sqlVersion, 0))
            {
                nStale++;
                int nAction = StringToInt(_GetQuestData(nQuestID, QUEST_VERSION_ACTION));
                if (nAction == QUEST_VERSION_ACTION_NONE)
                {
                    QuestDebug("Quest versions for " + QuestToString(nQuestID) + " do not match; " +
                        "no action taken due to version action setting");
                    continue;
                }
                else if (nAction == QUEST_VERSION_ACTION_RESET)
                {
                    QuestDebug("Quest versions for " + QuestToString(nQuestID) + " do not match; " +
                        "resetting quest for " + PCToString(oPC));
                    AssignQuest(oPC, sQuestTag);
                }
                else if (nAction == QUEST_VERSION_ACTION_DELETE)
                {
                    QuestDebug("Quest versions for " + QuestToString(nQuestID) + " do not match; " +
                        "deleting quest from " + PCToString(oPC));
                    DeletePCQuest(oPC, nQuestID);
                    RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
                }
            }
        }
    }

    QuestDebug("Quest check complete; " + 
        (nStale == 0 ? HexColorString("0 stale quests found", COLOR_GREEN_LIGHT) : 
        HexColorString(IntToString(nStale) + " stale quest" + (nStale == 1 ? "" : "s") + " found.", COLOR_RED_LIGHT) +
        "  Check the log for actions taken."));

/*
    sQuery = "SELECT GROUP_CONCAT(sTag) " +
             "FROM quest_quests;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    
    if (SqlStep(sql))
    {
        string sQuestTags = SqlGetString(sql, 0);
        sQuery = "DELETE FROM quest_pc_data " +
                 "WHERE quest_tag NOT IN (" + sQuestTags + ");";
        sql = SqlPrepareQueryObject(oPC, sQuery);
        SqlStep(sql);
    }

    HandleSqlDebugging(sql);*/ // Still doesn't work!
}

int _GetIsPropertyStackable(int nPropertyType)
{
    if (nPropertyType == QUEST_VALUE_GOLD ||
        nPropertyType == QUEST_VALUE_LEVEL_MAX ||
        nPropertyType == QUEST_VALUE_LEVEL_MIN ||
        nPropertyType == QUEST_VALUE_XP)
        return FALSE;
    else
        return TRUE;
}

void _SetQuestStepProperty(int nCategoryType, int nValueType, string sKey, string sValue,
                           string sValueMax = "", string sData = "", int bParty = FALSE)
{
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    int nStep = GetLocalInt(GetModule(), QUEST_BUILD_STEP);

    if (nCategoryType != QUEST_CATEGORY_OBJECTIVE)
    {
        if (_GetIsPropertyStackable(nValueType) == FALSE)
            DeleteQuestStepPropertyPair(nQuestID, nStep, nCategoryType, nValueType);
    }

    string sQuery = "INSERT INTO quest_step_properties " +
                        "(quest_steps_id, nCategoryType, nValueType, sKey, sValue, sValueMax, sData, bParty) " +
                    "VALUES (@step_id, @category, @type, @key, @value, @max, @data, @party);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@step_id", GetQuestStepID(nQuestID, nStep));
    SqlBindInt(sql, "@type", nValueType);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@value", sValue);
    SqlBindString(sql, "@max", sValueMax);
    SqlBindString(sql, "@data", sData);
    SqlBindInt(sql, "@party", bParty);

    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-step-property", IntToString(nQuestID),
            IntToString(nStep), IntToString(nCategoryType), IntToString(nValueType),
            sKey, sValue, sData);

    if (nCategoryType == QUEST_CATEGORY_OBJECTIVE)
    {
        int nObjectiveID = GetLastInsertedID("quest_step_properties");
        SetLocalInt(GetModule(), QUEST_BUILD_OBJECTIVE, nObjectiveID);
    }
}

// Private accessor for setting quest step objectives
void _SetQuestObjective(int nValueType, string sKey, string sValue, string sValueMax, string sData = "")
{
    _SetQuestStepProperty(QUEST_CATEGORY_OBJECTIVE, nValueType, sKey, sValue, sValueMax, sData);
}

// Private accessor for setting quest step prewards
void _SetQuestPreward(int nValueType, string sKey, string sValue, int bParty = FALSE)
{
    _SetQuestStepProperty(QUEST_CATEGORY_PREWARD, nValueType, sKey, sValue, "0", "", bParty);
}

// Private accessor for setting quest step rewards
void _SetQuestReward(int nValueType, string sKey, string sValue, int bParty = FALSE)
{
    _SetQuestStepProperty(QUEST_CATEGORY_REWARD, nValueType, sKey, sValue, "0", "", bParty);
}

void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS);

void _AssignQuest(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    if (GetPCHasQuest(oPC, sQuestTag))
    {
        DeletePCQuestProgress(oPC, nQuestID);
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, "0");
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, "");
    }
    else
        _AddQuestToPC(oPC, nQuestID);

    _SetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME, IntToString(GetUnixTimeStamp()));
    _SetPCQuestData(oPC, nQuestID, QUEST_PC_VERSION, _GetQuestData(nQuestID, QUEST_VERSION));
    IncrementPCQuestField(oPC, nQuestID, QUEST_PC_ATTEMPTS);
    RunQuestScript(oPC, sQuestTag, QUEST_SCRIPT_TYPE_ON_ACCEPT);
    AdvanceQuest(oPC, nQuestID);

    QuestDebug(PCToString(oPC) + " has been assigned quest " + QuestToString(nQuestID));
}

// Checks to see if oPC or their party members have at least nMinQuantity of sItemTag
int _HasMinimumItemCount(object oPC, string sItemTag, int nMinQuantity = 1, int bIncludeParty = FALSE)
{
    int bHasMinimum = FALSE;

    int nItemCount = 0;
    object oItem = GetItemPossessedBy(oPC, sItemTag);
    if (GetIsObjectValid(oItem))
    {
        oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem))
        {
            if (GetTag(oItem) == sItemTag)
                nItemCount += GetNumStackedItems(oItem);

            if (nItemCount >= nMinQuantity)
            {
                bHasMinimum = TRUE;
                break;
            }

            oItem = GetNextItemInInventory(oPC);
        }
    }

    // We haven't met the minimum yet, so let's check the other party members.
    if (bIncludeParty && !bHasMinimum)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            oItem = GetItemPossessedBy(oPC, sItemTag);
            if (GetIsObjectValid(oItem))
            {
                oItem = GetFirstItemInInventory(oPartyMember);
                while (GetIsObjectValid(oItem))
                {
                    if (GetTag(oItem) == sItemTag)
                        nItemCount += GetItemStackSize(oItem);
                    
                    if (nItemCount >= nMinQuantity)
                    {
                        bHasMinimum = TRUE;
                        break;
                    }

                    oItem = GetNextItemInInventory(oPartyMember);
                }
            }

            if (bHasMinimum) break;
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        if (bHasMinimum)
            QuestDebug("Minimum Item Count: " + PCToString(oPC) + " and party members " +
                "have at least " + IntToString(nMinQuantity) + " " + sItemTag);
        else
            QuestDebug("Minimum Item Count: " + PCToString(oPC) + " and party members " +
                "only have " + IntToString(nItemCount) + " of the required " +
                IntToString(nMinQuantity) + " " + sItemTag);
    }

    return bHasMinimum;
}

int GetPCItemCount(object oPC, string sItemTag, int bIncludeParty = FALSE)
{
    int nItemCount = 0;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetTag(oItem) == sItemTag)
            nItemCount += GetNumStackedItems(oItem);
        
        oItem = GetNextItemInInventory(oPC);
    }

    if (bIncludeParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            oItem = GetFirstItemInInventory(oPartyMember);
            while (GetIsObjectValid(oItem))
            {
                if (GetTag(oItem) == sItemTag)
                    nItemCount += GetItemStackSize(oItem);

                oItem = GetNextItemInInventory(oPartyMember);
            }

            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }

    QuestDebug("Found " + IntToString(nItemCount) + " " + sItemTag + " on " +
        PCToString(oPC) + (bIncludeParty ? " and party" : ""));

    return nItemCount;
}

// Awards gold to oPC and/or their party members
void _AwardGold(object oPC, int nGold, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            if (nGold < 0)
                TakeGoldFromCreature(abs(nGold), oPartyMember, TRUE);
            else
                GiveGoldToCreature(oPartyMember, nGold);
            
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        if (nGold < 0)
            TakeGoldFromCreature(abs(nGold), oPC, TRUE);
        else
            GiveGoldToCreature(oPC, nGold);
    }

    QuestDebug((nGold < 0 ? "Removing " : "Awarding ") + IntToString(nGold) +
        "gp " + (nGold < 0 ? "from " : "to ") + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards XP to oPC and/or their party members
void _AwardXP(object oPC, int nXP, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            SetXP(oPartyMember, GetXP(oPartyMember) + nXP);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        SetXP(oPC, GetXP(oPC) + nXP);

    QuestDebug((nXP < 0 ? "Removing " : "Awarding ") + IntToString(nXP) +
        "xp " + (nXP < 0 ? "from " : "to ") + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

void _AwardQuest(object oPC, int nQuestID, int nFlag = TRUE, int bParty = FALSE)
{
    int nAssigned, nComplete;
    string sQuestTag = GetQuestTag(nQuestID);

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            nAssigned = GetPCHasQuest(oPartyMember, sQuestTag);
            nComplete = GetIsPCQuestComplete(oPartyMember, sQuestTag);

            if (nFlag)
            {
                if (!nAssigned || (nAssigned && nComplete))
                    _AssignQuest(oPartyMember, nQuestID);
            }
            else
                UnassignQuest(oPartyMember, sQuestTag);
            
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        nAssigned = GetPCHasQuest(oPC, sQuestTag);
        nComplete = GetIsPCQuestComplete(oPC, sQuestTag);

        if (nFlag)
        {
            if (!nAssigned || (nAssigned && nComplete))
                _AssignQuest(oPC, nQuestID);
        }
        else
            UnassignQuest(oPC, sQuestTag);
    }

    QuestDebug("Awarding quest " + QuestToString(nQuestID) +
        " to " + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards item(s) to oPC and/or their party members
void _AwardItem(object oPC, string sResref, int nQuantity, int bParty = FALSE)
{
    int n, nCount = nQuantity;
    object oItem;

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            if (nQuantity < 0)
            {
                object oItem = GetFirstItemInInventory(oPartyMember);
                while (GetIsObjectValid(oItem))
                {
                    if (GetResRef(oItem) == sResref)
                        DestroyObject(oItem);
                    oItem = GetNextItemInInventory(oPartyMember);
                }
            }
            else
                for (n = 0; n < nQuantity; n++)
                    CreateItemOnObject(sResref, oPartyMember);

            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        if (nQuantity < 0)
        {
            object oItem = GetFirstItemInInventory(oPC);
            while (GetIsObjectValid(oItem))
            {
                if (GetResRef(oItem) == sResref)
                    DestroyObject(oItem);
                oItem = GetNextItemInInventory(oPC);
            }
        }
        else
            CreateItemOnObject(sResref, oPC, nQuantity);
    }

    QuestDebug((nQuantity < 0 ? "Removing " : "Awarding ") + "item " + sResref + 
        " (" + IntToString(abs(nQuantity)) + ") " +
        (nQuantity < 0 ? "from " : "to ") + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards alignment shift to oPC and/or their party members
void _AwardAlignment(object oPC, int nAxis, int nShift, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            AdjustAlignment(oPartyMember, nAxis, nShift, FALSE);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        AdjustAlignment(oPC, nAxis, nShift, FALSE);

    QuestDebug("Awarding alignment shift of " + IntToString(nShift) +
        " on alignment axis " + AlignmentAxisToString(nAxis) + " to " +
        PCToString(oPC) + (bParty ? " and party members" : ""));
}

// Awards quest sTag step nStep [p]rewards.  The awards type will be limited by nAwardType and can be
// provided to the entire party with bParty.  nCategoryType is a QUEST_CATEGORY_* constant.
void _AwardQuestStepAllotments(object oPC, int nQuestID, int nStep, int nCategoryType, 
                               int nAwardType = AWARD_ALL)
{
    int nValueType, nAllotmentCount, bParty;
    string sKey, sValue, sData;

    QuestDebug("Awarding quest step allotments for " + QuestToString(nQuestID) +
        " " + StepToString(nStep) + " of type " + CategoryTypeToString(nCategoryType) +
        " to " + PCToString(oPC));

    sqlquery sPairs = GetQuestStepPropertySets(nQuestID, nStep, nCategoryType);
    while (SqlStep(sPairs))
    {
        nAllotmentCount++;
        nValueType = SqlGetInt(sPairs, 0);
        sKey = SqlGetString(sPairs, 1);
        sValue = SqlGetString(sPairs, 2);
        sData = SqlGetString(sPairs, 3);
        bParty = SqlGetInt(sPairs, 4);

        QuestDebug("  " + HexColorString("Allotment #" + IntToString(nAllotmentCount), COLOR_CYAN) + " " +
            "  Value Type -> " + ColorValue(ValueTypeToString(nValueType)));            

        switch (nValueType)
        {
            case QUEST_VALUE_MESSAGE:
            {
                if ((nAwardType & AWARD_MESSAGE) || nAwardType == AWARD_ALL)
                {
                    string sMessage;

                    // If this is a random quest, we need to override the
                    // preward message
                    if (StringToInt(_GetQuestStepData(nQuestID, nStep, QUEST_STEP_RANDOM_OBJECTIVES)) != -1 &&
                        nCategoryType == QUEST_CATEGORY_PREWARD)
                    {
                        string sQuestTag = GetQuestTag(nQuestID);
                        string sCustomMessage = GetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nStep);
                        if (sCustomMessage == "")
                            QuestDebug("Custom preward message for " + QuestToString(nQuestID) + " " + StepToString(nStep) +
                                " not created; there is no preward message to build from");
                        else
                        {
                            sMessage = sCustomMessage;
                            QuestDebug("Overriding standard preward message for " + QuestToString(nQuestID) + " " +
                                StepToString(nStep) + " with customized preward message for random quest creation: " +
                                ColorValue(sMessage));
                        }                            
                    }

                    if (sMessage == "")
                        sMessage = sValue;
                    
                    sMessage = HexColorString(sMessage, COLOR_CYAN);
                    SendMessageToPC(oPC, sMessage);
                }
                continue;
            }
            case QUEST_VALUE_GOLD:
            {
                if ((nAwardType & AWARD_GOLD) || nAwardType == AWARD_ALL)
                {
                    int nGold = StringToInt(sValue);
                    _AwardGold(oPC, nGold, bParty);
                }
                continue;
            }
            case QUEST_VALUE_XP:
            {
                if ((nAwardType & AWARD_XP) || nAwardType == AWARD_ALL)
                {
                    int nXP = StringToInt(sValue);
                    _AwardXP(oPC, nXP, bParty);
                }
                continue;
            }
            case QUEST_VALUE_ALIGNMENT:
            {
                if ((nAwardType & AWARD_ALIGNMENT) || nAwardType == AWARD_ALL)
                {
                    int nAxis = StringToInt(sKey);
                    int nShift = StringToInt(sValue);
                    _AwardAlignment(oPC, nAxis, nShift, bParty);
                }
                continue;
            }  
            case QUEST_VALUE_ITEM:
            {
                if ((nAwardType & AWARD_ITEM) || nAwardType == AWARD_ALL)
                {
                    string sResref = sKey;     
                    int nQuantity = StringToInt(sValue);
                    _AwardItem(oPC, sResref, nQuantity, bParty);
                }
                continue;
            }
            case QUEST_VALUE_QUEST:
            {
                if ((nAwardType & AWARD_QUEST) || nAwardType == AWARD_ALL)
                {
                    int nValue = StringToInt(sValue);
                    int nFlag = StringToInt(sValue);
                    _AwardQuest(oPC, nValue, nFlag, bParty);
                }
                continue;
            }
            case QUEST_VALUE_REPUTATION:
            {
                if ((nAwardType & AWARD_REPUTATION) || nAwardType == AWARD_ALL)
                {
                    string sFaction = sKey;
                    int nChange = StringToInt(sValue);

                    object oFactionMember = GetObjectByTag(sFaction);
                    AdjustReputation(oPC, oFactionMember, nChange);
                }
                continue;
            }
            case QUEST_VALUE_VARIABLE:
            {
                if ((nAwardType & AWARD_VARIABLE || nAwardType == AWARD_ALL))
                {
                    string sType = _GetKey(sKey);
                    string sVarName = _GetValue(sKey);
                    string sOperator = _GetKey(sValue);
                    sValue = _GetValue(sValue);

                    if (sType == "STRING")
                    {
                        string sPC = GetLocalString(oPC, sVarName);

                        if (sOperator == "=")
                            sPC = sValue;
                        else if (sOperator == "+")
                            sPC += sValue;
                        
                        if (sOperator != "x" && sOperator != "X")
                        {
                            QuestDebug("Awarding variable " + sVarName + " with value " + sPC +
                                "to " + PCToString(oPC));      
                            SetLocalString(oPC, sVarName, sPC);
                        }
                        else
                        {
                            QuestDebug("Deleting variable " + sVarName + " from " +
                                PCToString(oPC));
                            DeleteLocalString(oPC, sVarName);
                        }
                    }
                    else if (sType == "INT")
                    {
                        int nPC = GetLocalInt(oPC, sVarName);
                        int nValue = StringToInt(sValue);

                        if (sOperator == "=")
                            nPC = nValue;
                        else if (sOperator == "+")
                            nPC += nValue;
                        else if (sOperator == "-")
                            nPC -= nValue;
                        else if (sOperator == "++")
                            nPC++;
                        else if (sOperator == "--")
                            nPC--;
                        else if (sOperator == "*")
                            nPC *= nValue;
                        else if (sOperator == "/")
                            nPC /= nValue;
                        else if (sOperator == "%")
                            nPC %= nValue;
                        else if (sOperator == "|")
                            nPC |= nValue;
                        else if (sOperator == "&")
                            nPC = nPC & nValue;
                        else if (sOperator == "~")
                            nPC = ~nPC;          
                        else if (sOperator == "^")
                            nPC = nPC ^ nValue;
                        else if (sOperator == ">>")
                            nPC = nPC >> nValue;
                        else if (sOperator == "<<")
                            nPC = nPC << nValue;
                        else if (sOperator == ">>>")
                            nPC = nPC >>> nValue;
                        
                        if (sOperator != "x" && sOperator != "X")
                            SetLocalInt(oPC, sVarName, nPC);
                        else
                            DeleteLocalInt(oPC, sVarName);
                    }
                }
            }
        }
    }

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        QuestDebug("Found " + IntToString(nAllotmentCount) + " allotments for " + QuestToString(nQuestID) + " " + StepToString(nStep) +
            (nAllotmentCount > 0 ?          
                "\n  Category -> " + ColorValue(CategoryTypeToString(nCategoryType)) +
                "\n  Award -> " + ColorValue(AwardTypeToString(nAwardType)) : ""));
        
        if (nAllotmentCount > 0)
            QuestDebug("Awarded " + IntToString(nAllotmentCount) + " allotments to " + PCToString(oPC) + (bParty ? " and party members" : ""));
        else
            QuestDebug("No allotments to award, no action taken");
    }
}

// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

int AddQuest(string sQuestTag, string sTitle = "")
{
    int nQuestID;
    if (GetQuestExists(sQuestTag) == TRUE)
    {
        nQuestID = GetQuestID(sQuestTag);
        if (nQuestID != 0)
        {
            QuestError(QuestToString(nQuestID) + " already exists and cannot be " +
                "overwritten; to delete, use DeleteQuest(" + sQuestTag + ")");
            nQuestID = -1;
        }        
    }
    
    if (nQuestID != -1 && sQuestTag == "")
    {   
        QuestError("Cannot add a quest with an empty tag");
        nQuestID = -1;
    }

    if (nQuestID != -1)
    {
        nQuestID = _AddQuest(sQuestTag, sTitle);
        if (nQuestID == -1)
            QuestError("Quest '" + sQuestTag + "' could not be created");
        else
            QuestDebug(QuestToString(nQuestID) + " has been created");
    }

    SetLocalInt(GetModule(), QUEST_BUILD_QUEST, nQuestID);
    return nQuestID;
}

void DeleteQuest(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID > 0)
    {
        QuestDebug("Deleting " + QuestToString(nQuestID));
        _DeleteQuest(nQuestID);
    }
    else
        QuestDebug("Quest '" + sQuestTag + "' does not exist and cannot be deleted");
}

//done
//int AddQuestStep(int nQuestID, string sJournalEntry = "", int nStep = -1)
int AddQuestStep(int nStep = -1)
{   
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    if (nQuestID == -1)
    {
        QuestError("AddQuestStep():  Could not add quest step, current quest ID is invalid");
        return -1;
    }

    if (nStep == -1)
        nStep = CountAllQuestSteps(nQuestID) + 1;

    _AddQuestStep(nQuestID, nStep);

    SetLocalInt(GetModule(), QUEST_BUILD_STEP, nStep);
    return nStep;
}

int EvaluateSimpleCondition(int nBase, int nCompare, string sOperator)
{
    if (sOperator == "=" && nBase == nCompare)
        return TRUE;
    else if (sOperator == ">" && nBase > nCompare)
        return TRUE;
    else if (sOperator == ">=" && nBase >= nCompare)
        return TRUE;
    else if (sOperator == "<" && nBase < nCompare)
        return TRUE;
    else if (sOperator == "<=" && nBase <= nCompare)
        return TRUE;
    else if (sOperator == "!=" && nBase != nCompare)
        return TRUE;
    else
        return FALSE;
}

int GetIsQuestAssignable(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    int bAssignable = FALSE;
    string sError, sErrors;

    QuestDebug("Checking for assignability of " + QuestToString(nQuestID));

    // Check if the quest exists
    if (nQuestID == -1 || GetQuestExists(sQuestTag) == FALSE)
    {
        QuestWarning("Quest " + sQuestTag + " does not exist and " +
            "cannot be assigned" +
            "\n  PC -> " + PCToString(oPC) +
            "\n  Area -> " + ColorValue(GetName(GetArea(oPC))));
        return FALSE;
    }
    else
        QuestDebug(QuestToString(nQuestID) + " EXISTS");

    // Check if the quest is active
    if (GetIsQuestActive(nQuestID) == FALSE)
    {
        QuestWarning("Quest " + QuestToString(nQuestID) + " is not active and " +
            " cannot be assigned");
        return FALSE;
    }
    else
        QuestDebug(QuestToString(nQuestID) + " is ACTIVE");

    // Check that the creator add that minimum number of steps
    // At least one resolution step is required, the rest are optional
    if (GetQuestHasMinimumNumberOfSteps(nQuestID))
        QuestDebug(QuestToString(nQuestID) + " has the minimum number of steps");
    else
    {
        QuestError(QuestToString(nQuestID) + " does not have a resolution step and cannot " +
            "be assigned; ensure a resolution step (success or failure) has been added to " +
            "this quest");
        return FALSE;
    }

    if (GetPCHasQuest(oPC, sQuestTag) == TRUE)
    {
        if (GetIsPCQuestComplete(oPC, sQuestTag) == TRUE)
        {
            // Check for cooldown
            string sCooldownTime = _GetQuestData(nQuestID, QUEST_COOLDOWN);
            if (sCooldownTime == "")
            {
                QuestDebug("There is no cooldown time set for this quest");
                bAssignable = TRUE;
            }
            else
            {
                int nCompleteTime = StringToInt(_GetPCQuestData(oPC, nQuestID, QUEST_PC_LAST_COMPLETE));
                int nAvailableTime = GetModifiedUnixTimeStamp(nCompleteTime, sCooldownTime);
                if (GetGreaterUnixTimeStamp(nAvailableTime) != nAvailableTime)
                {
                    QuestDebug(PCToString(oPC) + " has met the required cooldown time for " + QuestToString(nQuestID));
                    bAssignable = TRUE;
                }
                else
                {
                    QuestDebug(PCToString(oPC) + " has not met the required cooldown time for " + QuestToString(nQuestID) +
                        "\n  Quest Completion Time -> " + ColorValue(FormatUnixTimestamp(nCompleteTime, QUEST_TIME_FORMAT) + " UTC") +
                        "\n  Cooldown Time -> " + ColorValue(TimeVectorToString(sCooldownTime)) + 
                        "\n  Earliest Assignment Time -> " + ColorValue(FormatUnixTimestamp(nAvailableTime, QUEST_TIME_FORMAT) + " UTC") +
                        "\n  Attemped Assignment Time -> " + ColorValue(FormatUnixTimestamp(GetUnixTimeStamp(), QUEST_TIME_FORMAT) + " UTC"));
                    return FALSE;
                }
            }

            // Check for repetitions
            int nReps = GetQuestRepetitions(sQuestTag);
            if (nReps == 0)
                bAssignable = TRUE;
            else if (nReps > 0)
            {
                int nCompletions = GetPCQuestCompletions(oPC, sQuestTag);
                if (nCompletions < nReps)
                    bAssignable = TRUE;
                else
                {
                    QuestDebug(PCToString(oPC) + " has completed " + QuestToString(nQuestID) + 
                        " successfully the maximum number of times; quest cannot be re-assigned" +
                        "\n  PC Quest Completion Count -> " + ColorValue(IntToString(nCompletions)) +
                        "\n  Quest Repetitions Setting -> " + ColorValue(IntToString(nReps)));
                    return FALSE;
                }
            }
            else
            {
                QuestError(QuestToString(nQuestID) + " has been assigned an invalid " +
                    "number of repetitions; must be >= 0" +
                    "\n  Repetitions -> " + ColorValue(IntToString(nReps)));
                return FALSE;
            }
        }
        else
        {
            QuestDebug(PCToString(oPC) + " is still completing " + QuestToString(nQuestID) + "; quest cannot be " +
                "reassigned until the current attempt is complete");
            return FALSE;
        }
    }
    else
    {
        QuestDebug(PCToString(oPC) + " does not have " + QuestToString(nQuestID) + " assigned");
        bAssignable = TRUE;
    }

    QuestDebug("System pre-assignment check successfully completed; starting quest prerequisite checks");

    int nPrerequisites = CountQuestPrerequisites(sQuestTag);
    if (nPrerequisites == 0)
    {
        QuestDebug(QuestToString(nQuestID) + " has no prerequisites for " +
            PCToString(oPC) + " to meet");
        return TRUE;
    }
    else
        QuestDebug(QuestToString(nQuestID) + " has " + IntToString(nPrerequisites) + " prerequisites");

    sqlquery sqlPrerequisites = GetQuestPrerequisiteTypes(nQuestID);
    while (SqlStep(sqlPrerequisites))
    {
        int nValueType = SqlGetInt(sqlPrerequisites, 0);
        int nTypeCount = SqlGetInt(sqlPrerequisites, 1);

        QuestDebug(HexColorString("Checking quest prerequisite " + ValueTypeToString(nValueType), COLOR_CYAN));

        if (_GetIsPropertyStackable(nValueType) == FALSE && nTypeCount > 1)
        {
            QuestError("GetIsQuestAssignable found multiple entries for a " +
                "non-stackable property" +
                "\n  Quest -> " + QuestToString(nQuestID) + 
                "\n  Category -> " + ColorValue(CategoryTypeToString(QUEST_CATEGORY_PREREQUISITE)) +
                "\n  Value -> " + ColorValue(ValueTypeToString(nValueType)) +
                "\n  Entries -> " + ColorValue(IntToString(nTypeCount)));
            return FALSE;
        }

        sqlquery sqlPrerequisitesByType = GetQuestPrerequisitesByType(nQuestID, nValueType);
        switch (nValueType)
        {
            case QUEST_VALUE_ALIGNMENT:
            {
                int nAxis, bNeutral, bQualifies;
                int nGE = GetAlignmentGoodEvil(oPC);
                int nLC = GetAlignmentLawChaos(oPC);
                
                QuestDebug("  PC Good/Evil Alignment -> " + ColorValue(AlignmentAxisToString(nGE)) +
                     "\n  PC Law/Chaos Alignment -> " + ColorValue(AlignmentAxisToString(nLC)));                

                while (SqlStep(sqlPrerequisitesByType))
                {
                    nAxis = SqlGetInt(sqlPrerequisitesByType, 0);
                    bNeutral = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  ALIGNMENT | " + AlignmentAxisToString(nAxis) + " | " + (bNeutral ? "TRUE":"FALSE"));

                    if (bNeutral == TRUE)
                    {
                        if (nGE == ALIGNMENT_NEUTRAL ||
                            nLC == ALIGNMENT_NEUTRAL)
                            bQualifies = TRUE;
                    }
                    else
                    {
                        if (nGE == nAxis || nLC == nAxis)
                            bQualifies = TRUE;
                    }
                }

                QuestDebug("  ALIGNMENT resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_CLASS:
            {
                int nClass, nLevels, bQualifies;
                int nClass1 = GetClassByPosition(1, oPC);
                int nClass2 = GetClassByPosition(2, oPC);
                int nClass3 = GetClassByPosition(3, oPC);
                int nLevels1 = GetLevelByClass(nClass1, oPC);
                int nLevels2 = GetLevelByClass(nClass2, oPC);
                int nLevels3 = GetLevelByClass(nClass3, oPC);
                
                QuestDebug("  PC Classes -> " + ColorValue(ClassToString(nClass1) + " (" + IntToString(nLevels1) + ")" +
                    (nClass2 == CLASS_TYPE_INVALID ? "" : " | " + ClassToString(nClass2) + " (" + IntToString(nLevels2) + ")") +
                    (nClass3 == CLASS_TYPE_INVALID ? "" : " | " + ClassToString(nClass3) + " (" + IntToString(nLevels3) + ")")));

                while (SqlStep(sqlPrerequisitesByType))
                {
                    nClass = SqlGetInt(sqlPrerequisitesByType, 0);
                    string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                    string sOperator = _GetKey(sValue);
                    int nLevels = StringToInt(_GetValue(sValue));

                    QuestDebug("  CLASS | " + ColorValue(ClassToString(nClass)) + " | Levels " + ColorValue(sOperator + " " + IntToString(nLevels)));

                    switch (nLevels)
                    {
                        case 0:   // No levels in specific class
                            if (nClass1 == nClass || nClass2 == nClass || nClass3 == nClass)
                            {
                                bQualifies = FALSE;
                                break;
                            }

                            bQualifies = TRUE;
                            break;
                        default:  // Specific number or more of levels in a specified class
                            if (nClass1 == nClass && EvaluateSimpleCondition(nLevels1, nLevels, sOperator))
                            //if (nClass1 == nClass && nLevels1 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass2 == nClass && EvaluateSimpleCondition(nLevels2, nLevels, sOperator))
                            //else if (nClass2 == nClass && nLevels2 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass3 == nClass && EvaluateSimpleCondition(nLevels3, nLevels, sOperator))
                            //else if (nClass3 == nClass && nLevels3 >= nLevels)
                                bQualifies = TRUE;
                            
                            break;
                    }

                    if (!bQualifies)
                        break;
                }

                QuestDebug("  CLASS resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_REPUTATION:
            {
                int bQualifies;
                while (SqlStep(sqlPrerequisitesByType))
                {
                    string sFaction = SqlGetString(sqlPrerequisitesByType, 0);
                    string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                    string sOperator = _GetKey(sValue);
                    int nRequiredStanding = StringToInt(_GetValue(sValue));

                    object oFactionMember = GetObjectByTag(sFaction);
                    int nCurrentStanding = GetFactionAverageReputation(oFactionMember, oPC);

                    QuestDebug("  PC REPUTATION | " + sFaction + " | " + IntToString(nCurrentStanding));
                    QuestDebug("  REPUTATION | " + sFaction + " | Standing " + 
                        sOperator + " " + IntToString(abs(nRequiredStanding)));

                    if (EvaluateSimpleCondition(nCurrentStanding, nRequiredStanding, sOperator))
                        bQualifies = TRUE;
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }

                    /*
                    if (nRequiredStanding >= 0 && nCurrentStanding >= nRequiredStanding)
                        bQualifies = TRUE;
                    else if (nRequiredStanding < 0 && nCurrentStanding < nRequiredStanding)
                        bQualifies = TRUE;
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    */
                }

                QuestDebug("  REPUTATION resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }    

            case QUEST_VALUE_GOLD:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies; //, nGoldRequired = SqlGetInt(sqlPrerequisitesByType, 1);
                string sValue = SqlGetString(sqlPrerequisitesByType, 1);

                string sOperator = _GetKey(sValue);
                int nGold = StringToInt(_GetValue(sValue));

                QuestDebug("  PC Gold Balance -> " + ColorValue(IntToString(GetGold(oPC))));
                QuestDebug("  GOLD | " + ColorValue(sOperator + " " + IntToString(nGold)));
                
                bQualifies = EvaluateSimpleCondition(GetGold(oPC), nGold, sOperator);

                //if (GetGold(oPC) >= nGold)
                //    bQualifies = TRUE;

                QuestDebug("  GOLD resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_ITEM:
            {
                string sItemTag;
                int nItemQuantity, bQualifies;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sItemTag = SqlGetString(sqlPrerequisitesByType, 0);
                    string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                    string sOperator = _GetKey(sValue);
                    nItemQuantity = StringToInt(_GetValue(sValue));

                    QuestDebug("  ITEM | " + sItemTag + " | " + IntToString(nItemQuantity));

                    int nItemCount = GetPCItemCount(oPC, sItemTag);
                    QuestDebug("  PC has " + IntToString(nItemCount) + " " + sItemTag);
                    
                    if (nItemQuantity == 0 && nItemCount > 0)
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    else if (nItemQuantity > 0 && EvaluateSimpleCondition(nItemCount, nItemQuantity, sOperator))
                    //else if (nItemQuantity > 0 && nItemCount >= nItemQuantity)
                        bQualifies = TRUE;
                }

                QuestDebug("  ITEM resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_LEVEL_MAX:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nMaximumLevel = SqlGetInt(sqlPrerequisitesByType, 1);

                QuestDebug("  PC Total Levels -> " + ColorValue(IntToString(GetHitDice(oPC))));
                QuestDebug("  LEVEL_MAX | " + ColorValue(IntToString(nMaximumLevel)));
                
                if (GetHitDice(oPC) <= nMaximumLevel)
                    bQualifies = TRUE;
                
                QuestDebug("  LEVEL_MAX resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_LEVEL_MIN:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nMinimumLevel = SqlGetInt(sqlPrerequisitesByType, 1);
                
                QuestDebug("  PC Total Levels -> " + ColorValue(IntToString(GetHitDice(oPC))));
                QuestDebug("  LEVEL_MIN | " + ColorValue(IntToString(nMinimumLevel)));
                
                if (GetHitDice(oPC) >= nMinimumLevel)
                    bQualifies = TRUE;

                QuestDebug("  LEVEL_MAX resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_QUEST:
            {
                string sQuestTag;
                int nRequiredCompletions;
                int bQualifies, bPCHasQuest, nPCCompletions, nPCFailures;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sQuestTag = SqlGetString(sqlPrerequisitesByType, 0);
                    string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                    string sOperator = _GetKey(sValue);
                    nRequiredCompletions = StringToInt(_GetValue(sValue));
                    
                    bPCHasQuest = GetPCHasQuest(oPC, sQuestTag);
                    nPCCompletions = GetPCQuestCompletions(oPC, sQuestTag);
                    nPCFailures = GetPCQuestFailures(oPC, sQuestTag);
                    QuestDebug("  PC | Has Quest -> " + ColorValue((bPCHasQuest ? "TRUE":"FALSE")) + 
                        "\n  Completions -> " + ColorValue(IntToString(nPCCompletions)) +
                        "\n  Failures -> " + ColorValue(IntToString(nPCFailures)));
                    QuestDebug("  QUEST | " + sQuestTag + " | Required -> " + ColorValue(sOperator + " " + IntToString(nRequiredCompletions)));

                    if (nRequiredCompletions > 0)
                    {
                        if (bPCHasQuest == TRUE && EvaluateSimpleCondition(nPCCompletions, nRequiredCompletions, sOperator))
                        //if (bPCHasQuest == TRUE && nPCCompletions >= nRequiredCompletions)
                            bQualifies = TRUE;
                        else
                        {   
                            bQualifies = FALSE;
                            break;
                        }
                    }
                    else if (nRequiredCompletions == 0)
                    {
                        if (bPCHasQuest == TRUE && nPCCompletions == 0)
                            bQualifies = TRUE;
                    }
                    else if (nRequiredCompletions < 0)
                    {
                        if (bPCHasQuest == TRUE)
                        {
                            bQualifies = FALSE;
                            break;
                        }
                        else
                            bQualifies = TRUE;
                    }

                    if (!bQualifies)
                        break;
                }

                QuestDebug("  QUEST resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_QUEST_STEP:
            {
                string sQuestTag;
                int nRequiredStep;
                int bQualifies, bPCHasQuest, nPCStep;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sQuestTag = SqlGetString(sqlPrerequisitesByType, 0);
                    nRequiredStep = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  QUEST_STEP | " + sQuestTag + " | " + StepToString(nRequiredStep));

                    bPCHasQuest = GetPCHasQuest(oPC, sQuestTag);
                    nPCStep = GetPCQuestStep(oPC, sQuestTag);

                    QuestDebug("  PC | Has Quest -> " + (bPCHasQuest ? "TRUE":"FALSE") + " | " + StepToString(nRequiredStep));

                    if (bPCHasQuest)
                    {
                        if (nPCStep >= nRequiredStep)
                            bQualifies = TRUE;
                    }
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                }

                QuestDebug("  QUEST_STEP resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_RACE:
            {
                int nRace, nPCRace = GetRacialType(oPC);
                int bQualifies, bAllowed;

                QuestDebug("  PC Race -> " + ColorValue(RaceToString(nPCRace)));
                
                while (SqlStep(sqlPrerequisitesByType))
                {
                    nRace = SqlGetInt(sqlPrerequisitesByType, 0);
                    bAllowed = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  RACE | " + RaceToString(nRace) + " | Allowed -> " + (bAllowed ? "TRUE":"FALSE"));

                    if (bAllowed == TRUE)
                    {
                        if (nPCRace == nRace)
                            bQualifies = TRUE;
                    }
                    else if (bAllowed == FALSE)
                    {
                        if (nPCRace == nRace)
                        {
                            bQualifies = FALSE;
                            break;
                        }
                        else
                            bQualifies = TRUE;
                    }
                }
                    
                QuestDebug("  RACE resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_XP:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies;
                string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                string sOperator = _GetKey(sValue);
                int nXP = StringToInt(_GetValue(sValue));
                int nPC = GetXP(oPC);
                
                QuestDebug("  PC XP -> " + ColorValue(IntToString(nPC) + "xp"));
                QuestDebug("  XP | " + ColorValue(sOperator + " " + IntToString(abs(nXP)) + "xp"));
                //QuestDebug("  XP | " + (nXP >= 0 ? ">= " : "< ") + IntToString(abs(nXP)) + "xp");

                if (EvaluateSimpleCondition(nPC, nXP, sOperator))
                    bQualifies = TRUE;
                else
                    bQualifies = FALSE;

                /*
                if (nXP >= 0 && nPC >= nXP)
                    bQualifies = TRUE;
                else if (nXP < 0 && nXP < nXP)
                    bQualifies = TRUE;
                else
                    bQualifies = FALSE;
                */

                QuestDebug("  XP resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_ABILITY:
            {
                int bQualifies;
                while (SqlStep(sqlPrerequisitesByType))
                {

                    int nAbility = SqlGetInt(sqlPrerequisitesByType, 0);
                    string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                    string sOperator = _GetKey(sValue);
                    int nScore = StringToInt(_GetValue(sValue));
                    int nPC = GetAbilityScore(oPC, nAbility, FALSE);

                    QuestDebug("  PC " + AbilityToString(nAbility) + " Score -> " + IntToString(nPC));
                    QuestDebug("  ABILITY | " + AbilityToString(nAbility) + " | Score " + 
                        sOperator + " " + IntToString(abs(nScore)));

                    if (nScore <= 0)
                        QuestDebug(HexColorString("  ABILITY prerequisite has an invalide valid; must be >= 0", COLOR_RED_LIGHT));

                    if (EvaluateSimpleCondition(nPC, nScore, sOperator))
                        bQualifies = TRUE;
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    /*
                    if (nScore >= 0 && nPC >= nScore)
                        bQualifies = TRUE;
                    else if (nScore < 0 && nPC <= nScore)
                        bQualifies = TRUE;
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    */
                }

                QuestDebug("  ABILITY resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_SKILL:
            {
                int bQualifies;
                while (SqlStep(sqlPrerequisitesByType))
                {
                    int nSkill = SqlGetInt(sqlPrerequisitesByType, 0);
                    string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                    string sOperator = _GetKey(sValue);
                    int nRank = StringToInt(_GetValue(sValue));
                    int nPC = GetSkillRank(nSkill, oPC, TRUE);

                    QuestDebug("  PC " + SkillToString(nSkill) + " Rank -> " + IntToString(nPC));
                    QuestDebug("  SKILL | " + SkillToString(nSkill) + " | Score " + 
                        sOperator + " " + IntToString(nRank));

                    if (nRank > 0 && EvaluateSimpleCondition(nPC, nRank, sOperator))
                        bQualifies = TRUE;
                    else if (nRank == 0 && nRank > 0)
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    /*
                    if (nRank >= 0 && nPC >= nRank)
                        bQualifies = TRUE;
                    else if (nRank < 0 && nPC <= nRank)
                        bQualifies = TRUE;
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    */
                }

                QuestDebug("  SKILL resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_VARIABLE:
            {
                int bQualifies;
                while (SqlStep(sqlPrerequisitesByType))
                {
                    string sKey = SqlGetString(sqlPrerequisitesByType, 0);
                    string sValue = SqlGetString(sqlPrerequisitesByType, 1);
                    
                    string sType = _GetKey(sKey);
                    string sVarName = _GetValue(sKey);
                    string sOperator = _GetKey(sValue);
                    sValue = _GetValue(sValue);

                    if (sType == "STRING")
                    {
                        string sPC = GetLocalString(oPC, sVarName);

                        QuestDebug("  PC | STRING " + sVarName + " | " + sPC);
                        QuestDebug("  VARIABLE | STRING | " + sOperator + "\"" + sValue + "\"");

                        if ((sOperator == "=" || sOperator == "==") && sPC == sValue)
                            bQualifies = TRUE;
                        else if (sOperator == "!=" && sPC != sValue)
                            bQualifies = TRUE;
                        else
                        {
                            bQualifies = FALSE;
                            break;
                        }
                    }
                    else if (sType == "INT")
                    {
                        int nValue = StringToInt(sValue);
                        int nPC = GetLocalInt(oPC, sVarName);

                        QuestDebug("  PC | INT " + sVarName + " | " + IntToString(nPC));
                        QuestDebug("  VARIABLE | INT | " + sOperator + sValue);

                        if ((sOperator == "=" || sOperator == "==") && nPC == nValue)
                            bQualifies = TRUE;
                        else if (sOperator == ">" && nPC > nValue)
                            bQualifies = TRUE;
                        else if (sOperator == ">=" && nPC >= nValue)
                            bQualifies = TRUE;
                        else if (sOperator == "<" && nPC < nValue)
                            bQualifies = TRUE;
                        else if (sOperator == "<=" && nPC <= nValue)
                            bQualifies = TRUE;
                        else if (sOperator == "!=" && nPC != nValue)
                            bQualifies = TRUE;
                        else if (sOperator == "|" && nPC | nValue)
                            bQualifies = TRUE;
                        else if (sOperator == "&" && nPC & nValue)
                            bQualifies = TRUE;
                        else
                        {
                            bQualifies = FALSE;
                            break;
                        }
                    }
                }

                QuestDebug("  VARIABLE resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
        }
    }

    if (sErrors != "")
    {
        int n, nCount = CountList(sErrors);
        string sResult;

        for (n = 0; n < nCount; n++)
        {
            string sError = GetListItem(sErrors, n);
            sResult = AddListItem(sResult, ValueTypeToString(StringToInt(sError)));
        }

        QuestNotice(QuestToString(nQuestID) + " could not be assigned to " + PCToString(oPC) +
            "; PC did not meet the following prerequisites: " + sResult);

        return FALSE;
    }
    else
    {
        QuestDebug(PCToString(oPC) + " has met all prerequisites for " + QuestToString(nQuestID));
        return TRUE;
    }
}

void AssignQuest(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    _AssignQuest(oPC, nQuestID);
}

void RunQuestScript(object oPC, string sQuestTag, int nScriptType)
{
    string sScript;
    int bSetStep = FALSE;
    int nQuestID = GetQuestID(sQuestTag);

    if (nScriptType == QUEST_SCRIPT_TYPE_ON_ACCEPT)
        sScript = GetQuestScriptOnAccept(sQuestTag);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_ADVANCE)
    {
        sScript = GetQuestScriptOnAdvance(sQuestTag);
        bSetStep = TRUE;
    }
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_COMPLETE)
        sScript = GetQuestScriptOnComplete(sQuestTag);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_FAIL)
        sScript = GetQuestScriptOnFail(sQuestTag);

    if (sScript == "")
        return;
    
    object oModule = GetModule();
    int nStep;

    // Set values that the script has available to it
    SetLocalString(oModule, QUEST_CURRENT_QUEST, sQuestTag);
    SetLocalInt(oModule, QUEST_CURRENT_EVENT, nScriptType);
    if (bSetStep)
    {
        nStep = GetPCQuestStep(oPC, sQuestTag);
        SetLocalInt(oModule, QUEST_CURRENT_STEP, nStep);
    }

    QuestDebug("Running " + ScriptTypeToString(nScriptType) + " event script " +
        "for " + QuestToString(nQuestID) + (bSetStep ? " " + StepToString(nStep) : "") + 
        " with " + PCToString(oPC) + " as OBJECT_SELF");
    
    ExecuteScript(sScript, oPC);

    DeleteLocalString(oModule, QUEST_CURRENT_QUEST);
    DeleteLocalInt(oModule, QUEST_CURRENT_STEP);
    DeleteLocalInt(oModule, QUEST_CURRENT_EVENT);
}

void UnassignQuest(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    QuestDebug("Deleting " + QuestToString(nQuestID) + " from " + PCToString(oPC));
    RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
    DeletePCQuest(oPC, nQuestID);
}

int CountPCQuestCompletions(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    return GetPCQuestCompletions(oPC, sQuestTag);
}

void CopyQuestStepObjectiveData(object oPC, int nQuestID, int nStep)
{
    sqlquery sqlStepData;
    string sPrewardMessage;
    int nRandom = FALSE;
    string sQuestTag = GetQuestTag(nQuestID);

    int nRecords = GetQuestStepObjectiveRandom(sQuestTag, nStep);
    if (nRecords == -1)
    {
        sqlStepData = GetQuestStepObjectiveData(nQuestID, nStep);
        QuestDebug("Selecting all quest step objectives from " + QuestToString(nQuestID) +
            " " + StepToString(nStep) + " for assignment to " + PCToString(oPC));
    }
    else
    {
        sqlStepData = GetRandomQuestStepObjectiveData(nQuestID, nStep, nRecords);

        int nObjectiveCount = CountQuestStepObjectives(nQuestID, nStep);
        QuestDebug("Selecting " + ColorValue(IntToString(nRecords)) + " of " +
            ColorValue(IntToString(nObjectiveCount)) + " available objectives from " +
            QuestToString(nQuestID) + " " + StepToString(nStep) + " for assignment to " +
            PCToString(oPC));

        int nRandomCount = GetQuestStepObjectiveRandom(sQuestTag, nStep);
        int nMinimum = GetQuestStepObjectiveMinimum(sQuestTag, nStep);

        string sCount = "You must complete ";
        if (nRandomCount > nMinimum && nMinimum >= 1)
            sCount += IntToString(nMinimum) + " of the following " + IntToString(nRandomCount) + " objectives:";
        else if (nRandomCount == nMinimum)
            sCount += "the following objective" + (nMinimum == 1 ? "" : "s") + ":";

        sPrewardMessage = GetQuestStepPropertyValue(nQuestID, nStep, QUEST_CATEGORY_PREWARD, QUEST_VALUE_MESSAGE) + "  " + sCount;
        nRandom = TRUE;
    }

    while (SqlStep(sqlStepData))
    { 
        int nObjectiveID = SqlGetInt(sqlStepData, 0);
        int nObjectiveType = SqlGetInt(sqlStepData, 1);
        string sTag = SqlGetString(sqlStepData, 2);
        int nQuantity = SqlGetInt(sqlStepData, 3);
        int nQuantityMax = SqlGetInt(sqlStepData, 4);
        string sData = SqlGetString(sqlStepData, 5);

        if (nQuantity > 0 && nQuantityMax > nQuantity)
            nQuantity += Random(nQuantityMax - nQuantity);

        AddQuestStepObjectiveData(oPC, nQuestID, nObjectiveType, sTag, nQuantity, nObjectiveID, sData);

        // For random quests, build the message
        if (nRandom && sPrewardMessage != "")
        {
            string sQuestTag = GetQuestTag(nQuestID);
            string sDescriptor = GetQuestString(sQuestTag, QUEST_DESCRIPTOR + IntToString(nObjectiveID));
            string sDescription = GetQuestString(sQuestTag, QUEST_DESCRIPTION + IntToString(nObjectiveID));

            sPrewardMessage +=
                "\n  " + ObjectiveTypeToString(nObjectiveType) + " " +
                    IntToString(nQuantity) + " " +
                    sDescriptor + (nQuantity == 1 ? "" : "s") +
                    (sDescription == "" ? "" : " " + sDescription);
        }
    }

    if (nRandom && sPrewardMessage != "")
        SetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, sPrewardMessage, nStep);
}

void SendJournalQuestEntry(object oPC, int nQuestID, int nStep, int bComplete = FALSE)
{
    string sQuestTag = GetQuestTag(nQuestID);
    int nDestination = GetQuestJournalHandler(sQuestTag);
    int bDelete = StringToInt(_GetQuestData(nQuestID, QUEST_JOURNAL_DELETE));

    switch (nDestination)
    {
        case QUEST_JOURNAL_NONE:
            QuestDebug("Journal Quest entries for " + QuestToString(nQuestID) + " have been suppressed");
            break;
        case QUEST_JOURNAL_NWN:
            if (bComplete && bDelete)
                RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
            else
                AddJournalQuestEntry(sQuestTag, nStep, oPC, FALSE, FALSE, TRUE);
            
            QuestDebug("Journal Quest entry for " + QuestToString(nQuestID) + " " + StepToString(nStep) +
                " on " + PCToString(oPC) + " has been dispatched to the NWN journal system");
            break;
        case QUEST_JOURNAL_NWNX:
        {
            if (bComplete && bDelete)
                RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
            else
            {
                string sText;
                if (StringToInt(_GetQuestStepData(nQuestID, nStep, QUEST_STEP_RANDOM_OBJECTIVES)) != -1 &&
                    QUEST_CONFIG_USE_CUSTOM_MESSAGE == TRUE)
                    sText = GetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nStep);
                else
                    sText = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY);
                    
                struct NWNX_Player_JournalEntry je;
                je.sName = _GetQuestData(nQuestID, QUEST_TITLE);
                je.sText = sText;
                je.sTag = sQuestTag;
                je.nQuestCompleted = bComplete;

                string sEmpty = "[Empty]";
                if (je.sName == "") je.sName = sEmpty;
                if (je.sText == "") je.sTag = sEmpty;

                NWNX_Player_AddCustomJournalEntry(oPC, je);
            }

            QuestDebug("Journal Quest entry for " + QuestToString(nQuestID) + " " + StepToString(nStep) +
                " on " + PCToString(oPC) + " has been dispatched to the NWN journal system via NWNX");
        }
    }
}

void UpdateJournalQuestEntries(object oPC)
{
    QuestDebug("Restoring journal quest entries for " + PCToString(oPC));
    int nUpdate, nTotal;

    sqlquery sqlPCQuestData = GetPCQuestData(oPC);
    while (SqlStep(sqlPCQuestData))
    {
        nTotal++;
        string sQuestTag = SqlGetString(sqlPCQuestData, 0);
        int nStep = SqlGetInt(sqlPCQuestData, 1);
        int nCompletions = SqlGetInt(sqlPCQuestData, 2);
        int nFailures = SqlGetInt(sqlPCQuestData, 3);
        int nLastCompleteType = SqlGetInt(sqlPCQuestData, 4);
        int bComplete;

        int nQuestID = GetQuestID(sQuestTag);
        nCompletions += nFailures;

        if (nStep == 0)
        {
            if (nCompletions == 0)
                continue;
            else
            {
                if (nLastCompleteType == 0)
                    nLastCompleteType = 1;

                bComplete = TRUE;
                nStep = GetQuestCompletionStep(nQuestID, nLastCompleteType);
            }
        }

        SendJournalQuestEntry(oPC, nQuestID, nStep, bComplete);
    }

    QuestDebug("Found " + IntToString(nTotal) + " quest" + (nTotal == 1 ? "" : "s") + " on " + 
        PCToString(oPC) + "; restoring journal entries");
}

void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    QuestDebug("Attempting to advance quest " + QuestToString(nQuestID) +
        " for " + PCToString(oPC));

    string sQuestTag = GetQuestTag(nQuestID);

    if (nRequestType == QUEST_ADVANCE_SUCCESS)
    {
        int nCurrentStep = GetPCQuestStep(oPC, sQuestTag);
        int nNextStep = GetNextPCQuestStep(oPC, sQuestTag);

        if (nNextStep == -1)
        {
            // Next step is the last step, go to the completion step
            nNextStep = GetQuestCompletionStep(nQuestID);
                        
            if (nNextStep == -1)
            {
                QuestDebug("Could not locate success completion step for " + QuestToString(nQuestID) +
                    "; ensure you've assigned one via AddQuestResolutionSuccess(); aborting quest " +
                    "advance attempt");
                return;
            }
            
            DeletePCQuestProgress(oPC, nQuestID);
            _AwardQuestStepAllotments(oPC, nQuestID, nCurrentStep, QUEST_CATEGORY_REWARD);
            SendJournalQuestEntry(oPC, nQuestID, nNextStep, TRUE);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
            IncrementPCQuestCompletions(oPC, nQuestID, GetUnixTimeStamp());
            RunQuestScript(oPC, sQuestTag, QUEST_SCRIPT_TYPE_ON_COMPLETE);

            if (GetQuestStepObjectiveRandom(sQuestTag, nCurrentStep) != -1)
            {
                QuestDebug(QuestToString(nQuestID) + " " + StepToString(nCurrentStep) + " is marked " +
                    "random and has been completed; deleting custom message");

                DeletePCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nCurrentStep);
            }

            if (GetQuestDeleteOnComplete(sQuestTag))
                DeletePCQuest(oPC, nQuestID);
        }
        else
        {
            // There is another step to complete, press...
            DeletePCQuestProgress(oPC, nQuestID);
            CopyQuestStepObjectiveData(oPC, nQuestID, nNextStep);
            SendJournalQuestEntry(oPC, nQuestID, nNextStep);
            _AwardQuestStepAllotments(oPC, nQuestID, nCurrentStep, QUEST_CATEGORY_REWARD);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_PREWARD);
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, IntToString(nNextStep));
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, IntToString(GetUnixTimeStamp()));
            RunQuestScript(oPC, sQuestTag, QUEST_SCRIPT_TYPE_ON_ADVANCE);

            if (GetQuestAllowPrecollectedItems(sQuestTag) == TRUE)
            {
                sqlquery sObjectiveData = GetQuestStepObjectiveData(nQuestID, nNextStep);
                while (SqlStep(sObjectiveData))
                {
                    int nValueType = SqlGetInt(sObjectiveData, 0);
                    if (nValueType == QUEST_OBJECTIVE_GATHER)
                    {
                        string sItemTag = SqlGetString(sObjectiveData, 1);
                        //int nQuantity = SqlGetInt(sObjectiveData, 2);
                        //int nQuantityMax = SqlGetInt(sObjectiveData, 3);
                        string sData = SqlGetString(sObjectiveData, 4);
                        int bParty = GetQuestStepPartyCompletion(sQuestTag, nNextStep);
                        int n, nPCCount = GetPCItemCount(oPC, sItemTag, bParty);

                        if (nPCCount == 0)
                            QuestDebug(PCToString(oPC) + " does not have any precollected items that " +
                                "satisfy requirements for " + QuestToString(nQuestID) + " " + StepToString(nNextStep));
                        else
                            QuestDebug("Applying " + IntToString(nPCCount) + " precollected items toward " +
                                "requirements for " + QuestToString(nQuestID) + " " + StepToString(nNextStep));

                        for (n = 0; n < nPCCount; n++)
                            SignalQuestStepProgress(oPC, sItemTag, QUEST_OBJECTIVE_GATHER, sData);
                    }
                }
            }
            else
                QuestDebug("Precollected items are not authorized for " + QuestToString(nQuestID) + " " + StepToString(nNextStep));
        }

        QuestDebug("Advanced " + QuestToString(nQuestID) + " for " +
            PCToString(oPC) + " from " + StepToString(nCurrentStep) +
            " to " + StepToString(nNextStep));
    }
    else if (nRequestType == QUEST_ADVANCE_FAIL)
    {
        int nNextStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_FAIL);
        DeletePCQuestProgress(oPC, nQuestID);
        IncrementPCQuestFailures(oPC, nQuestID, GetUnixTimeStamp());

        if (nNextStep != -1)
        {
            SendJournalQuestEntry(oPC, nQuestID, nNextStep, TRUE);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
        }
        else
            QuestDebug(QuestToString(nQuestID) + " has a failure mode but no failure completion step assigned; " +
                "all quests that have failure modes should have a failure completion step assigned with " +
                "AddQuestResolutionFail()");

        RunQuestScript(oPC, sQuestTag, QUEST_SCRIPT_TYPE_ON_FAIL);

        if (GetQuestDeleteOnComplete(sQuestTag))
            DeletePCQuest(oPC, nQuestID);
    }
}

int CheckQuestStepProgress(object oPC, int nQuestID, int nStep)
{
    int QUEST_STEP_INCOMPLETE = 0;
    int QUEST_STEP_COMPLETE = 1;
    int QUEST_STEP_FAIL = 2;

    int nRequired, nAcquired, nStatus = QUEST_STEP_INCOMPLETE;
    int nStartTime, nGoalTime;

    string sQuestTag = GetQuestTag(nQuestID);

    // Check for time failure first, if there is a time limit
    string sQuestTimeLimit = GetQuestTimeLimit(sQuestTag);
    string sStepTimeLimit = GetQuestStepTimeLimit(sQuestTag, nStep);

    // Check for quest step time limit ...
    if (sStepTimeLimit != "")
    {
        int nStartTime = StringToInt(_GetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME));
        int nGoalTime = GetModifiedUnixTimeStamp(nStartTime, sStepTimeLimit);

        if (GetGreaterUnixTimeStamp(nGoalTime) != nGoalTime)
        {
            QuestDebug(PCToString(oPC) + " failed to meet the time limit for " +
                QuestToString(nQuestID) + " " + StepToString(nStep) +
                "\n  Step Start Time -> " + ColorValue(FormatUnixTimestamp(nStartTime, QUEST_TIME_FORMAT) + " UTC") +
                "\n  Allowed Time -> " + ColorValue(TimeVectorToString(sStepTimeLimit)) +
                "\n  Goal Time -> " + ColorValue(FormatUnixTimestamp(nGoalTime, QUEST_TIME_FORMAT) + " UTC") + 
                "\n  Completion Time -> " + ColorValue(FormatUnixTimestamp(GetUnixTimeStamp(), QUEST_TIME_FORMAT) + " UTC"));
            nStatus = QUEST_STEP_FAIL;
        }
    }
    else
        QuestDebug(QuestToString(nQuestID) + " " + StepToString(nStep) + " does not have " +
            "a time limit specified");

    if (nStatus != QUEST_STEP_FAIL)
    {
        // Check for overall quest time limit ...
        if (sQuestTimeLimit != "")
        {
            nStartTime = StringToInt(_GetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME));
            nGoalTime = GetModifiedUnixTimeStamp(nStartTime, sQuestTimeLimit);

            if (GetGreaterUnixTimeStamp(nGoalTime) != nGoalTime)
            {
                nStatus = QUEST_STEP_FAIL;
                QuestDebug(PCToString(oPC) + " failed to meet the time limit for " +
                    QuestToString(nQuestID) +
                "\n  Quest Start Time -> " + ColorValue(FormatUnixTimestamp(nStartTime, QUEST_TIME_FORMAT) + " UTC") +
                "\n  Allowed Time -> " + ColorValue(TimeVectorToString(sQuestTimeLimit)) +
                "\n  Goal Time -> " + ColorValue(FormatUnixTimestamp(nGoalTime, QUEST_TIME_FORMAT) + " UTC") +
                "\n  Completion Time -> " + ColorValue(FormatUnixTimestamp(GetUnixTimeStamp(), QUEST_TIME_FORMAT) + " UTC"));
            }
        }
        else
            QuestDebug(QuestToString(nQuestID) + " does not have a time limit specified");
    }

    // Okay, we passed the time tests, now see if we failed an "exclusive" objective
    if (nStatus != QUEST_STEP_FAIL)
    {
        sqlquery sqlSums = GetQuestStepSums(oPC, nQuestID);
        sqlquery sqlFail = GetQuestStepSumsFailure(oPC, nQuestID);

        if (SqlStep(sqlFail))
        {
            nRequired = SqlGetInt(sqlFail, 1);
            nAcquired = SqlGetInt(sqlFail, 2);

            if (nAcquired > nRequired)
            {
                nStatus = QUEST_STEP_FAIL;
                QuestDebug(PCToString(oPC) + "failed to meet an exclusive quest objective " +
                    "for " + QuestToString(nQuestID) + " " + StepToString(nStep));
            }
        }

        // We passed the exclusive checks, see about the inclusive checks
        if (nStatus != QUEST_STEP_FAIL)
        {
            int nObjectiveCount = GetQuestStepObjectiveMinimum(sQuestTag, nStep);
            if (nObjectiveCount == -1)
            {
                // Check for success, all step objectives must be completed
                if (SqlStep(sqlSums))
                {
                    nRequired = SqlGetInt(sqlSums, 1);
                    nAcquired = SqlGetInt(sqlSums, 2);

                    if (nAcquired >= nRequired)
                    {
                        QuestDebug(PCToString(oPC) + " has met all requirements to " +
                            "successfully complete " + QuestToString(nQuestID) +
                            " " + StepToString(nStep));
                        nStatus = QUEST_STEP_COMPLETE;
                    }
                }
            }
            else
            {
                // Less that the total number of step objective must be complete
                int nCompletedCount = CountPCStepObjectivesCompleted(oPC, nQuestID, nStep);
                int nObjectives = CountQuestStepObjectives(nQuestID, nStep);
                if (nCompletedCount >= nObjectiveCount)
                {
                    QuestDebug(PCToString(oPC) + " has completed " + IntToString(nCompletedCount) +
                        " of " + IntToString(nObjectives) + " possible objectives for " + 
                        QuestToString(nQuestID) + " " + StepToString(nStep) + " and has met all " +
                        "requirements for successfull step completion");
                    nStatus = QUEST_STEP_COMPLETE;
                }
                else
                    QuestDebug(QuestToString(nQuestID) + " " + StepToString(nStep) + " requires at " +
                        "least " + IntToString(nObjectiveCount) + " objective" + 
                        (nObjectiveCount == 1 ? "" : "s") + " be completed before step requirements are " +
                        "satisfied");                    
            }
        }
    }

    if (nStatus != QUEST_STEP_INCOMPLETE)
        AdvanceQuest(oPC, nQuestID, nStatus);

    return nStatus;
}

string EvalQuestTokens(string sToken, object oPC, string sQuestTag, int nAcquired, int nRequired);

int SignalQuestStepProgress(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    int nMatch = QUEST_MATCH_NONE;

    // This prevents the false-positives that occur during login events such as OnItemAcquire
    if (GetIsObjectValid(GetArea(oPC)) == FALSE)
        return nMatch;

    QuestDebug(sTargetTag + " is signalling " +
        "quest " + HexColorString("progress", COLOR_GREEN_LIGHT) + " triggered by " + PCToString(oPC) + " for objective " +
        "type " + ObjectiveTypeToString(nObjectiveType) + (sData == "" ? "" : " (sData -> " + sData + ")"));

    while (GetIsObjectValid(GetMaster(oPC)))
        oPC = GetMaster(oPC);

    if (GetIsPC(oPC) == FALSE)
        return nMatch;

    // Deal with the subject PC
    if (IncrementQuestStepQuantity(oPC, sTargetTag, nObjectiveType, sData) > 0)
    {
        // oPC has at least one quest that is satisfied with sTargetTag, sData, nObjectiveType
        // Loop through them and ensure the quest is active before awarding credit and checking
        // for quest advancement
        sqlquery sqlQuestData = GetPCIncrementableSteps(oPC, sTargetTag, nObjectiveType, sData);
        while (SqlStep(sqlQuestData))
        {    
            string sQuestTag = SqlGetString(sqlQuestData, 0);
            int nObjectiveID = SqlGetInt(sqlQuestData, 1);
            int nRequired = SqlGetInt(sqlQuestData, 2);
            int nAcquired = SqlGetInt(sqlQuestData, 3);

            int nQuestID = GetQuestID(sQuestTag);
            int nStep = GetPCQuestStep(oPC, sQuestTag);

            if (GetIsQuestActive(nQuestID) == FALSE)
            {
                QuestDebug(QuestToString(nQuestID) + " is currently inactive and cannot be " +
                    "credited to " + PCToString(oPC));
                DecrementQuestStepQuantityByQuest(oPC, sQuestTag, sTargetTag, nObjectiveType, sData);
                continue;
            }
                   
            if (nAcquired <= nRequired && nObjectiveID != 0)
            {
                string sMessage = GetQuestStepObjectiveFeedback(nQuestID, nObjectiveID);
                if (sMessage != "")
                {
                    sMessage = EvalQuestTokens(sMessage, oPC, sQuestTag, nAcquired, nRequired);
                    SendMessageToPC(oPC, sMessage);
                }
            }

            nMatch = QUEST_MATCH_PC;
            CheckQuestStepProgress(oPC, nQuestID, nStep);
        }
    }
    else
        QuestDebug(PCToString(oPC) + " does not have a quest associated with " + sTargetTag + 
            (sData == "" ? "" : " and " + sData));

    // Deal with the subject PC's party
    object oParty = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(oParty))
    {
        if (CountPCIncrementableSteps(oParty, sTargetTag, nObjectiveType, sData) > 0)
        {
            sqlquery sqlCandidates = GetPCIncrementableSteps(oParty, sTargetTag, nObjectiveType, sData);
            while (SqlStep(sqlCandidates))
            {
                string sQuestTag = SqlGetString(sqlCandidates, 0);
                int nQuestID = GetQuestID(sQuestTag);
                int nStep = GetPCQuestStep(oParty, sQuestTag);
                int bActive = GetIsQuestActive(nQuestID);
                int bPartyCompletion = GetQuestStepPartyCompletion(sQuestTag, nStep);
                int bProximity = GetQuestStepProximity(sQuestTag, nStep);

                if (bActive && bPartyCompletion)
                {
                    if (bProximity ? GetArea(oParty) == GetArea(oPC) : TRUE)
                    {
                        IncrementQuestStepQuantityByQuest(oParty, sQuestTag, sTargetTag, nObjectiveType, sData);
                        CheckQuestStepProgress(oParty, nQuestID, nStep);

                        if (nMatch == QUEST_MATCH_PC)
                            nMatch = QUEST_MATCH_ALL;
                        else
                            nMatch = QUEST_MATCH_PARTY;
                    }
                }
            }
        }

        oParty = GetNextFactionMember(oPC, TRUE);
    }

    return nMatch;
}

int SignalQuestStepRegress(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    int nMatch = QUEST_MATCH_NONE;

    if (GetIsObjectValid(GetArea(oPC)) == FALSE)
        return QUEST_MATCH_NONE;

    QuestDebug(sTargetTag + " is signalling " +
        "quest " + HexColorString("regress", COLOR_RED_LIGHT) + " triggered by " + PCToString(oPC) + " for objective " +
        "type " + ObjectiveTypeToString(nObjectiveType) + (sData == "" ? "" : " (sData -> " + sData + ")"));

    while (GetIsObjectValid(GetMaster(oPC)))
        oPC = GetMaster(oPC);

    if (GetIsPC(oPC) == FALSE)
        return QUEST_MATCH_NONE;

    if (DecrementQuestStepQuantity(oPC, sTargetTag, nObjectiveType, sData) > 0)
    {
        // oPC has at least one quest that is satisfied with sTargetTag, sData, nObjectiveType
        // Loop through them and ensure the quest is active before awarding credit and checking
        // for quest advancement
        sqlquery sqlQuestData = GetPCIncrementableSteps(oPC, sTargetTag, nObjectiveType, sData);
        while (SqlStep(sqlQuestData))
        {    
            string sQuestTag = SqlGetString(sqlQuestData, 0);
            int nQuestID = GetQuestID(sQuestTag);
            int nStep = GetPCQuestStep(oPC, sQuestTag);

            if (GetIsQuestActive(nQuestID) == FALSE)
            {
                QuestDebug(QuestToString(nQuestID) + " is currently invactive and cannot be " +
                    "debited to " + PCToString(oPC));
                IncrementQuestStepQuantityByQuest(oPC, sQuestTag, sTargetTag, nObjectiveType, sData);
                continue;
            }

            nMatch = QUEST_MATCH_PC;
            CheckQuestStepProgress(oPC, nQuestID, nStep);
        }
    }
    else
        QuestDebug(PCToString(oPC) + " does not have a quest associated with " + sTargetTag + 
            (sData == "" ? "" : " and " + sData));

    return nMatch;
}

string EvalQuestToken(string sToken, object oPC, string sQuestTag, int nAcquired, int nRequired)
{
    string sResult;

    if (sToken == "acquired") return IntToString(nAcquired);
    else if (sToken == "required") return IntToString(nRequired);
    else if (sToken == "remaining") return IntToString(nRequired - nAcquired);
    else if (sToken == "quest_title") return HexColorString(GetQuestTitle(sQuestTag), COLOR_ORANGE_LIGHT);
    else
    {
        sResult = GetQuestString(sQuestTag, sToken);
        if (sResult != "")
            return sResult;
    }

    return "";
}

string EvalQuestTokens(string sString, object oPC, string sQuestTag, int nAcquired, int nRequired)
{
    string sRet, sToken;
    int nPos, nClose;
    int nOpen = FindSubString(sString, "<");

    while (nOpen >= 0)
    {
        nClose = FindSubString(sString, ">", nOpen);

        // If no matching bracket, this isn't a token
        if (nClose < 0)
            break;

        // Add everything before the bracket to the return value
        sRet += GetSubString(sString, nPos, nOpen - nPos);

        // Everything between the brackets is our token
        sToken = GetSubString(sString, nOpen + 1, nClose - nOpen - 1);

        sRet += EvalQuestToken(sToken, oPC, sQuestTag, nAcquired, nRequired);
        nPos = nClose + 1;

        // Update position and find the next token
        nOpen = FindSubString(sString, "<", nPos);
    }

    // Add any remaining text to the return value
    sRet += GetStringRight(sString, GetStringLength(sString) - nPos);
    return sRet;
}

string CreateTimeVector(int nYears = 0, int nMonths = 0, int nDays = 0,
                        int nHours = 0, int nMinutes = 0, int nSeconds = 0)
{
    string sResult = AddListItem(""     , IntToString(nYears));
           sResult = AddListItem(sResult, IntToString(nMonths));
           sResult = AddListItem(sResult, IntToString(nDays));
           sResult = AddListItem(sResult, IntToString(nHours));
           sResult = AddListItem(sResult, IntToString(nMinutes));
           sResult = AddListItem(sResult, IntToString(nSeconds));

    return sResult;
}

string GetCurrentQuest()
{
    return GetLocalString(GetModule(), QUEST_CURRENT_QUEST);
}

int GetCurrentQuestStep()
{
    return GetLocalInt(GetModule(), QUEST_CURRENT_STEP);
}

int GetCurrentQuestEvent()
{
    return GetLocalInt(GetModule(), QUEST_CURRENT_EVENT);
}

void AwardQuestStepPrewards(object oPC, int nQuestID, int nStep, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_PREWARD, nAwardType);
}

void AwardQuestStepRewards(object oPC, int nQuestID, int nStep, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_REWARD, nAwardType);
}

string GetQuestTitle(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestData(nQuestID, QUEST_TITLE);
}

void SetQuestTitle(string sTitle)
{
    _SetQuestData(QUEST_TITLE, sTitle);
}

int GetQuestActive(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sActive = _GetQuestData(nQuestID, QUEST_ACTIVE);
    return StringToInt(sActive);
}

void SetQuestActive(string sQuestTag = "")
{
    int nQuestID = -1;

    if (sQuestTag != "")
        nQuestID = GetQuestID(sQuestTag);

    _SetQuestData(QUEST_ACTIVE, IntToString(TRUE), nQuestID);
}

void SetQuestInactive(string sQuestTag = "")
{
    int nQuestID = -1;
    if (sQuestTag != "")
        nQuestID = GetQuestID(sQuestTag);

    _SetQuestData(QUEST_ACTIVE, IntToString(FALSE), nQuestID);
}

int GetQuestRepetitions(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sRepetitions = _GetQuestData(nQuestID, QUEST_REPETITIONS);
    return StringToInt(sRepetitions);
}

void SetQuestRepetitions(int nRepetitions = 1)
{
    string sRepetitions = IntToString(nRepetitions);
    _SetQuestData(QUEST_REPETITIONS, sRepetitions);
}

string GetQuestTimeLimit(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestData(nQuestID, QUEST_TIME_LIMIT);
}

void SetQuestTimeLimit(string sTimeVector)
{
    _SetQuestData(QUEST_TIME_LIMIT, sTimeVector);
}

string GetQuestCooldown(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestData(nQuestID, QUEST_COOLDOWN);
}

void SetQuestCooldown(string sTimeVector)
{
    _SetQuestData(QUEST_COOLDOWN, sTimeVector);
}

string GetQuestScriptOnAccept(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ACCEPT);
}

void SetQuestScriptOnAccept(string sScript)
{
    _SetQuestData(QUEST_SCRIPT_ON_ACCEPT, sScript);
}

string GetQuestScriptOnAdvance(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ADVANCE);
}

void SetQuestScriptOnAdvance(string sScript)
{
    _SetQuestData(QUEST_SCRIPT_ON_ADVANCE, sScript);
}

string GetQuestScriptOnComplete(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_COMPLETE);
}

void SetQuestScriptOnComplete(string sScript)
{
    _SetQuestData(QUEST_SCRIPT_ON_COMPLETE, sScript);
}

string GetQuestScriptOnFail(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_FAIL);
}

void SetQuestScriptOnFail(string sScript)
{
    _SetQuestData(QUEST_SCRIPT_ON_FAIL, sScript);
}

void SetQuestScriptOnAll(string sScript)
{
    SetQuestScriptOnAccept(sScript);
    SetQuestScriptOnAdvance(sScript);
    SetQuestScriptOnComplete(sScript);
    SetQuestScriptOnFail(sScript);
}

int GetQuestJournalHandler(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sResult = _GetQuestData(nQuestID, QUEST_JOURNAL_HANDLER);
    return StringToInt(sResult);
}

void SetQuestJournalHandler(int nJournalHandler = QUEST_JOURNAL_NWN)
{
    _SetQuestData(QUEST_JOURNAL_HANDLER, IntToString(nJournalHandler));
}

int GetQuestJournalDeleteOnComplete(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sResult = _GetQuestData(nQuestID, QUEST_JOURNAL_DELETE);
    return StringToInt(sResult);
}

void DeleteQuestJournalEntriesOnCompletion()
{
    string sData = IntToString(TRUE);
    _SetQuestData(QUEST_JOURNAL_DELETE, sData);
}

void RetainQuestJournalEntriesOnCompletion()
{
    string sData = IntToString(FALSE);
    _SetQuestData(QUEST_JOURNAL_DELETE, sData);
}

int GetQuestAllowPrecollectedItems(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sData = _GetQuestData(nQuestID, QUEST_PRECOLLECTED_ITEMS);
    return StringToInt(sData);
}

void SetQuestAllowPrecollectedItems(int nAllow = TRUE)
{
    string sData = IntToString(nAllow);
    _SetQuestData(QUEST_PRECOLLECTED_ITEMS, sData);
}

int GetQuestDeleteOnComplete(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sData = _GetQuestData(nQuestID, QUEST_DELETE);
    return StringToInt(sData);
}

void SetQuestDeleteOnComplete(int bDelete = TRUE)
{
    string sData = IntToString(bDelete);
    _SetQuestData(QUEST_DELETE, sData);
}

int GetQuestVersion(int nQuestID)
{
    string sData = _GetQuestData(nQuestID, QUEST_VERSION);
    return StringToInt(sData);
}

void SetQuestVersion(int nVersion)
{
    string sData = IntToString(nVersion);
    _SetQuestData(QUEST_VERSION, sData);
}

int GetQuestVersionAction(int nQuestID)
{
    string sData = _GetQuestData(nQuestID, QUEST_VERSION_ACTION);
    return StringToInt(sData);
}

void SetQuestVersionActionReset()
{
    string sData = IntToString(QUEST_VERSION_ACTION_RESET);
    _SetQuestData(QUEST_VERSION_ACTION, sData);
}

void SetQuestVersionActionDelete()
{
    string sData = IntToString(QUEST_VERSION_ACTION_DELETE);
    _SetQuestData(QUEST_VERSION_ACTION, sData);
}

void SetQuestVersionActionNone()
{
    string sData = IntToString(QUEST_VERSION_ACTION_NONE);
    _SetQuestData(QUEST_VERSION_ACTION, sData);
}

string GetQuestStepJournalEntry(string sQuestTag, int nStep)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY);
}

void SetQuestStepJournalEntry(string sJournalEntry)
{
    _SetQuestStepData(QUEST_STEP_JOURNAL_ENTRY, sJournalEntry);
}

string GetQuestStepTimeLimit(string sQuestTag, int nStep)
{
    int nQuestID = GetQuestID(sQuestTag);
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_TIME_LIMIT);
}

void SetQuestStepTimeLimit(string sTimeVector)
{
    if (sTimeVector == "")
        return;

    _SetQuestStepData(QUEST_STEP_TIME_LIMIT, sTimeVector);
}

int GetQuestStepPartyCompletion(string sQuestTag, int nStep)
{   
    int nQuestID = GetQuestID(sQuestTag);
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_PARTY_COMPLETION);
    return StringToInt(sData);
}

void SetQuestStepPartyCompletion(int nPartyCompletion = TRUE)
{
    string sData = IntToString(nPartyCompletion);
    _SetQuestStepData(QUEST_STEP_PARTY_COMPLETION, sData);
}

int GetQuestStepProximity(string sQuestTag, int nStep)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_PROXIMITY);
    return StringToInt(sData);
}

void SetQuestStepProximity(int bProximity = TRUE)
{
    string sData = IntToString(bProximity);
    _SetQuestStepData(QUEST_STEP_PROXIMITY, sData);
}

int GetQuestStepObjectiveMinimum(string sQuestTag, int nStep)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_OBJECTIVE_COUNT);
    return StringToInt(sData);
}

void SetQuestStepObjectiveMinimum(int nMinimum)
{
    string sData = IntToString(nMinimum);
    _SetQuestStepData(QUEST_STEP_OBJECTIVE_COUNT, sData);
}

int GetQuestStepObjectiveRandom(string sQuestTag, int nStep)
{
    int nQuestID = GetQuestID(sQuestTag);
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_RANDOM_OBJECTIVES);
    return StringToInt(sData);
}

void SetQuestStepObjectiveRandom(int nObjectiveCount)
{
    string sData = IntToString(nObjectiveCount);
    _SetQuestStepData(QUEST_STEP_RANDOM_OBJECTIVES, sData);
}   

string GetRandomQuestCustomMessage(object oPC, string sQuestTag)
{
    int nStep = GetPCQuestStep(oPC, sQuestTag);
    if (nStep == -1)
        return "";

    return GetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nStep);
}

string GetQuestStepObjectiveDescription(int nQuestID, int nObjectiveID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    return GetQuestString(sQuestTag, QUEST_DESCRIPTION + IntToString(nObjectiveID));
}

void SetQuestStepObjectiveDescription(string sDescription)
{
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    int nObjectiveID = GetLocalInt(GetModule(), QUEST_BUILD_OBJECTIVE);
    string sQuestTag = GetQuestTag(nQuestID);

    SetQuestString(sQuestTag, QUEST_DESCRIPTION + IntToString(nObjectiveID), sDescription);
}

string GetQuestStepObjectiveDescriptor(int nQuestID, int nObjectiveID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    return GetQuestString(sQuestTag, QUEST_DESCRIPTOR + IntToString(nObjectiveID));
}

void SetQuestStepObjectiveDescriptor(string sDescriptor)
{
    if (sDescriptor == "")
        return;

    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    int nObjectiveID = GetLocalInt(GetModule(), QUEST_BUILD_OBJECTIVE);
    string sQuestTag = GetQuestTag(nQuestID);

    SetQuestString(sQuestTag, QUEST_DESCRIPTOR + IntToString(nObjectiveID), sDescriptor);
}

string GetQuestStepObjectiveFeedback(int nQuestID, int nObjectiveID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    return GetQuestString(sQuestTag, QUEST_FEEDBACK + IntToString(nObjectiveID));
}

void SetQuestStepObjectiveFeedback(string sFeedback)
{
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    int nObjectiveID = GetLocalInt(GetModule(), QUEST_BUILD_OBJECTIVE);
    string sQuestTag = GetQuestTag(nQuestID);

    SetQuestString(sQuestTag, QUEST_FEEDBACK + IntToString(nObjectiveID), sFeedback);
}

void SetQuestPrerequisiteAlignment(int nAlignmentAxis, int bNeutral = FALSE)
{
    string sKey = IntToString(nAlignmentAxis);
    string sValue = IntToString(bNeutral);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestPrerequisiteClass(int nClass, int nLevels = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sKey = IntToString(nClass);
    string sValue = sOperator + ":" + IntToString(nLevels);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_CLASS, sKey, sValue);
}

void SetQuestPrerequisiteGold(int nGold = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sValue = sOperator + ":" + IntToString(max(0, nGold));
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestPrerequisiteItem(string sItemTag, int nQuantity = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sKey = sItemTag;
    string sValue = sOperator + ":" + IntToString(nQuantity);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestPrerequisiteLevelMax(int nLevelMin)
{
    string sValue = IntToString(nLevelMin);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_LEVEL_MAX, "", sValue);
}

void SetQuestPrerequisiteLevelMin(int nLevelMax)
{
    string sValue = IntToString(nLevelMax);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_LEVEL_MIN, "", sValue);
}

void SetQuestPrerequisiteQuest(string sQuestTag, int nCompletionCount = 1, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sKey = sQuestTag;
    string sValue = sOperator + ":" + IntToString(nCompletionCount);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_QUEST, sKey, sValue);
}

void SetQuestPrerequisiteQuestStep(string sQuestTag, int nStep)
{
    string sKey = sQuestTag;
    string sValue = IntToString(nStep);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_QUEST_STEP, sKey, sValue);
}

void SetQuestPrerequisiteRace(int nRace, int bAllowed = TRUE)
{
    string sKey = IntToString(nRace);
    string sValue = IntToString(bAllowed);   
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST); 
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_RACE, sKey, sValue);
}

void SetQuestPrerequisiteXP(int nXP, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sXP = sOperator + ":" + IntToString(nXP);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_XP, "", sXP);
}

void SetQuestPrerequisiteSkill(int nSkill, int nRank, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sSkill = IntToString(nSkill);
    string sRank = sOperator + ":" + IntToString(nRank);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_SKILL, sSkill, sRank);
}

void SetQuestPrerequisiteAbility(int nAbility, int nScore, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sAbility = IntToString(nAbility);
    string sScore = sOperator + ":" + IntToString(nScore);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ABILITY, sAbility, sScore);
}

void SetQuestPrerequisiteReputation(string sFaction, int nStanding, string sOperator = GREATER_THAN_OR_EQUAL_TO)
{
    string sStanding = sOperator + ":" + IntToString(nStanding);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_REPUTATION, sFaction, sStanding);
}

void SetQuestPrerequisiteVariableInt(string sVarName, string sOperator, int nValue)
{
    string sValue = IntToString(nValue);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_VARIABLE, "INT:" + sVarName, sOperator + ":" + sValue);
}

void SetQuestPrerequisiteVariableString(string sVarName, string sOperator, string sValue)
{
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_VARIABLE, "STRING:" + sVarName, sOperator + ":" + sValue);
}

void SetQuestStepFeedback(string sFeedback)
{
    string s;
}

void SetQuestStepObjectiveKill(string sTargetTag, int nValue = 1, int nMax = 0)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    string sMax = IntToString(nMax);
    _SetQuestObjective(QUEST_OBJECTIVE_KILL, sKey, sValue, sMax);
}

void SetQuestStepObjectiveGather(string sTargetTag, int nValue = 1, int nMax = 0)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    string sMax = IntToString(nMax);
    _SetQuestObjective(QUEST_OBJECTIVE_GATHER, sKey, sValue, sMax);
}

void SetQuestStepObjectiveDeliver(string sTargetTag, string sData, int nValue, int nMax = 0)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    string sMax = IntToString(nMax);
    _SetQuestObjective(QUEST_OBJECTIVE_DELIVER, sKey, sValue, sMax, sData);
}

void SetQuestStepObjectiveDiscover(string sTargetTag, int nValue = 1, int nMax = 0)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    string sMax = IntToString(nMax);
    _SetQuestObjective(QUEST_OBJECTIVE_DISCOVER, sKey, sValue, sMax);
}

void SetQuestStepObjectiveSpeak(string sTargetTag, int nValue = 1, int nMax = 0)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    string sMax = IntToString(nMax);
    _SetQuestObjective(QUEST_OBJECTIVE_SPEAK, sKey, sValue, sMax);
}

void SetQuestStepPrewardAlignment(int nAlignmentAxis, int nValue, int bParty = FALSE)
{
    string sKey = IntToString(nAlignmentAxis);
    string sValue = IntToString(nValue);
    _SetQuestPreward(QUEST_VALUE_ALIGNMENT, sKey, sValue, bParty);
}

void SetQuestStepPrewardGold(int nGold, int bParty = FALSE)
{
    string sValue = IntToString(nGold);
    _SetQuestPreward(QUEST_VALUE_GOLD, "", sValue, bParty);
}

void SetQuestStepPrewardItem(string sResref, int nQuantity, int bParty = FALSE)
{
    string sKey = sResref;
    string sValue = IntToString(nQuantity);
    _SetQuestPreward(QUEST_VALUE_ITEM, sKey, sValue, bParty);
}

void SetQuestStepPrewardXP(int nXP, int bParty = FALSE)
{
    string sValue = IntToString(nXP);
    _SetQuestPreward(QUEST_VALUE_XP, "", sValue, bParty);
}

void SetQuestStepPrewardMessage(string sMessage, int bParty = FALSE)
{
    string sValue = sMessage;
    _SetQuestPreward(QUEST_VALUE_MESSAGE, "", sValue, bParty);
}

void SetQuestStepPrewardReputation(string sFaction, int nChange, int bParty = FALSE)
{
    string sKey = sFaction;
    string sValue = IntToString(nChange);
    _SetQuestPreward(QUEST_VALUE_REPUTATION, sKey, sValue, bParty);
}

void SetQuestStepPrewardVariableInt(string sVarName, string sOperator, int nValue, int bParty = FALSE)
{
    string sKey = "INT:" + sVarName;
    string sValue = sOperator + ":" + IntToString(nValue);
    _SetQuestPreward(QUEST_VALUE_VARIABLE, sKey, sValue, bParty);
}

void SetQuestStepPrewardVariableString(string sVarName, string sOperator, string sValue, int bParty = FALSE)
{
    string sKey = "STRING:" + sVarName;
    string sKVP = sOperator + ":" + sValue;
    _SetQuestPreward(QUEST_VALUE_VARIABLE, sKey, sKVP, bParty);
}

void SetQuestStepRewardAlignment(int nAlignmentAxis, int nValue, int bParty = FALSE)
{
    string sKey = IntToString(nAlignmentAxis);
    string sValue = IntToString(nValue);
    _SetQuestReward(QUEST_VALUE_ALIGNMENT, sKey, sValue, bParty);
}

void SetQuestStepRewardGold(int nGold, int bParty = FALSE)
{
    string sValue = IntToString(nGold);
    _SetQuestReward(QUEST_VALUE_GOLD, "", sValue, bParty);
}

void SetQuestStepRewardItem(string sResref, int nQuantity = 1, int bParty = FALSE)
{
    string sKey = sResref;
    string sValue = IntToString(nQuantity);
    _SetQuestReward(QUEST_VALUE_ITEM, sKey, sValue, bParty);
}

void SetQuestStepRewardQuest(string sQuestTag, int bAssign = TRUE, int bParty = FALSE)
{
    string sKey = sQuestTag;
    string sValue = IntToString(bAssign);
    _SetQuestReward(QUEST_VALUE_QUEST, sKey, sValue, bParty);
}

void SetQuestStepRewardXP(int nXP, int bParty = FALSE)
{
    string sValue = IntToString(nXP);
    _SetQuestReward(QUEST_VALUE_XP, "", sValue, bParty);
}

void SetQuestStepRewardMessage(string sMessage, int bParty = FALSE)
{
    string sValue = sMessage;
    _SetQuestReward(QUEST_VALUE_MESSAGE, "", sValue, bParty);
}

void SetQuestStepRewardReputation(string sFaction, int nChange, int bParty = FALSE)
{
    string sKey = sFaction;
    string sValue = IntToString(nChange);
    _SetQuestReward(QUEST_VALUE_REPUTATION, sKey, sValue, bParty);
}

void SetQuestStepRewardVariableInt(string sVarName, string sOperator, int nValue, int bParty = FALSE)
{
    string sKey = "INT:" + sVarName;
    string sValue = sOperator + ":" + IntToString(nValue);
    _SetQuestReward(QUEST_VALUE_VARIABLE, sKey, sValue, bParty);
}

void SetQuestStepRewardVariableString(string sVarName, string sOperator, string sValue, int bParty = FALSE)
{
    string sKey = "STRING:" + sVarName;
    string sKVP = sOperator + ":" + sValue;
    _SetQuestReward(QUEST_VALUE_VARIABLE, sKey, sKVP, bParty);
}

int AddQuestResolutionSuccess(int nStep = -1)
{
    nStep = AddQuestStep(nStep);

    string sType = IntToString(QUEST_STEP_TYPE_SUCCESS);
    _SetQuestStepData(QUEST_STEP_TYPE, sType);

    return nStep;
}

int AddQuestResolutionFail(int nStep = -1)
{
    nStep = AddQuestStep(nStep);

    string sType = IntToString(QUEST_STEP_TYPE_FAIL);
    _SetQuestStepData(QUEST_STEP_TYPE, sType);

    return nStep;
}
