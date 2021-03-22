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
    functions are avaialable for general use by including quest_i_database.
*/

// ---< Create[Module|PC]QuestTables >---
// Creates the required database tables on either the module (usually called in the
// OnModuleLoad event) or on the PC (usually called in the OnClientEnter event).
void CreateModuleQuestTables(int bReset = FALSE);
void CreatePCQuestTables(object oPC, int bReset = FALSE);

// ---< CleanPCQuestTables >---
// Clears PC quest tables of all quest data if a matching quest tag is not found
// in the module's quest database.  If this is called before quest definitions are
// loaded, all PC quest data will be erased.  Usually called in the OnClientEnter
// event.
void CleanPCQuestTables(object oPC);

// ---< GetQuest[Tag|ID] >---
// Converts a QuestTag to a QuestID
string GetQuestTag(int nQuestID);
int GetQuestID(string sQuestTag);

// ---< CountActiveQuestSteps >---
// Counts the total number of steps in a quest, not including the final success/
// completion step.
int CountActiveQuestSteps(string sQuestTag);

// ---< CountQuestPrerequisites >---
// Counts the total number or prerequisites assigned to nQuestID.
int CountQuestPrerequisites(string sQuestTag);

// ---< GetPCHasQuest >---
// Returns TRUE if oPC has quest sQuestTag assigned.
int GetPCHasQuest(object oPC, string sQuestTag);

// ---< GetIsPCQuestComplete >---
// Returns TRUE if oPC has complete quest nQuestID at least once
int GetIsPCQuestComplete(object oPC, string sQuestTag);

// ---< GetPCQuestCompletions >---
// Returns the total number of times oPC has completed quest sQuestTag
int GetPCQuestCompletions(object oPC, string sQuestTag);

// ---< GetPCQuestStep >---
// Returns the current step oPC is on for quest nQuestID
int GetPCQuestStep(object oPC, string sQuestTag);

// ---< GetNextPCQuestStep >---
// Given nCurrentStep, returns the step number of the next step in quest nQuestID
int GetNextPCQuestStep(object oPC, string sQuestTag);

#include "util_i_csvlists"
#include "util_i_debug"
#include "util_i_time"

#include "quest_i_const"
#include "quest_i_debug"
#include "quest_i_database"

// -----------------------------------------------------------------------------
//                          Quest System Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddQuest >---
// Adds a new quest with tag sTag and Journal Entry Title sTitle.  sTag is required;
// the Journal Entry title can be added later with SetQuestTitle().
int AddQuest(string sTag, string sTitle = "");

// ---< [Get|Set]Quest[Active|Inactive] >---
// Gets or sets the active status of quest sTag.
int GetQuestActive(int nQuestID);
void SetQuestActive(string sQuestTag = "");
void SetQuestInactive(string sQuestTag = "");

// ---< [Get|Set]QuestTitle >---
// TODO Gets or sets the quest title shown for quest sTag in the player's journal,  This is only
// useful for NWNX implementation and currently has no effect.
string GetQuestTitle(int nQuestID);
void SetQuestTitle(string sTitle);

// ---< [Get|Set]QuestRepetitions >---
// Gets or sets the number of times a PC can complete quest sTag.
int GetQuestRepetitions(int nQuestID);  // TODO sQuestTag?
void SetQuestRepetitions(int nRepetitions = 1);

// ---< [Get|Set]QuestScriptOn[Accept|Advance|Complete|Fail|All] >---
// Gets or sets the script associated with quest events OnAccept|Advance|Complete|Fail|All for
//  quest sTag.
string GetQuestScriptOnAccept(int nQuestID);
string GetQuestScriptOnAdvance(int nQuestID);
string GetQuestScriptOnComplete(int nQuestID);
string GetQuestScriptOnFail(int nQuestID);
void SetQuestScriptOnAccept(string sScript = "");
void SetQuestScriptOnAdvance(string sScript = "");
void SetQuestScriptOnComplete(string sScript = "");
void SetQuestScriptOnFail(string sScript = "");
void SetQuestScriptOnAll(string sScript = "");

// ---< RunQuestScript >---
// Runs the assigned quest script for quest nQuestID and nScriptType with oPC
// as OBJECT_SELF.
void RunQuestScript(object oPC, int nQuestID, int nScriptType);

// ---< [Get|Set]QuestTimeLimit >---
// Gets or sets the quest time limit for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.
string GetQuestTimeLimit(int nQuestID);
void SetQuestTimeLimit(string sTime);

// ---< [Get|Set]QuestCooldown >---
// Gets or sets the quest cooldown for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.  Cooldown is the minimum amount of time that
// must elapse before a player can repeat a repeatable quest.
string GetQuestCooldown(int nQuestID);
void SetQuestCooldown(string sTime);

// ---< [Get|Set]QuestJournalLocation >---
// Gets or sets which system will handle journal entries for nQuestID.  By default, the base
// game will handle journal entries, however, a mixture of NWNX journal functions and the
// NWN journal system can be used to handle various journal entries.  Setting nJournalHandler
// to QUEST_JOURNAL_NONE will suppress all journal entries.
int GetQuestJournalHandler(int nQuestID);
void SetQuestJournalHandler(int nJournalHandler = QUEST_JOURNAL_NWN);

