/// ----------------------------------------------------------------------------
/// @file   quest_i_database.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Quest System (database)
/// ----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_strings"

#include "quest_i_const"
#include "quest_i_debug"

sqlquery quest_PrepareQuery(string s)
{
    return SqlPrepareQueryCampaign(QUEST_DATABASE, s);
}

void quest_BeginTransaction()  { SqlStep(quest_PrepareQuery("BEGIN TRANSACTION;")); }
void quest_CommitTransaction() { SqlStep(quest_PrepareQuery("COMMIT TRANSACTION;")); }

void CreateModuleQuestTables(int bReset = FALSE)
{
    /// @brief expriment:
    ///     Let's take a page from the nui playbook and save everything in json objects
    ///     - no requirement to modify tables if we want to change the data structure
    ///     - easily queries and stored as a single field
    ///     - human-readable
    ///     - queries are bit more difficult to write and maintain
    ///     - array insertion order is maintained organically (good for repeated quests)
    string sModule = r"
        CREATE TABLE IF NOT EXISTS quest_module (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quest_tag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE,
            quest_data NONE
        );
    ";
    
    /// Expected Keys:
    /// properties:
    ///     active (bool), repetitions (int), time_limit (int), cooldown (int),
    ///     allowPrecollectedItems (bool), removeOnCompleted (bool),
    ///     version (string), versionAction (int/string?)
    /// scripts (strings):
    ///     onAssign, onAccept, onAdvance, onComplete, onFail
    /// journal:
    ///     title (string), handler (int), removeOnCompleted (bool)
    /// prerequisites:
    ///     type (int), key (string), value (?)
    /// steps: [
    ///     number (int): # 
    ///     properties:
    ///         active (bool), time_limit (int), party_completion (bool), proximity (bool), 
    ///         type (int), objMinCount (int), objRandomCount (int)
    ///     variables: [
    ///         type (int), name (string), value (string)
    ///     ]
    ///     journal:
    ///         entry (string)
    /// ]
    /// variables: [
    ///     type (int), name (string), value (string)
    /// ]
    /// data: {
    ///     webhook(string): ~
    /// }
    ///     

    /// @note This table will likely be reset on every ModuleLoad event so we can always ensure the
    ///     data isn't stale, then quest versions will be checked against currently open quests in the
    ///     pc table.
    
 /*
    
    
    
    /// @brief
    ///     `quest_quests` holds high-level metadata for every quest.
    ///     `quest_prerequisites` holds optional prerequisites for quests in `quest_quests`
    ///     `quest_steps` holds individual quest step data for quests in `quest_quests`
    ///     `quest_step_properties` holds optional properties for each step in `quest_steps`
    ///     `quest_variables` holds optional variables for quests in `quest_quests`
    /// @note These tables are held in the module's volatile database, therefore 
    ///     all quests must be reloaded on each module load.
    /// @warning All of these tables are related to `quest_quests` via foreign keys and
    ///     will cascade delete records if a quest is deleted from `quest_quests`.
    ///     These tables include `quest_prerequisites`, `quest_steps`,
    ///     `quest_step_properties`, and `quest_variables`.
    string sQuests = r"
        CREATE TABLE IF NOT EXISTS quest_quests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quest_tag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE,
            nActive TEXT NOT NULL default '1',
            nRepetitions TEXT default '1',
            sScriptOnAssign TEXT default NULL,
            sScriptOnAccept TEXT default NULL,
            sScriptOnAdvance TEXT default NULL,
            sScriptOnComplete TEXT default NULL, 
            sScriptOnFail TEXT default NULL,
            sTimeLimit TEXT default NULL,
            sCooldown TEXT default NULL,
            sJournalTitle TEXT default NULL,
            nJournalHandler TEXT default NULL,
            nRemoveJournalOnCompleted TEXT default '0',
            nAllowPrecollectedItems TEXT default '1',
            nRemoveQuestOnCompleted TEXT default '0',
            nQuestVersion TEXT default '0',
            nQuestVersionAction TEXT default '0'
        );
    ";

    string sPrerequisites = r"
        CREATE TABLE IF NOT EXISTS quest_prerequisites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quests_id INTEGER NOT NULL default '0',
            nValueType INTEGER NOT NULL default '0',
            sKey TEXT NOT NULL default '',
            sValue TEXT NOT NULL default '',
            FOREIGN KEY (quests_id) REFERENCES quest_quests (id)
                ON UPDATE CASCADE ON DELETE CASCADE
        );
    ";

    string sSteps = r"
        CREATE TABLE IF NOT EXISTS quest_steps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quests_id INTEGER NOT NULL default '0',
            nStep INTEGER NOT NULL default '0',
            nActive TEXT NOT NULL default '1', 
            sJournalEntry TEXT default NULL,
            sTimeLimit TEXT default NULL,
            nPartyCompletion TEXT default '0',
            nProximity INTEGER default '1',
            nStepType INTEGER default '0',
            nObjectiveMinimumCount INTEGER default '-1',
            nRandomObjectiveCount INTEGER default '-1',
            UNIQUE (quests_id, nStep) ON CONFLICT IGNORE,
            FOREIGN KEY (quests_id) REFERENCES quest_quests (id)
                ON DELETE CASCADE ON UPDATE CASCADE
        );
    ";

    string sStepProperties = r"
        CREATE TABLE IF NOT EXISTS quest_step_properties (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quest_steps_id INTEGER NOT NULL,
            nCategoryType INTEGER NOT NULL,
            nValueType INTEGER NOT NULL,
            sKey TEXT NOT NULL COLLATE NOCASE,
            sValue INTEGER default '',
            sValueMax INTEGER default '',
            sData TEXT default '',
            bParty INTEGER default '0',
            FOREIGN KEY (quest_steps_id) REFERENCES quest_steps (id)
                ON DELETE CASCADE ON UPDATE CASCADE
        );
    ";
    string sVariables = r"
        CREATE TABLE IF NOT EXISTS quest_variables (
            quests_id INTEGER NOT NULL,
            sType TEXT NOT NULL,
            sName TEXT NOT NULL,
            sValue TEXT NOT NULL,
            UNIQUE (quests_id, sType, sName) ON CONFLICT REPLACE,
            FOREIGN KEY (quests_id) REFERENCES quest_quests (id) 
                ON UPDATE CASCADE ON DELETE CASCADE
        );
    ";
*/

    /// @brief
    ///     Now for the experimental pc quest data table
    string sPC = r"
        CREATE TABLE IF NOT EXISTS quest_pc (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pc_uuid TEXT NOT NULL default '~',
            quest_tag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE,
            quest_data NONE
        );
    ";

    /// Expected structure (array of): [{
    ///     properties:
    ///         startTime, completeTime, completeType, version
    ///     variables: [
    ///         type, name, value
    ///     ]
    ///     steps: [
    ///         number, data, required, acquired, objectiveID, startTime, completeTime
    ///     ]
    ///  },]
    /// @note each object in the array will represent one quest completion.  If the quest
    ///     can be completed multiple times, there will be multiple objects in the array,
    ///     inserted in the order they were added, so the most recent is always last.
    /// @note There simply is no potential sharing of quest data bewteen characters, so
    ///     we'll use pc object uuids.  However, we will provide a method to move all
    ///     quest data from one character to another (but never applying to more than
    ///     on pc at a time) due to potential for character re-creation and other issues
    ///     the real world creates.

/*
    /// @brief 
    ///     `quest_pc_data` holds current and historic pc quest completion data
    ///     `quest_pc_step` holds current and historic pc quest step completion data
    ///     `quest_pc_variables` holds current and historic pc quest variable data
    /// @note These tables are held in a persistent campaign database, therefore 
    ///     all pc quest data will be persistent across module resets/restarts/
    /// @warning All of these tables are related to `quest_pc_data` via foreign keys and
    ///     will cascade delete records if a quest is deleted from `quest_pc_data`.
    ///     These tables include `quest_pc_step` and `quest_pc_variables`.
    /// @note Deleteing a quest from `quest_quests` will *NOT* delete any related
    ///     pc-specific quest data.  All data in pc-specific quest data tables is referenced
    ///     to `quest_quests` via the quest_tag field, so if the quest_tag field changes,
    ///     the link to the related pc-specific data may be lost.
    string sPCData = r"
        CREATE TABLE IF NOT EXISTS quest_pc_data (
            quest_uuid TEXT default '',
            pc_uuid TEXT default '',
            quest_tag TEXT default '',
            nStartTime INTEGER default '0',
            nCompleteTime INTEGER default '0',
            nCompleteType INTEGER default '0',
            nVersion INTEGER default '0'
        );
    ";

    string sPCStep = r"
        CREATE TABLE IF NOT EXISTS quest_pc_step (
            quest_uuid TEXT default '',
            nObjectiveType INTEGER,
            sTag TEXT default '' COLLATE NOCASE,
            sData TEXT default '' COLLATE NOCASE,
            nRequired INTEGER,
            nAcquired INTEGER default '0',
            nObjectiveID INTEGER,
            nStartTime INTEGER default '0',
            nCompleteTime INTEGER default '0',
            FOREIGN KEY (quest_uuid) REFERENCES quest_pc_data (quest_uuid)
                ON UPDATE CASCADE ON DELETE CASCADE
        );
    ";

    string sPCVariables = r"
        CREATE TABLE IF NOT EXISTS quest_pc_variables (
            quest_uuid TEXT NOT NULL default '~',
            quest_tag TEXT NOT NULL,
            nStep INTEGER NOT NULL default '0',
            sType TEXT NOT NULL,
            sName TEXT NOT NULL,
            sValue TEXT NOT NULL,
            UNIQUE (quest_tag, nStep, sType, sName) ON CONFLICT REPLACE,
            FOREIGN KEY (quest_uuid) REFERENCES quest_pc_data (quest_uuid)
                ON UPDATE CASCADE ON DELETE CASCADE
        );
    ";
*/

    if (bReset)
    {
        QuestDebug(HexColorString("Resetting", COLOR_RED_LIGHT) + " quest database tables");

        string sTable, sTables = "module,pc";
        int n, nCount = CountList(sTables);  
            for (; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            string s = r" 
                DROP TABLE IF EXISTS quest_$1;
            ";
            s = SubstituteSubString(s, "$1", sTable);

            sqlquery sql = quest_PrepareQuery(s);
            SqlStep(sql);
        }
    }

    sqlquery sql = quest_PrepareQuery(sModule); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_quests", "campaign");

    sql = quest_PrepareQuery(sPC); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_prerequisites", "campaign");
}

