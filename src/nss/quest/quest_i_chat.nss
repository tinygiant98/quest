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

void _AssignQuestToPC(object oPC, string sQuestTag = "")
{
    if (sQuestTag == "")
        sQuestTag = GetChatKeyValue(oPC, "assign");

    if (GetIsQuestAssignable(oPC, sQuestTag))
    {
        Debug(HexColorString("Quest " + sQuestTag + " is assignable", COLOR_GREEN_LIGHT));
        AssignQuest(oPC, sQuestTag);
    }
    else
        Debug(HexColorString("Quest " + sQuestTag + " is NOT assignable", COLOR_RED_LIGHT));
}

void _UnassignQuestFromPC(object oPC, string sQuestTag = "")
{
    if (sQuestTag == "")
        sQuestTag = GetChatKeyValue(oPC, "unassign");
    
    if (sQuestTag == "")
        CreatePCQuestTables(oPC);
    else
        UnassignQuest(oPC, sQuestTag);
}

void main()
{
    object oPC = GetPCChatSpeaker();

    if (HasChatOption(oPC, "v, version"))
        Debug("Quest System Version -> " + ColorValue(QUEST_SYSTEM_VERSION));

    if (HasChatOption(oPC, "item"))
    {
        object oItem = CreateItemOnObject("nw_aarcl001", oPC, 1, "quest_gather_armor");
        SetIdentified(oItem, TRUE);

        SendChatResult("Created item {tag} " + GetTag(oItem) +
                       " {name} " + GetName(oItem) + " on " + GetName(oPC), oPC);
        return;
    }

    if (HasChatOption(oPC, "view"))
    {
        DisplayPCQuestData(oPC, oPC);
    }

    if (HasChatOption(oPC, "test"))
    {
        SignalQuestStepProgress(oPC, "nw_oldman", QUEST_OBJECTIVE_SPEAK);
    }

    if (HasChatOption(oPC, "load"))
        ExecuteScript("quest_define", GetModule());

    if (HasChatOption(oPC, "reset"))
    {
        if (HasChatOption(oPC, "pc"))
        {
            CreatePCQuestTables(oPC, TRUE);
            return;
        }
        else
        {
            CreatePCQuestTables(oPC, TRUE);
            ExecuteScript("quest_define", GetModule());
        }
    }

    if (HasChatKey(oPC, "assign"))
        _AssignQuestToPC(oPC);

    if (HasChatOption(oPC, "unassign") || HasChatKey(oPC, "unassign"))
    {
        _UnassignQuestFromPC(oPC);
    }

    if (HasChatOption(oPC, "nwnx"))
    {
        if (HasChatOption(oPC, "d"))
        {
            _UnassignQuestFromPC(oPC, "quest_discovery_random");
            SendChatResult("Removing quest_discovery_random via NWNX", oPC);
        }
        else
        {
            _AssignQuestToPC(oPC, "quest_discovery_random");
            SendChatResult("Assigning quest_discovery_random via nwnx", oPC);
        }
    }

    if (HasChatOption(oPC, "dump"))
    {
        if (HasChatOption(oPC, "pc"))
        {
            Debug(HexColorString("Dumping PC Quest data", COLOR_CYAN));
            Debug("  Quest System Version -> " + ColorValue(QUEST_SYSTEM_VERSION));

            string sPCQuestTag;
            int nPCStepStartTime, nPCQuestStartTime, nPCLastCompleteTime, nPCLastCompleteType;
            int n, nPCStep, nPCCompletions, nPCAttempts, nPCFailures, bDataFound, nPCQuestVersion;

            sqlquery sql;
            string sQuery, sRequestedQuest = GetChatArgument(oPC);
            
            // Dump all the quest date (or specific quest data)
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
                nPCLastCompleteType = SqlGetInt(sql, ++n);
                nPCQuestVersion = SqlGetInt(sql, ++n);

                Debug(HexColorString("Dumping PC data for " + sPCQuestTag, COLOR_CYAN));
                Debug("  Step  " + ColorValue(IntToString(nPCStep)) +
                     "\n  Attempts  " + ColorValue(IntToString(nPCAttempts)) +
                     "\n  Completions  " + ColorValue(IntToString(nPCCompletions)) +
                     "\n  Failures  " + ColorValue(IntToString(nPCFailures)) + 
                     "\n  Quest Start Time  " + (nPCQuestStartTime == 0 ? 
                        ColorValue(IntToString(nPCQuestStartTime), TRUE) :
                        ColorValue(FormatUnixTimestamp(nPCQuestStartTime, QUEST_TIME_FORMAT)) + " UTC") +
                     "\n  Step Start Time  " + (nPCStepStartTime == 0 ? 
                        ColorValue(IntToString(nPCStepStartTime), TRUE) :
                        ColorValue(FormatUnixTimestamp(nPCStepStartTime, QUEST_TIME_FORMAT)) + " UTC") +
                     "\n  Last Completion Time  " + (nPCLastCompleteTime == 0 ? 
                        ColorValue(IntToString(nPCLastCompleteTime), TRUE) :
                        ColorValue(FormatUnixTimestamp(nPCLastCompleteTime, QUEST_TIME_FORMAT)) + " UTC") +
                     "\n  Last Completion Type  " + ColorValue(StepTypeToString(nPCLastCompleteType)) +
                     "\n  Quest Version  " + ColorValue(IntToString(nPCQuestVersion)));

                // Dump all the quest step data
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

                    Debug(HexColorString("Dumping PC step data for " + sPCQuestTag + " " + StepToString(nPCStep), COLOR_CYAN));
                    Debug("    Objective Type  " + ColorValue(sObjectiveType) +
                         "\n    Tag  " + ColorValue(sTag) +
                         "\n    sData  " + ColorValue(sData) +
                         "\n    Required  " + ColorValue(sRequired) +
                         "\n    Acquired  " + ColorValue(sAcquired));
                }

                bDataFound = TRUE;
            }

            if (!bDataFound)
                Debug(HexColorString("  No quest data found for " + PCToString(oPC), COLOR_RED_LIGHT));

            // Dump variables
            Debug(HexColorString("Dumping PC Quest Variables", COLOR_CYAN));
            if (GetTableExists(oPC, "quest_pc_variables") == FALSE)
                Debug(HexColorString("  Variables table does not exist on " + PCToString(oPC), COLOR_RED_LIGHT));
            else if (CountQuestVariables(oPC, "quest_pc_variables") == 0)
                Debug(HexColorString("  No variables found for " + PCToString(oPC), COLOR_RED_LIGHT));
            else
            {
                if (sRequestedQuest == "")
                {
                    sQuery = "SELECT * FROM quest_pc_variables;";
                    sql = SqlPrepareQueryObject(oPC, sQuery);
                }
                else
                {
                    sQuery = "SELECT * FROM quest_pc_variables WHERE quest_tag = @tag;";
                    sql = SqlPrepareQueryObject(oPC, sQuery);
                    SqlBindString(sql, "@tag", sRequestedQuest);
                }

                while(SqlStep(sql))
                {
                    string sPCQuestTag = SqlGetString(sql, 0);
                    int nPCStep = SqlGetInt(sql, 1);
                    string sPCType = SqlGetString(sql, 2);
                    string sPCName = SqlGetString(sql, 3);
                    string sPCValue = SqlGetString(sql, 4);

                    Debug("  Quest Tag -> " + ColorValue(sPCQuestTag) + 
                        "\n    Step -> " + (nPCStep > 0 ? StepToString(nPCStep) : ColorValue(IntToString(nPCStep), TRUE)) +
                        "\n    Type -> " + ColorValue((sPCType == "INT" ? "INTEGER" : "STRING")) +
                        "\n    Var Name -> " + ColorValue(sPCName) +
                        "\n    Value -> " + ColorValue(sPCValue));
                }
            }
        }
        else 
        {
            Debug(HexColorString("Dumping Quest data", COLOR_CYAN));
            Debug("  Quest System Version -> " + ColorValue(QUEST_SYSTEM_VERSION));

            int n, nID, nActive, nRepetitions;
            string sTag, sTitle, sAccept, sAdvance, sComplete, sFail;
            string sTime, sCooldown;

            int nStepID, nQuestID, nStep, nPartyCompletion, nProximity, nStepType;
            int nJournalLocation, nDeleteOnComplete, nAllowPrecollected, bDataFound;
            int nMinimumObjectives, nRandomObjectives, nQuestVersion, nQuestVersionAction;
            int nRemoveOnComplete;
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
                sTime = SqlGetString(sql, ++n);
                sCooldown = SqlGetString(sql, ++n);
                nJournalLocation = SqlGetInt(sql, ++n);
                nDeleteOnComplete = SqlGetInt(sql, ++n);
                nAllowPrecollected = SqlGetInt(sql, ++n);
                nRemoveOnComplete = SqlGetInt(sql, ++n);
                nQuestVersion = SqlGetInt(sql, ++n);
                nQuestVersionAction = SqlGetInt(sql, ++n);

                bDataFound = TRUE;

                Debug(HexColorString("Dumping data for " + QuestToString(nID), COLOR_CYAN));
                Debug("  Tag  " + ColorValue(sTag) +
                    "\n  Active  " + ColorValue((nActive ? "TRUE":"FALSE")) +
                    "\n  Journal  " + ColorValue(sTitle) +
                    "\n  Repetitions  " + ColorValue(IntToString(nRepetitions)) +
                    "\n  Accept Script  " + ColorValue(sAccept) +
                    "\n  Advance Script  " + ColorValue(sAdvance) +
                    "\n  Complete Script  " + ColorValue(sComplete) +
                    "\n  Fail Script  " + ColorValue(sFail) +
                    "\n  Time Limit  " + ColorValue(TimeVectorToString(sTime)) +
                    "\n  Cooldown Time  " + ColorValue(TimeVectorToString(sCooldown)) +
                    "\n  Journal Handler  " + ColorValue(JournalLocationToString(nJournalLocation)) +
                    "\n  Delete Journal on Quest Completion  " + ColorValue((nDeleteOnComplete ? "TRUE":"FALSE")) +
                    "\n  Allow Precollected Items  " + ColorValue((nAllowPrecollected ? "TRUE":"FALSE")) +
                    "\n  Delete Quest on Quest Completion  " + ColorValue((nRemoveOnComplete ? "TRUE":"FALSE")) +
                    "\n  Quest Version  " + ColorValue(IntToString(nQuestVersion)) +
                    "\n  Quest Version Action  " + ColorValue(VersionActionToString(nQuestVersionAction)));

                if (CountQuestPrerequisites(sTag) > 0)
                {
                    n = 0;

                    Debug(HexColorString("  Dumping prerequisites for " + QuestToString(nID), COLOR_CYAN));
                    
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

                        Debug(HexColorString("    " + IntToString(++n), COLOR_CYAN) +
                                TranslateValue(nValueType, sKey, sValue));
                    }
                }
                else
                    Debug(HexColorString("  No prerequisites found for " + QuestToString(nID), COLOR_RED_LIGHT));

                if (CountAllQuestSteps(nID) > 0)
                {
                    // Dump Step data
                    Debug(HexColorString("  Dumping step data for " + QuestToString(nID), COLOR_CYAN));
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
                        nMinimumObjectives = SqlGetInt(sqlSub, ++n);
                        nRandomObjectives = SqlGetInt(sqlSub, ++n);

                        string sStep = HexColorString(IntToString(nStep), COLOR_CYAN);
                        Debug("    " + sStep + "  Journal  " + ColorValue(sJournalEntry) +
                            "\n        Time Limit  " + ColorValue(TimeVectorToString(sTimeLimit)) +
                            "\n        Party Completion  " + ColorValue((nPartyCompletion ? "TRUE":"FALSE")) +
                            "\n        Proximity Required  " + ColorValue((nProximity ? "TRUE":"FALSE")) +
                            "\n        Step Type  " + ColorValue(StepTypeToString(nStepType)) +
                            "\n        Minimum Objective Count  " + ColorValue(IntToString(nMinimumObjectives)) +
                            "\n        Random Objective Count  " + ColorValue(IntToString(nRandomObjectives)));
                    
                        // Another inside loop for the step objectives/properties
                        Debug(HexColorString("        Dumping step properties for " + StepToString(nStep), COLOR_CYAN));
                        sNewQuery = "SELECT quest_step_properties.* FROM quest_steps INNER JOIN quest_step_properties " +
                                        "ON quest_steps.id = quest_step_properties.quest_steps_id " +
                                    "WHERE quest_steps.quests_id = @id " +
                                    "AND quest_steps.nStep = @step;";
                        sqlNew = SqlPrepareQueryObject(GetModule(), sNewQuery);
                        SqlBindInt(sqlNew, "@id", nID);
                        SqlBindInt(sqlNew, "@step", nStep);

                        while (SqlStep(sqlNew))
                        {
                            int n = 1;
                            int nCategoryType = SqlGetInt(sqlNew, ++n);
                            int nValueType = SqlGetInt(sqlNew, ++n);
                            string sKey = SqlGetString(sqlNew, ++n);
                            string sValue = SqlGetString(sqlNew, ++n);
                            string sValueMax = SqlGetString(sqlNew, ++n);
                            string sData = SqlGetString(sqlNew, ++n);
                            int bParty = SqlGetInt(sqlNew, ++n);

                            Notice(TranslateCategoryValue(nCategoryType, nValueType, sKey, sValue, sValueMax, sData, bParty));
                        }
                    }       
                }
                else
                    Debug(HexColorString("    No step data found for " + QuestToString(nID), COLOR_RED_LIGHT));
            }

            if (!bDataFound)
                Debug("  No quest data found");

            // Dump variables
            Debug(HexColorString("Dumping Quest Variables", COLOR_CYAN));
            if (GetTableExists(GetModule(), "quest_variables") == FALSE)
                Debug(HexColorString("  Variables table does not exist on the module", COLOR_RED_LIGHT));
            else if (CountQuestVariables(GetModule(), "quest_variables") == 0)
                Debug(HexColorString("  No quest variables found for the module", COLOR_RED_LIGHT));
            else
            {
                if (sRequestedQuest == "")
                {
                    sQuery = "SELECT * FROM quest_variables;";
                    sql = SqlPrepareQueryObject(GetModule(), sQuery);
                }
                else
                {
                    sQuery = "SELECT * FROM quest_variables WHERE quests_id = @id;";
                    sql = SqlPrepareQueryObject(GetModule(), sQuery);
                    SqlBindInt(sql, "@id", GetQuestID(sRequestedQuest));
                }

                int bColor = FALSE;
                while(SqlStep(sql))
                {
                    string sPCQuestTag = GetQuestTag(SqlGetInt(sql, 0));
                    string sPCType = SqlGetString(sql, 1);
                    string sPCName = SqlGetString(sql, 2);
                    string sPCValue = SqlGetString(sql, 3);

                    int nColor = bColor ? COLOR_GRAY : COLOR_GRAY_LIGHT;

                    Debug(HexColorString("  Quest Tag -> ", nColor) + ColorValue(sPCQuestTag, FALSE, bColor) + 
                        HexColorString("\n    Type -> ", nColor) + ColorValue((sPCType == "INT" ? "INTEGER" : "STRING"), FALSE, bColor) +
                        HexColorString("\n    Var Name -> ", nColor) + ColorValue(sPCName, FALSE, bColor) +
                        HexColorString("\n    Value -> ", nColor) + ColorValue(sPCValue, FALSE, bColor));

                    bColor = !bColor;
                }
            }
        }
    }
}
