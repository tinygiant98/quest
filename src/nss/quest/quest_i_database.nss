// -----------------------------------------------------------------------------
//    File: quest_i_database.nss
//  System: Quest Control System
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

/*
    This file contains all the database-related code to support the quest system.
    All sqlite formations and calls should be in this file.  NWN-organic sqlite
    database for the PC (persistent) and the module (volatile) are used.  The
    campaign sqlite db (persistent) is not used in this implementation.  Generally,
    this file should not be modified in any way unless you know exactly what you
    are doing.  All SQL sequences are built as strings and the compiler has no
    way of verifying their veracity until they are run against an sqlite database.

    This is an internal-use file, so very few function prototypes are provided, and
    they are provided in the primary quest system file.
*/

#include "util_i_csvlists"

#include "quest_i_const"
#include "quest_i_debug"

string sQuery;
sqlquery sql;

void CreateModuleQuestTables(int bReset = FALSE)
{
    // Define the tables
    string sQuests = "CREATE TABLE IF NOT EXISTS quest_quests (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "sTag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE, " +
                        "nActive TEXT NOT NULL default '1', " +
                        "sJournalTitle TEXT default NULL, " +
                        "nRepetitions TEXT default '1', " +
                        "sScriptOnAccept TEXT default NULL, " +
                        "sScriptOnAdvance TEXT default NULL, " +
                        "sScriptOnComplete TEXT default NULL, " + 
                        "sScriptOnFail TEXT default NULL, " +
                        "sTimeLimit TEXT default NULL, " +
                        "sCooldown TEXT default NULL, " +
                        "nJournalHandler TEXT default '" + IntToString(QUEST_CONFIG_JOURNAL_HANDLER) + "', " +
                        "nRemoveJournalOnComplete TEXT default '0', " +
                        "nAllowPrecollectedItems TEXT default '1', " +
                        "nRemoveQuestOnCompleted TEXT default '0', " +
                        "nQuestVersion TEXT default '0', " +
                        "nQuestVersionAction TEXT default '0');";

    string sQuestPrerequisites = "CREATE TABLE IF NOT EXISTS quest_prerequisites (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quests_id INTEGER NOT NULL default '0', " +
                        "nValueType INTEGER NOT NULL default '0', " +
                        "sKey TEXT NOT NULL default '', " +
                        "sValue TEXT NOT NULL default '', " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";

    string sQuestSteps = "CREATE TABLE IF NOT EXISTS quest_steps (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quests_id INTEGER NOT NULL default '0', " +
                        "nStep INTEGER NOT NULL default '0', " +
                        "sJournalEntry TEXT default NULL, " +
                        "sTimeLimit TEXT default NULL, " +
                        "nPartyCompletion TEXT default '0', " +
                        "nProximity INTEGER default '1', " +
                        "nStepType INTEGER default '0', " +
                        "nObjectiveMinimumCount INTEGER default '-1', " +
                        "nRandomObjectiveCount INTEGER default '-1', " +
                        "UNIQUE (quests_id, nStep) ON CONFLICT IGNORE, " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON DELETE CASCADE ON UPDATE CASCADE);";

    string sQuestStepProperties = "CREATE TABLE IF NOT EXISTS quest_step_properties (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quest_steps_id INTEGER NOT NULL, " +
                        "nCategoryType INTEGER NOT NULL, " +
                        "nValueType INTEGER NOT NULL, " +
                        "sKey TEXT NOT NULL COLLATE NOCASE, " +
                        "sValue INTEGER default '', " +
                        "sValueMax INTEGER default '', " +
                        "sData TEXT default '', " +
                        "bParty INTEGER default '0', " +
                        "FOREIGN KEY (quest_steps_id) REFERENCES quest_steps (id) " +
                            "ON DELETE CASCADE ON UPDATE CASCADE);";

    // Destroy if required
    if (bReset)
    {
        QuestDebug(HexColorString("Resetting", COLOR_RED_LIGHT) + " quest database tables for the module");

        string sTable, sTables = "quests,prerequisites,steps,step_properties";
        int n, nCount = CountList(sTables);  
    
        for (n = 0; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            sQuery = "DROP TABLE IF EXISTS quest_" + sTable + ";";
            sql = SqlPrepareQueryObject(GetModule(), sQuery);
            SqlStep(sql);
        }
    }

    sql = SqlPrepareQueryObject(GetModule(), sQuests);              SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_quests", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestPrerequisites);  SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_prerequisites", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestSteps);          SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_steps", "module");

    sql = SqlPrepareQueryObject(GetModule(), sQuestStepProperties); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_step_properties", "module");
}

