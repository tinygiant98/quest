/// ----------------------------------------------------------------------------
/// @file   quest_i_database.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Quest System (database)
/// ----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_strings"

#include "quest_i_const"
#include "quest_i_debug"

void CreateModuleQuestTables(int bReset = FALSE)
{
    string sQuests = r"
        CREATE TABLE IF NOT EXISTS quest_quests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sTag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE,
            nActive TEXT NOT NULL default '1',
            sJournalTitle TEXT default NULL,
            nRepetitions TEXT default '1',
            sScriptOnAssign TEXT default NULL,
            sScriptOnAccept TEXT default NULL,
            sScriptOnAdvance TEXT default NULL,
            sScriptOnComplete TEXT default NULL, 
            sScriptOnFail TEXT default NULL,
            sTimeLimit TEXT default NULL,
            sCooldown TEXT default NULL,
            nJournalHandler TEXT default NULL,
            nRemoveJournalOnComplete TEXT default '0',
            nAllowPrecollectedItems TEXT default '1',
            nRemoveQuestOnCompleted TEXT default '0',
            nQuestVersion TEXT default '0',
            nQuestVersionAction TEXT default '0'
        );
    ";

    string sQuestPrerequisites = r"
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

    string sQuestSteps = r"
        CREATE TABLE IF NOT EXISTS quest_steps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quests_id INTEGER NOT NULL default '0',
            nStep INTEGER NOT NULL default '0',
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

    string sQuestStepProperties = r"
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

    string sPCData = r"
        CREATE TABLE IF NOT EXISTS quest_pc_data (
            quest_uuid TEXT default '',
            pc_uuid TEXT default '',
            quest_tag TEXT default '',
            nStep INTEGER default '0',
            nAttempts INTEGER default '0',
            nCompletions INTEGER default '0',
            nFailures INTEGER default '0',
            nQuestStartTime INTEGER default '0',
            nStepStartTime INTEGER default '0',
            nLastCompleteTime INTEGER default '0',
            nLastCompleteType INTEGER default '0',
            nQuestVersion INTEGER default '0'
        );
    ";

    string sPCStep = r"
        CREATE TABLE IF NOT EXISTS quest_pc_step (
            quest_uuid TEXT default '',
            quest_tag TEXT,
            nObjectiveType INTEGER,
            sTag TEXT default '' COLLATE NOCASE,
            sData TEXT default '' COLLATE NOCASE,
            nRequired INTEGER,
            nAcquired INTEGER default '0',
            nObjectiveID INTEGER,
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

    if (bReset)
    {
        QuestDebug(HexColorString("Resetting", COLOR_RED_LIGHT) + " quest database tables for the module");

        string sTable, sTables = "quests,prerequisites,steps,step_properties,pc_data,pc_step,pc_variables";
        int n, nCount = CountList(sTables);  
            for (; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            string s = r" 
                DROP TABLE IF EXISTS quest_$1;
            ";
            s = SubstituteSubString(s, "$1", sTable);

            sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
            SqlStep(sql);
        }
    }

    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuests); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_quests", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestPrerequisites); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_prerequisites", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestSteps); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_steps", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestStepProperties); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_step_properties", "module");

    sql = SqlPrepareQueryCampaign(QUEST_DATABASE, sPCData); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_pc_data", "campaign");

    sql = SqlPrepareQueryCampaign(QUEST_DATABASE, sPCStep); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_pc_step", "campaign");

    sql = SqlPrepareQueryCampaign(QUEST_DATABASE, sPCVariables); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_pc_variables", "campaign");
}

