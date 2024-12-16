/// ----------------------------------------------------------------------------
/// @file   quest_i_main.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Quest System (core)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                          Database Function Prototypes
// -----------------------------------------------------------------------------

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

// ---< CountQuestPrerequisites >---
// Counts the number or prerequisites assigned to quest sQuestTag.
int CountQuestPrerequisites(string sQuestTag);

// ---< GetPCHasQuest >---
// Returns TRUE if oPC has quest sQuestTag assigned.
int GetPCHasQuest(object oPC, string sQuestTag);

// ---< quest_IsComplete >---
// Returns TRUE if oPC has completed quest sQuestTag at least once
int quest_IsComplete(object oPC, string sQuestTag);

// ---< quest_CountCompletions >---
// Returns the total number of times oPC has completed quest sQuestTag
int quest_CountCompletions(object oPC, string sQuestTag);

// ---< GetPCQuestStep >---
// Returns the current step oPC is on for quest sQuestTag.
int GetPCQuestStep(object oPC, string sQuestTag);

// ---< GetNextPCQuestStep >---
// Returns the step number of the next step in quest sQuestTag for oPC.
int GetNextPCQuestStep(object oPC, string sQuestTag);

#include "util_i_csvlists"
#include "util_i_variables"
#include "util_i_debug"
#include "util_i_time"
#include "util_i_unittest"

#include "quest_i_const"
#include "quest_i_debug"
#include "quest_i_core"

#include "nwnx_player"

/// @note idea is to keep all the prototypes from v1 in place, so quests can be
///     easily migrated and nothing breaks, so we'll just modify what the various
///     functions do instead of changing the names of the functions.

/// @note If any functions names *must* be changed, we'll be sure to note those
///     in the readme.

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

/// @brief Adds a new quest with tag sTag and Journal Entry Title sTitle.
/// @param sTag Tag of the quest to add. This value must be module-unique and will
///     be used to reference all quest-related data for the module and all players.
/// @param sTitle Optional. The journal title for quest sTag. Will only be used
///     when adding journal entries with NWNX.
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

// ---< GetQuestScriptOnAssign >---
// Returns the script associated with sQuestTag's OnAssign event.  The event runs before a script is
// assigned to a PC and can be cancelled.
string GetQuestScriptOnAssign(string sQuestTag);

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
int RunQuestScript(object oPC, string sQuestTag, int nQuestEvent);

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

/// @brief Add an alignment prerequisite.
/// @param nAlignment ALIGNMENT_* constant.
/// @param bNeutral If TRUE, the player must have a neutral alignment on the axis
///     specified by nAlignment.
/// @note Stackable.  If stacked, player must meet all alignment prerequisites.
/// @warning Not meant for use outside of the quest definition process.
void SetQuestPrerequisiteAlignment(int nAlignment, int bNeutral = FALSE);