/// @private Retrieves the specified segment from a segment:=segment:=... series.
string quest_GetSegment(string sSegments, int nIndex = 0)
{
    string sRegex = "(?:.*?[:=]){" + _i(nIndex) + "}(.*?)(?:[:=]|$)";
    return JsonGetString(JsonArrayGet(RegExpMatch(sRegex, sSegments), 1));
}

/// @private Retrieves the key from a key[:=]value pair, or the first segment from a
///     segment series.
string quest_GetKey(string sSegments)
{
    return quest_GetSegment(sSegments);
}

/// @private Retrieves the value from a key[:=]value pair, or the nNth segment from a
///     segment series.
string quest_GetValue(string sSegments, int nNth = 1)
{
    return quest_GetSegment(sSegments, nNth);
}


void quest_ClearBuildVariables()
{
    object o = GetModule();
    DeleteLocalInt(o, QUEST_BUILD_QUEST);
    DeleteLocalInt(o, QUEST_BUILD_STEP);
    DeleteLocalInt(o, QUEST_BUILD_OBJECTIVE);
}

/// @private Clears module quest data.
void quest_OnModuleLoad()
{
    SqlStep(quest_PrepareQuery("DELETE FROM quest_module;"));
}

/// @private Compares quest versions with new data in `quest_module`
///     and updated/modified/deletes as optioned.
void quest_OnClientEnter()
{
    object o = GetEnteringObject();

    // check pc quest versions against module versions and see what to do...
}






