// ---< [Delete|Retain]JournalEntriesOnCompletion >---
// Allows users to delete journal entries upon quest completion.  Designed primarily for 
// small, multi-use (i.e. throw-away) quests that you don't want filling up the player's journal.
int GetQuestJournalDeleteOnComplete(int nQuestID);
void DeleteQuestJournalEntriesOnCompletion();
void RetainQuestJournalEntriesOnCompletion();

// ---< [Get|Set]QuestAllowPrecollectedItems >---
// Gets|Sets whether specified quests can use items that are already in the player's
// inventory to satisfy quest requirements.  Defaults to TRUE.  Note:  The default is
// TRUE because this is a difficult requirement to enforce as the player can simply
// drop their items and pick them up again to get credit.
int GetQuestAllowPrecollectedItems(int nQuest);
void SetQuestAllowPrecollectedItems(int nAllow = TRUE);

// ---< SetQuestPrerequisite[Alignment|Class|Gold|Item|LevelMax|LevelMin|Quest|QuestStep|Race|XP|Skill|Ability] >---
// Sets a prerequisite for a PC to be able to be assigned a quest.  Prerequisites are used by
//  GetIsQuestAssignable() to determine if a PC is eligible to be assigned quest sTag
void SetQuestPrerequisiteAlignment(int nAlignmentAxis, int nValue = FALSE);
void SetQuestPrerequisiteClass(int nClass, int nLevels = -1);
void SetQuestPrerequisiteGold(int nGold = 1);
void SetQuestPrerequisiteItem(string sItemTag, int nQuantity = 1);
void SetQuestPrerequisiteLevelMax(int nLevelMin);
void SetQuestPrerequisiteLevelMin(int nLevelMax);
void SetQuestPrerequisiteQuest(string sQuestTag, int nCompletionCount = 0);
void SetQuestPrerequisiteRace(int nRace, int bAllowed = TRUE);
void SetQuestPrerequisiteXP(int nXP);
void SetQuestPrerequisiteSkill(int nSkill, int nRank);
void SetQuestPrerequisiteAbility(int nAbility, int nScore);

// ---< AddQuestStep >---
// Adds a new quest step to quest sTag with Journal Entry sJournalEntry.  The quest
//  step's journal entry can be added at a later time with SetQuestStepJournalEntry().
//  Returns the new quest step for use in assigning quest step variables.
int AddQuestStep(int nStep = -1);

// ---< [Get|Set]QuestStepJournalEntry >---
// Gets or sets the journal entry associated with nStep of quest sTag
string GetQuestStepJournalEntry(int nQuestID, int nStep);
void SetQuestStepJournalEntry(string sJournalEntry);

// ---< [Get|Set]QuestTimeLimit >---
// Gets or sets nStep's time limit for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.
string GetQuestStepTimeLimit(int nQuestID, int nStep);
void SetQuestStepTimeLimit(string sTime = "");

// ---< [Get|Set]QuestStepPartyCompletion >---
// Gets or sets the ability to allow party members to help complete quest steps
int GetQuestStepPartyCompletion(int nQuestID, int nStep);
void SetQuestStepPartyCompletion(int nParty);

// ---< [Get|Set]QuestStepProximity >---
// Sets whether a party member has to be within the same area as a triggering PC
// to qualify that party member to receive credit for an objective.  Has not effect
// if nPartyCompletion = FALSE.
int GetQuestStepProximity(int nQuestID, int nStep);
void SetQuestStepProximity(int nRequired = TRUE);

// ---< [Get|Set]QuestStepObjectiveMinimum >---
// Gets|Sets the minimum number of objectives that have to be met on nStep for the
// step to be considered complete.  The default value is "all steps", however setting
// a specified number here allow the user to create a quest step that can be used
// by many PCs while still allowing some variety (for example, PCs of different classes
// have to speak to different NPCs to complete their quest -- you can list each of those
// NPCs as a speak objective and set the minimum to 1, so each PC can still complete the
// step with different NPCs while still using the same quest).
int GetQuestStepObjectiveMinimum(int nQuestID, int nStep);
void SetQuestStepObjectiveMinimum(int nCount = -1);

// ---< [Get|Set]QuestStepObjectiveRandom >---
// Gets|Sets a random number of quest step objectives to be used when assigning this quest
// step.  This allows for semi-randomized quest creation.  Users can list multiple quest
// objectives and then set this value to a number less than the number of overall objectives.
// The system will randomly select nObjectiveCount objectives and assign them to the PC
// on quest assignment (instead of assigning all available objectives).
int GetQuestStepObjectiveRandom(int nQuestID, int nStep);
void SetQuestStepObjectiveRandom(int nObjectiveCount);

// TODO
string GetQuestStepObjectiveDescription(int nQuestID, int nObjectiveID);
void SetQuestStepObjectiveDescription(string sDescription);

// TODO
string GetQuestStepObjectiveDescriptor(int nQuestID, int nObjectiveID);
void SetQuestStepObjectiveDescriptor(string sDescriptor);

// ---< [AddQuestResolution[Success|Fail] >---
// Adds the final quest step to quest nQuestID.
int AddQuestResolutionSuccess(int nStep = -1);
int AddQuestResolutionFail(int nStep = -1);