/// @brief Add a class prerequisite.
/// @param nClass CLASS_TYPE_* constant.
/// @param nLevels Number of levels.
///     nLevel > 0 : Compare nClass using sComparison
///     nLevel = 0 : nClass is excluded
/// @param sComparison Comparison operator.
/// @note Stackable.  If stacked, player must meet at least one of the prerequisites.
/// @warning Not meant for use outside of the quest definition process.
void SetQuestPrerequisiteClass(int nClass, int nLevels = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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
void SetQuestPrerequisiteGold(int nGold = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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
void SetQuestPrerequisiteItem(string sItemTag, int nQuantity = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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
void SetQuestPrerequisiteQuest(string sQuestTag, int nCompletionCount = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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
void SetQuestPrerequisiteXP(int nXP, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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
void SetQuestPrerequisiteSkill(int nSkill, int nRank, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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
void SetQuestPrerequisiteAbility(int nScore, int nScore, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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
void SetQuestPrerequisiteReputation(string sFaction, int nStanding, string sComparison = GREATER_THAN_OR_EQUAL_TO);

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

// ---< SetQuestStepPrewardFloatingText >--
void SetQuestStepPrewardFloatingText(string sText, int bPartyOnly = FALSE, int bChatDisplay = FALSE, int bParty = FALSE);

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
void SetQuestStepPrewardVariableInt(string sVarName, string sComparison, int nValue, int bParty = FALSE);

// ---< SetQuestStepPrewardVariableInt >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is started.  This preward will create, modify or delete a specified
// local variable on the PC object.  This function is considered advance usage and the
// system README should be consulted before using.
void SetQuestStepPrewardVariableString(string sVarName, string sComparison, string sValue, int bParty = FALSE);

// ---< SetQuestStepPrewardMessage >---
// Provides a preward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This preward will display a pre-defined message to
// the assigned PC as floating text.  Not meant to be used outside the quest definition process.
void SetQuestStepPrewardMessage(string sMessage, int bParty = FALSE);

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
void SetQuestStepRewardVariableInt(string sVarName, string sComparison, int nValue, int bParty = FALSE);

// ---< SetQuestStepRewardVariableString >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will create, modify or delete a specified
// local variable on the PC object.  This function is considered advance usage and the
// system README should be consulted before using.
void SetQuestStepRewardVariableString(string sVarName, string sComparison, string sValue, int bParty = FALSE);

// ---< SetQuestStepRewardFloatingText >---
// Provides a reward allotment for the assigned PC when the active step of the quest
// currently being defined is ended.  This reward will display a pre-defined message to
// the assigned PC as floating text.  Not meant to be used outside the quest definition process.
void SetQuestStepRewardMessage(string sMessage, int bParty = FALSE);

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

/// @deprecated Use GetQuestVariable()
/// @brief Retrieves an integer value set into the volatile module database by 
///     SetQuestInt().
/// @param sQuestTag Quest tag associated with the integer variable.
/// @param sVarName Name of the integer variable to retrieve.
/// @param bDelete If TRUE, the variable will be deleted after retrieval.
int GetQuestInt(string sQuestTag, string sVarName, int bDelete = FALSE);

// ---< SetQuestInt >---
// Sets an integer value into the volatile module database and associated the value with a specific quest.
void SetQuestInt(string sQuestTag, string sVarName, int nValue);

// ---< DeleteQuestInt >---
// Deletes an integer value from the volatile module database.
void DeleteQuestInt(string sQuestTag, string sVarName);

// ---< GetQuestString >---
// Returns an string value set into the volatile module database by SetQuestInt().
string GetQuestString(string sQuestTag, string sVarName, int bDelete = FALSE);

// ---< SetQuestString >---
// Sets an string value into the volatile module database and associated the value with a specific quest.
void SetQuestString(string sQuestTag, string sVarName, string sValue);

// ---< DeleteQuestString >---
// Deletes an string value from the volatile module database.
void DeleteQuestString(string sQuestTag, string sVarName);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

void SetQuestVariable(string sVarName, json jValue, string sTag = "")
{
    quest_AddVariable(sVarName, jValue, "questVariables", sTag);
}

void SetQuestStepVariable(string sVarName, json jValue, int nStep = -1, string sTag = "")
{
    quest_AddVariable(sVarName, jValue, "stepVariables", sTag, nStep);
}

/*
void _DeleteQuestVariable(string sQuestTag, string sType, string sVarName, object oPC = OBJECT_INVALID, int nStep = -1)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == -1 || sVarName == "" || !HasListItem("INT,STRING", sType))
        return;

    DeleteModuleString(sVarName, _BuildVariableTag(sQuestTag, sType, oPC, nStep));
}

void SetQuestInt(string sQuestTag, string sVarName, int nValue)
{
    //quest_SetProperty(QUEST_KEY_VARIABLES, sVarName, JsonInt(nValue));
}

int GetQuestInt(string sQuestTag, string sVarName, int bDelete = FALSE)
{
    return StringToInt(_GetQuestVariable(sQuestTag, "INT", sVarName, OBJECT_INVALID, -1, bDelete));
}

void DeleteQuestInt(string sQuestTag, string sVarName)
{
    _DeleteQuestVariable(sQuestTag, "INT", sVarName);
}

void SetQuestString(string sQuestTag, string sVarName, string sValue)
{
    //quest_SetProperty(QUEST_KEY_VARIABLES, sVarName, JsonString(sValue), sQuestTag);
} 

string GetQuestString(string sQuestTag, string sVarName, int bDelete = FALSE)
{
    return _GetQuestVariable(sQuestTag, "STRING", sVarName, OBJECT_INVALID, -1, bDelete);
}

void DeleteQuestString(string sQuestTag, string sVarName)
{
    _DeleteQuestVariable(sQuestTag, "STRING", sVarName);
}

void SetPCQuestString(object oPC, string sQuestTag, string sVarName, string sValue, int nStep = 0)
{
    _SetQuestVariable(sQuestTag, "STRING", sVarName, sValue, oPC, nStep);
}

string GetPCQuestString(object oPC, string sQuestTag, string sVarName, int nStep = 0, int bDelete = FALSE)
{
    return _GetQuestVariable(sQuestTag, "STRING", sVarName, oPC, nStep, bDelete);
}

void DeletePCQuestString(object oPC, string sQuestTag, string sVarName, int nStep = 0)
{
    _DeleteQuestVariable(sQuestTag, "STRING", sVarName, oPC, nStep);
}

void SetPCQuestInt(object oPC, string sQuestTag, string sVarName, int nValue, int nStep = 0)
{
    _SetQuestVariable(sQuestTag, "INT", sVarName, _i(nValue), oPC, nStep);
}

int GetPCQuestInt(object oPC, string sQuestTag, string sVarName, int nStep = 0, int bDelete = -1)
{
    return StringToInt(_GetQuestVariable(sQuestTag, "INT", sVarName, oPC, nStep, bDelete));    
}

void DeletePCQuestInt(object oPC, string sQuestTag, string sVarName, int nStep = 0)
{
    _DeleteQuestVariable(sQuestTag, "INT", sVarName, oPC, nStep);
}

*/

/*
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

        string sQuestTitle = quest_GetData(sQuestTag, QUEST_TITLE);

        sMessage += ColorHeading("* ") + quest_QuestToString(-1, sQuestTag) + " " + quest_StepToString(nStep) + " " + 
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

    sMessage = HexColorString("Current quest status for ", COLOR_CYAN) + quest_PCToString(oPC) + "\n" + sMessage;

    if (GetIsPC(oDestination))
        SendMessageToPC(oDestination, sMessage);
    else
        WriteTimestampedLogEntry(UnColorString(sMessage));
}

void CleanPCQuestTables(object oPC)
{
    QuestDebug("Cleaning PC Quest Tables for " + quest_PCToString(oPC));
    QuestDebug("Checking quest versions for stale quests ...");

    int nStale;

    string s = r"
        SELECT quest_tag, nQuestVersion
        FROM quest_pc_data;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    while (SqlStep(sql))
    {
        string sQuestTag = SqlGetString(sql, 0);
        int nQuestVersion = SqlGetInt(sql, 1);
        int nQuestID = GetQuestID(sQuestTag);

        s = r"
            SELECT nQuestVersion
            FROM quest_quests
            WHERE sTag = @tag;
        ";
        sqlquery sqlVersion = SqlPrepareQueryObject(GetModule(), s);
        SqlBindString(sqlVersion, "@tag", sQuestTag);

        if (SqlStep(sqlVersion))
        {
            if (nQuestVersion != SqlGetInt(sqlVersion, 0))
            {
                nStale++;
                int nAction = StringToInt(quest_GetData(sQuestTag, QUEST_VERSION_ACTION));
                if (nAction == QUEST_VERSION_ACTION_NONE)
                {
                    QuestDebug("Quest versions for " + quest_QuestToString(0, sQuestTag) + " do not match; " +
                        "no action taken due to version action setting");
                    continue;
                }
                else if (nAction == QUEST_VERSION_ACTION_RESET)
                {
                    QuestDebug("Quest versions for " + quest_QuestToString(0, sQuestTag) + " do not match; " +
                        "resetting quest for " + quest_PCToString(oPC));
                    AssignQuest(oPC, sQuestTag);
                }
                else if (nAction == QUEST_VERSION_ACTION_DELETE)
                {
                    QuestDebug("Quest versions for " + quest_QuestToString(0, sQuestTag) + " do not match; " +
                        "deleting quest from " + quest_PCToString(oPC));
                    DeletePCQuest(oPC, nQuestID);
                    RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
                }
            }
        }
    }

    QuestDebug("Quest check complete; " + 
        (nStale == 0 ? HexColorString("0 stale quests found", COLOR_GREEN_LIGHT) : 
        HexColorString(_i(nStale) + " stale quest" + (nStale == 1 ? "" : "s") + " found.", COLOR_RED_LIGHT) +
        "  Check the log for actions taken."));
}
*/

void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS);

/*
void _AssignQuest(object oPC, int nQuestID)
{
    string sQuestTag = quest_GetTag(nQuestID);

    if (GetPCHasQuest(oPC, sQuestTag))
    {
        DeletePCQuestProgress(oPC, nQuestID);
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, "0");
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, "");
    }
    else
        quest_Assign(oPC, nQuestID);

    _SetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME, _i(GetQuestUnixTimeStamp()));
    _SetPCQuestData(oPC, nQuestID, QUEST_PC_VERSION, quest_GetData(sQuestTag, QUEST_VERSION));
    RunQuestScript(oPC, sQuestTag, QUEST_EVENT_ON_ACCEPT);
    AdvanceQuest(oPC, nQuestID);

    QuestDebug(quest_PCToString(oPC) + " has been assigned quest " + quest_QuestToString(nQuestID));
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
            QuestDebug("Minimum Item Count: " + quest_PCToString(oPC) + " and party members " +
                "have at least " + _i(nMinQuantity) + " " + sItemTag);
        else
            QuestDebug("Minimum Item Count: " + quest_PCToString(oPC) + " and party members " +
                "only have " + _i(nItemCount) + " of the required " +
                _i(nMinQuantity) + " " + sItemTag);
    }

    return bHasMinimum;
}

void _AwardFloatingText(object oPC, string sMessage, int nPartyOnly, int nChatDisplay, int bParty)
{
    object o = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(o))
    {
        if (bParty || o == oPC)
            FloatingTextStringOnCreature(sMessage, o, nPartyOnly, nChatDisplay);

        o = GetNextFactionMember(oPC, TRUE);
    }
}

// Awards gold to oPC and/or their party members
void _AwardGold(object oPC, int nGold, int bParty = FALSE)
{
    object o = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(o))
    {
        if (bParty || o == oPC)
        {
            if (nGold < 0)
                TakeGoldFromCreature(abs(nGold), o, TRUE);
            else
                GiveGoldToCreature(o, nGold);
        }
        o = GetNextFactionMember(oPC, TRUE);
    }

    QuestDebug((nGold < 0 ? "Removing " : "Awarding ") + _i(nGold) +
        "gp " + (nGold < 0 ? "from " : "to ") + quest_PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards XP to oPC and/or their party members
void _AwardXP(object oPC, int nXP, int bParty = FALSE)
{
    object o = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(o))
    {
        if (bParty || o == oPC)
            SetXP(o, GetXP(o) + nXP);

        o = GetNextFactionMember(oPC, TRUE);
    }

    QuestDebug((nXP < 0 ? "Removing " : "Awarding ") + _i(nXP) +
        "xp " + (nXP < 0 ? "from " : "to ") + quest_PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

void _AwardQuest(object oPC, int nQuestID, int nFlag = TRUE, int bParty = FALSE)
{
    int nAssigned, nComplete;
    string sQuestTag = quest_GetTag(nQuestID);

    object o = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(o))
    {
        if (bParty || o == oPC)
        {
            nAssigned = GetPCHasQuest(o, sQuestTag);
            nComplete = quest_IsComplete(o, sQuestTag);

            if (nFlag)
            {
                if (!nAssigned || (nAssigned && nComplete))
                    _AssignQuest(o, nQuestID);
            }
            else
                UnassignQuest(o, sQuestTag);
        }
        o = GetNextFactionmember(oPC, TRUE);
    }

    QuestDebug("Awarding quest " + quest_QuestToString(nQuestID) +
        " to " + quest_PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards item(s) to oPC and/or their party members
void _AwardItem(object oPC, string sResref, int nQuantity, int bParty = FALSE)
{
    object o = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(o))
    {
        if (bParty || o == oPC)
        {
            if (nQuantity < 0)
            {
                object oItem = GetFirstItemInInventory(o);
                while (GetIsObjectValid(oItem))
                {
                    if (GetResRef(oItem) == sResref)
                        DestroyObject(oItem);
                    oItem = GetNextItemInInventory(o);
                }
            }
            else
                for (n = 0; n < nQuantity; n++)
                    CreateItemOnObject(sResref, o);
        }
        o = GetNextFactionMember(oPC, TRUE);
    }

    QuestDebug((nQuantity < 0 ? "Removing " : "Awarding ") + "item " + sResref + 
        " (" + _i(abs(nQuantity)) + ") " +
        (nQuantity < 0 ? "from " : "to ") + quest_PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards alignment shift to oPC and/or their party members
void _AwardAlignment(object oPC, int nAxis, int nShift, int bParty = FALSE)
{
    object o = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(o))
    {
        if (bParty || o == oPC)
            AdjustAlignment(o, nAxis, nShift, FALSE);

        o = GetNextFactionMember(oPC, TRUE);
    }

    QuestDebug("Awarding alignment shift of " + _i(nShift) +
        " on alignment axis " + AlignmentAxisToString(nAxis) + " to " +
        quest_PCToString(oPC) + (bParty ? " and party members" : ""));
}

*/

// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

/// @brief Start quest definition process for a new quest.
/// @param sTag Module-unique tag for this quest.
/// @param sJournalTitle Optional title of journal entry for this quest.
/// @returns TRUE if the quest was added, FALSE otherwise.
int AddQuest(string sTag, string sJournalTitle = "")
{
    return quest_AddQuest(sTag, sJournalTitle);
}

/// @deprecated No replacement.
/// @brief Delete a previously defined quest.
/// @param sTag Unique tag of quest to be deleted.
/// @returns TRUE if a record was deleted, FALSE otherwise.
int DeleteQuest(string sTag)
{
    //quest_EmitDeprecation(__FUNCTION__);

    return 0; //quest_DeleteQuest(sQuesTag);
}

/// @brief Add a quest step to the quest currently being defined.
/// @param nStep Custom step number if using non-sequential numbering.
///     This value should reflect the associated step number in the
///     journal if using pre-defined journal entries.
/// @returns -1 if the step could not be added, otherwise an incremental
///     value of the last step number.  The incremented value is
///     generally not useful, but -1 indicates an error state.
/// @warning This function should only be called during the quest definition
///     process.
int AddQuestStep(int nStep = -1)
{   
    return quest_AddStep(nStep);
}

int AddQuestResolutionSuccess(int nStep = -1)
{
    nStep = AddQuestStep(nStep);
    quest_SetProperty(QUEST_KEY_STEP_TYPE, JsonInt(QUEST_STEP_TYPE_SUCCESS));
    return nStep;
}

int AddQuestResolutionFail(int nStep = -1)
{
    nStep = AddQuestStep(nStep);
    quest_SetProperty(QUEST_KEY_STEP_TYPE, JsonInt(QUEST_STEP_TYPE_FAIL));
    return nStep;
}

int GetIsQuestAssignable(object oPC, string sTag)
{
    int bAssignable = FALSE;
    string sError, sErrors;

    QuestDebug("Checking for assignability of " + quest_QuestToString(sTag) + " to " + quest_PCToString(oPC));

    json jQuest = quest_GetData(sTag);
    if (jQuest == JSON_NULL)
    {
        QuestWarning("Quest " + quest_QuestToString(sTag) + " is not module-defined and " +
            "cannot be assigned" +
            "\n  PC -> " + quest_PCToString(oPC) +
            "\n  Area -> " + ColorValue(GetName(GetArea(oPC))));
        return FALSE;
    }
    else
        QuestDebug(quest_QuestToString(sTag) + " EXISTS");




    /*
    // Check if the quest is active
    if (quest_IsActive(nQuestID) == FALSE)
    {
        QuestWarning("Quest " + quest_QuestToString(nQuestID) + " is not active and " +
            " cannot be assigned");
        return FALSE;
    }
    else
        QuestDebug(quest_QuestToString(nQuestID) + " is ACTIVE");
    */

    /*
    // Check that the creator added that minimum number of steps
    // At least one resolution step is required, the rest are optional
    if (quest_HasMinimumSteps(nQuestID))
        QuestDebug(quest_QuestToString(nQuestID) + " has the minimum number of steps");
    else
    {
        QuestError(quest_QuestToString(nQuestID) + " does not have a resolution step and cannot " +
            "be assigned; ensure a resolution step (success or failure) has been added to " +
            "this quest");
        return FALSE;
    }
    */

    if (GetPCHasQuest(oPC, sTag) == TRUE)
    {
        if (quest_IsComplete(oPC, sTag) == TRUE)
        {
            // Check for cooldown
            string sCooldownTime = ""; //JsonGetString(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_TIME_COOLDOWN, sQuestTag));
            if (sCooldownTime == "")
            {
                QuestDebug("There is no cooldown time set for this quest");
                bAssignable = TRUE;
            }
            else
            {
                /*
                int nCompleteTime = StringToInt(_GetPCQuestData(oPC, nQuestID, QUEST_PC_LAST_COMPLETE));
                int nAvailableTime = GetModifiedUnixTimeStamp(nCompleteTime, sCooldownTime);
                if (GetGreaterUnixTimeStamp(nAvailableTime) != nAvailableTime)
                {
                    QuestDebug(quest_PCToString(oPC) + " has met the required cooldown time for " + quest_QuestToString(nQuestID));
                    bAssignable = TRUE;
                }
                else
                {
                    QuestDebug(quest_PCToString(oPC) + " has not met the required cooldown time for " + quest_QuestToString(nQuestID) +
                        "\n  Quest Completion Time -> " + ColorValue(FormatUnixTimestamp(nCompleteTime, QUEST_TIME_FORMAT) + " UTC") +
                        "\n  Cooldown Time -> " + ColorValue(TimeVectorToString(sCooldownTime)) + 
                        "\n  Earliest Assignment Time -> " + ColorValue(FormatUnixTimestamp(nAvailableTime, QUEST_TIME_FORMAT) + " UTC") +
                        "\n  Attemped Assignment Time -> " + ColorValue(FormatUnixTimestamp(GetQuestUnixTimeStamp(), QUEST_TIME_FORMAT) + " UTC"));
                    return FALSE;
                }
                */
            }

            // Check for repetitions
            int nReps = GetQuestRepetitions(sTag);
            if (nReps == 0)
                bAssignable = TRUE;
            else if (nReps > 0)
            {
                int nCompletions = quest_CountCompletions(oPC, sTag);
                if (nCompletions < nReps)
                    bAssignable = TRUE;
                else
                {
                    QuestDebug(quest_PCToString(oPC) + " has completed " + quest_QuestToString(sTag) + 
                        " successfully the maximum number of times; quest cannot be re-assigned" +
                        "\n  PC Quest Completion Count -> " + ColorValue(_i(nCompletions)) +
                        "\n  Quest Repetitions Setting -> " + ColorValue(_i(nReps)));
                    return FALSE;
                }
            }
            else
            {
                QuestError(quest_QuestToString(sTag) + " has been assigned an invalid " +
                    "number of repetitions; must be >= 0" +
                    "\n  Repetitions -> " + ColorValue(_i(nReps)));
                return FALSE;
            }
        }
        else
        {
            QuestDebug(quest_PCToString(oPC) + " is still completing " + quest_QuestToString(sTag) + "; quest cannot be " +
                "reassigned until the current attempt is complete");
            return FALSE;
        }
    }
    else
    {
        QuestDebug(quest_PCToString(oPC) + " does not have " + quest_QuestToString(sTag) + " assigned");
        bAssignable = TRUE;
    }

    QuestDebug("System pre-assignment check successfully completed; starting quest prerequisite checks");

    json jPrerequisites = quest_SortArray(jQuest, "questPrerequisites", "type");
    int nPrerequisites = JsonGetLength(jPrerequisites);
    if (nPrerequisites == 0)
    {
        QuestDebug(quest_QuestToString(sTag) + " has no prerequisites for " +
            quest_PCToString(oPC) + " to meet");
        return TRUE;
    }
    else
        QuestDebug(quest_QuestToString(sTag) + " has " + _i(nPrerequisites) + " prerequisites");


    //QuestDebug(HexColorString("Checking quest prerequisite " + ValueTypeToString(nValue), COLOR_CYAN));

    // TODO move stackable check to build process.
    //if (quest_IsPropertyStackable(nValueType) == FALSE && nTypeCount > 1)
    //{
    //    QuestError("GetIsQuestAssignable found multiple entries for a " +
    //        "non-stackable property" +
    //        "\n  Quest    -> " + quest_QuestToString(nQuestID) + 
    //        "\n  Category -> " + ColorValue(CategoryTypeToString(QUEST_CATEGORY_PREREQUISITE)) +
    //        "\n  Value    -> " + ColorValue(ValueTypeToString(nValueType)) +
    //        "\n  Entries  -> " + ColorValue(_i(nTypeCount)));
    //    return FALSE;
    //}

    //sqlquery sqlPrerequisitesByType = quest_GetPrerequisitesByType(nQuestID, nValueType);
    //switch (nValueType)
    int n; for (; n < nPrerequisites; n++)
    {
        // temp
        int nType = 0;
        string sKey, sValue;

        json p = JsonArrayGet(jPrerequisites, n);
        string sType = JsonGetString(JsonObjectGet(p, "type"));

        if (sType == "alignment")
        {
            int nAxis, bNeutral, bQualifies;
            int nGE = GetAlignmentGoodEvil(oPC);
            int nLC = GetAlignmentLawChaos(oPC);
            
            QuestDebug("  PC Good/Evil Alignment -> " + ColorValue(AlignmentAxisToString(nGE)) +
                "\n  PC Law/Chaos Alignment -> " + ColorValue(AlignmentAxisToString(nLC)));                

            nAxis = JsonGetInt(JsonObjectGet(p, "axis"));
            bNeutral = JsonGetInt(JsonObjectGet(p, "neutral"));

            QuestDebug("  ALIGNMENT | " + AlignmentAxisToString(nAxis) + " | " + (bNeutral ? "TRUE":"FALSE"));

            if (bNeutral)
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

            QuestDebug("  ALIGNMENT resolution -> " + ResolutionToString(bQualifies));

            if (bQualifies)
                bAssignable = TRUE;
            else
                sErrors = AddListItem(sErrors, sType);  
        }
        else if (sType == "gold")
        {
            int bQualifies, nGold = JsonGetInt(JsonObjectGet(p, "gold"));
            string sOperator = JsonGetString(JsonObjectGet(p, "comp"));

            QuestDebug("  PC Gold Balance -> " + ColorValue(_i(GetGold(oPC))));
            QuestDebug("  GOLD | " + ColorValue(sOperator + " " + _i(nGold)));
            
            bQualifies = quest_EvaluateCondition(GetGold(oPC), nGold, sOperator);

            QuestDebug("  GOLD resolution -> " + ResolutionToString(bQualifies));

            if (bQualifies)
                bAssignable = TRUE;
            else
                sErrors = AddListItem(sErrors, _i(nType));
        }
        else if (sType == "level")
        {
            int bQualifies, nLevel = JsonGetInt(JsonObjectGet(p, "level"));
            string sOperator = JsonGetString(JsonObjectGet(p, "comp"));

            QuestDebug("  PC Total Levels -> " + ColorValue(_i(GetHitDice(oPC))));
            //QuestDebug("  LEVEL | " + sOperator + " " + ColorValue(_i(nMaximumLevel)));
            
            if (quest_EvaluateCondition(GetHitDice(oPC), nLevel, sOperator))
                bQualifies = TRUE;
            
            QuestDebug("  LEVEL resolution -> " + ResolutionToString(bQualifies));

            if (bQualifies)
                bAssignable = TRUE;
            else
                sErrors = AddListItem(sErrors, _i(nType));
        }






        switch (nType)
        {
            case QUEST_VALUE_ALIGNMENT:
            {
//                int nAxis, bNeutral, bQualifies;
//                int nGE = GetAlignmentGoodEvil(oPC);
//                int nLC = GetAlignmentLawChaos(oPC);
//                
//                QuestDebug("  PC Good/Evil Alignment -> " + ColorValue(AlignmentAxisToString(nGE)) +
//                    "\n  PC Law/Chaos Alignment -> " + ColorValue(AlignmentAxisToString(nLC)));                
//
//                nAxis = StringToInt(sKey);
//                bNeutral = StringToInt(sValue);
//
//                QuestDebug("  ALIGNMENT | " + AlignmentAxisToString(nAxis) + " | " + (bNeutral ? "TRUE":"FALSE"));
//
//                if (bNeutral == TRUE)
//                {
//                    if (nGE == ALIGNMENT_NEUTRAL ||
//                        nLC == ALIGNMENT_NEUTRAL)
//                        bQualifies = TRUE;
//                }
//                else
//                {
//                    if (nGE == nAxis || nLC == nAxis)
//                        bQualifies = TRUE;
//                }
//
//                QuestDebug("  ALIGNMENT resolution -> " + ResolutionToString(bQualifies));
//
//                if (bQualifies == TRUE)
//                    bAssignable = TRUE;
//                else
//                    sErrors = AddListItem(sErrors, _i(nType));
//
//                break;
            }
            case QUEST_VALUE_CLASS:
            {
                int nClass, bQualifies;
                int nClass1 = GetClassByPosition(1, oPC);
                int nClass2 = GetClassByPosition(2, oPC);
                int nClass3 = GetClassByPosition(3, oPC);
                int nLevels1 = GetLevelByClass(nClass1, oPC);
                int nLevels2 = GetLevelByClass(nClass2, oPC);
                int nLevels3 = GetLevelByClass(nClass3, oPC);
                
                QuestDebug("  PC Classes -> " + ColorValue(ClassToString(nClass1) + " (" + _i(nLevels1) + ")" +
                    (nClass2 == CLASS_TYPE_INVALID ? "" : " | " + ClassToString(nClass2) + " (" + _i(nLevels2) + ")") +
                    (nClass3 == CLASS_TYPE_INVALID ? "" : " | " + ClassToString(nClass3) + " (" + _i(nLevels3) + ")")));

                nClass = StringToInt(sKey);
                string sOperator = quest_GetKey(sValue);
                int nLevels = StringToInt(quest_GetValue(sValue));

                QuestDebug("  CLASS | " + ColorValue(ClassToString(nClass)) + " | Levels " + ColorValue(sOperator + " " + _i(nLevels)));

                switch (nLevels)
                {
                    case 0:
                        if (nClass1 == nClass || nClass2 == nClass || nClass3 == nClass)
                        {
                            bQualifies = FALSE;
                            break;
                        }

                        bQualifies = TRUE;
                        break;
                    default:
                        if (nClass1 == nClass && quest_EvaluateCondition(nLevels1, nLevels, sOperator))
                            bQualifies = TRUE;
                        else if (nClass2 == nClass && quest_EvaluateCondition(nLevels2, nLevels, sOperator))
                            bQualifies = TRUE;
                        else if (nClass3 == nClass && quest_EvaluateCondition(nLevels3, nLevels, sOperator))
                            bQualifies = TRUE;
                        
                        break;
                }

                if (!bQualifies)
                    break;

                QuestDebug("  CLASS resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_REPUTATION:
            {
                int bQualifies;

                string sFaction = sKey;
                string sValue = sValue;
                string sOperator = quest_GetKey(sValue);
                int nRequiredStanding = StringToInt(quest_GetValue(sValue));

                object oFactionMember = GetObjectByTag(sFaction);
                int nCurrentStanding = GetFactionAverageReputation(oFactionMember, oPC);

                QuestDebug("  PC REPUTATION | " + sFaction + " | " + _i(nCurrentStanding));
                QuestDebug("  REPUTATION | " + sFaction + " | Standing " + 
                    sOperator + " " + _i(abs(nRequiredStanding)));

                if (quest_EvaluateCondition(nCurrentStanding, nRequiredStanding, sOperator))
                    bQualifies = TRUE;
                else
                {
                    bQualifies = FALSE;
                    break;
                }

                QuestDebug("  REPUTATION resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }    

            case QUEST_VALUE_ITEM:
            {
                int nItemQuantity, bQualifies;

                string sItemTag = sKey;
                string sOperator = quest_GetKey(sValue);
                nItemQuantity = StringToInt(quest_GetValue(sValue));

                QuestDebug("  ITEM | " + sItemTag + " | " + _i(nItemQuantity));

                int nItemCount = 0; //GetPCItemCount(oPC, sItemTag);
                QuestDebug("  PC has " + _i(nItemCount) + " " + sItemTag);
                
                if (nItemQuantity == 0 && nItemCount > 0)
                {
                    bQualifies = FALSE;
                    break;
                }
                else if (nItemQuantity > 0 && quest_EvaluateCondition(nItemCount, nItemQuantity, sOperator))
                    bQualifies = TRUE;

                QuestDebug("  ITEM resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_QUEST:
            {
                int bQualifies, bPCHasQuest, nPCCompletions, nPCFailures;

                string sTag = sKey;
                string sOperator = quest_GetKey(sValue);
                int nRequiredCompletions = StringToInt(quest_GetValue(sValue));
                
                bPCHasQuest = GetPCHasQuest(oPC, sTag);
                nPCCompletions = quest_CountCompletions(oPC, sTag);
                nPCFailures = 0; //quest_CountCompletionsByType(oPC, sTag, QUEST_TYPE_TYPE_FAIL);
                QuestDebug("  PC | Has Quest -> " + ColorValue((bPCHasQuest ? "TRUE":"FALSE")) + 
                    "\n  Completions -> " + ColorValue(_i(nPCCompletions)) +
                    "\n  Failures -> " + ColorValue(_i(nPCFailures)));
                QuestDebug("  QUEST | " + sTag + " | Required -> " + ColorValue(sOperator + " " + _i(nRequiredCompletions)));

                if (nRequiredCompletions > 0)
                {
                    if (bPCHasQuest == TRUE && quest_EvaluateCondition(nPCCompletions, nRequiredCompletions, sOperator))
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

                QuestDebug("  QUEST resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_QUEST_STEP:
            {
                string sTag;
                int nRequiredStep;
                int bQualifies, bPCHasQuest, nPCStep;

                sTag = sKey;
                nRequiredStep = StringToInt(sValue);

                QuestDebug("  QUEST_STEP | " + sTag + " | " + quest_StepToString(nRequiredStep));

                bPCHasQuest = GetPCHasQuest(oPC, sTag);
                nPCStep = GetPCQuestStep(oPC, sTag);

                QuestDebug("  PC | Has Quest -> " + (bPCHasQuest ? "TRUE":"FALSE") + " | " + quest_StepToString(nRequiredStep));

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

                QuestDebug("  QUEST_STEP resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_RACE:
            {
                int nRace, nPCRace = GetRacialType(oPC);
                int bQualifies, bAllowed;

                QuestDebug("  PC Race -> " + ColorValue(RaceToString(nPCRace)));
                
                nRace = StringToInt(sKey);
                bAllowed = StringToInt(sValue);

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
                    
                QuestDebug("  RACE resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_XP:
            {
                int bQualifies;
                string sOperator = quest_GetKey(sValue);
                int nXP = StringToInt(quest_GetValue(sValue));
                int nPC = GetXP(oPC);
                
                QuestDebug("  PC XP -> " + ColorValue(_i(nPC) + "xp"));
                QuestDebug("  XP | " + ColorValue(sOperator + " " + _i(abs(nXP)) + "xp"));

                if (quest_EvaluateCondition(nPC, nXP, sOperator))
                    bQualifies = TRUE;
                else
                    bQualifies = FALSE;

                QuestDebug("  XP resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_ABILITY:
            {
                int bQualifies;

                int nAbility = StringToInt(sKey);
                string sOperator = quest_GetKey(sValue);
                int nScore = StringToInt(quest_GetValue(sValue));
                int nPC = GetAbilityScore(oPC, nAbility, FALSE);

                QuestDebug("  PC " + AbilityToString(nAbility) + " Score -> " + _i(nPC));
                QuestDebug("  ABILITY | " + AbilityToString(nAbility) + " | Score " + 
                    sOperator + " " + _i(abs(nScore)));

                if (nScore <= 0)
                    QuestDebug(HexColorString("  ABILITY prerequisite has an invalide valid; must be >= 0", COLOR_RED_LIGHT));

                if (quest_EvaluateCondition(nPC, nScore, sOperator))
                    bQualifies = TRUE;
                else
                {
                    bQualifies = FALSE;
                    break;
                }

                QuestDebug("  ABILITY resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_SKILL:
            {
                int bQualifies;

                int nSkill = StringToInt(sKey);
                string sOperator = quest_GetKey(sValue);
                int nRank = StringToInt(quest_GetValue(sValue));
                int nPC = GetSkillRank(nSkill, oPC, TRUE);

                QuestDebug("  PC " + SkillToString(nSkill) + " Rank -> " + _i(nPC));
                QuestDebug("  SKILL | " + SkillToString(nSkill) + " | Score " + 
                    sOperator + " " + _i(nRank));

                if (nRank > 0 && quest_EvaluateCondition(nPC, nRank, sOperator))
                    bQualifies = TRUE;
                else if (nRank == 0 && nRank > 0)
                {
                    bQualifies = FALSE;
                    break;
                }

                QuestDebug("  SKILL resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
            case QUEST_VALUE_VARIABLE:
            {
                int bQualifies;
                string sType = quest_GetKey(sKey);
                string sVarName = quest_GetValue(sKey);
                string sOperator = quest_GetKey(sValue);
                sValue = quest_GetValue(sValue);

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

                    QuestDebug("  PC | INT " + sVarName + " | " + _i(nPC));
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

                QuestDebug("  VARIABLE resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, _i(nType));

                break;
            }
        }
    }

    if (sErrors != "")
    {
        int n, nCount = CountList(sErrors);
        string sResult;

        for (; n < nCount; n++)
        {
            string sError = GetListItem(sErrors, n);
            sResult = AddListItem(sResult, ValueTypeToString(StringToInt(sError)));
        }

        QuestNotice(quest_QuestToString(sTag) + " could not be assigned to " + quest_PCToString(oPC) +
            "; PC did not meet the following prerequisites: " + sResult);

        return FALSE;
    }
    else
    {
        QuestDebug(quest_PCToString(oPC) + " has met all prerequisites for " + quest_QuestToString(sTag));
        return TRUE;
    }
}

/*
void AssignQuest(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);

    if (RunQuestScript(oPC, sQuestTag, QUEST_EVENT_ON_ASSIGN) == TRUE)
        _AssignQuest(oPC, nQuestID);
    else
        QuestDebug("Could not assign " + quest_QuestToString(nQuestID) + " " +
            "to " + quest_PCToString(oPC) + "; assignment cancelled during " +
            "ON_ASSIGN event script run");
}

int RunQuestScript(object oPC, string sQuestTag, int nScriptType)
{
    string sScript;
    int bSetStep = FALSE;
    int nQuestID = GetQuestID(sQuestTag);

    if (nScriptType == QUEST_EVENT_ON_ASSIGN)
        sScript = GetQuestScriptOnAssign(sQuestTag);
    else if (nScriptType == QUEST_EVENT_ON_ACCEPT)
        sScript = GetQuestScriptOnAccept(sQuestTag);
    else if (nScriptType == QUEST_EVENT_ON_ADVANCE)
    {
        sScript = GetQuestScriptOnAdvance(sQuestTag);
        bSetStep = TRUE;
    }
    else if (nScriptType == QUEST_EVENT_ON_COMPLETE)
        sScript = GetQuestScriptOnComplete(sQuestTag);
    else if (nScriptType == QUEST_EVENT_ON_FAIL)
        sScript = GetQuestScriptOnFail(sQuestTag);

    if (sScript == "")
        return FALSE;
    
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
        "for " + quest_QuestToString(nQuestID) + (bSetStep ? " " + quest_StepToString(nStep) : "") + 
        " with " + quest_PCToString(oPC) + " as OBJECT_SELF");
    
    ExecuteScript(sScript, oPC);

    DeleteLocalString(oModule, QUEST_CURRENT_QUEST);
    DeleteLocalInt(oModule, QUEST_CURRENT_STEP);
    DeleteLocalInt(oModule, QUEST_CURRENT_EVENT);

    return TRUE;
}

void UnassignQuest(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    QuestDebug("Deleting " + quest_QuestToString(nQuestID) + " from " + quest_PCToString(oPC));
    RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
    DeletePCQuest(oPC, nQuestID);
}

int CountPCQuestCompletions(object oPC, int nQuestID)
{
    string sQuestTag = quest_GetTag(nQuestID);
    return quest_CountCompletions(oPC, sQuestTag);
}

void CopyQuestStepObjectiveData(object oPC, int nQuestID, int nStep)
{
    sqlquery sqlStepData;
    string sPrewardMessage;
    int nRandom = FALSE;
    string sQuestTag = quest_GetTag(nQuestID);

    int nRecords = GetQuestStepObjectiveRandom(sQuestTag, nStep);
    if (nRecords == -1)
    {
        sqlStepData = GetQuestStepObjectiveData(nQuestID, nStep);
        QuestDebug("Selecting all quest step objectives from " + quest_QuestToString(nQuestID) +
            " " + quest_StepToString(nStep) + " for assignment to " + quest_PCToString(oPC));
    }
    else
    {
        sqlStepData = GetRandomQuestStepObjectiveData(nQuestID, nStep, nRecords);

        int nObjectiveCount = CountQuestStepObjectives(nQuestID, nStep);
        QuestDebug("Selecting " + ColorValue(_i(nRecords)) + " of " +
            ColorValue(_i(nObjectiveCount)) + " available objectives from " +
            quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) + " for assignment to " +
            quest_PCToString(oPC));

        int nRandomCount = GetQuestStepObjectiveRandom(sQuestTag, nStep);
        int nMinimum = GetQuestStepObjectiveMinimum(sQuestTag, nStep);

        string sCount = "You must complete ";
        if (nRandomCount > nMinimum && nMinimum >= 1)
            sCount += _i(nMinimum) + " of the following " + _i(nRandomCount) + " objectives:";
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
            string sQuestTag = quest_GetTag(nQuestID);
            string sDescriptor = GetQuestString(sQuestTag, QUEST_DESCRIPTOR + _i(nObjectiveID));
            string sDescription = GetQuestString(sQuestTag, QUEST_DESCRIPTION + _i(nObjectiveID));

            sPrewardMessage +=
                "\n  " + ObjectiveTypeToString(nObjectiveType) + " " +
                    _i(nQuantity) + " " +
                    sDescriptor + (nQuantity == 1 ? "" : "s") +
                    (sDescription == "" ? "" : " " + sDescription);
        }
    }

    if (nRandom && sPrewardMessage != "")
        SetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, sPrewardMessage, nStep);
}

void SendJournalQuestEntry(object oPC, int nQuestID, int nStep, int bComplete = FALSE)
{
    string sQuestTag = quest_GetTag(nQuestID);
    int nDestination = GetQuestJournalHandler(sQuestTag);
    int bDelete = StringToInt(quest_GetData(sQuestTag, QUEST_JOURNAL_DELETE));

    switch (nDestination)
    {
        case QUEST_JOURNAL_NONE:
            QuestDebug("Journal Quest entries for " + quest_QuestToString(nQuestID) + " have been suppressed");
            break;
        case QUEST_JOURNAL_NWN:
            if (bComplete && bDelete)
                RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
            else
                AddJournalQuestEntry(sQuestTag, nStep, oPC, FALSE, FALSE, TRUE);
            
            QuestDebug("Journal Quest entry for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) +
                " on " + quest_PCToString(oPC) + " has been dispatched to the NWN journal system");
            break;
        case QUEST_JOURNAL_NWNX:
        {
            if (bComplete && bDelete)
                RemoveJournalQuestEntry(sQuestTag, oPC, FALSE, FALSE);
            else
            {
                string sText;
                if (StringToInt("";//_GetQuestStepData(nQuestID, nStep, QUEST_STEP_RANDOM_OBJECTIVES)) != -1 &&
                    QUEST_CONFIG_USE_CUSTOM_MESSAGE == TRUE)
                    sText = GetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nStep);
                else
                    sText = "";//_GetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY);
                    
                struct NWNX_Player_JournalEntry je;
                je.sName = quest_GetData(sQuestTag, QUEST_TITLE);
                je.sText = sText;
                je.sTag = sQuestTag;
                je.nQuestCompleted = bComplete;

                string sEmpty = "[Empty]";
                if (je.sName == "") je.sName = sEmpty;
                if (je.sText == "") je.sTag = sEmpty;

                NWNX_Player_AddCustomJournalEntry(oPC, je);
            }

            QuestDebug("Journal Quest entry for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) +
                " on " + quest_PCToString(oPC) + " has been dispatched to the NWN journal system via NWNX");
        }
    }
}

void UpdateJournalQuestEntries(object oPC)
{
    QuestDebug("Restoring journal quest entries for " + quest_PCToString(oPC));
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

    QuestDebug("Found " + _i(nTotal) + " quest" + (nTotal == 1 ? "" : "s") + " on " + 
        quest_PCToString(oPC) + "; restoring journal entries");
}

void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    QuestDebug("Attempting to advance quest " + quest_QuestToString(nQuestID) +
        " for " + quest_PCToString(oPC));

    string sQuestTag = quest_GetTag(nQuestID);

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
                QuestDebug("Could not locate success completion step for " + quest_QuestToString(nQuestID) +
                    "; ensure you've assigned one via AddQuestResolutionSuccess(); aborting quest " +
                    "advance attempt");
                return;
            }
            
            DeletePCQuestProgress(oPC, nQuestID);
            _AwardQuestStepAllotments(oPC, nQuestID, nCurrentStep, QUEST_CATEGORY_REWARD);
            SendJournalQuestEntry(oPC, nQuestID, nNextStep, TRUE);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
            quest_SetComplete(oPC, nQuestID, QUEST_STEP_TYPE_SUCCESS);
            RunQuestScript(oPC, sQuestTag, QUEST_EVENT_ON_COMPLETE);

            if (GetQuestStepObjectiveRandom(sQuestTag, nCurrentStep) != -1)
            {
                QuestDebug(quest_QuestToString(nQuestID) + " " + quest_StepToString(nCurrentStep) + " is marked " +
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
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, _i(nNextStep));
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, _i(GetQuestUnixTimeStamp()));
            RunQuestScript(oPC, sQuestTag, QUEST_EVENT_ON_ADVANCE);

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
                            QuestDebug(quest_PCToString(oPC) + " does not have any precollected items that " +
                                "satisfy requirements for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nNextStep));
                        else
                            QuestDebug("Applying " + _i(nPCCount) + " precollected items toward " +
                                "requirements for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nNextStep));

                        for (n = 0; n < nPCCount; n++)
                            SignalQuestStepProgress(oPC, sItemTag, QUEST_OBJECTIVE_GATHER, sData);
                    }
                }
            }
            else
                QuestDebug("Precollected items are not authorized for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nNextStep));
        }

        QuestDebug("Advanced " + quest_QuestToString(nQuestID) + " for " +
            quest_PCToString(oPC) + " from " + quest_StepToString(nCurrentStep) +
            " to " + quest_StepToString(nNextStep));
    }
    else if (nRequestType == QUEST_ADVANCE_FAIL)
    {
        int nNextStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_FAIL);
        DeletePCQuestProgress(oPC, nQuestID);
        quest_SetComplete(oPC, nQuestID, QUEST_STEP_TYPE_FAIL);

        if (nNextStep != -1)
        {
            SendJournalQuestEntry(oPC, nQuestID, nNextStep, TRUE);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
        }
        else
            QuestDebug(quest_QuestToString(nQuestID) + " has a failure mode but no failure completion step assigned; " +
                "all quests that have failure modes should have a failure completion step assigned with " +
                "AddQuestResolutionFail()");

        RunQuestScript(oPC, sQuestTag, QUEST_EVENT_ON_FAIL);

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

    string sQuestTag = quest_GetTag(nQuestID);

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
            QuestDebug(quest_PCToString(oPC) + " failed to meet the time limit for " +
                quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) +
                "\n  Step Start Time -> " + ColorValue(FormatUnixTimestamp(nStartTime, QUEST_TIME_FORMAT) + " UTC") +
                "\n  Allowed Time -> " + ColorValue(TimeVectorToString(sStepTimeLimit)) +
                "\n  Goal Time -> " + ColorValue(FormatUnixTimestamp(nGoalTime, QUEST_TIME_FORMAT) + " UTC") + 
                "\n  Completion Time -> " + ColorValue(FormatUnixTimestamp(GetQuestUnixTimeStamp(), QUEST_TIME_FORMAT) + " UTC"));
            nStatus = QUEST_STEP_FAIL;
        }
    }
    else
        QuestDebug(quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) + " does not have " +
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
                QuestDebug(quest_PCToString(oPC) + " failed to meet the time limit for " +
                    quest_QuestToString(nQuestID) +
                "\n  Quest Start Time -> " + ColorValue(FormatUnixTimestamp(nStartTime, QUEST_TIME_FORMAT) + " UTC") +
                "\n  Allowed Time -> " + ColorValue(TimeVectorToString(sQuestTimeLimit)) +
                "\n  Goal Time -> " + ColorValue(FormatUnixTimestamp(nGoalTime, QUEST_TIME_FORMAT) + " UTC") +
                "\n  Completion Time -> " + ColorValue(FormatUnixTimestamp(GetQuestUnixTimeStamp(), QUEST_TIME_FORMAT) + " UTC"));
            }
        }
        else
            QuestDebug(quest_QuestToString(nQuestID) + " does not have a time limit specified");
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
                QuestDebug(quest_PCToString(oPC) + "failed to meet an exclusive quest objective " +
                    "for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep));
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
                        QuestDebug(quest_PCToString(oPC) + " has met all requirements to " +
                            "successfully complete " + quest_QuestToString(nQuestID) +
                            " " + quest_StepToString(nStep));
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
                    QuestDebug(quest_PCToString(oPC) + " has completed " + _i(nCompletedCount) +
                        " of " + _i(nObjectives) + " possible objectives for " + 
                        quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) + " and has met all " +
                        "requirements for successfull step completion");
                    nStatus = QUEST_STEP_COMPLETE;
                }
                else
                    QuestDebug(quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) + " requires at " +
                        "least " + _i(nObjectiveCount) + " objective" + 
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
        "quest " + HexColorString("progress", COLOR_GREEN_LIGHT) + " triggered by " + quest_PCToString(oPC) + " for objective " +
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

            if (quest_IsActive(nQuestID) == FALSE)
            {
                QuestDebug(quest_QuestToString(nQuestID) + " is currently inactive and cannot be " +
                    "credited to " + quest_PCToString(oPC));
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
        QuestDebug(quest_PCToString(oPC) + " does not have a quest associated with " + sTargetTag + 
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
                int bActive = quest_IsActive(nQuestID);
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

    QuestDebug(sTargetTag + " is signalling quest " + HexColorString("regress", COLOR_RED_LIGHT) + 
        " triggered by " + quest_PCToString(oPC) + " for objective type " + 
        ObjectiveTypeToString(nObjectiveType) + (sData == "" ? "" : " (sData -> " + sData + ")"));

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

            if (quest_IsActive(nQuestID) == FALSE)
            {
                QuestDebug(quest_QuestToString(nQuestID) + " is currently invactive and cannot be " +
                    "debited to " + quest_PCToString(oPC));
                IncrementQuestStepQuantityByQuest(oPC, sQuestTag, sTargetTag, nObjectiveType, sData);
                continue;
            }

            nMatch = QUEST_MATCH_PC;
            CheckQuestStepProgress(oPC, nQuestID, nStep);
        }
    }
    else
        QuestDebug(quest_PCToString(oPC) + " does not have a quest associated with " + sTargetTag + 
            (sData == "" ? "" : " and " + sData));

    return nMatch;
}

string EvalQuestToken(string sToken, object oPC, string sQuestTag, int nAcquired, int nRequired)
{
    string sResult;

    if (sToken == "acquired") return _i(nAcquired);
    else if (sToken == "required") return _i(nRequired);
    else if (sToken == "remaining") return _i(nRequired - nAcquired);
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
    string sResult = AddListItem(""     , _i(nYears));
           sResult = AddListItem(sResult, _i(nMonths));
           sResult = AddListItem(sResult, _i(nDays));
           sResult = AddListItem(sResult, _i(nHours));
           sResult = AddListItem(sResult, _i(nMinutes));
           sResult = AddListItem(sResult, _i(nSeconds));

    return sResult;
}
*/

string GetCurrentQuest() { return GetLocalString(GetModule(), QUEST_CURRENT_QUEST); }
int GetCurrentQuestStep() { return GetLocalInt(GetModule(), QUEST_CURRENT_STEP); }
int GetCurrentQuestEvent() { return GetLocalInt(GetModule(), QUEST_CURRENT_EVENT); }

/*
void AwardQuestStepPrewards(object oPC, int nQuestID, int nStep, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_PREWARD, nAwardType);
}

void AwardQuestStepRewards(object oPC, int nQuestID, int nStep, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_REWARD, nAwardType);
}
*/

string GetQuestTitle(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_JOURNAL_TITLE, sQuestTag));
}

void SetQuestTitle(string sTitle) { quest_SetProperty(QUEST_KEY_JOURNAL_TITLE, JsonString(sTitle)); }
void SetQuestActive(string sTag = "") { quest_SetProperty(QUEST_KEY_ACTIVE, JSON_TRUE, sTag); }
void SetQuestInactive(string sTag = "") { quest_SetProperty(QUEST_KEY_ACTIVE, JSON_FALSE, sTag); }
void SetQuestRepetitions(int nRepetitions = 1) { quest_SetProperty(QUEST_KEY_REPETITIONS, JsonInt(nRepetitions)); }
void SetQuestTimeLimit(string sTimeVector) { quest_SetProperty(QUEST_KEY_TIME_LIMIT, JsonString(sTimeVector)); }
void SetQuestCooldown(string sTimeVector) { quest_SetProperty(QUEST_KEY_TIME_COOLDOWN, JsonString(sTimeVector)); }
void SetQuestScriptOnAccept(string sScript) { quest_SetProperty(QUEST_KEY_ON_ACCEPT, JsonString(sScript)); }
void SetQuestScriptOnAdvance(string sScript) { quest_SetProperty(QUEST_KEY_ON_ADVANCE, JsonString(sScript)); }
void SetQuestScriptOnAll(string sScript) { quest_SetProperty(QUEST_KEY_ON_ALL, JsonString(sScript)); }
void SetQuestScriptOnAssign(string sScript) { quest_SetProperty(QUEST_KEY_ON_ASSIGN, JsonString(sScript)); }
void SetQuestScriptOnComplete(string sScript) { quest_SetProperty(QUEST_KEY_ON_COMPLETE, JsonString(sScript)); }
void SetQuestScriptOnFail(string sScript) { quest_SetProperty(QUEST_KEY_ON_FAIL, JsonString(sScript)); }
void SetQuestJournalHandler(int nHandler = QUEST_JOURNAL_NWN) { quest_SetProperty(QUEST_KEY_JOURNAL_HANDLER, JsonInt(nHandler)); }
void SetQuestAllowPrecollectedItems(int bAllow = TRUE) { quest_SetProperty(QUEST_KEY_PRECOLLECTED, JsonBool(bAllow)); }
void SetQuestDeleteOnComplete(int bDelete = TRUE) { quest_SetProperty(QUEST_KEY_REMOVE, JsonBool(bDelete)); }
void SetQuestVersion(int nVersion) { quest_SetProperty(QUEST_KEY_VERSION_VERSION, JsonInt(nVersion)); }
void SetQuestVersionActionDelete() { quest_SetProperty(QUEST_KEY_VERSION_ACTION, JsonInt(QUEST_VERSION_ACTION_DELETE)); }
void SetQuestVersionActionNone() { quest_SetProperty(QUEST_KEY_VERSION_ACTION, JsonInt(QUEST_VERSION_ACTION_NONE)); }
void SetQuestVersionActionReset() { quest_SetProperty(QUEST_KEY_VERSION_ACTION, JsonInt(QUEST_VERSION_ACTION_RESET)); }

void DeleteQuestJournalEntriesOnCompletion() { quest_SetProperty(QUEST_KEY_JOURNAL_REMOVE, JSON_TRUE); }
void RetainQuestJournalEntriesOnCompletion() { quest_SetProperty(QUEST_KEY_JOURNAL_REMOVE, JSON_FALSE); }

void SetQuestStepJournalEntry(string sEntry) { quest_SetProperty(QUEST_KEY_STEP_JOURNAL_ENTRY, JsonString(sEntry)); }
void SetQuestStepTimeLimit(string sTimeVector) { quest_SetProperty(QUEST_KEY_STEP_TIME_LIMIT, JsonString(sTimeVector)); }
void SetQuestStepPartyCompletion(int bParty = TRUE) { quest_SetProperty(QUEST_KEY_STEP_PARTY_COMPLETION, JsonBool(bParty)); }
void SetQuestStepProximity(int bProximity = TRUE) { quest_SetProperty(QUEST_KEY_STEP_PARTY_PROXIMITY, JsonBool(bProximity)); }
void SetQuestStepObjectiveMinimum(int nMinimum) { quest_SetProperty(QUEST_KEY_STEP_OBJECTIVE_MINIMUM, JsonInt(nMinimum)); }
void SetQuestStepObjectiveRandom(int nObjectiveCount) {quest_SetProperty(QUEST_KEY_STEP_OBJECTIVE_RANDOM, JsonInt(nObjectiveCount)); }





int GetQuestActive(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_ACTIVE, sQuestTag));
}

// TODO add SetQuestStep[In]Active?

int GetQuestRepetitions(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_REPETITIONS, sQuestTag));
}

string GetQuestTimeLimit(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_TIME_LIMIT, sQuestTag));
}

string GetQuestCooldown(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_TIME_COOLDOWN, sQuestTag));
}

string GetQuestScriptOnAssign(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_SCRIPTS, QUEST_KEY_ON_ASSIGN, sQuestTag));
}

string GetQuestScriptOnAccept(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_SCRIPTS, QUEST_KEY_ON_ACCEPT, sQuestTag));
}

string GetQuestScriptOnAdvance(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_SCRIPTS, QUEST_KEY_ON_ADVANCE, sQuestTag));
}

string GetQuestScriptOnComplete(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_SCRIPTS, QUEST_KEY_ON_COMPLETE, sQuestTag));
}

string GetQuestScriptOnFail(string sQuestTag)
{
    return "";//JsonGetString(quest_GetProperty(QUEST_KEY_SCRIPTS, QUEST_KEY_ON_FAIL, sQuestTag));
}

int GetQuestJournalHandler(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_JOURNAL, QUEST_KEY_JOURNAL_HANDLER, sQuestTag));
}

int GetQuestJournalDeleteOnComplete(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_JOURNAL, QUEST_KEY_REMOVE_COMPLETED, sQuestTag));
}

int GetQuestAllowPrecollectedItems(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_ALLOW_PRECOLLECTED, sQuestTag));
}

int GetQuestDeleteOnComplete(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_REMOVE_COMPLETED));
}