int GetLastInsertedID(string sTable)
{
    string s = r"
        SELECT seq 
        FROM sqlite_sequence 
        WHERE name = @name;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindString(sql, "@name", sTable);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

string GetQuestTag(int nQuestID)
{
    string s = r"
        SELECT sTag FROM quest_quests
        WHERE id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nQuestID);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

int CountRowChanges(object oTarget)
{
    sqlquery sql = SqlPrepareQueryObject(oTarget, "SELECT CHANGES();");
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

string GetQuestTimeStamp()
{
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "SELECT CURRENT_TIMESTAMP;");
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

int GetQuestUnixTimeStamp()
{
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "SELECT strftime('%s', 'now')");
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

string GetGreaterTimeStamp(string sTime1, string sTime2)
{
    string s = r"
        SELECT strftime('%s', '$1');
    ";
    s = SubstituteSubString(s, "$1", sTime1);
    
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    int nTime1 = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;

    s = r"
        SELECT strftime('%s', '$1');
    ";
    s = SubstituteSubString(s, "$1", sTime2);

    sql = SqlPrepareQueryObject(GetModule(), s);
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

    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
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

    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlStep(sql);

    return SqlGetString(sql, 0);
}

string QuestToString(int nQuestID, string sQuestTag = "")
{
    string sTag = (sQuestTag == "" ? _GetQuestTag(nQuestID) : sQuestTag);

    if (sTag == "")
        return "[NOT FOUND]";

    return HexColorString(sTag + " (ID " + IntToString(nQuestID) + ")", COLOR_ORANGE_LIGHT);
}

int GetQuestID(string sTag)
{
    string s = "SELECT id FROM quest_quests WHERE sTag = @sTag;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindString(sql, "@sTag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

void AddQuestPrerequisite(int nValueType, string sKey, string sValue)
{
    int nQuestID = GetLocalInt(GetModule(), QUEST_BUILD_QUEST);

    string s = r"
        INSERT INTO quest_prerequisites (quests_id, nValueType, sKey, sValue)
        VALUES (@quests_id, @nValueType, @key, @sValue);
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@quests_id", nQuestID);
    SqlBindInt(sql, "@nValueType", nValueType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@sValue", sValue);

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int _AddQuest(string sQuestTag, string sJournalTitle)
{
    string s = r"
        INSERT INTO quest_quests (sTag, sJournalTitle)
        VALUES (@sTag, @sTitle);
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindString(sql, "@sTag", sQuestTag);
    SqlBindString(sql, "@sTitle", sJournalTitle);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return GetLastInsertedID("quest_quests");
}

void _DeleteQuest(int nQuestID)
{
    string s = r"
        DELETE FROM quest_quests
        WHERE id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nQuestID);
    SqlStep(sql);                
}

void _AddQuestStep(int nID, int nStep)
{
    string s = r"
        INSERT INTO quest_steps (quests_id, nStep)
        VALUES (@quests_id, @nStep);
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@quests_id", nID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlStep(sql);

    HandleSqlDebugging(sql);

    if (CountRowChanges(GetModule()) == 0)
        QuestError(StepToString(nStep) + " for " + QuestToString(nID) +
            " already exists and cannot be overwritten.  Check quest definitions " +
            "to ensure the same step number is not being assigned to different " +
            "steps.");
}

sqlquery GetQuestPrerequisites(int nID)
{
    string s = r"
        SELECT nPropertyType, sKey, sValue
        FROM quest_prerequisites
        WHERE quests_id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);

    return sql;
}

sqlquery GetQuestPrerequisiteTypes(int nID)
{
    string s = r"
        SELECT nValueType, COUNT(sKey)
        FROM quest_prerequisites
        WHERE quests_id = @id
        GROUP BY nValueType
        ORDER BY nValueType;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);

    return sql;
}

sqlquery GetQuestPrerequisitesByType(int nID, int nType)
{
    string s = r"
        SELECT sKey, sValue
        FROM quest_prerequisites
        WHERE quests_id = @id
            AND nValueType = @type;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);
    SqlBindInt(sql, "@type", nType);

    return sql;
}

int GetIsQuestActive(int nID)
{
    string s = r"
        SELECT nActive
        FROM quest_quests
        WHERE id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);

    int nActive = SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
    HandleSqlDebugging(sql);

    return nActive;
}

int CountActiveQuestSteps(string sTag)
{
    int nID = GetQuestID(sTag);

    string s = r"
        SELECT COUNT(*)
        FROM quest_steps
        WHERE quests_id = @id
            AND nStepType = @type;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_PROGRESS);

    int nSteps = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nSteps;
}

int CountAllQuestSteps(int nID)
{
    string s = r"
        SELECT COUNT(*)
        FROM quest_steps
        WHERE quests_id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);

    int nSteps = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nSteps;
}