int GetLastInsertedID(string sTable)
{
    string s = r"
        SELECT seq 
        FROM sqlite_sequence 
        WHERE name = @sTable;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTable", sTable);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

/// @private Retrieve a quest's tag given its ID.
/// @param nID The record ID of the quest.
/// @returns The quest tag, if found, otherwise an empty string.
string quest_GetTag(int nID)
{
    string s = r"
        SELECT sTag
        FROM quest_quests
        WHERE id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

/// @private Retrieves a quest's ID given its tag.
/// @param sTag The tag of the quest.
/// @returns The quest record ID, if found, otherwise -1.
int quest_GetID(string sTag)
{
    string s = r"
        SELECT id 
        FROM quest_quests 
        WHERE sTag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

string GetQuestTimeStamp()
{
    sqlquery sql = quest_PrepareQuery("SELECT CURRENT_TIMESTAMP;");
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

int GetQuestUnixTimeStamp()
{
    sqlquery sql = quest_PrepareQuery("SELECT strftime('%s', 'now')");
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

string GetGreaterTimeStamp(string sTime1, string sTime2)
{
    string s = r"
        SELECT strftime('%s', '$1');
    ";
    s = SubstituteSubString(s, "$1", sTime1);
    
    sqlquery sql = quest_PrepareQuery(s);
    int nTime1 = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;

    s = r"
        SELECT strftime('%s', '$1');
    ";
    s = SubstituteSubString(s, "$1", sTime2);

    sql = quest_PrepareQuery(s);
    int nTime2 = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;

    return nTime1 == nTime2 ? sTime1 :
           nTime1 <  nTime2 ? sTime2 :
           nTime1 >  nTime2 ? sTime1 :
           "";
}

int GetGreaterUnixTimeStamp(int nTime1, int nTime2 = 0)
{
    if (nTime2 == 0)
        nTime2 = GetQuestUnixTimeStamp();

    if (nTime1 == nTime2 || nTime1 > nTime2)
        return nTime1;
    else
        return nTime2;
}

int GetModifiedUnixTimeStamp(int nTimeStamp, string sTimeVector)
{
    string sUnit, sUnits = "years, months, days, hours, minutes, seconds";
    string sTime, sResult;

    int n, nTime, nCount = CountList(sTimeVector);
    for (n = 0; n < nCount; n++)
    {
        sUnit = GetListItem(sUnits, n);         // units
        sTime = GetListItem(sTimeVector, n);    // time vector value
        nTime = StringToInt(sTime);

        if (nTime != 0)
        {
            if (nTime < 0)
                sTime = "-" + sTime;
            else if (nTime > 0)
                sTime = "+" + sTime;
            else
                break;

            sResult += (sResult == "" ? "" : ",") + "'" + sTime + " " + sUnit + "'";
        }
    }

    if (sResult == "")
        return nTimeStamp;

    string s = r"
        SELECT strftime('%s', datetime($1,'unixepoch', $2));
    ";
    s = SubstituteSubString(s, "$1", IntToString(nTimeStamp));
    s = SubstituteSubString(s, "$2", sResult);

    sqlquery sql = quest_PrepareQuery(s);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

string GetModifiedTimeStamp(string sTimeStamp, string sTimeVector)
{
    string sUnit, sUnits = "years, months, days, hours, minutes, seconds";
    string sTime, sResult;

    int n, nTime, nCount = CountList(sTimeVector);
    for (n = 0; n < nCount; n++)
    {
        sUnit = GetListItem(sUnits, n);         // units
        sTime = GetListItem(sTimeVector, n);    // time vector value
        nTime = StringToInt(sTime);

        if (nTime != 0)
        {
            if (nTime < 0)
                sTime = "-" + sTime;
            else if (nTime > 0)
                sTime = "+" + sTime;
            else
                break;

            sResult += (sResult == "" ? "" : ",") + "'" + sTime + " " + sUnit + "'";
        }
    }

    if (sResult == "")
        return sTimeStamp;

    string s = r"
        SELECT datetime('$1', $2);
    ";
    s = SubstituteSubString(s, "$1", sTimeStamp);
    s = SubstituteSubString(s, "$2", sResult);

    sqlquery sql = quest_PrepareQuery(s);
    SqlStep(sql);

    return SqlGetString(sql, 0);
}

/// @private Add minimal quest metadata and start quest definition process.
/// @param sTag Unique quest tag
/// @param sTitle Jounral title
/// @returns Unique quest record ID, if created, otherwise -1.
/// @note If a quest tagged with `sTag` already exists, or `sTag` is an
///     empty string, this function will fail and -1 will be returned.
int quest_AddQuest(string sTag, string sTitle)
{
    int nID = quest_GetID(sTag);
    if (nID > 0)
    {
        QuestError(quest_QuestToString(nID) + " already exists and cannot be " +
            "overwritten; use `DeleteQuest(" + sTag + ")");
        return -1;
    }

    if (sTag == "")
    {
        QuestError("Cannot add quest with empty tag");
        return -1;
    }

    string s = r"
        INSERT INTO quest_quests 
            (sTag, sJournalTitle)
        VALUES
            (@sTag, @sTitle)
        RETURNING id;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    SqlBindString(sql, "@sTitle", sTitle);
    
    nID = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
    HandleSqlDebugging(sql);

    if (nID != -1)
    {
        QuestDebug(quest_QuestToString(nID) + " has been created");
        SetLocalInt(GetModule(), QUEST_BUILD_QUEST, nID);
        DeleteLocalInt(GetModule(), QUEST_BUILD_STEP);
        DeleteLocalInt(GetModule(), QUEST_BUILD_OBJECTIVE);
    }

    return nID;
}

/// @private Add a prerequisite to the quest currently being .
/// @param nValueType QUEST_VALUE_* constant -> see quest_i_const.nss.
/// @param sKey Prerequisite key reference.
/// @param sValue Prerequisite value.
/// @warning This function is designed for use during the quest definition
///     process.  Calling this function outside of that process may have
///     unintended consequences and could cause data modification or loss.
void quest_AddPrerequisite(int nValueType, string sKey, string sValue)
{
    int nID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    string s = r"
        INSERT INTO quest_prerequisites
            (quests_id, nValueType, sKey, sValue)
        VALUES
            (@nID, @nValueType, @sKey, @sValue);
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nValueType", nValueType);
    SqlBindString(sql, "@sKey", sKey);
    SqlBindString(sql, "@sValue", sValue);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

/// @private Delete all quest primary and supporting data.
/// @param nID Quest record ID.
/// @returns Count of records deleted.
/// @warning Quest data in all related tables will also be deleted.
///     PC-specific quest data will be retained.
int quest_DeleteQuest(string sTag)
{
    int nID = quest_GetID(sTag);
    string s = r"
        DELETE FROM quest_quests
        WHERE id = @nID;
        RETURNING COUNT(*);
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);

    string s = r"
        Attempting to delete quest $1
          Result: $2 $3 deleted
    ";

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;

    json j = JsonArrayInsert(JSON_ARRAY, JsonString(sTag));
    JsonArrayInsertInplace(j, JsonInt(nCount));
    JsonArrayInsertInplace(j, JsonString(nCount == 1 ? "quest" : "quests"));

    QuestDebug(SubstituteString(s, j));
    return nCount;
}

/// @private Add a quest step to the quest currently being defined.
/// @param nValueType QUEST_VALUE_* constant -> see quest_i_const.nss.
/// @param sKey Prerequisite key reference.
/// @param sValue Prerequisite value.
/// @warning This function is designed for use during the quest definition
///     process.  Calling this function outside of that process may have
///     unintended consequences and could cause data modification or loss.
int quest_AddStep(int nStep)
{
    int nID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);
    if (nID == 0)
    {
        QuestError("AddQuestStep():  Could not add quest step, current quest ID is invalid");
        return FALSE;
    }

    if (nStep == -1)
        nStep = quest_CountSteps(nID) + 1;

    string s = r"
        INSERT INTO quest_steps
            (quests_id, nStep)
        VALUES
            (@nID, @nStep);
        RETURNING COUNT(*);
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nStep", nStep);
    
    int nResult = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    if (nResult == 0)
    {
        QuestError(StepToString(nStep) + " for " + quest_QuestToString(nID) +
            " already exists and cannot be overwritten.  Check quest definitions " +
            "to ensure the same step number is not being assigned to different " +
            "steps.");
        return -1;
    }

    SetLocalInt(GetModule(), QUEST_BUILD_STEP, nStep);
    return nStep;   
}

/// @private Determine if sField exists in sTable.
int quest_FieldExists(string sTable, string sField)
{
    string s = r"
        SELECT COUNT(*)
        FROM pragma_table_info('$1')
        WHERE name = @sField;
    ";
    s = SubstituteSubString(s, "$1", sTable);
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sField", sField);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

/// @private Sets quest data into the `quest_quests` table.
/// @param sField Field/column to set.
/// @param sValue Value to set sField to.
/// @param nID -1 if used during the quest definition process,
///     otherwise the unique record ID of the quest.
/// @param sTable Table to retrieve quest data from.
void quest_SetData(string sField, string sValue, int nID = -1, string sTable = "quest_quests")
{
    if (nID == -1)
        nID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);

    if (nID == 0)
    {
        QuestError("quest_SetQuestData():  Attempted to set quest data for invalid quest" +
            "\n  Quest ID -> " + ColorValue(_i(nID)) +
            "\n  Table    -> " + Colorvalue(sTable) +
            "\n  Field    -> " + ColorValue(sField) +
            "\n  Value    -> " + ColorValue(sValue));
        return;
    }

    if (!quest_FieldExists(sTable, sField))
    {
        QuestError("quest_SetQuestData();  Attempted to set quest data for invalid field" +
            "\n  Quest ID -> " + ColorValue(_i(nID)) +
            "\n  Table    -> " + Colorvalue(sTable) +
            "\n  Field    -> " + ColorValue(sField) +
            "\n  Value    -> " + ColorValue(sValue));
        return;
    }

    json j = JsonArrayInsert(JSON_ARRAY, JsonString(sTable));
    JsonArrayInsertInplace(j, JsonString(sField));

    string s = r"
        UPDATE $1
        SET $2 = @sValue
        WHERE id = @nID;
    ";
    s = SubstituteString(s, j);

    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sValue", sValue);
    SqlBindInt(sql, "@nID", nID);
    SqlStep(sql);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-field", _i(nQuestID), sField, "module", sValue);
}

/// @private Retrieve quest-specific data.
/// @param sTag Unique quest tag.
/// @param sField Field/column to retrive quest data from.
/// @param sTable Table to retrieve quest data from.
/// @returns Requested quest data as a string.
string quest_GetData(string sTag, string sField, string sTable = "quest_quests")
{
    int nID = quest_GetID(sTag);
    if (nID == -1)
    {
        QuestError("quest_GetQuestData():  Attempted to get quest data for invalid quest" +
            "\n  Quest ID -> " + ColorValue(_i(nID)) +
            "\n  Field    -> " + ColorValue(sField));
        return "";
    }

    if (!quest_FieldExists(sTable, sField))
    {
        QuestError("quest_GetQuestData();  Attempted to get quest data for invalid field" +
            "\n  Quest ID -> " + ColorValue(_i(nID)) +
            "\n  Field    -> " + ColorValue(sField));
        return "";
    }

    json j = JsonArrayInsert(JSON_ARRAY, JsonString(sField));
    JsonArrayInsertInplace(j, JsonString(sTable));

    string s = r"
        SELECT $1
        FROM $2
        WHERE id = @nID;
    ";
    s = SubstituteString(s, j);

    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);

    string sResult = SqlStep(sql) ? SqlGetString(sql, 0) : "";
    
    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:retrieve-field", _i(nID), sField, "module", sResult);

    return sResult;
}

/// @private Set PC-specific quest data into the `quest_pc_data` table.
/// @param oPC Player character object.
/// @param nID Unique quest record ID.
/// @param sField Field/column to set.
/// @param sValue Value to set sField to.
/// @returns Number of records updated.
/// @warning This method was designed to insert data into the most recent
///     incomplete quest related to nID; however, if there are no associated
///     incomplete quests and at least one complete quest, the data will be
///     inserted into that quest record.  To prevent unintended data modifications
///     ensure all data modification for an open quest is accomplished before the
///     quest is marked as complete.
int quest_SetPCData(object oPC, int nID, string sField, string sValue)
{
    string s = r"
        UPDATE quest_pc_data
        SET $1 = @sValue
        WHERE quest_uuid = (
            SELECT quest_uuid
            FROM quest_pc_data
            WHERE pc_uuid = @sUUID
                AND quest_tag = (
                    SELECT sTag
                    FROM quest_quests
                    WHERE id = @nID
                )
                AND nCompleteTime = 0

            UNION

            SELECT quest_uuid
            FROM quest_pc_data
            WHERE pc_uuid = @sUUID
                AND quest_tag = (
                    SELECT sTag
                    FROM quest_quests
                    WHERE id = @nID
                )
                AND nCompleteTime != 0
            
            ORDER BY nCompleteTime DESC
            LIMIT 1
        )
        RETURNING COUNT(*);
    ";
    s = SubstituteSubString(s, "$1", sField);

    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sValue", svalue);
    SqlBindString(sql, "@sUUID", GetObjectUUID(oPC));
    SqlBindInt   (sql", @nID", nID);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        HandleSqlDebugging(sql, "SQL:set-field", _i(nID), sField, PCToString(oPC), sValue);
    
    return nCount;
}

// TODO Not Used?
sqlquery quest_GetQuestPrerequisites(int nID)
{
    string s = r"
        SELECT nPropertyType, sKey, sValue
        FROM quest_prerequisites
        WHERE quests_id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);

    return sql;
}

sqlquery quest_GetPrerequisiteTypes(int nID)
{
    string s = r"
        SELECT nValueType, COUNT(sKey)
        FROM quest_prerequisites
        WHERE quests_id = @nID
        GROUP BY nValueType
        ORDER BY nValueType;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);

    return sql;
}

sqlquery quest_GetPrerequisitesByType(int nID, int nType)
{
    string s = r"
        SELECT sKey, sValue
        FROM quest_prerequisites
        WHERE quests_id = @nID
            AND nValueType = @nType;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nType", nType);

    return sql;
}

int CountActiveQuestSteps(string sTag)
{
    int nID = quest_GetID(sTag);

    string s = r"
        SELECT COUNT(*)
        FROM quest_steps
        WHERE quests_id = @nID
            AND nStepType = @nType;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nType", QUEST_STEP_TYPE_PROGRESS);

    int nSteps = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nSteps;
}

/// @private Count number of steps assigned to a given quest.
int quest_CountSteps(int nID)
{
    string s = r"
        SELECT COUNT(*)
        FROM quest_steps
        WHERE quests_id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);

    int nSteps = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nSteps;
}

/// @private Determine if a property type is stackable.
int quest_IsPropertyStackable(int nPropertyType)
{
    if (nPropertyType == QUEST_VALUE_GOLD ||
        nPropertyType == QUEST_VALUE_LEVEL_MAX ||
        nPropertyType == QUEST_VALUE_LEVEL_MIN ||
        nPropertyType == QUEST_VALUE_XP)
        return FALSE;
    else
        return TRUE;
}

int CountQuestPrerequisites(string sTag)
{
    int nID = quest_GetID(sTag);

    string s = r"
        SELECT COUNT(id)
        FROM quest_prerequisites
        WHERE quests_id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

int quest_TableExists(string sTable)
{
    string s = r"
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
            AND name = @sTable;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTable", sTable);
    return SqlStep(sql);
}

int quest_CountPCVariables(object oPC, string sTag)
{
    string s = r"
        SELECT COUNT(*)
        FROM quest_pc_variables
        WHERE quest_uuid = (
            SELECT quest_uuid
            FROM quest_pc_data
            WHERE pc_uuid = @sUUID
                AND quest_tag = (
                    SELECT sTag
                    FROM quest_quests
                    WHERE id = @nID
                )
            ORDER BY ...
        );
    ";
}

int CountQuestVariables(object oTarget, string sTable)
{
    string s = r"
        SELECT COUNT(*) 
        FROM $1;
    ";
    s = SubstituteSubString(s, "$1", sTable);
    
    sqlquery sql = quest_PrepareQuery(s);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int quest_Exists(string sTag)
{
    string s = r"
        SELECT COUNT(id)
        FROM quest_quests
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;    
}

int quest_HasMinimumSteps(int nID)
{
    string s = r"
        SELECT COUNT(id) FROM quest_steps
        WHERE quests_id = @nID
            AND nStepType != @nType;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nType", QUEST_STEP_TYPE_PROGRESS);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int quest_GetStepID(int nID, int nStep)
{
    string s = r"
        SELECT id FROM quest_steps
        WHERE quests_id = @nID
            AND nStep = @nStep;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nStep", nStep);

    int nID = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nID;
}

sqlquery GetQuestStepPropertySets(int nID, int nStep, int nCategoryType)
{
    string s = r"
        SELECT nValueType, sKey, sValue, sData, bParty
        FROM quest_step_properties
        WHERE nCategoryType = @nCategoryType
            AND quest_steps_id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nCategoryType", nCategoryType);
    SqlBindInt(sql, "@nID", quest_GetStepID(nID, nStep));

    return sql;
}

sqlquery GetQuestStepPropertyPairs(int nID, int nStep, int nCategoryType, int nValueType)
{
    string s = r"
        SELECT quest_step_properties.sKey,
            quest_step_properties.sValue,
            quest_step_properties.sData
        FROM quest_steps 
            INNER JOIN quest_step_properties
                ON quest_steps.id = quest_step_properties.quest_steps_id
        WHERE quest_steps.id = @nID
            AND quest_steps.nStep = @nStep
            AND quest_step_properties.nCategoryType = @nCategoryType
            AND quest_step_properties.nValueType = @nValueType;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindInt(sql, "@nCategoryType", nCategoryType);
    SqlBindInt(sql, "@nValueType", nValueType);

    return sql;
}

void DeleteQuestStepPropertyPair(int nID, int nStep, int nCategoryType, int nValueType)
{
    string s = r"
        DELETE FROM quest_step_properties
        WHERE nCategoryType = @nCategoryType
            AND nValueType = @nValueType
            AND quest_steps_id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nCategoryType", nCategoryType);
    SqlBindInt(sql, "@nValueType", nValueType);
    SqlBindInt(sql, "@nID", quest_GetStepID(nID, nStep));

    SqlStep(sql);
    HandleSqlDebugging(sql);
}

string GetQuestStepPropertyValue(int nID, int nStep, int nCategoryType, int nValueType)
{
    string s = r"
        SELECT sValue
        FROM quest_step_properties
        WHERE quest_steps_id = @nID
            AND nCategoryType = @nCategoryType
            AND nValueType = @nValueType;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", quest_GetStepID(nID, nStep));
    SqlBindInt(sql, "@nCategoryType", nCategoryType);
    SqlBindInt(sql, "@nValueType", nValueType);

    string sValue = SqlStep(sql) ? SqlGetString(sql, 0) : "";
    HandleSqlDebugging(sql);
    return sValue;
}

sqlquery GetQuestStepObjectiveData(int nID, int nStep)
{
    string s = r"
        SELECT quest_step_properties.id,
            quest_step_properties.nValueType,
            quest_step_properties.sKey,
            quest_step_properties.sValue,
            quest_step_properties.sValueMax,
            quest_step_properties.sData
        FROM quest_steps INNER JOIN quest_step_properties
            ON quest_steps.id = quest_step_properties.quest_steps_id
        WHERE quest_step_properties.nCategoryType = @nCategoryType
            AND quest_steps.nStep = @nStep
            AND quest_steps.quests_id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nCategoryType", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindInt(sql, "@nID", nID);

    return sql;
}

sqlquery GetRandomQuestStepObjectiveData(int nID, int nStep, int nRecords)
{
    string s = r"
        SELECT quest_step_properties.id,
            quest_step_properties.nValueType,
            quest_step_properties.sKey,
            quest_step_properties.sValue,
            quest_step_properties.sValueMax,
            quest_step_properties.sData
        FROM quest_steps INNER JOIN quest_step_properties
            ON quest_steps.id = quest_step_properties.quest_steps_id
        WHERE quest_step_properties.nCategoryType = @nCategoryType
            AND quest_steps.nStep = @nStep
            AND quest_steps.quests_id = @nID
        ORDER BY RANDOM() LIMIT $1;
    ";
    s = SubstituteSubString(s, "$1", IntToString(nRecords));

    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nCategoryType", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindInt(sql, "@nID", nID);

    return sql;
}

int GetQuestStepObjectiveType(int nID, int nStep)
{
    string s = r"
        SELECT quest_step_properties.nValueType
        FROM quest_steps INNER JOIN quest_step_properties
            ON quest_steps.id = quest_step_properties.quest_steps_id
        WHERE quest_step_properties.nCategoryType = @nCategoryType
            AND quest_steps.nStep = @nStep
            AND quest_steps.quests_id = @nID
        LIMIT 1;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nCategoryType", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@stnStepep", nStep);
    SqlBindInt(sql, "@nID", nID);

    int nType = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nType;
}

int CountQuestStepObjectives(int nID, int nStep)
{
    string s = r"
        SELECT COUNT(quest_steps_id)
        FROM quest_step_properties
        WHERE nCategoryType = @nCategoryType
            AND quest_steps_id = @nID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nCategoryType", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@nID", quest_GetStepID(nID, nStep));
    
    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

/// @private Assign the quest associated with nID to oPC.
string quest_Assign(object oPC, int nID)
{
    string s = r"
        INSERT INTO quest_pc_data 
            (quest_uuid, pc_uuid, quest_tag)
        VALUES 
            (@sQuestUUID, @sPCUUID, 
                (SELECT sTag
                FROM quest_quests
                WHERE id = @nID)
            );
        RETURNING quest_uuid;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sQuestUUID", GetRandomUUID());
    SqlBindString(sql, "@sPCUUID", GetObjectUUID(oPC));
    SqlBindInt   (sql, "@nID", nID);
    
    string sUUID = SqlStep(sql) ? SqlGetString(sql, 0) : "";
    HandleSqlDebugging(sql);

    return sUUID;
}

/// @private Set PC-specific quest data by reference to the
///     quest UUID.
/// @return Count of rows updated.
int quest_SetPCDataByUUID(object oPC, string sUUID, string sField, string sValue)
{
    string s = r"
        UPDATE quest_pc_data
        SET $1 = @sValue
        WHERE quest_uuid = @sUUID
            AND pc_uuid = @sPCUUID
        RETURNING COUNT(*);
    ";
    s = SubstituteSubString(s, "$1", sField);
    
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sValue", sValue);
    SqlBindString(sql, "@sUUID", sUUID);
    SqlBindString(sql, "@sPCUUID", GetObjectUUID(oPC));

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

void DeletePCQuest(object oPC, int nID)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        DELETE FROM quest_pc_data 
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int quest_CountQuests(object oPC, string sTag)
{
    string s = r"
        SELECT COUNT(quest_tag)
        FROM quest_pc_data
        WHERE quest_tag = @sTag
            AND pc_uuid = @sUUID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    SqlBindString(sql, "@sUUID", GetObjectUUID(oPC));
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int quest_HasQuest(object oPC, string sTag)
{
    return quest_CountQuests(oPC, sTag) > 0;
}

int quest_IsAssigned(object oPC, string sTag)
{

    return TRUE;
}

int GetPCHasQuest(object oPC, string sTag)
{
    string s = r"
        SELECT COUNT(quest_tag)
        FROM quest_pc_data
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    
    int nHas = SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
    HandleSqlDebugging(sql);

    return nHas;
}

string quest_GetUUID(object oPC, string sTag)
{
    string s = r"
        SELECT quest_uuid
        FROM quest_pc_data
        WHERE pc_uuid = @sUUID
            AND quest_tag = @sTag
            AND nCompleteTime = 0;
    ";

    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sUUID", GetObjectID(oPC));
    SqlBindString(sql, "@sTag", sTag);

    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

int quest_IsComplete(object oPC, string sTag)
{
    string s = r"
        SELECT COUNT(*)
        FROM quest_pc_step
        WHERE pc_uuid = @sUUID
            AND quest_tag = @sTag
            AND nCompleteTime != 0;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    SqlBindString(sql, "@sUUID", GetObjectUUID(oPC));

    int nComplete = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return !nComplete;
}

int GetPCHasQuestAssigned(object oPC, string sTag)
{
    return GetPCHasQuest(oPC, sTag) && !quest_IsComplete(oPC, sTag);
}

int quest_CountCompletions(object oPC, string sTag)
{
    string s = r"
        SELECT COUNT(quest_uuid)
        FROM quest_pc_data
        WHERE pc_uuid = @sUUID
            AND quest_tag = @sTag
            AND nCompleteTime != 0;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    SqlBindString(sql, "@sUUID", GetObjectUUID(oPC));

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

int quest_CountCompletionsByType(object oPC, string sTag, int nType)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        SELECT COUNT(quest_uuid)
        FROM quest_pc_data
        WHERE pc_uuid = @sUUID
            AND quest_tag = @sTag
            AND nCompleteTime != 0
            AND nCompleteType = @nType;
    ";
    sqlquery sql = query_PrepareQuery(s);
    SqlBindString(sql, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(sql, "@sTag", sTag);
    SqlBindInt(sql, "@nType", nType);

    int nCompletions = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCompletions;
}

void quest_SetComplete(object oPC, int nID, int nType)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        UPDATE quest_pc_data
        SET nCompleteTime = strftime('%s', 'now')
            nCompleteType = @nType
        WHERE quest_uuid = @sUUID;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nType", nType);
    SqlBindString(sql, "@sUUID", quest_GetUUID(oPC, sTag));
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

sqlquery GetStepObjectivesByTarget(object oPC, string sTargetTag)
{
    string s = r"
        SELECT quest_pc_step.sTag,
            quest_pc_data.quest_tag,
            quest_pc_data.nStep
        FROM quest_pc_data INNER JOIN quest_pc_step
            ON quest_pc_data.quest_tag = quest_pc_step.quest_tag
        WHERE quest_pc_step.sTag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTargetTag);

    return sql;
}

sqlquery GetTargetQuestData(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        SELECT quest_pc_data.quest_tag,
            quest_pc_data.nStep
        FROM quest_pc_data INNER JOIN quest_pc_step
            ON quest_pc_data.quest_tag = quest_pc_step.quest_tag
        WHERE quest_pc_step.nObjectiveType = @nObjectiveType
            AND quest_pc_step.sTag = @sTag
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND quest_pc_step.sData = @sData");

    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    SqlBindString(sql, "@sTag", sTargetTag);
    if (sData != "") SqlBindString(sql, "@sData", sData);

    return sql;
}

sqlquery GetPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        SELECT quest_tag, nObjectiveID, nRequired, nAcquired
        FROM quest_pc_step
        WHERE sTag = @sTag
            AND nObjectiveType = @nObjectiveType
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @sData");
    
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@target_tag", sTargetTag);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@sData", sData);

    return sql;
}

int CountPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        SELECT COUNT(quest_tag) FROM quest_pc_step
        WHERE sTag = @sTag
            AND nObjectiveType = @nObjectiveType
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @sData");
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTargetTag);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@sData", sData);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

//void IncrementQuestStepQuantity(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
int IncrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = nAcquired + 1
        WHERE nObjectiveType = @nObjectiveType
            AND sTag = @sTag
            AND nAcquired < nRequired
            AND nCompleteTime == 0
            $1
        RETURNING COUNT(*);
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @sData");
    
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    SqlBindString(sql, "@sTag", sTargetTag);
    if (sData != "") SqlBindString(sql, "@sData", sData);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

int IncrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = nAcquired + 1
        WHERE nObjectiveType = @nObjectiveType
            AND quest_tag = @sQuestTag
            AND sTag = @sTargetTag
            $1
        RETURNING COUNT(*);
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @sData");

    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    SqlBindString(sql, "@sTargetTag", sTargetTag);
    SqlBindString(sql, "@sQuestTag", sQuestTag);
    if (sData != "") SqlBindString(sql, "@sData", sData);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

int DecrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = max(0, nAcquired - 1)
        WHERE nObjectiveType = @nObjectiveType
            AND sTag = @sTag
            $1
        RETURNING COUNT(*);
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @sData");
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    SqlBindString(sql, "@sTag", sTargetTag);
    if (sData != "") SqlBindString(sql, "@sData", sData);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

void DecrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = max(0, nAcquired - 1)
        WHERE nObjectiveType = @nObjectiveType
            AND sTag = @sTargetTag
            AND quest_tag = @sQuestTag
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @sData");
    
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    SqlBindString(sql, "@sTargetTag", sTargetTag);
    SqlBindString(sql, "@sQuestTag", sQuestTag);
    if (sData != "") SqlBindString(sql, "@sData", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);
}

int CountPCStepObjectivesCompleted(object oPC, int nID, int nStep)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        SELECT COUNT(quest_tag)
        FROM quest_pc_step
        WHERE quest_tag = @sTag
            AND nAcquired >= nRequired;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    
    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

sqlquery GetQuestStepSums(object oPC, int nID)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        SELECT quest_tag, SUM(nRequired), SUM(nAcquired)
        FROM quest_pc_step
        WHERE quest_tag = @sTag
            AND nRequired > 0
        GROUP BY quest_tag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    return sql;
}

sqlquery GetQuestStepSumsFailure(object oPC, int nID)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        SELECT quest_tag, SUM(nRequired), SUM(nAcquired)
        FROM quest_pc_step
        WHERE quest_tag = @sTag
            AND nRequired <= 0
        GROUP BY quest_tag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    return sql;
}