int GetQuestVersion(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_VERSION, sQuestTag));
}

int GetQuestVersionAction(string sQuestTag)
{
    return 0;//JsonGetInt(quest_GetProperty(QUEST_KEY_PROPERTIES, QUEST_KEY_VERSION_ACTION, sQuestTag));
}

string _GetQuestStepData(int q, int n, string t)
{
    return "";
}

string GetQuestStepJournalEntry(string sQuestTag, int nStep)
{
    return ""; //"";//_GetQuestStepData(GetQuestID(sQuestTag), nStep, QUEST_KEY_JOURNAL_ENTRY);
}

string GetQuestStepTimeLimit(string sQuestTag, int nStep)
{
    return ""; //"";//_GetQuestStepData(GetQuestID(sQuestTag), nStep, QUEST_KEY_TIME_LIMIT);
}

int GetQuestStepPartyCompletion(string sQuestTag, int nStep)
{   
    string sData = ""; //= "";//_GetQuestStepData(GetQuestID(sQuestTag), nStep, QUEST_KEY_PARTY_COMPLETION);
    return StringToInt(sData);
}

int GetQuestStepProximity(string sQuestTag, int nStep)
{
    string sData = "";//_GetQuestStepData(GetQuestID(sQuestTag), nStep, QUEST_KEY_PARTY_PROXIMITY);
    return StringToInt(sData);
}