// ---< SetQuestStepObjective[Kill|Gather|Deliver|Discover|Speak] >---
// Sets the objective type for a specified quest step
void SetQuestStepObjectiveKill(string sTargetTag, int nQuantity = 1);
void SetQuestStepObjectiveGather(string sTargetTag, int nQuantity = 1);
void SetQuestStepObjectiveDeliver(string sTargetTag, string sItemTag, int nQuantity = 1);
void SetQuestStepObjectiveDiscover(string sTargetTag, int nQuantity = 1);
void SetQuestStepObjectiveSpeak(string sTargetTag, int nQuantity = 1);


// ---< SetQuestStep[Preward|Reward][Alignment|Gold|Item|XP] >---
// Sets nStep's preward or reward
void SetQuestStepPrewardAlignment(int nAlignmentAxis, int nValue);
void SetQuestStepPrewardGold(int nGold);
void SetQuestStepPrewardItem(string sResref, int nQuantity = 1);
void SetQuestStepPrewardXP(int nXP);
void SetQuestStepPrewardMessage(string sMessage);
void SetQuestStepRewardAlignment(int nAlignmentAxis, int nValue);
void SetQuestStepRewardGold(int nGold);
void SetQuestStepRewardItem(string sResref, int nQuantity = 1);
void SetQuestStepRewardXP(int nXP);
void SetQuestStepRewardMessage(string sMessage);

// ---< GetIsQuestAssignable >---
// Returns whether oPC meets all prerequisites for quest sTag.  Quest prerequisites can only
// be satisfied by the PC object, not party members.
int GetIsQuestAssignable(object oPC, string sTag);

// ---< [Un]AssignQuest >---
// Assigns or unassigns quest sTag to player object oPC.  Does not check for quest elgibility. 
// GetIsQuestAssignable() should be run before calling this procedure to ensure the PC
// meets all prerequisites for quest assignment.
void AssignQuest(object oPC, string sQuestTag);
void UnassignQuest(object oPC, int nQuestID);

// ---< AdvanceQuest >---
// Called from the internal function that checks quest progress, this function can be called
// on its own to force-advance the quest by one step regardless of whether the PC completed
// the current step.
void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS);

// ---< SignalQuestStepProgress >---
// Called from module/game object scripts to signal the quest system to advance the quest, if
// the PC has completed all required objectives for the current step.
int SignalQuestStepProgress(object oPC, string sTargetTag, int nObjectiveType, string sData = "");
int SignalQuestStepRegress(object oPC, string sTargetTag, int ObjectiveType, string sData = "");

// ---< GetCurrentQuest[Step|Event] >---
// Global accessors to retrieve the current quest tag (all events), step number (OnAdvance only) 
// and Event (all events) when quest scripts are running.
string GetCurrentQuest();
int GetCurrentQuestStep();
int GetCurrentQuestEvent();

// ---< [Get|Set|Delete]Quest[Int|String] >---
// Gets|Sets|Deletes a variable from a database table associated with nQuestID.  These variables
// are stored in a module-level sqlite database table and associated with the quest, so it's
// a good place to store random variables that you want to save to the quest.  Currently only
// implemented with Ints and Strings.
int GetQuestInt(string sQuestTag, string sVarName);
void SetQuestInt(string sQuestTag, string sVarName, int nValue);
void DeleteQuestInt(string sQuestTag, string sVarName);
string GetQuestString(string sQuestTag, string sVarName);
void SetQuestString(string sQuestTag, string sVarName, string sValue);
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

// Should only be called after the quest has been created
//void _SetQuestData(int nQuestID, string sField, string sValue)
void _SetQuestData(string sField, string sValue, int nQuestID = -1)
{
    if (nQuestID == -1)
        nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);

    if (nQuestID == 0 || nQuestID == -1)
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
    CreateQuestVariablesTable();

    string sQuery = "INSERT INTO quest_variables (quests_id, sType, sName, sValue) " +
                    "VALUES (@id, @type, @name, @value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
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
    if (nQuestID == 0 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "INT", sVarName, IntToString(nValue));
}

int GetQuestInt(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == 0 || sVarName == "")
        return 0;

    return StringToInt(_GetQuestVariable(nQuestID, "INT", sVarName));
}

void DeleteQuestInt(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _DeleteQuestVariable(nQuestID, "INT", sVarName);
}

void SetQuestString(string sQuestTag, string sVarName, string sValue)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "STRING", sVarName, sValue);
}

string GetQuestString(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == 0 || sVarName == "")
        return "";

    return _GetQuestVariable(nQuestID, "STRING", sVarName);
}