void DeletePCQuestProgress(object oPC, int nID)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        DELETE FROM quest_pc_step
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetPCQuestStep(object oPC, string sTag)
{
    string s = r"
        SELECT nStep
        FROM quest_pc_data
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);

    int nStep = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
    HandleSqlDebugging(sql);

    return nStep;
}

int GetNextPCQuestStep(object oPC, string sTag)
{
    int nID = quest_GetID(sTag);
    int nStep = GetPCQuestStep(oPC, sTag);

    string s = r"
        SELECT nStep FROM quest_steps
        WHERE quests_id = @nID
            AND nStep > @nStep
            AND nStepType = @nStepType
        ORDER BY nStep ASC LIMIT 1;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindInt(sql, "@nStepType", QUEST_STEP_TYPE_PROGRESS);

    nStep = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
    HandleSqlDebugging(sql);
    return nStep;
}

sqlquery GetPCQuestData(object oPC, string sTag = "")
{
    string s = r"
        SELECT quest_tag, nStep, nCompletions, nFailures, nLastCompleteType
        FROM quest_pc_data
        $1;
    ";
    s = SubstituteSubString(s, "$1", sTag == "" ? "" : "WHERE quest_tag = @sTag");
    sqlquery sql = quest_PrepareQuery(s);
    if (sTag != "") SqlBindString(sql, "@sTag", sTag);

    return sql;
}