int GetQuestStepObjectiveMinimum(string sQuestTag, int nStep)
{
    string sData = "";//_GetQuestStepData(GetQuestID(sQuestTag), nStep, QUEST_KEY_OBJ_MIN_COUNT);
    return StringToInt(sData);
}

int GetQuestStepObjectiveRandom(string sQuestTag, int nStep)
{
    string sData = "";//_GetQuestStepData(GetQuestID(sQuestTag), nStep, QUEST_KEY_OBJ_RANDOM_COUNT);
    return StringToInt(sData);
}


string GetRandomQuestCustomMessage(object oPC, string sQuestTag)
{
    int nStep = GetPCQuestStep(oPC, sQuestTag);
    if (nStep == -1)
        return "";

    return ""; //GetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nStep);
}

string GetQuestStepObjectiveDescription(int nQuestID, int nObjectiveID)
{
    return "";//return GetQuestString(quest_GetTag(nQuestID), QUEST_DESCRIPTION + _i(nObjectiveID));
}

string GetQuestStepObjectiveDescriptor(int nQuestID, int nObjectiveID)
{
    return "";//return GetQuestString(quest_GetTag(nQuestID), QUEST_DESCRIPTOR + _i(nObjectiveID));
}

string GetQuestStepObjectiveFeedback(int nQuestID, int nObjectiveID)
{
    return ""; //return GetQuestString(quest_GetTag(nQuestID), QUEST_FEEDBACK + _i(nObjectiveID));
}