void CreatePCQuestTables(object oPC, int bReset = FALSE)
{
    string sQuest = "CREATE TABLE IF NOT EXISTS quest_pc_data (" +
        "quest_tag TEXT UNIQUE ON CONFLICT IGNORE, " +
        "nStep INTEGER default '0', " +
        "nAttempts INTEGER default '0', " +
        "nCompletions INTEGER default '0', " +
        "nFailures INTEGER default '0', " +
        "nQuestStartTime INTEGER default '0', " +
        "nStepStartTime INTEGER default '0', " +
        "nLastCompleteTime INTEGER default '0', " +
        "nLastCompleteType INTEGER default '0', " +
        "nQuestVersion INTEGER default '0');";

    string sQuestStep = "CREATE TABLE IF NOT EXISTS quest_pc_step (" +
        "quest_tag TEXT, " +
        "nObjectiveType INTEGER, " +
        "sTag TEXT default '' COLLATE NOCASE, " +
        "sData TEXT default '' COLLATE NOCASE, " +
        "nRequired INTEGER, " +
        "nAcquired INTEGER default '0', " +
        "nObjectiveID INTEGER, " +
        "FOREIGN KEY (quest_tag) REFERENCES quest_pc_data (quest_tag) " +
            "ON UPDATE CASCADE ON DELETE CASCADE);";

    // Destroy if required
    if (bReset)
    {
        QuestDebug(HexColorString("Resetting", COLOR_RED_LIGHT) + " quest database tables for " +
            PCToString(oPC));

        string sTable, sTables = "data,step";
        int n, nCount = CountList(sTables);  
    
        for (n = 0; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            sQuery = "DROP TABLE IF EXISTS quest_pc_" + sTable + ";";
            sql = SqlPrepareQueryObject(oPC, sQuery);
            SqlStep(sql);
        }
    }

    sql = SqlPrepareQueryObject(oPC, sQuest);     SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_pc_data", PCToString(oPC));

    sql = SqlPrepareQueryObject(oPC, sQuestStep); SqlStep(sql);
    HandleSqlDebugging(sql, "SQL:table", "quest_pc_step", PCToString(oPC));
}

void CreateQuestVariablesTable(int bReset = FALSE)
{
    string sQuestVariables = "CREATE TABLE IF NOT EXISTS quest_variables (" +
                        "quests_id INTEGER NOT NULL, " +
                        "sType TEXT NOT NULL, " +
                        "sName TEXT NOT NULL, " +
                        "sValue TEXT NOT NULL, " +
                        "UNIQUE (quests_id, sType, sName) ON CONFLICT REPLACE, " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";
    
    if (bReset)
    {
        sQuery = "DROP TABLE IF EXISTS quest_variables;";
        sql = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlStep(sql);
    }
    
    sql = SqlPrepareQueryObject(GetModule(), sQuestVariables);
    SqlStep(sql);

    SetLocalInt(GetModule(), QUEST_VARIABLE_TABLES_INITIALIZED, TRUE);
    HandleSqlDebugging(sql, "SQL:table", "quest_variables", "module");
}