int CountQuestPrerequisites(string sTag)
{
    int nID = GetQuestID(sTag);

    string s = r"
        SELECT COUNT(id)
        FROM quest_prerequisites
        WHERE quests_id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

sqlquery GetQuestData(int nID)
{
    string s = r"
        SELECT * 
        FROM quest_quests 
        WHERE id = @nID;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@nID", nID);

    return sql;
}

sqlquery GetQuestProperties(int nID)
{
    string s = r"
        SELECT * 
        FROM quest_properties 
        WHERE quest_id = @nID;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@nID", nID);

    return sql;
}

int GetTableExists(object oTarget, string sTable)
{
    string s = r"
        SELECT name FROM sqlite_master
        WHERE type = 'table'
            AND name = @table;
    ";
    sqlquery sql = SqlPrepareQueryObject(oTarget, s);
    SqlBindString(sql, "@table", sTable);
    return SqlStep(sql);
}

int CountQuestVariables(object oTarget, string sTable)
{
    string s = "SELECT COUNT(*) FROM " + sTable + ";";
    sqlquery sql = SqlPrepareQueryObject(oTarget, s);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int GetQuestExists(string sTag)
{
    string s = r"
        SELECT COUNT(id)
        FROM quest_quests
        WHERE sTag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindString(sql, "@tag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int GetQuestHasMinimumNumberOfSteps(int nID)
{
    string s = r"
        SELECT COUNT(id) FROM quest_steps
        WHERE quests_id = @id
            AND nStepType != @type;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_PROGRESS);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int GetQuestStepID(int nID, int nStep)
{
    string s = r"
        SELECT id FROM quest_steps
        WHERE quests_id = @id
            AND nStep = @step;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nID);
    SqlBindInt(sql, "@step", nStep);

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
            AND quest_steps_id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@nCategoryType", nCategoryType);
    SqlBindInt(sql, "@id", GetQuestStepID(nID, nStep));

    return sql;
}

sqlquery GetQuestStepPropertyPairs(int nID, int nStep, int nCategoryType, int nValueType)
{
    string s = r"
        SELECT quest_step_properties.sKey,
            quest_step_properties.sValue,
            quest_step_properties.sData
        FROM quest_steps INNER JOIN quest_step_properties
        ON quest_steps.id = quest_step_properties.quest_steps_id
        WHERE quest_steps.id = @nID
            AND quest_steps.nStep = @nStep
            AND quest_step_properties.nCategoryType = @nCategoryType
            AND quest_step_properties.nValueType = @nValueType;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
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
            AND quest_steps_id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@nCategoryType", nCategoryType);
    SqlBindInt(sql, "@nValueType", nValueType);
    SqlBindInt(sql, "@id", GetQuestStepID(nID, nStep));

    SqlStep(sql);
    HandleSqlDebugging(sql);
}

string GetQuestStepPropertyValue(int nID, int nStep, int nCategoryType, int nValueType)
{
    string s = r"
        SELECT sValue
        FROM quest_step_properties
        WHERE quest_steps_id = @id
            AND nCategoryType = @nCategoryType
            AND nValueType = @nValueType;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", GetQuestStepID(nID, nStep));
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
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
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
        WHERE quest_step_properties.nCategoryType = @category
            AND quest_steps.nStep = @step
            AND quest_steps.quests_id = @id
        ORDER BY RANDOM() LIMIT $1;
    ";
    s = SubstituteSubString(s, "$1", IntToString(nRecords));

    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nID);

    return sql;
}

int GetQuestStepObjectiveType(int nID, int nStep)
{
    string s = r"
        SELECT quest_step_properties.nValueType
        FROM quest_steps INNER JOIN quest_step_properties
            ON quest_steps.id = quest_step_properties.quest_steps_id
        WHERE quest_step_properties.nCategoryType = @category
            AND quest_steps.nStep = @step
            AND quest_steps.quests_id = @id
        LIMIT 1;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nID);

    int nType = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nType;
}

int CountQuestStepObjectives(int nID, int nStep)
{
    string s = r"
        SELECT COUNT(quest_steps_id)
        FROM quest_step_properties
        WHERE nCategoryType = @category
            AND quest_steps_id = @id;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@id", GetQuestStepID(nID, nStep));
    
    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

void _AddQuestToPC(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        INSERT INTO quest_pc_data (quest_tag)
        VALUES (@tag);
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

void DeletePCQuest(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        DELETE FROM quest_pc_data 
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetPCHasQuest(object oPC, string sQuestTag)
{
    string s = r"
        SELECT COUNT(quest_tag)
        FROM quest_pc_data
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    
    int nHas = SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
    HandleSqlDebugging(sql);

    return nHas;
}

int GetIsPCQuestComplete(object oPC, string sQuestTag)
{
    string s = r"
        SELECT COUNT(*)
        FROM quest_pc_step
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);

    int nComplete = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return !nComplete;
}

int GetPCHasQuestAssigned(object oPC, string sQuestTag)
{
    return GetPCHasQuest(oPC, sQuestTag) && !GetIsPCQuestComplete(oPC, sQuestTag);
}

int GetPCQuestCompletions(object oPC, string sQuestTag)
{
    string s = r"
        SELECT nCompletions
        FROM quest_pc_data
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

int GetPCQuestFailures(object oPC, string sQuestTag)
{
    string s = r"
        SELECT nFailures
        FROM quest_pc_data
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);

    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

void ResetPCQuestData(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        UPDATE quest_pc_data
        SET nStep = @step,
            nQuestStartTime = @quest_start,
            nStepStartTime = @step_start
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@step", 0);
    SqlBindInt(sql, "@quest_start", 0);
    SqlBindInt(sql, "@step_start", 0);
    SqlStep(sql);
    HandleSqlDebugging(sql);
}

void IncrementPCQuestField(object oPC, int nQuestID, string sField)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        UPDATE quest_pc_data 
        SET $1 = $1 + 1
        WHERE quest_tag = @tag;
    ";
    s = SubstituteSubStrings(s, "$1", sField);

    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

void IncrementPCQuestCompletions(object oPC, int nQuestID, int nTimeStamp)
{
    ResetPCQuestData(oPC, nQuestID);

    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        UPDATE quest_pc_data
        SET nCompletions = nCompletions + 1,
            nLastCompleteTime = @time,
            nLastCompleteType = @type
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@time", nTimeStamp);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_SUCCESS);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

void IncrementPCQuestFailures(object oPC, int nQuestID, int nTimeStamp)
{
    ResetPCQuestData(oPC, nQuestID);

    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        UPDATE quest_pc_data
        SET nFailures = nFailures + 1,
            nLastCompleteTime = @time
            nLastCompleteType = @type
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@time", nTimeStamp);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_FAIL);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

sqlquery GetStepObjectivesByTarget(object oPC, string sTarget)
{
    string s = r"
        SELECT quest_pc_step.sTag,
            quest_pc_data.quest_tag,
            quest_pc_data.nStep
        FROM quest_pc_data INNER JOIN quest_pc_step
            ON quest_pc_data.quest_tag = quest_pc_step.quest_tag
        WHERE quest_pc_step.sTag = @target;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@target", sTarget);

    return sql;
}

sqlquery GetTargetQuestData(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        SELECT quest_pc_data.quest_tag,
            quest_pc_data.nStep
        FROM quest_pc_data INNER JOIN quest_pc_step
            ON quest_pc_data.quest_tag = quest_pc_step.quest_tag
        WHERE quest_pc_step.nObjectiveType = @type
            AND quest_pc_step.sTag = @tag
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND quest_pc_step.sData = @data");

    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    if (sData != "") SqlBindString(sql, "@data", sData);

    return sql;
}

sqlquery GetPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        SELECT quest_tag, nObjectiveID, nRequired, nAcquired
        FROM quest_pc_step
        WHERE sTag = @target_tag
            AND nObjectiveType = @objective_type
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @data");
    
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@target_tag", sTargetTag);
    SqlBindInt(sql, "@objective_type", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@data", sData);

    return sql;
}

int CountPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        SELECT COUNT(quest_tag) FROM quest_pc_step
        WHERE sTag = @target_tag
            AND nObjectiveType = @objective_type
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @data");
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@target_tag", sTargetTag);
    SqlBindInt(sql, "@objective_type", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@data", sData);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

//void IncrementQuestStepQuantity(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
int IncrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = nAcquired + 1
        WHERE nObjectiveType = @type
            AND sTag = @tag
            AND nAcquired < nRequired
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @data");
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    if (sData != "") SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return CountRowChanges(oPC);
}

int IncrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = nAcquired + 1
        WHERE nObjectiveType = @type
            AND quest_tag = @quest_tag
            AND sTag = @tag
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @data");
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "") SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return CountRowChanges(oPC);
}

int DecrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = max(0, nAcquired - 1)
        WHERE nObjectiveType = @type
            AND sTag = @tag
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @data");
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    if (sData != "") SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return CountRowChanges(oPC);
}

void DecrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    string s = r"
        UPDATE quest_pc_step
            SET nAcquired = max(0, nAcquired - 1)
        WHERE nObjectiveType = @type
            AND sTag = @tag
            AND quest_tag = @quest_tag
            $1;
    ";
    s = SubstituteSubString(s, "$1", sData == "" ? "" : "AND sData = @data");
    
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "") SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);
}