void SetQuestStepObjectiveDescription(string sDescription)
{
    quest_AddVariable("description", JsonString(sDescription), "stepObjectives");
}

void SetQuestStepObjectiveDescriptor(string sDescriptor)
{
    quest_AddVariable("descriptor", JsonString(sDescriptor), "stepObjectives");
}

void SetQuestStepObjectiveFeedback(string sFeedback)
{
    quest_AddVariable("feedback", JsonString(sFeedback), "stepObjectives");
}

void SetQuestPrerequisiteAlignment(int nAlignment, int bNeutral = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("alignment"));
         j = JsonObjectSet(j, "axis", JsonInt(nAlignment));
         j = JsonObjectSet(j, "neutral", JsonBool(bNeutral));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteClass(int nClass, int nLevels = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("class"));
         j = JsonObjectSet(j, "class", JsonInt(nClass));
         j = JsonObjectSet(j, "levels", JsonInt(nLevels));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_OR));
    quest_AddPrerequisite(j);     
}

void SetQuestPrerequisiteGold(int nGold = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("gold"));
         j = JsonObjectSet(j, "gold", JsonInt(nGold));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteItem(string sTag, int nQuantity = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("item"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "quantity", JsonInt(nQuantity));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteLevelMax(int nLevel)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("level"));
         j = JsonObjectSet(j, "level", JsonInt(nLevel));
         j = JsonObjectSet(j, "comp", JsonString(LESS_THAN_OR_EQUAL_TO));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteLevelMin(int nLevel)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("level"));
         j = JsonObjectSet(j, "level", JsonInt(nLevel));
         j = JsonObjectSet(j, "comp", JsonString(GREATER_THAN_OR_EQUAL_TO));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteQuest(string sTag, int nCompletions = 1, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("quest"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "completions", JsonInt(nCompletions));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteQuestStep(string sTag, int nStep, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("step"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "step", JsonInt(nStep));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteRace(int nRace, int bAllowed = TRUE)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("race"));
         j = JsonObjectSet(j, "race", JsonInt(nRace));
         j = JsonObjectSet(j, "allowed", JsonBool(bAllowed));
         j = JsonObjectSet(j, "op", JsonString(OP_OR));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteXP(int nXP, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("xp"));
         j = JsonObjectSet(j, "xp", JsonInt(nXP));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteSkill(int nSkill, int nRank, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("skill"));
         j = JsonObjectSet(j, "skill", JsonInt(nSkill));
         j = JsonObjectSet(j, "rank", JsonInt(nRank));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);    
}