void DeleteQuestString(string sQuestTag, string sVarName)
{
    int nQuestID = GetQuestID(sQuestTag);
    if (nQuestID == 0 || sVarName == "")
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

void _SetQuestStepProperty(int nCategoryType, int nValueType, string sKey, string sValue, string sData = "")
{
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    int nStep = GetLocalInt(GetModule(), QUEST_BUILD_STEP);

    if (nCategoryType != QUEST_CATEGORY_OBJECTIVE)
    {
        if (_GetIsPropertyStackable(nValueType) == FALSE)
            DeleteQuestStepPropertyPair(nQuestID, nStep, nCategoryType, nValueType);
    }

    string sQuery = "INSERT INTO quest_step_properties " +
                        "(quest_steps_id, nCategoryType, nValueType, sKey, sValue, sData) " +
                    "VALUES (@step_id, @category, @type, @key, @value, @data);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@step_id", GetQuestStepID(nQuestID, nStep));
    SqlBindInt(sql, "@type", nValueType);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@value", sValue);
    SqlBindString(sql, "@data", sData);

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
void _SetQuestObjective(int nValueType, string sKey, string sValue, string sData = "")
{
    int nCategoryType = QUEST_CATEGORY_OBJECTIVE;
    _SetQuestStepProperty(nCategoryType, nValueType, sKey, sValue, sData);

}

// Private accessor for setting quest step prewards
void _SetQuestPreward(int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_PREWARD;
    _SetQuestStepProperty(nCategoryType, nValueType, sKey, sValue);
}

// Private accessor for setting quest step rewards
void _SetQuestReward(int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_REWARD;
    _SetQuestStepProperty(nCategoryType, nValueType, sKey, sValue);
}

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

    // Set the quest start time
    _SetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME, IntToString(GetUnixTimeStamp()));
    IncrementPCQuestField(oPC, nQuestID, "nAttempts");
    
    RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_ACCEPT);
    // Go to the first step
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
                // TODO probably not appropriate?
                UnassignQuest(oPartyMember, nQuestID);
            
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
            UnassignQuest(oPC, nQuestID);
    }

    QuestDebug("Awarding quest " + QuestToString(nQuestID) +
        " to " + PCToString(oPC) +
        (bParty ? " and party members" : ""));
}