void CreatePCVariablesTable(object oPC, int bReset = FALSE)
{
    string sPCVariables = "CREATE TABLE IF NOT EXISTS quest_pc_variables (" +
                        "quest_tag TEXT NOT NULL, " +
                        "nStep INTEGER NOT NULL default '0', " +
                        "sType TEXT NOT NULL, " +
                        "sName TEXT NOT NULL, " +
                        "sValue TEXT NOT NULL, " +
                        "UNIQUE (quest_tag, nStep, sType, sName) ON CONFLICT REPLACE, " +
                        "FOREIGN KEY (quest_tag) REFERENCES quest_pc_data (quest_tag) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";

    if (bReset)
    {
        sQuery = "DROP TABLE IF EXISTS quest_pc_variables;";
        sql = SqlPrepareQueryObject(oPC, sQuery);
        SqlStep(sql);
    }

    sql = SqlPrepareQueryObject(oPC, sPCVariables);
    SqlStep(sql);

    HandleSqlDebugging(sql, "SQL:table", "quest_pc_variables", GetName(oPC));
}

int GetLastInsertedID(string sTable)
{
    sQuery = "SELECT seq FROM sqlite_sequence WHERE name = @name;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@name", sTable);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

string GetQuestTag(int nQuestID)
{
    sQuery = "SELECT sTag FROM quest_quests " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

int CountRowChanges(object oTarget)
{
    sQuery = "SELECT CHANGES();";
    sql = SqlPrepareQueryObject(oTarget, sQuery);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

string GetTimeStamp()
{
    //sQuery = "SELECT strftime('%s', 'now')";
    sQuery = "SELECT CURRENT_TIMESTAMP;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);
    
    return SqlGetString(sql, 0);
}

int GetUnixTimeStamp()
{
    sQuery = "SELECT strftime('%s', 'now')";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    return SqlGetInt(sql, 0);
}

string GetGreaterTimeStamp(string sTime1, string sTime2)
{
    sQuery = "SELECT strftime('%s', '" + sTime1 + "');";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    int nTime1 = SqlGetInt(sql, 0);

    sQuery = "SELECT strftime('%s', '" + sTime2 + "');";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    int nTime2 = SqlGetInt(sql, 0);

    if (nTime1 == nTime2)
        return sTime1;
    else if (nTime1 < nTime2)
        return sTime2;
    else if (nTime1 > nTime2)
        return sTime1;
    else 
        return "";
}

int GetGreaterUnixTimeStamp(int nTime1, int nTime2 = 0)
{
    if (nTime2 == 0)
        nTime2 = GetUnixTimeStamp();

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

    sQuery = "SELECT strftime('%s', datetime(" + IntToString(nTimeStamp) + ",'unixepoch', " + sResult + "));";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    return SqlGetInt(sql, 0);   
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

    sQuery = "SELECT datetime('" + sTimeStamp + "', " + sResult + ");";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    return SqlGetString(sql, 0);
}

string QuestToString(int nQuestID)
{
    string sTag = GetQuestTag(nQuestID);

    if (sTag == "")
        return "[NOT FOUND]";

    return HexColorString(sTag + " (ID " + IntToString(nQuestID) + ")", COLOR_ORANGE_LIGHT);
}

int GetQuestID(string sQuestTag)
{
    sQuery = "SELECT id FROM quest_quests WHERE sTag = @sQuestTag;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sQuestTag", sQuestTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

void AddQuestPrerequisite(int nQuestID, int nValueType, string sKey, string sValue)
{
    sQuery = "INSERT INTO quest_prerequisites (quests_id, nValueType, sKey, sValue) " +
             "VALUES (@quests_id, @nValueType, @key, @sValue);";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@quests_id", nQuestID);
    SqlBindInt(sql, "@nValueType", nValueType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@sValue", sValue);

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int _AddQuest(string sQuestTag, string sJournalTitle)
{
    string sQuery = "INSERT INTO quest_quests (sTag, sJournalTitle) " +
                    "VALUES (@sTag, @sTitle);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sTag", sQuestTag);
    SqlBindString(sql, "@sTitle", sJournalTitle);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return GetLastInsertedID("quest_quests");
}

void _DeleteQuest(int nQuestID)
{
    sQuery = "DELETE FROM quest_quests " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlStep(sql);                
}

void _AddQuestStep(int nQuestID, int nStep)
{
    string sQuest = "INSERT INTO quest_steps (quests_id, nStep) " +
                    "VALUES (@quests_id, @nStep);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuest);
    SqlBindInt(sql, "@quests_id", nQuestID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlStep(sql);

    HandleSqlDebugging(sql);

    if (CountRowChanges(GetModule()) == 0)
        QuestError(StepToString(nStep) + " for " + QuestToString(nQuestID) +
            " already exists and cannot overwritten.  Check quest definitions " +
            "to ensure the same step number is not being assigned to different " +
            "steps.");
}

sqlquery GetQuestPrerequisites(int nQuestID)
{
    sQuery = "SELECT nPropertyType, sKey, sValue " +
             "FROM quest_prerequisites " + 
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetQuestPrerequisiteTypes(int nQuestID)
{
    sQuery = "SELECT nValueType, COUNT(sKey) " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id " +
             "GROUP BY nValueType " +
             "ORDER BY nValueType;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetQuestPrerequisitesByType(int nQuestID, int nValueType)
{
    sQuery = "SELECT sKey, sValue " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id " +
                "AND nValueType = @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", nValueType);

    return sql;
}

int GetIsQuestActive(int nQuestID)
{
    sQuery = "SELECT nActive " +
             "FROM quest_quests " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    int nActive;
    if (SqlStep(sql))
        nActive = SqlGetInt(sql, 0);
    else
        nActive = FALSE;

    HandleSqlDebugging(sql);
    return nActive;
}

int CountActiveQuestSteps(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);

    sQuery = "SELECT COUNT(*) " +
             "FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType = @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_PROGRESS);

    int nSteps;
    if (SqlStep(sql))
        nSteps = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nSteps;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int CountAllQuestSteps(int nQuestID)
{
    sQuery = "SELECT COUNT(*) " +
             "FROM quest_steps " +
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    int nSteps;
    if (SqlStep(sql))
        nSteps = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nSteps;
}

int CountQuestPrerequisites(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);

    sQuery = "SELECT COUNT(id) " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    int nCount;
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;
}

sqlquery GetQuestData(int nQuestID)
{
    sQuery = "SELECT * FROM quest_quests WHERE id = @nQuestID;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@nQuestID", nQuestID);

    return sql;
}

sqlquery GetQuestProperties(int nQuestID)
{
    sQuery = "SELECT * FROM quest_properties WHERE quest_id = @nQuestID;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@nQuestID", nQuestID);

    return sql;
}

int GetTableExists(object oTarget, string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master " +
                "WHERE type='table' " +
                "AND name='" + sTable + "';";
    
    sqlquery sql = SqlPrepareQueryObject(oTarget, sQuery);
    return SqlStep(sql);
}

int CountQuestVariables(object oTarget, string sTable)
{
    string sQuery = "SELECT COUNT(*) " +
                    "FROM " + sTable + ";";
    sqlquery sql = SqlPrepareQueryObject(oTarget, sQuery);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int GetQuestExists(string sTag)
{
    sQuery = "SELECT COUNT(id) FROM quest_quests " +
             "WHERE sTag = @tag;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@tag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int GetQuestHasMinimumNumberOfSteps(int nQuestID)
{
    sQuery = "SELECT COUNT(id) FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType != @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_PROGRESS);

    int nSteps;
    if (SqlStep(sql))
        return SqlGetInt(sql, 0) > 0;
    else
        return FALSE;
}

int GetQuestStepID(int nQuestID, int nStep)
{
    sQuery = "SELECT id FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStep = @step;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);

    int nID;
    if (SqlStep(sql))
        nID = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nID;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

sqlquery GetQuestStepPropertySets(int nQuestID, int nStep, int nCategoryType)
{
    string sQuery = "SELECT nValueType, sKey, sValue, sData, bParty " +
                    "FROM quest_step_properties " +
                    "WHERE nCategoryType = @category " +
                        "AND quest_steps_id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));

    return sql;
}

sqlquery GetQuestStepPropertyPairs(int nQuestID, int nStep, int nCategoryType, int nValueType)
{
    sQuery = "SELECT quest_step_properties.sKey, " +
                    "quest_step_properties.sValue " +
                    "quest_step_properties.sData " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_steps.id = @id " +
                "AND quest_steps.nStep = @step " +
                "AND quest_step_properties.nCategoryType = @category " +
                "AND quest_step_properties.nValueType = @value_type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@value_type", nValueType);

    return sql;
}

void DeleteQuestStepPropertyPair(int nQuestID, int nStep, int nCategoryType, int nValueType)
{
    string sQuery = "DELETE FROM quest_step_properties " +
             "WHERE nCategoryType = @category " +
                "AND nValueType = @type " +
                "AND quest_steps_id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@type", nValueType);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));

    SqlStep(sql);

    HandleSqlDebugging(sql);
}

string GetQuestStepPropertyValue(int nQuestID, int nStep, 
                                 int nCategoryType, int nValueType)
{
    string sQuery = "SELECT sValue " +
             "FROM quest_step_properties " +
             "WHERE quest_steps_id = @id " +
                "AND nCategoryType = @category_type " +
                "AND nValueType = @value_type;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));
    SqlBindInt(sql, "@category_type", nCategoryType);
    SqlBindInt(sql, "@value_type", nValueType);

    string sValue = SqlStep(sql) ? SqlGetString(sql, 0) : "";
    HandleSqlDebugging(sql);
    return sValue;
}

sqlquery GetQuestStepObjectiveData(int nQuestID, int nStep)
{
    sQuery = "SELECT quest_step_properties.id, " +
                    "quest_step_properties.nValueType, " +
                    "quest_step_properties.sKey, " +
                    "quest_step_properties.sValue, " +
                    "quest_step_properties.sValueMax, " +
                    "quest_step_properties.sData " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetRandomQuestStepObjectiveData(int nQuestID, int nStep, int nRecords)
{
    sQuery = "SELECT quest_step_properties.id, " +
                    "quest_step_properties.nValueType, " +
                    "quest_step_properties.sKey, " +
                    "quest_step_properties.sValue, " +
                    "quest_step_properties.sValueMax, " +
                    "quest_step_properties.sData " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id " +
             "ORDER BY RANDOM() LIMIT " + IntToString(nRecords) + ";";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

int GetQuestStepObjectiveType(int nQuestID, int nStep)
{
    sQuery = "SELECT quest_step_properties.nValueType " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id " +
            "LIMIT 1;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    int nType;
    if (SqlStep(sql))
        nType = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nType;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int CountQuestStepObjectives(int nQuestID, int nStep)
{
    string sQuery = "SELECT COUNT(quest_steps_id) " +
                    "FROM quest_step_properties " +
                    "WHERE nCategoryType = @category " +
                        "AND quest_steps_id = @id;";

    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));
    
    int nCount;
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

void _AddQuestToPC(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "INSERT INTO quest_pc_data (quest_tag) " +
             "VALUES (@tag);";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

void DeletePCQuest(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "DELETE FROM quest_pc_data " + 
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetPCHasQuest(object oPC, string sQuestTag)
{
    sQuery = "SELECT COUNT(quest_tag) FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    
    int nHas;
    if (SqlStep(sql))
        nHas = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nHas;
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int GetIsPCQuestComplete(object oPC, string sQuestTag)
{
    sQuery = "SELECT COUNT(*) FROM quest_pc_step " +
                "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    int nComplete;
    if (SqlStep(sql))
        nComplete = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return !nComplete;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) == 0 : FALSE;
}

int GetPCHasQuestAssigned(object oPC, string sQuestTag)
{
    return GetPCHasQuest(oPC, sQuestTag) && !GetIsPCQuestComplete(oPC, sQuestTag);
}

int GetPCQuestCompletions(object oPC, string sQuestTag)
{
    sQuery = "SELECT nCompletions FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    int nCount;
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int GetPCQuestFailures(object oPC, string sQuestTag)
{
    sQuery = "SELECT nFailures FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    int nCount;
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;
}

void ResetPCQuestData(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string sQuery = "UPDATE quest_pc_data " +
                    "SET nStep = @step, " +
                        "nQuestStartTime = @quest_start, " +
                        "nStepStartTime = @step_start " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
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
    sQuery = "UPDATE quest_pc_data " + 
             "SET " + sField + " = " + sField + " + 1 " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

void IncrementPCQuestCompletions(object oPC, int nQuestID, int nTimeStamp)
{
    ResetPCQuestData(oPC, nQuestID);

    string sQuestTag = GetQuestTag(nQuestID);
    sQuery = "UPDATE quest_pc_data " +
             "SET nCompletions = nCompletions + 1, " +
                 "nLastCompleteTime = @time, " +
                 "nLastCompleteType = @type " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
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
    sQuery = "UPDATE quest_pc_data " +
             "SET nFailures = nFailures + 1, " +
                 "nLastCompleteTime = @time " +
                 "nLastCompleteType = @type " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@time", nTimeStamp);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_FAIL);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

sqlquery GetStepObjectivesByTarget(object oPC, string sTarget)
{
    string sQuery = "SELECT quest_pc_step.sTag, " +
                        "quest_pc_data.quest_tag, " +
                        "quest_pc_data.nStep " +
                    "FROM quest_pc_data INNER JOIN quest_pc_step " +
                        "ON quest_pc_data.quest_tag = quest_pc_step.quest_tag " +
                    "WHERE quest_pc_step.sTag = @target;";

    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@target", sTarget);

    return sql;
}

sqlquery GetTargetQuestData(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "SELECT quest_pc_data.quest_tag, " +
                    "quest_pc_data.nStep " +
             "FROM quest_pc_data INNER JOIN quest_pc_step " +
                "ON quest_pc_data.quest_tag = quest_pc_step.quest_tag " +
             "WHERE quest_pc_step.nObjectiveType = @type " +
                "AND quest_pc_step.sTag = @tag" +
                (sData == "" ? ";" : " AND quest_pc_step.sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    return sql;
}

sqlquery GetPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "SELECT quest_tag, nObjectiveID, nRequired, nAcquired FROM quest_pc_step " +
             "WHERE sTag = @target_tag " +
                "AND nObjectiveType = @objective_type" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@target_tag", sTargetTag);
    SqlBindInt(sql, "@objective_type", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@data", sData);

    return sql;
}

int CountPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "SELECT COUNT(quest_tag) FROM quest_pc_step " +
             "WHERE sTag = @target_tag " +
                "AND nObjectiveType = @objective_type" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@target_tag", sTargetTag);
    SqlBindInt(sql, "@objective_type", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@data", sData);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

//void IncrementQuestStepQuantity(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
int IncrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             //"SET nAcquired = min(nRequired, nAcquired + 1) " +
             "SET nAcquired = nAcquired + 1 " +
             "WHERE nObjectiveType = @type " +
                //"AND quest_tag = @quest_tag " +
                "AND sTag = @tag " +
                "AND nAcquired < nRequired " +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    //SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return CountRowChanges(oPC);
}

int IncrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = nAcquired + 1 " +
             "WHERE nObjectiveType = @type " +
                "AND quest_tag = @quest_tag " +
                "AND sTag = @tag" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return CountRowChanges(oPC);
}

int DecrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = max(0, nAcquired - 1) " +
             "WHERE nObjectiveType = @type " +
                //"AND quest_tag = @quest_tag " +
                "AND sTag = @tag" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    //SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);

    return CountRowChanges(oPC);
}

void DecrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = max(0, nAcquired - 1) " +
             "WHERE nObjectiveType = @type " +
                "AND sTag = @tag" +
                "AND quest_tag = @quest_tag" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    HandleSqlDebugging(sql);
}

int CountPCStepObjectivesCompleted(object oPC, int nQuestID, int nStep)
{
    string sQuestTag = GetQuestTag(nQuestID);
    int nCount;

    sQuery = "SELECT COUNT(quest_tag) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @quest_tag " +
                "AND nAcquired >= nRequired;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    
    if (SqlStep(sql))
        nCount = SqlGetInt(sql, 0);

    HandleSqlDebugging(sql);
    return nCount;
}

sqlquery GetQuestStepSums(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT quest_tag, SUM(nRequired), SUM(nAcquired) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @tag " +
                "AND nRequired > @zero " +
             "GROUP BY quest_tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

sqlquery GetQuestStepSumsFailure(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT quest_tag, SUM(nRequired), SUM(nAcquired) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @tag " +
                "AND nRequired <= @zero " +
             "GROUP BY quest_tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

void DeletePCQuestProgress(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "DELETE FROM quest_pc_step " + 
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);

    HandleSqlDebugging(sql);
}

int GetPCQuestStep(object oPC, string sQuestTag)
{
    sQuery = "SELECT nStep FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    // This could be 0 for the first step, so return -1
    //return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

int GetNextPCQuestStep(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    int nCurrentStep = GetPCQuestStep(oPC, sQuestTag);

    sQuery = "SELECT nStep FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStep > @step " +
                "AND nStepType = @step_type " +
             "ORDER BY nStep ASC LIMIT 1;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nCurrentStep);
    SqlBindInt(sql, "@step_type", QUEST_STEP_TYPE_PROGRESS);

    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

sqlquery GetPCQuestData(object oPC, string sQuestTag = "")
{
    sQuery = "SELECT quest_tag, nStep, nCompletions, nFailures, nLastCompleteType " +
             "FROM quest_pc_data " +
             (sQuestTag == "" ? "" : "WHERE quest_tag = @sQuestTag") + ";";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    if (sQuestTag != "")
        SqlBindString(sql, "@sQuestTag", sQuestTag);

    return sql;
}

sqlquery GetPCQuestStepData(object oPC, string sQuestTag)
{
    sQuery = "SELECT quest_tag, nObjectiveType, sTag, sData, nRequired, nAcquired, nObjectiveID " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @sQuestTag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@sQuestTag", sQuestTag);

    return sql;
}

void AddQuestStepObjectiveData(object oPC, int nQuestID, int nObjectiveType, 
                               string sTargetTag, int nQuantity, int nObjectiveID,
                               string sData = "")
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "INSERT INTO quest_pc_step (quest_tag, nObjectiveType, " +
                "sTag, sData, nRequired, nObjectiveID) " +
             "VALUES (@quest_tag, @type, @tag, @data, @qty, @id);";
    sql = SqlPrepareQueryObject(oPC, sQuery);
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
    sQuery = "SELECT nStep FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType = @step_type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step_type", nRequestType == QUEST_ADVANCE_SUCCESS ? 
                                                    QUEST_STEP_TYPE_SUCCESS :
                                                    QUEST_STEP_TYPE_FAIL);

    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    //return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

int GetPCQuestStepAcquired(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT nAcquired FROM quest_pc_step " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    
    int nStep;
    if (SqlStep(sql))
        nStep = SqlGetInt(sql, 0);
    else
        nStep = -1;

    HandleSqlDebugging(sql);
    return nStep;

    //return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

void UpdatePCQuestTables(object oPC)
{
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
}