int CountPCStepObjectivesCompleted(object oPC, int nQuestID, int nStep)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        SELECT COUNT(quest_tag)
        FROM quest_pc_step
        WHERE quest_tag = @quest_tag
            AND nAcquired >= nRequired;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    
    int nCount = SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
    HandleSqlDebugging(sql);

    return nCount;
}

sqlquery GetQuestStepSums(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        SELECT quest_tag, SUM(nRequired), SUM(nAcquired)
        FROM quest_pc_step
        WHERE quest_tag = @tag
            AND nRequired > @zero
        GROUP BY quest_tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

sqlquery GetQuestStepSumsFailure(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        SELECT quest_tag, SUM(nRequired), SUM(nAcquired)
        FROM quest_pc_step
        WHERE quest_tag = @tag
            AND nRequired <= @zero
        GROUP BY quest_tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

void DeletePCQuestProgress(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        DELETE FROM quest_pc_step
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetPCQuestStep(object oPC, string sQuestTag)
{
    string s = r"
        SELECT nStep
        FROM quest_pc_data
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);

    int nStep = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
    HandleSqlDebugging(sql);

    return nStep;
}

int GetNextPCQuestStep(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    int nCurrentStep = GetPCQuestStep(oPC, sQuestTag);

    string s = r"
        SELECT nStep FROM quest_steps
        WHERE quests_id = @id
            AND nStep > @step
            AND nStepType = @step_type
        ORDER BY nStep ASC LIMIT 1;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nCurrentStep);
    SqlBindInt(sql, "@step_type", QUEST_STEP_TYPE_PROGRESS);

    int nStep = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
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
    s = SubstituteSubString(s, "$1", sTag == "" ? "" : "WHERE quest_tag = @sQuestTag");
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    if (sTag != "") SqlBindString(sql, "@sQuestTag", sTag);

    return sql;
}

sqlquery GetPCQuestStepData(object oPC, string sQuestTag)
{
    string s = r"
        SELECT quest_tag, nObjectiveType, sTag, sData,
            nRequired, nAcquired, nObjectiveID
        FROM quest_pc_step
        WHERE quest_tag = @sQuestTag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@sQuestTag", sQuestTag);

    return sql;
}

void AddQuestStepObjectiveData(object oPC, int nQuestID, int nObjectiveType, 
                               string sTargetTag, int nQuantity, int nObjectiveID,
                               string sData = "")
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        INSERT INTO quest_pc_step (quest_tag, nObjectiveType,
            sTag, sData, nRequired, nObjectiveID)
        VALUES (@quest_tag, @type, @tag, @data, @qty, @id);
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindInt(sql, "@qty", nQuantity);
    SqlBindString(sql, "@data", sData);
    SqlBindInt(sql, "@id", nObjectiveID);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetQuestCompletionStep(int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    string s = r"
        SELECT nStep FROM quest_steps
        WHERE quests_id = @id
            AND nStepType = @step_type;
    ";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), s);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step_type", nRequestType == QUEST_ADVANCE_SUCCESS ? 
                                                  QUEST_STEP_TYPE_SUCCESS :
                                                  QUEST_STEP_TYPE_FAIL);

    int nStep = SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
    HandleSqlDebugging(sql);
    return nStep;
}

int GetPCQuestStepAcquired(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string s = r"
        SELECT nAcquired
        FROM quest_pc_step
        WHERE quest_tag = @tag;
    ";
    sqlquery sql = SqlPrepareQueryObject(oPC, s);
    SqlBindString(sql, "@tag", sQuestTag);
    
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
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlStep(sql);

    string sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_data " +
                 "ADD COLUMN nLastCompleteType INTEGER default '0';";
        sql = SqlPrepareQueryObject(oPC, sQuery);
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
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlStep(sql);

    sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_data " +
                 "ADD COLUMN nQuestVersion INTEGER default '0';";
        sql = SqlPrepareQueryObject(oPC, sQuery);
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
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlStep(sql);

    sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_step " +
                 "ADD COLUMN nObjectiveID INTEGER default '0';";
        sql = SqlPrepareQueryObject(oPC, sQuery);
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
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlStep(sql);

    sError = SqlGetError(sql);
    if (sError != "")
    {
        sQuery = "ALTER TABLE quest_pc_data " +
                 "ADD COLUMN nFailures INTEGER default '0';";
        sql = SqlPrepareQueryObject(oPC, sQuery);
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