// Awards item(s) to oPC and/or their party members
void _AwardItem(object oPC, string sResref, int nQuantity, int bParty = FALSE)
{
    int nCount;
    object oItem;

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);

        while (GetIsObjectValid(oPartyMember))
        {
            nCount = nQuantity;
            if (nCount < 0)
            {
                while (nCount < 0)
                {   // TODO this might not work as expected due to the destroy delay.
                    // TODO loop inventory instead?
                    oItem = GetItemPossessedBy(oPartyMember, sResref);
                    DestroyObject(oItem);
                    nCount++;
                }
            }
            else
                // TODO also needs work, nQuantity like this doesn't work for non-stackable items
                CreateItemOnObject(sResref, oPartyMember, nQuantity);

            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        nCount = nQuantity;
        if (nCount < 0)
        {
            while (nCount < 0)
            {
                oItem = GetItemPossessedBy(oPC, sResref);
                DestroyObject(oItem);
                nCount++;
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
                               int nAwardType = AWARD_ALL, int bParty = FALSE)
{
    int nValueType, nAllotmentCount;
    string sKey, sValue;

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

        QuestDebug("  " + HexColorString("Allotment #" + IntToString(nAllotmentCount), COLOR_CYAN) + " " +
            "  Value Type -> " + ColorValue(ValueTypeToString(nValueType)));            

        switch (nValueType)
        {
            case QUEST_VALUE_GOLD:
            {
                if ((nAwardType && AWARD_GOLD) || nAwardType == AWARD_ALL)
                {
                    int nGold = StringToInt(sValue);
                    _AwardGold(oPC, nGold, bParty);
                }
                continue;
            }
            case QUEST_VALUE_XP:
            {
                if ((nAwardType && AWARD_XP) || nAwardType == AWARD_ALL)
                {
                    int nXP = StringToInt(sValue);
                    _AwardXP(oPC, nXP, bParty);
                }
                continue;
            }
            case QUEST_VALUE_ALIGNMENT:
            {
                if ((nAwardType && AWARD_ALIGNMENT) || nAwardType == AWARD_ALL)
                {
                    int nAxis = StringToInt(sKey);
                    int nShift = StringToInt(sValue);
                    _AwardAlignment(oPC, nAxis, nShift, bParty);
                }
                continue;
            }  
            case QUEST_VALUE_ITEM:
            {
                if ((nAwardType && AWARD_ITEM) || nAwardType == AWARD_ALL)
                {
                    string sResref = sKey;     
                    int nQuantity = StringToInt(sValue);
                    _AwardItem(oPC, sResref, nQuantity, bParty);
                }
                continue;
            }
            case QUEST_VALUE_QUEST:
            {
                if ((nAwardType && AWARD_QUEST) || nAwardType == AWARD_ALL)
                {
                    int nValue = StringToInt(sValue);
                    int nFlag = StringToInt(sValue);
                    _AwardQuest(oPC, nValue, nFlag, bParty);
                }
                continue;
            }
            case QUEST_VALUE_MESSAGE:
            {
                if ((nAwardType && AWARD_MESSAGE) || nAwardType == AWARD_ALL)
                {
                    string sMessage;

                    // If this is a random quest, we need to override the
                    // preward message
                    if (GetQuestStepObjectiveRandom(nQuestID, nStep) != -1 &&
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

int GetIsQuestAssignable(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    int bAssignable = FALSE;
    string sError, sErrors;

    QuestDebug("Checking for assignability of " + QuestToString(nQuestID));

    // Check if the quest exists
    if (nQuestID == 0 || GetQuestExists(sQuestTag) == FALSE)
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
            string sCooldownTime = GetQuestCooldown(nQuestID);
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
            int nReps = GetQuestRepetitions(nQuestID);
            if (nReps == 0)
                bAssignable = TRUE;
            else if (nReps > 0)
            {
                int nCompletions = GetPCQuestCompletions(oPC, sQuestTag);
                if (nCompletions < nReps)
                    bAssignable = TRUE;
                else
                {
                    QuestError(PCToString(oPC) + " has completed " + QuestToString(nQuestID) + 
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
                    nLevels = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  CLASS | " + ColorValue(ClassToString(nClass)) + " | Levels " + ColorValue(IntToString(nLevels)));

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
                            if (nClass1 == nClass && nLevels1 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass2 == nClass && nLevels2 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass3 == nClass && nLevels3 >= nLevels)
                                bQualifies = TRUE;
                            
                            break;
                    }
                }

                QuestDebug("  CLASS resolution -> " + ResolutionToString(bQualifies));

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_FACTION:   // TODO
                // Not yet implemented
                break;
            case QUEST_VALUE_GOLD:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nGoldRequired = SqlGetInt(sqlPrerequisitesByType, 1);
                
                QuestDebug("  PC Gold Balance -> " + ColorValue(IntToString(GetGold(oPC))));
                QuestDebug("  GOLD | " + ColorValue(IntToString(nGoldRequired)));
                
                if (GetGold(oPC) >= nGoldRequired)
                    bQualifies = TRUE;

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
                    nItemQuantity = SqlGetInt(sqlPrerequisitesByType, 1);

                    QuestDebug("  ITEM | " + sItemTag + " | " + IntToString(nItemQuantity));

                    int nItemCount = GetPCItemCount(oPC, sItemTag);
                    QuestDebug("  PC has " + IntToString(nItemCount) + " " + sItemTag);
                    
                    if (nItemQuantity == 0 && nItemCount > 0)
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    else if (nItemQuantity > 0 && nItemCount >= nItemQuantity)
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
                    nRequiredCompletions = SqlGetInt(sqlPrerequisitesByType, 1);
                    
                    bPCHasQuest = GetPCHasQuest(oPC, sQuestTag);
                    nPCCompletions = GetPCQuestCompletions(oPC, sQuestTag);
                    nPCFailures = GetPCQuestFailures(oPC, sQuestTag);
                    QuestDebug("  PC | Has Quest -> " + ColorValue((bPCHasQuest ? "TRUE":"FALSE")) + 
                        "\n  Completions -> " + ColorValue(IntToString(nPCCompletions)) +
                        "\n  Failures -> " + ColorValue(IntToString(nPCFailures)));
                    QuestDebug("  QUEST | " + sQuestTag + " | Required -> " + ColorValue(IntToString(nRequiredCompletions)));

                    if (nRequiredCompletions > 0)
                    {
                        if (bPCHasQuest == TRUE && nPCCompletions >= nRequiredCompletions)
                            bQualifies = TRUE;
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
                int bQualifies, nXP = SqlGetInt(sqlPrerequisitesByType, 1);
                int nPC = GetXP(oPC);
                
                QuestDebug("  PC XP -> " + ColorValue(IntToString(nPC) + "xp"));
                QuestDebug("  XP | " + (nXP >= 0 ? ">= " : "<= ") + IntToString(abs(nXP)) + "xp");

                if (nXP >= 0 && nPC >= nXP)
                    bQualifies = TRUE;
                else if (nXP < 0 && nXP <= nXP)
                    bQualifies = TRUE;
                else
                    bQualifies = FALSE;

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
                    int nScore = SqlGetInt(sqlPrerequisitesByType, 1);
                    int nPC = GetAbilityScore(oPC, nAbility, FALSE);

                    QuestDebug("  PC " + AbilityToString(nAbility) + " Score -> " + IntToString(nPC));
                    QuestDebug("  ABILITY | " + AbilityToString(nAbility) + " | Score " + 
                        (nScore >= 0 ? ">= " : "<= ") + IntToString(nScore));

                    if (nScore >= 0 && nPC >= nScore)
                        bQualifies = TRUE;
                    else if (nScore < 0 && nScore <= nScore)
                        bQualifies = TRUE;
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
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
                    int nRank = SqlGetInt(sqlPrerequisitesByType, 1);
                    int nPC = GetSkillRank(nSkill, oPC, TRUE);

                    QuestDebug("  PC " + SkillToString(nSkill) + " Rank -> " + IntToString(nPC));
                    QuestDebug("  SKILL | " + SkillToString(nSkill) + " | Score " + 
                        (nRank >= 0 ? ">= " : "<= ") + IntToString(nRank));

                    if (nRank >= 0 && nPC >= nRank)
                        bQualifies = TRUE;
                    else if (nRank < 0 && nPC <= nRank)
                        bQualifies = TRUE;
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                }

                QuestDebug("  SKILL resolution -> " + ResolutionToString(bQualifies));

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

void RunQuestScript(object oPC, int nQuestID, int nScriptType)
{
    string sScript, sQuestTag = GetQuestTag(nQuestID);
    int bSetStep = FALSE;

    if (nScriptType == QUEST_SCRIPT_TYPE_ON_ACCEPT)
        sScript = GetQuestScriptOnAccept(nQuestID);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_ADVANCE)
    {
        sScript = GetQuestScriptOnAdvance(nQuestID);
        bSetStep = TRUE;
    }
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_COMPLETE)
        sScript = GetQuestScriptOnComplete(nQuestID);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_FAIL)
        sScript = GetQuestScriptOnFail(nQuestID);

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

void UnassignQuest(object oPC, int nQuestID)
{
    QuestDebug("Deleting " + QuestToString(nQuestID) + " from " + PCToString(oPC));

    string sQuestTag = GetQuestTag(nQuestID);
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

    int nRecords = GetQuestStepObjectiveRandom(nQuestID, nStep);
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

        int nRandomCount = GetQuestStepObjectiveRandom(nQuestID, nStep);
        int nMinimum = GetQuestStepObjectiveMinimum(nQuestID, nStep);

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
        string sData = SqlGetString(sqlStepData, 4);

        AddQuestStepObjectiveData(oPC, nQuestID, nObjectiveType, sTag, nQuantity, sData);

        // For random quests, build the message
        if (nRandom && sPrewardMessage != "")
        {
            string sDescriptor = GetQuestStepObjectiveDescriptor(nQuestID, nObjectiveID);
            string sDescription = GetQuestStepObjectiveDescription(nQuestID, nObjectiveID);

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
    int nDestination = GetQuestJournalHandler(nQuestID);
    string sQuestTag = GetQuestTag(nQuestID);
    int bDelete;
    
    if (bComplete)
        bDelete = GetQuestJournalDeleteOnComplete(nQuestID);

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
                " has been dispatched to the NWN journal system");
            break;
        case QUEST_JOURNAL_NWNX:
            QuestError("Journal Quest entries for " + QuestToString(nQuestID) + " have been designated for " +
                "NWNX, however NWNX functionality has not yet been instituted.");
            break;
    }
}

void UpdateJournalQuestEntries(object oPC)
{
    sqlquery sqlPCQuestData = GetPCQuestData(oPC);
    while (SqlStep(sqlPCQuestData))
    {
        string sQuestTag = SqlGetString(sqlPCQuestData, 0);
        int nStep = SqlGetInt(sqlPCQuestData, 1);
        int nCompletions = SqlGetInt(sqlPCQuestData, 2);
        int nLastCompleteType = SqlGetInt(sqlPCQuestData, 3);

        int nQuestID = GetQuestID(sQuestTag);

        if (nStep == 0)
        {
            if (nCompletions == 0)
                continue;
            else
            {
                if (nLastCompleteType == 0)
                    nLastCompleteType = 1;

                nStep = GetQuestCompletionStep(nQuestID, nLastCompleteType);
            }
        }

        SendJournalQuestEntry(oPC, nQuestID, nStep);
    }
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
            DeletePCQuestProgress(oPC, nQuestID);
            
            if (nNextStep == -1)
            {
                QuestDebug("Could not locate success completion step for " + QuestToString(nQuestID) +
                    "; ensure you've assigned one via AddQuestResolutionSuccess(); aborting quest " +
                    "advance attempt");
                return;
            }
            
            SendJournalQuestEntry(oPC, nQuestID, nNextStep, TRUE);
            _AwardQuestStepAllotments(oPC, nQuestID, nCurrentStep, QUEST_CATEGORY_REWARD);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
            IncrementPCQuestCompletions(oPC, nQuestID, GetUnixTimeStamp());
            RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_COMPLETE);

            if (GetQuestStepObjectiveRandom(nQuestID, nCurrentStep) != -1)
            {
                QuestDebug(QuestToString(nQuestID) + " " + StepToString(nCurrentStep) + " is marked " +
                    "random and has been completed; deleting custom message");

                DeletePCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nCurrentStep);
            }
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
            RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_ADVANCE);

            if (GetQuestAllowPrecollectedItems(nQuestID) == TRUE)
            {
                sqlquery sObjectiveData = GetQuestStepObjectiveData(nQuestID, nNextStep);
                while (SqlStep(sObjectiveData))
                {
                    int nValueType = SqlGetInt(sObjectiveData, 0);
                    if (nValueType == QUEST_OBJECTIVE_GATHER)
                    {
                        string sItemTag = SqlGetString(sObjectiveData, 1);
                        int nQuantity = SqlGetInt(sObjectiveData, 2);
                        string sData = SqlGetString(sObjectiveData, 3);
                        int bParty = GetQuestStepPartyCompletion(nQuestID, nNextStep);
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

        RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_FAIL);
    }
}

void CheckQuestStepProgress(object oPC, int nQuestID, int nStep)
{
    int QUEST_STEP_INCOMPLETE = 0;
    int QUEST_STEP_COMPLETE = 1;
    int QUEST_STEP_FAIL = 2;

    int nRequired, nAcquired, nStatus = QUEST_STEP_INCOMPLETE;
    int nStartTime, nGoalTime;

    // Check for time failure first, if there is a time limit
    string sQuestTimeLimit = GetQuestTimeLimit(nQuestID);
    string sStepTimeLimit = GetQuestStepTimeLimit(nQuestID, nStep);

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
            int nObjectiveCount = GetQuestStepObjectiveMinimum(nQuestID, nStep);
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
}

int SignalQuestStepProgress(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    int nMatch = QUEST_MATCH_NONE;

    // This prevents the false-positives that occur during login events such as OnItemAcquire
    if (GetIsObjectValid(GetArea(oPC)) == FALSE)
        return QUEST_MATCH_NONE;

    QuestDebug(sTargetTag + " is signalling " +
        "quest " + HexColorString("progress", COLOR_GREEN_LIGHT) + " triggered by " + PCToString(oPC) + " for objective " +
        "type " + ObjectiveTypeToString(nObjectiveType) + (sData == "" ? "" : " (sData -> " + sData + ")"));

    while (GetIsObjectValid(GetMaster(oPC)))
        oPC = GetMaster(oPC);

    if (GetIsPC(oPC) == FALSE)
        return QUEST_MATCH_NONE;

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
            int nQuestID = GetQuestID(sQuestTag);
            int nStep = GetPCQuestStep(oPC, sQuestTag);

            if (GetIsQuestActive(nQuestID) == FALSE)
            {
                QuestDebug(QuestToString(nQuestID) + " is currently invactive and cannot be " +
                    "credited to " + PCToString(oPC));
                DecrementQuestStepQuantityByQuest(oPC, sQuestTag, sTargetTag, nObjectiveType, sData);
                continue;
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
                int bPartyCompletion = GetQuestStepPartyCompletion(nQuestID, nStep);
                int bProximity = GetQuestStepProximity(nQuestID, nStep);

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

string CreateTimeVector(int nYears = 0, int nMonths = 0, int nDays = 0,
                        int nHours = 0, int nMinutes = 0, int nSeconds = 0)
{
    string sResult = AddListItem(sResult, IntToString(nYears));
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

void AwardQuestStepPrewards(object oPC, int nQuestID, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_PREWARD, nAwardType, bParty);
}

void AwardQuestStepRewards(object oPC, int nQuestID, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_REWARD, nAwardType, bParty);
}

string GetQuestTitle(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_TITLE);
}

void SetQuestTitle(string sTitle)
{
    _SetQuestData(QUEST_TITLE, sTitle);
}

int GetQuestActive(int nQuestID)
{
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

int GetQuestRepetitions(int nQuestID)
{
    string sRepetitions = _GetQuestData(nQuestID, QUEST_REPETITIONS);
    return StringToInt(sRepetitions);
}

void SetQuestRepetitions(int nRepetitions = 1)
{
    string sRepetitions = IntToString(nRepetitions);
    _SetQuestData(QUEST_REPETITIONS, sRepetitions);
}

string GetQuestTimeLimit(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_TIME_LIMIT);
}

void SetQuestTimeLimit(string sTime)
{
    _SetQuestData(QUEST_TIME_LIMIT, sTime);
}

string GetQuestCooldown(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_COOLDOWN);
}

void SetQuestCooldown(string sTime)
{
    _SetQuestData(QUEST_COOLDOWN, sTime);
}

string GetQuestScriptOnAccept(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ACCEPT);
}

void SetQuestScriptOnAccept(string sScript = "")
{
    _SetQuestData(QUEST_SCRIPT_ON_ACCEPT, sScript);
}

string GetQuestScriptOnAdvance(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ADVANCE);
}

void SetQuestScriptOnAdvance(string sScript = "")
{
    _SetQuestData(QUEST_SCRIPT_ON_ADVANCE, sScript);
}

string GetQuestScriptOnComplete(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_COMPLETE);
}