void SetQuestPrerequisiteAbility(int nAbility, int nScore, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("ability"));
         j = JsonObjectSet(j, "ability", JsonInt(nAbility));
         j = JsonObjectSet(j, "score", JsonInt(nScore));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteReputation(string sFaction, int nStanding, string sComparison = GREATER_THAN_OR_EQUAL_TO)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("reputation"));
         j = JsonObjectSet(j, "faction", JsonString(sFaction));
         j = JsonObjectSet(j, "standing", JsonInt(nStanding));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteVariableInt(string sVarName, string sComparison, int nValue)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("variable"));
         j = JsonObjectSet(j, "varname", JsonString(sVarName));
         j = JsonObjectSet(j, "value", JsonInt(nValue));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestPrerequisiteVariableString(string sVarName, string sComparison, string sValue)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("variable"));
         j = JsonObjectSet(j, "varname", JsonString(sVarName));
         j = JsonObjectSet(j, "value", JsonString(sValue));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "op", JsonString(OP_AND));
    quest_AddPrerequisite(j);
}

void SetQuestStepObjectiveKill(string sTag, int nValue = 1, int nMax = 0)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("kill"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "quantity", JsonInt(nValue));
         j = JsonObjectSet(j, "max", JsonInt(nMax));
    quest_AddObjective(j);
}