sqlquery GetPCQuestStepData(object oPC, string sTag)
{
    string s = r"
        SELECT quest_tag, nObjectiveType, sTag, sData,
            nRequired, nAcquired, nObjectiveID
        FROM quest_pc_step
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);

    return sql;
}

void AddQuestStepObjectiveData(object oPC, int nID, int nObjectiveType, 
                               string sTargetTag, int nQuantity, int nObjectiveID,
                               string sData = "")
{
    string sTag = quest_GetTag(nID);
    string s = r"
        INSERT INTO quest_pc_step 
            (quest_tag, nObjectiveType, sTag, sData, nRequired, nObjectiveID)
        VALUES 
            (@sQuestTag, @nObjectiveType, @sTargetTag, @sData, @nQuantity, @nObjectiveID);
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sQuestTag", sTag);
    SqlBindInt(sql, "@nObjectiveType", nObjectiveType);
    SqlBindString(sql, "@sTargetTag", sTargetTag);
    SqlBindInt(sql, "@nQuantity", nQuantity);
    SqlBindString(sql, "@sData", sData);
    SqlBindInt(sql, "@nObjectiveID", nObjectiveID);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetQuestCompletionStep(int nID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    string s = r"
        SELECT nStep FROM quest_steps
        WHERE quests_id = @nID
            AND nStepType = @nStepType;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindInt(sql, "@nID", nID);
    SqlBindInt(sql, "@nStepType", nRequestType == QUEST_ADVANCE_SUCCESS ? 
                                                  QUEST_STEP_TYPE_SUCCESS :
                                                  QUEST_STEP_TYPE_FAIL);

    int nStep = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
    HandleSqlDebugging(sql);
    return nStep;
}

int GetPCQuestStepAcquired(object oPC, int nID)
{
    string sTag = quest_GetTag(nID);
    string s = r"
        SELECT nAcquired
        FROM quest_pc_step
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);
    
    int nStep = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
    HandleSqlDebugging(sql);
    return nStep;
}