void SetQuestScriptOnComplete(string sScript = "")
{
    _SetQuestData(QUEST_SCRIPT_ON_COMPLETE, sScript);
}

string GetQuestScriptOnFail(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_FAIL);
}

void SetQuestScriptOnFail(string sScript = "")
{
    _SetQuestData(QUEST_SCRIPT_ON_FAIL, sScript);
}

void SetQuestScriptOnAll(string sScript = "")
{
    SetQuestScriptOnAccept(sScript);
    SetQuestScriptOnAdvance(sScript);
    SetQuestScriptOnComplete(sScript);
    SetQuestScriptOnFail(sScript);
}

int GetQuestJournalHandler(int nQuestID)
{
    string sResult = _GetQuestData(nQuestID, QUEST_JOURNAL_LOCATION);
    return StringToInt(sResult);
}

void SetQuestJournalHandler(int nJournalHandler = QUEST_JOURNAL_NWN)
{
    _SetQuestData(QUEST_JOURNAL_LOCATION, IntToString(nJournalHandler));
}

int GetQuestJournalDeleteOnComplete(int nQuestID)
{
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

int GetQuestAllowPrecollectedItems(int nQuestID)
{
    string sData = _GetQuestData(nQuestID, QUEST_PRECOLLECTED_ITEMS);
    return StringToInt(sData);
}

void SetQuestAllowPrecollectedItems(int nAllow = TRUE)
{
    string sData = IntToString(nAllow);
    _SetQuestData(QUEST_PRECOLLECTED_ITEMS, sData);
}

string GetQuestStepJournalEntry(int nQuestID, int nStep)
{
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY);
}