void SetQuestStepObjectiveGather(string sTag, int nValue = 1, int nMax = 0)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("gather"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "quantity", JsonInt(nValue));
         j = JsonObjectSet(j, "max", JsonInt(nMax));
    quest_AddObjective(j);
}

void SetQuestStepObjectiveDeliver(string sTag, string sData, int nValue, int nMax = 0)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("discover"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "quantity", JsonInt(nValue));
         j = JsonObjectSet(j, "max", JsonInt(nMax));
         j = JsonObjectSet(j, "destination", JsonString(sData));
    quest_AddObjective(j);
}

void SetQuestStepObjectiveDiscover(string sTag, int nValue = 1, int nMax = 0)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("discover"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "quantity", JsonInt(nValue));
         j = JsonObjectSet(j, "max", JsonInt(nMax));
    quest_AddObjective(j);
}

void SetQuestStepObjectiveSpeak(string sTag, int nValue = 1, int nMax = 0)
{
    json j = JsonObjectSet(JSON_OBJECT, "type", JsonString("speak"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "quantity", JsonInt(nValue));
         j = JsonObjectSet(j, "max", JsonInt(nMax));
    quest_AddObjective(j);
}

void SetQuestStepPrewardAlignment(int nAxis, int nValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("alignment"));
         j = JsonObjectSet(j, "axis", JsonInt(nAxis));
         j = JsonObjectSet(j, "value", JsonInt(nValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardGold(int nGold, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("gold"));
         j = JsonObjectSet(j, "gold", JsonInt(nGold));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardItem(string sResref, int nQuantity, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("item"));
         j = JsonObjectSet(j, "resref", JsonString(sResref));
         j = JsonObjectSet(j, "quantity", JsonInt(nQuantity));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardXP(int nXP, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("xp"));
         j = JsonObjectSet(j, "xp", JsonInt(nXP));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardMessage(string sMessage, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("message"));
         j = JsonObjectSet(j, "message", JsonString(sMessage));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardFloatingText(string sText, int bPartyOnly = FALSE, int bChatDisplay = FALSE, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("float"));
         j = JsonObjectSet(j, "text", JsonString(sText));
         j = JsonObjectSet(j, "partyOnly", JsonBool(bPartyOnly));
         j = JsonObjectSet(j, "chatDisplay", JsonBool(bChatDisplay));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardReputation(string sFaction, int nValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("reputation"));
         j = JsonObjectSet(j, "faction", JsonString(sFaction));
         j = JsonObjectSet(j, "value", JsonInt(nValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardVariableInt(string sVarName, string sComparison, int nValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("variable"));
         j = JsonObjectSet(j, "varname", JsonString(sVarName));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "value", JsonInt(nValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepPrewardVariableString(string sVarName, string sComparison, string sValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("preward"));
         j = JsonObjectSet(j, "type", JsonString("variable"));
         j = JsonObjectSet(j, "varname", JsonString(sVarName));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "value", JsonString(sValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardAlignment(int nAxis, int nValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("alignment"));
         j = JsonObjectSet(j, "axis", JsonInt(nAxis));
         j = JsonObjectSet(j, "value", JsonInt(nValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardGold(int nGold, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("gold"));
         j = JsonObjectSet(j, "gold", JsonInt(nGold));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardItem(string sResref, int nQuantity = 1, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("item"));
         j = JsonObjectSet(j, "resref", JsonString(sResref));
         j = JsonObjectSet(j, "quantity", JsonInt(nQuantity));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardQuest(string sTag, int bAssign = TRUE, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("quest"));
         j = JsonObjectSet(j, "tag", JsonString(sTag));
         j = JsonObjectSet(j, "assign", JsonBool(bAssign));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardXP(int nXP, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("xp"));
         j = JsonObjectSet(j, "xp", JsonInt(nXP));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardMessage(string sMessage, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("message"));
         j = JsonObjectSet(j, "message", JsonString(sMessage));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardReputation(string sFaction, int nValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("reputation"));
         j = JsonObjectSet(j, "faction", JsonString(sFaction));
         j = JsonObjectSet(j, "value", JsonInt(nValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardVariableInt(string sVarName, string sComparison, int nValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("variable"));
         j = JsonObjectSet(j, "varname", JsonString(sVarName));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "value", JsonInt(nValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardVariableString(string sVarName, string sComparison, string sValue, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("variable"));
         j = JsonObjectSet(j, "varname", JsonString(sVarName));
         j = JsonObjectSet(j, "comp", JsonString(sComparison));
         j = JsonObjectSet(j, "value", JsonString(sValue));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}

void SetQuestStepRewardFloatingText(string sText, int bPartyOnly = FALSE, int bChatDisplay = FALSE, int bParty = FALSE)
{
    json j = JsonObjectSet(JSON_OBJECT, "category", JsonString("reward"));
         j = JsonObjectSet(j, "type", JsonString("float"));
         j = JsonObjectSet(j, "text", JsonString(sText));
         j = JsonObjectSet(j, "partyOnly", JsonBool(bPartyOnly));
         j = JsonObjectSet(j, "chatDisplay", JsonBool(bChatDisplay));
         j = JsonObjectSet(j, "party", JsonBool(bParty));
    quest_AddReward(j);
}
