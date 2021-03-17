// -----------------------------------------------------------------------------
//    File: quest_i_chat.nss
//  System: Quest Persistent World Subsystem (constants)
// -----------------------------------------------------------------------------
// Description:
//  Chat Support for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_chat"
#include "quest_i_database"
#include "quest_i_main"
#include "quest_i_debug"

void _AssignQuestToPC(object oPC)
{
    string sQuestTag = GetChatKeyValue(oPC, "assign");

    if (GetIsQuestAssignable(oPC, sQuestTag))
    {
        QuestDebug(HexColorString("Quest " + sQuestTag + " is assignable", COLOR_GREEN_LIGHT));
        AssignQuest(oPC, sQuestTag);
    }
    else
        QuestDebug(HexColorString("Quest " + sQuestTag + " is NOT assignable", COLOR_RED_LIGHT));
}

void _UnassignQuestFromPC(object oPC)
{
    string sQuestTag = GetChatKeyValue(oPC, "unassign");
    if (sQuestTag == "")
    {
        CreatePCQuestTables(oPC, TRUE);
    }
    else
    {
        int nQuestID = GetQuestID(sQuestTag);
        UnassignQuest(oPC, nQuestID);
    }
}

void main()
{
    object oPC = GetPCChatSpeaker();

    if (HasChatOption(oPC, "time"))
    {
        int nTime = GetUnixTimeStamp();
        Notice(FormatUnixTimestamp(nTime));

        nTime = GetModifiedUnixTimeStamp(nTime, CreateTimeVector(0,0,0,1,5,0));
        Notice(FormatUnixTimestamp(nTime));
        return;
    }

    if (HasChatOption(oPC, "v, version"))
        QuestDebug("Quest System Version -> " + ColorValue(QUEST_SYSTEM_VERSION));

    if (HasChatOption(oPC, "item"))
    {
        object oItem = CreateItemOnObject("nw_aarcl001", oPC, 1, "quest_gather_armor");
        SetIdentified(oItem, TRUE);

        SendChatResult("Created item {tag} " + GetTag(oItem) +
                       " {name} " + GetName(oItem) + " on " + GetName(oPC), oPC);
        return;
    }

    if (HasChatOption(oPC, "load"))
        ExecuteScript("quest_define", GetModule());

    if (HasChatOption(oPC, "reset"))
    {
        CreateModuleQuestTables(TRUE);
        CreatePCQuestTables(oPC, TRUE);
        ExecuteScript("quest_define", GetModule());
    }

    if (HasChatKey(oPC, "assign"))
        _AssignQuestToPC(oPC);

    if (HasChatOption(oPC, "unassign") || HasChatKey(oPC, "unassign"))
    {
        _UnassignQuestFromPC(oPC);
    }

    if (HasChatOption(oPC, "dump"))
    {
        if (HasChatOption(oPC, "pc"))
        {
            QuestNotice("Dumping PC Quest data");
            QuestNotice("  Quest System Version -> " + ColorValue(QUEST_SYSTEM_VERSION));

            string sPCQuestTag;
            int nPCStepStartTime, nPCQuestStartTime, nPCLastCompleteTime;
            int n, nPCStep, nPCCompletions, nPCAttempts, nPCFailures, bDataFound;

            sqlquery sql;
            string sQuery, sRequestedQuest = GetChatArgument(oPC);
            if (sRequestedQuest == "")
            {
                sQuery = "SELECT * FROM quest_pc_data;";
                sql = SqlPrepareQueryObject(oPC, sQuery);
            }
            else
            {
                sQuery = "SELECT * FROM quest_pc_data WHERE quest_tag = @tag;";
                sql = SqlPrepareQueryObject(oPC, sQuery);
                SqlBindString(sql, "@tag", sRequestedQuest);
            }

            while (SqlStep(sql))
            {
                n = 0;
                sPCQuestTag = SqlGetString(sql, n);
                nPCStep = SqlGetInt(sql, ++n);
                nPCAttempts = SqlGetInt(sql, ++n);
                nPCCompletions = SqlGetInt(sql, ++n);
                nPCFailures = SqlGetInt(sql, ++n);
                nPCQuestStartTime = SqlGetInt(sql, ++n);
                nPCStepStartTime = SqlGetInt(sql, ++n);
                nPCLastCompleteTime = SqlGetInt(sql, ++n);

                Notice(HexColorString("Dumping PC data for " + sPCQuestTag, COLOR_CYAN));
                Notice("  Step  " + ColorValue(IntToString(nPCStep)) +
                     "\n  Attempts  " + ColorValue(IntToString(nPCAttempts)) +
                     "\n  Completions  " + ColorValue(IntToString(nPCCompletions)) +
                     "\n  Failures  " + ColorValue(IntToString(nPCFailures)) + 
                     "\n  Quest Start  " + ColorValue(IntToString(nPCQuestStartTime), TRUE) +
                     "\n  Step Start  " + ColorValue(IntToString(nPCStepStartTime), TRUE) +
                     "\n  Last Completion  " + ColorValue(IntToString(nPCLastCompleteTime), TRUE)); 

                string sQuery1 = "SELECT * FROM quest_pc_step " +
                                 "WHERE quest_tag = @tag;";
                sqlquery sql1 = SqlPrepareQueryObject(oPC, sQuery1);
                SqlBindString(sql1, "@tag", sPCQuestTag);

                while (SqlStep(sql1))
                {
                    n = 1;
                    string sObjectiveType = ObjectiveTypeToString(SqlGetInt(sql1, n));
                    string sTag = SqlGetString(sql1, ++n);
                    string sData = SqlGetString(sql1, ++n);
                    string sRequired = SqlGetString(sql1, ++n);
                    string sAcquired = SqlGetString(sql1, ++n);

                    Notice(HexColorString("Dumping PC step data for " + sPCQuestTag + "/" + IntToString(nPCStep), COLOR_CYAN));
                    Notice("    Objective Type  " + ColorValue(sObjectiveType) +
                         "\n    Tag  " + ColorValue(sTag) +
                         "\n    sData  " + ColorValue(sData) +
                         "\n    Required  " + ColorValue(sRequired) +
                         "\n    Acquired  " + ColorValue(sAcquired));
                }

                bDataFound = TRUE;
            }

            if (!bDataFound)
                QuestDebug("  No quest data found for " + PCToString(oPC));
        }
        else 
        {
            QuestNotice("Dumping Quest data");
            QuestNotice("  Quest System Version -> " + ColorValue(QUEST_SYSTEM_VERSION));

            int n, nID, nActive, nRepetitions, nStepOrder;
            string sTag, sTitle, sAccept, sAdvance, sComplete, sFail;
            string sTime, sCooldown;

            int nStepID, nQuestID, nStep, nPartyCompletion, nProximity, nStepType;
            int nJournalLocation, nDeleteOnComplete, nAllowPrecollected, bDataFound;
            string sJournalEntry, sTimeLimit;

            sqlquery sql;
            string sQuery, sRequestedQuest = GetChatArgument(oPC);
            if (sRequestedQuest == "")
            {
                sQuery = "SELECT * FROM quest_quests;";
                sql = SqlPrepareQueryObject(GetModule(), sQuery);
            }
            else
            {
                sQuery = "SELECT * FROM quest_quests WHERE sTag = @tag;";
                sql = SqlPrepareQueryObject(GetModule(), sQuery);
                SqlBindString(sql, "@tag", sRequestedQuest);
            }

            string sNewQuery, sSubQuery;
            sqlquery sqlNew, sqlSub;
            while (SqlStep(sql))
            {
                // Display all the quest data
                n = 0;
                nID = SqlGetInt(sql, n);
                sTag = SqlGetString(sql, ++n);
                nActive = SqlGetInt(sql, ++n);
                sTitle = SqlGetString(sql, ++n);
                nRepetitions = SqlGetInt(sql, ++n);
                sAccept = SqlGetString(sql, ++n);
                sAdvance = SqlGetString(sql, ++n);
                sComplete = SqlGetString(sql, ++n);
                sFail = SqlGetString(sql, ++n);
                nStepOrder = SqlGetInt(sql, ++n);
                sTime = SqlGetString(sql, ++n);
                sCooldown = SqlGetString(sql, ++n);
                nJournalLocation = SqlGetInt(sql, ++n);
                nDeleteOnComplete = SqlGetInt(sql, ++n);
                nAllowPrecollected = SqlGetInt(sql, ++n);

                bDataFound = TRUE;
            
                Notice(HexColorString("Dumping data for " + QuestToString(nID), COLOR_CYAN));
                Notice("  Tag  " + ColorValue(sTag) +
                    "\n  Active  " + ColorValue((nActive ? "TRUE":"FALSE")) +
                    "\n  Journal  " + ColorValue(sTitle) +
                    "\n  Repetitions  " + ColorValue(IntToString(nRepetitions)) +
                    "\n  Accept Script  " + ColorValue(sAccept) +
                    "\n  Advance Script  " + ColorValue(sAdvance) +
                    "\n  Complete Script  " + ColorValue(sComplete) +
                    "\n  Fail Script  " + ColorValue(sFail) +
                    "\n  Step Order  " + ColorValue(StepOrderToString(nStepOrder)) +
                    "\n  Time Limit  " + ColorValue(sTime) +
                    "\n  Cooldown Time  " + ColorValue(sCooldown) +
                    "\n  Journal Handler  " + ColorValue(JournalLocationToString(nJournalLocation)) +
                    "\n  Delete Journal on Quest Completion  " + ColorValue((nDeleteOnComplete ? "TRUE":"FALSE")) +
                    "\n  Allow Precollected Items  " + ColorValue((nAllowPrecollected ? "TRUE":"FALSE")));

                if (CountQuestPrerequisites(nID) > 0)
                {
                    n = 0;

                    Notice(HexColorString("  Dumping prerequisites for " + QuestToString(nID), COLOR_CYAN));
                    
                    sSubQuery = "SELECT * FROM quest_prerequisites " +
                                "WHERE quests_id = @id;";
                    sqlSub = SqlPrepareQueryObject(GetModule(), sSubQuery);
                    SqlBindInt(sqlSub, "@id", nID);
                    while (SqlStep(sqlSub))
                    {
                        int nPrereqID = SqlGetInt(sqlSub, 0);
                        int nPrereqQuest = SqlGetInt(sqlSub, 1);
                        int nValueType = SqlGetInt(sqlSub, 2);
                        string sKey = SqlGetString(sqlSub, 3);
                        string sValue = SqlGetString(sqlSub, 4);

                        Notice(HexColorString("    " + IntToString(++n), COLOR_CYAN) +
                                TranslateValue(nValueType, sKey, sValue));
                    }
                }
                else
                    Notice(HexColorString("  No prerequisites found for " + QuestToString(nID), COLOR_RED_LIGHT));

                if (CountAllQuestSteps(nID) > 0)
                {
                    // Dump Step data
                    Notice(HexColorString("  Dumping step data for " + QuestToString(nID), COLOR_CYAN));
                    sSubQuery = "SELECT * FROM quest_steps " +
                            "WHERE quests_id = @id;";
                    sqlSub = SqlPrepareQueryObject(GetModule(), sSubQuery);
                    SqlBindInt(sqlSub, "@id", nID);

                    while (SqlStep(sqlSub))
                    {
                        n = 0;
                        nStepID = SqlGetInt(sqlSub, n);
                        nQuestID = SqlGetInt(sqlSub, ++n);
                        nStep = SqlGetInt(sqlSub, ++n);
                        sJournalEntry = SqlGetString(sqlSub, ++n);
                        sTimeLimit = SqlGetString(sqlSub, ++n);
                        nPartyCompletion = SqlGetInt(sqlSub, ++n);
                        nProximity = SqlGetInt(sqlSub, ++n);
                        nStepType = SqlGetInt(sqlSub, ++n);

                        string sStep = HexColorString(IntToString(nStep), COLOR_CYAN);
                        Notice("    " + sStep + "  Journal  " + ColorValue(sJournalEntry) +
                            "\n        Time Limit  " + ColorValue(sTimeLimit == "" ? "" : "(" + sTimeLimit + ")") +
                            "\n        Party Completion  " + ColorValue((nPartyCompletion ? "TRUE":"FALSE")) +
                            "\n        Proximity Required  " + ColorValue((nProximity ? "TRUE":"FALSE")) +
                            "\n        Step Type  " + ColorValue(StepTypeToString(nStepType)));
                    
                        // Another inside loop for the step objectives/properties
                        Notice(HexColorString("        Dumping step properties for " + StepToString(nStep), COLOR_CYAN));
                        sNewQuery = "SELECT quest_step_properties.* FROM quest_steps INNER JOIN quest_step_properties " +
                                        "ON quest_steps.id = quest_step_properties.quest_steps_id " +
                                    "WHERE quest_steps.quests_id = @id " +
                                    "AND quest_steps.nStep = @step;";
                        sqlNew = SqlPrepareQueryObject(GetModule(), sNewQuery);
                        SqlBindInt(sqlNew, "@id", nID);
                        SqlBindInt(sqlNew, "@step", nStep);

                        while (SqlStep(sqlNew))
                        {
                            int nCategoryType = SqlGetInt(sqlNew, 1);
                            int nValueType = SqlGetInt(sqlNew, 2);
                            string sKey = SqlGetString(sqlNew, 3);
                            string sValue = SqlGetString(sqlNew, 4);
                            string sData = SqlGetString(sqlNew, 5);
                            Notice(TranslateCategoryValue(nCategoryType, nValueType, sKey, sValue, sData));
                        }
                    }       
                }
                else
                    Notice(HexColorString("    No step data found for " + QuestToString(nID), COLOR_RED_LIGHT));
            }

            if (!bDataFound)
                QuestDebug("  No quest data found");
        }
    }
}