void SetQuestStepJournalEntry(string sJournalEntry)
{
    _SetQuestStepData(QUEST_STEP_JOURNAL_ENTRY, sJournalEntry);
}

string GetQuestStepTimeLimit(int nQuestID, int nStep)
{
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_TIME_LIMIT);
}

void SetQuestStepTimeLimit(string sTime = "")
{
    if (sTime == "")
        return;

    _SetQuestStepData(QUEST_STEP_TIME_LIMIT, sTime);
}

int GetQuestStepPartyCompletion(int nQuestID, int nStep)
{   
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_PARTY_COMPLETION);
    return StringToInt(sData);
}

void SetQuestStepPartyCompletion(int nParty)
{
    string sData = IntToString(nParty);
    _SetQuestStepData(QUEST_STEP_PARTY_COMPLETION, sData);
}

int GetQuestStepProximity(int nQuestID, int nStep)
{
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_PROXIMITY);
    return StringToInt(sData);
}

void SetQuestStepProximity(int nRequired = TRUE)
{
    string sData = IntToString(nRequired);
    _SetQuestStepData(QUEST_STEP_PROXIMITY, sData);
}

int GetQuestStepObjectiveMinimum(int nQuestID, int nStep)
{
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_OBJECTIVE_COUNT);
    return StringToInt(sData);
}