void UpdatePCQuestTables(object oPC)
{
/*
    // First update @ 1.0.2 -- adding an nLastCompleteType column to update journal
    // entries OnClientEnter (this is a work around for the bug that prevents journal
    // integers from persistently saving in the base game, possibly introduced in 
    // .14).  https://github.com/Beamdog/nwn-issues/issues/258

    // The purpose of this new column is to know whether the last completion was a
    // success of failure in order to determine which journal entry to show since this
    // system allows for an entry for both types.

    sQuery = "SELECT nLastCompleteType " +
             "FROM quest_pc_data;";
    sql = quest_PrepareQuery(sQuery);
    SqlStep(sql);

    string sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_data " +
                 "ADD COLUMN nLastCompleteType INTEGER default '0';";
        sql = quest_PrepareQuery(sQuery);
        SqlStep(sql);

        sError = SqlGetError(sql);
        if (sError == "")
            QuestDebug("Stale quest table found on " + PCToString(oPC) + "; " +
                "table definition updated to 1.0.2 (add nLastCompleteType column)");
        else
            Notice("Error: " + sError);
    }

    // End update @ 1.0.2

    // Update @ 1.1.1 -- adding a nQuestVersion column to allow cleaning quest tables
    // when a quest version is updated.

    sQuery = "SELECT nQuestVersion " +
             "FROM quest_pc_data;";
    sql = quest_PrepareQuery(sQuery);
    SqlStep(sql);

    sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_data " +
                 "ADD COLUMN nQuestVersion INTEGER default '0';";
        sql = quest_PrepareQuery(sQuery);
        SqlStep(sql);

        sError = SqlGetError(sql);
        if (sError == "")
            QuestDebug("Stale quest table found on " + PCToString(oPC) + "; " +
                "table definition updated to 1.1.1 (add nQuestVersion column)");
        else
            Notice("Error: " + sError);
    }

    // Ensure we're not wiping everyone's quest data, so update to the latest version of the
    // quest as a default, since this is still early in the process.

    // End update @ 1.1.1

    // Update @ 1.1.4 -- adding nObjectiveID column to allow for partial step completion
    // feedback.

    sQuery = "SELECT nObjectiveID " +
             "FROM quest_pc_step;";
    sql = quest_PrepareQuery(sQuery);
    SqlStep(sql);

    sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_step " +
                 "ADD COLUMN nObjectiveID INTEGER default '0';";
        sql = quest_PrepareQuery(sQuery);
        SqlStep(sql);

        sError = SqlGetError(sql);
        if (sError == "")
            QuestDebug("Stale quest step table found on " + PCToString(oPC) + "; " +
                "table definition updated to 1.1.4 (add nObjectiveID column)");
        else
            Notice("Error: " + sError);
    }

    // End update @ 1.1.4

    // Update @ 1.1.5 -- workaround for weird case of missing `nFailures` column from
    // early in the testing process.

    sQuery = "SELECT nFailures " +
             "FROM quest_pc_data;";
    sql = quest_PrepareQuery(sQuery);
    SqlStep(sql);

    sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_data " +
                 "ADD COLUMN nFailures INTEGER default '0';";
        sql = quest_PrepareQuery(sQuery);
        SqlStep(sql);

        sError = SqlGetError(sql);
        if (sError == "")
            QuestDebug("Stale quest data table found on " + PCToString(oPC) + "; " +
                "table definition updated to 1.1.5 (add nFailures column)");
        else
            Notice("Error: " + sError);
    }

    // End update @ 1.1.5
*/
}