void SetQuestStepObjectiveMinimum(int nCount = -1)
{
    string sData = IntToString(nCount);
    _SetQuestStepData(QUEST_STEP_OBJECTIVE_COUNT, sData);
}

int GetQuestStepObjectiveRandom(int nQuestID, int nStep)
{
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_RANDOM_OBJECTIVES);
    return StringToInt(sData);
}

void SetQuestStepObjectiveRandom(int nObjectiveCount)
{
    string sData = IntToString(nObjectiveCount);
    _SetQuestStepData(QUEST_STEP_RANDOM_OBJECTIVES, sData);
}   

string GetRandomQuestCustomMessage(object oPC, string sQuestTag, int nStep = -1)
{
    if (nStep == -1)
        nStep = GetPCQuestStep(oPC, sQuestTag);
        
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

void SetQuestPrerequisiteAlignment(int nAlignmentAxis, int bNeutral = FALSE)
{
    string sKey = IntToString(nAlignmentAxis);
    string sValue = IntToString(bNeutral);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestPrerequisiteClass(int nClass, int nLevels = -1)
{
    string sKey = IntToString(nClass);
    string sValue = IntToString(nLevels);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_CLASS, sKey, sValue);
}

void SetQuestPrerequisiteGold(int nGold = 1)
{
    string sValue = IntToString(max(0, nGold));
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestPrerequisiteItem(string sItemTag, int nQuantity = 1)
{
    string sKey = sItemTag;
    string sValue = IntToString(nQuantity);
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

void SetQuestPrerequisiteQuest(string sQuestTag, int nCompletionCount = 1)
{
    string sKey = sQuestTag;
    string sValue = IntToString(nCompletionCount);
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

void SetQuestPrerequisiteXP(int nXP)
{
    string sXP = IntToString(nXP);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_XP, "", sXP);
}

void SetQuestPrerequisiteSkill(int nSkill, int nRank)
{
    string sSkill = IntToString(nSkill);
    string sRank = IntToString(nRank);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_SKILL, sSkill, sRank);
}

void SetQuestPrerequisteAbility(int nAbility, int nScore)
{
    string sAbility = IntToString(nAbility);
    string sScore = IntToString(nScore);
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ABILITY, sAbility, sScore);
}

void SetQuestStepObjectiveKill(string sTargetTag, int nValue = 1)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    _SetQuestObjective(QUEST_OBJECTIVE_KILL, sKey, sValue);
}

void SetQuestStepObjectiveGather(string sTargetTag, int nValue = 1)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    _SetQuestObjective(QUEST_OBJECTIVE_GATHER, sKey, sValue);
}

void SetQuestStepObjectiveDeliver(string sTargetTag, string sData, int nValue)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    _SetQuestObjective(QUEST_OBJECTIVE_DELIVER, sKey, sValue, sData);
}

void SetQuestStepObjectiveDiscover(string sTargetTag, int nValue = 1)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    _SetQuestObjective(QUEST_OBJECTIVE_DISCOVER, sKey, sValue);
}

void SetQuestStepObjectiveSpeak(string sTargetTag, int nValue = 1)
{
    string sKey = sTargetTag;
    string sValue = IntToString(nValue);
    _SetQuestObjective(QUEST_OBJECTIVE_SPEAK, sKey, sValue);
}

void SetQuestStepPrewardAlignment(int nAlignmentAxis, int nValue)
{
    string sKey = IntToString(nAlignmentAxis);
    string sValue = IntToString(nValue);
    _SetQuestPreward(QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestStepPrewardGold(int nGold)
{
    string sValue = IntToString(nGold);
    _SetQuestPreward(QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestStepPrewardItem(string sResref, int nQuantity)
{
    string sKey = sResref;
    string sValue = IntToString(nQuantity);
    _SetQuestPreward(QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestStepPrewardXP(int nXP)
{
    string sValue = IntToString(nXP);
    _SetQuestPreward(QUEST_VALUE_XP, "", sValue);
}

void SetQuestStepPrewardMessage(string sMessage)
{
    string sValue = sMessage;
    _SetQuestPreward(QUEST_VALUE_MESSAGE, "", sValue);
}

void SetQuestStepRewardAlignment(int nAlignmentAxis, int nValue)
{
    string sKey = IntToString(nAlignmentAxis);
    string sValue = IntToString(nValue);
    _SetQuestReward(QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestStepRewardGold(int nGold)
{
    string sValue = IntToString(nGold);
    _SetQuestReward(QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestStepRewardItem(string sResref, int nQuantity = 1)
{
    string sKey = sResref;
    string sValue = IntToString(nQuantity);
    _SetQuestReward(QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestStepRewardQuest(string sQuestTag, int bGive = TRUE)
{
    string sKey = sQuestTag;
    string sValue = IntToString(bGive);
    _SetQuestReward(QUEST_VALUE_QUEST, sKey, sValue);
}

void SetQuestStepRewardXP(int nXP)
{
    string sValue = IntToString(nXP);
    _SetQuestReward(QUEST_VALUE_XP, "", sValue);
}

void SetQuestStepRewardMessage(string sMessage)
{
    string sValue = sMessage;
    _SetQuestReward(QUEST_VALUE_MESSAGE, "", sValue);
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
