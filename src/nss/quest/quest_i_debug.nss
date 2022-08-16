#include "util_i_debug"
#include "util_i_csvlists"
#include "util_i_math"
#include "quest_i_const"

const int DISPLAY_DB_RETRIEVALS = TRUE;

string _GetKey(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, 0, nIndex);
}

string _GetValue(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, ++nIndex, GetStringLength(sPair));
}

string AwardTypeToString(int nAwardType)
{
    switch (nAwardType)
    {
        case AWARD_ALL: return "ALL";
        case AWARD_GOLD: return "GOLD";
        case AWARD_XP: return "XP";
        case AWARD_ITEM: return "ITEMS";
        case AWARD_ALIGNMENT: return "ALIGNMENT";
        case AWARD_QUEST: return "QUEST";
        case AWARD_MESSAGE: return "MESSAGE";
    }

    return "[NOT FOUND]";
}

string AlignmentAxisToString(int nAxis)
{
    switch (nAxis)
    {
        case ALIGNMENT_ALL: return "ALL";
        case ALIGNMENT_CHAOTIC: return "CHAOTIC";
        case ALIGNMENT_EVIL: return "EVIL";
        case ALIGNMENT_GOOD: return "GOOD";
        case ALIGNMENT_LAWFUL: return "LAWFUL";        
        case ALIGNMENT_NEUTRAL: return "NEUTRAL";
    }

    return "[NOT FOUND]";
}

string ClassToString(int nClass)
{
    switch (nClass)
    {
        case CLASS_TYPE_ABERRATION: return "ABERRATION";
        case CLASS_TYPE_ANIMAL: return "ANIMAL";
        case CLASS_TYPE_ARCANE_ARCHER: return "ARCANE ARCHER";
        case CLASS_TYPE_ASSASSIN: return "ASSASSIN";
        case CLASS_TYPE_BARBARIAN: return "BARBARIAN";
        case CLASS_TYPE_BARD: return "BARD";
        case CLASS_TYPE_BEAST: return "BEAST";
        case CLASS_TYPE_CLERIC: return "CLERIC"; 
        case CLASS_TYPE_COMMONER: return "COMMONER";
        case CLASS_TYPE_CONSTRUCT: return "CONSTRUCT";
        //case CLASS_TYPE_DIVINECHAMPION:
        case CLASS_TYPE_DIVINE_CHAMPION: return "DIVINE CHAMPION";
        case CLASS_TYPE_DRAGON: return "DRAGON";
        //case CLASS_TYPE_DRAGONDISCIPLE:
        case CLASS_TYPE_DRAGON_DISCIPLE: return "DRAGON DISCIPLE";
        case CLASS_TYPE_DRUID: return "DRUID"; 
        //case CLASS_TYPE_DWARVENDEFENDER:
        case CLASS_TYPE_DWARVEN_DEFENDER: return "DWARVEN DEFENDER";
        case CLASS_TYPE_ELEMENTAL: return "ELEMENTAL";
        case CLASS_TYPE_EYE_OF_GRUUMSH: return "GRUUMSH";
        case CLASS_TYPE_FEY: return "FEY";
        case CLASS_TYPE_FIGHTER: return "FIGHTER"; 
        case CLASS_TYPE_GIANT: return "GIANT";
        case CLASS_TYPE_HARPER: return "HARPER";
        case CLASS_TYPE_HUMANOID: return "HUMANOID";
        case CLASS_TYPE_INVALID: return "INVALID";
        case CLASS_TYPE_MAGICAL_BEAST: return "MAGICAL BEAST";
        case CLASS_TYPE_MONK: return "MONK"; 
        case CLASS_TYPE_MONSTROUS: return "MONSTROUS";
        case CLASS_TYPE_OOZE: return "OOZE";
        case CLASS_TYPE_OUTSIDER: return "OUTSIDER";
        case CLASS_TYPE_PALADIN: return "PALADIN";
        //case CLASS_TYPE_PALEMASTER: return "PALE MASTER";
        case CLASS_TYPE_PALE_MASTER	: return "PALE MASTER";
        case CLASS_TYPE_PURPLE_DRAGON_KNIGHT: return "PURPLE DRAGON KNIGHT";
        case CLASS_TYPE_RANGER: return "RANGER";
        case CLASS_TYPE_ROGUE: return "ROGUE"; 
        case CLASS_TYPE_SHADOWDANCER: return "SHADOW DANCER";
        case CLASS_TYPE_SHAPECHANGER: return "SHAPE CHANGER";
        case CLASS_TYPE_SHOU_DISCIPLE: return "SHOU DISCIPLE"; 
        case CLASS_TYPE_SHIFTER: return "SHIFTER";
        case CLASS_TYPE_SORCERER: return "SORCERER";
        case CLASS_TYPE_UNDEAD: return "UNDEAD"; 
        case CLASS_TYPE_VERMIN: return "VERMIN";
        case CLASS_TYPE_WEAPON_MASTER: return "WEAPON MASTER";
        case CLASS_TYPE_WIZARD: return "WIZARD"; 
    }

    // if we're here must be a custom class
    string sField = "Name";
    string sRef = Get2DAString("classes", sField, nClass);

    if (sRef != "")
        return GetStringByStrRef(StringToInt(sRef));
    else
        return "[NOT FOUND]";
}

string StepToString(int nStep)
{
    return HexColorString("Step " + IntToString(nStep), COLOR_PINK);
}

string RaceToString(int nRace)
{
    switch (nRace)
    {
        case RACIAL_TYPE_ABERRATION: return "ABERRATION";
        case RACIAL_TYPE_ALL: return "ALL|INVALID";
        case RACIAL_TYPE_ANIMAL: return "ANIMAL";
        case RACIAL_TYPE_BEAST: return "BEAST";
        case RACIAL_TYPE_CONSTRUCT: return "CONSTRUCT";
        case RACIAL_TYPE_DRAGON: return "DRAGON";
        case RACIAL_TYPE_DWARF: return "DWARF";
        case RACIAL_TYPE_ELEMENTAL: return "ELEMENTAL";
        case RACIAL_TYPE_ELF: return "ELF";
        case RACIAL_TYPE_FEY: return "FEY";
        case RACIAL_TYPE_GIANT: return "GIANT";
        case RACIAL_TYPE_GNOME: return "GNOME";
        case RACIAL_TYPE_HALFELF: return "HALF ELF";
        case RACIAL_TYPE_HALFLING: return "HALFLING";
        case RACIAL_TYPE_HALFORC: return "HALF ORC";
        case RACIAL_TYPE_HUMAN: return "HUMAN";
        case RACIAL_TYPE_HUMANOID_GOBLINOID: return "HUMANOID GOBLINOID";
        case RACIAL_TYPE_HUMANOID_MONSTROUS: return "HUMANOID MONSTROUS";
        case RACIAL_TYPE_HUMANOID_ORC: return "HUMANOID ORC";
        case RACIAL_TYPE_HUMANOID_REPTILIAN: return "HUMANOID REPTILIAN";
        //case RACIAL_TYPE_INVALID: return "INVALID";
        case RACIAL_TYPE_MAGICAL_BEAST: return "MAGICAL BEAST";
        case RACIAL_TYPE_OOZE: return "OOZE";
        case RACIAL_TYPE_OUTSIDER: return "OUTSIDER";
        case RACIAL_TYPE_SHAPECHANGER: return "SHAPE CHANGER";
        case RACIAL_TYPE_UNDEAD: return "UNDEAD";
        case RACIAL_TYPE_VERMIN: return "VERMIN";
    }

    return "[NOT FOUND]";
}

string JournalLocationToString(int nJournalLocation)
{
    switch (nJournalLocation)
    {
        case QUEST_JOURNAL_NONE: return "NONE";
        case QUEST_JOURNAL_NWN: return "NWN";
        case QUEST_JOURNAL_NWNX: return "NWNX";
    }

    return "[NOT FOUND]";
}

string ColorHeading(string sValue)
{
    return HexColorString(sValue, COLOR_GRAY_LIGHT);
}

string ColorValue(string sValue, int nZeroIsEmpty = FALSE, int bStripe = FALSE)
{
    if (sValue == "" || (nZeroIsEmpty && sValue == "0") || sValue == "-1")
        return HexColorString("[EMPTY]", COLOR_GRAY);
    else if (sValue == "[NOT FOUND]")
        return HexColorString(sValue, COLOR_RED_LIGHT);
    else
        return HexColorString(sValue, bStripe ? COLOR_BLUE : COLOR_BLUE_LIGHT);
}

string ScriptTypeToString(int nScriptType)
{
    switch (nScriptType)
    {
        case QUEST_SCRIPT_TYPE_ON_ACCEPT: return "ON_ACCEPT";
        case QUEST_SCRIPT_TYPE_ON_ADVANCE: return "ON_ADVANCE";
        case QUEST_SCRIPT_TYPE_ON_COMPLETE: return "ON_COMPLETE";
        case QUEST_SCRIPT_TYPE_ON_FAIL: return "ON_FAIL";
    }
    
    return "[NOT FOUND]";
}

string ObjectiveTypeToString(int nObjectiveType)
{
    switch (nObjectiveType)
    {
        case QUEST_OBJECTIVE_GATHER: return "GATHER";
        case QUEST_OBJECTIVE_KILL: return "KILL";
        case QUEST_OBJECTIVE_DELIVER: return "DELIVER";
        case QUEST_OBJECTIVE_SPEAK: return "SPEAK";
        case QUEST_OBJECTIVE_DISCOVER: return "DISCOVER";
    }

    return "[NOT FOUND]";
}

string StepTypeToString(int nStepType)
{
    switch (nStepType)
    {
        case QUEST_STEP_TYPE_PROGRESS: return "PROGRESS";
        case QUEST_STEP_TYPE_SUCCESS: return "SUCCESS";
        case QUEST_STEP_TYPE_FAIL: return "FAIL";
    }

    return "[NOT FOUND]";
}

string AbilityToString(int nAbility)
{
    switch (nAbility)
    {
        case ABILITY_CHARISMA: return "CHARISMA";
        case ABILITY_CONSTITUTION: return "CONSTITUTION";
        case ABILITY_DEXTERITY: return "DEXTERITY";
        case ABILITY_INTELLIGENCE: return "INTELLIGENCE";
        case ABILITY_STRENGTH: return "STRENGTH";
        case ABILITY_WISDOM: return "WISDOM";
    }

    return "[NOT FOUND]";
}

string ValueTypeToString(int nValueType, int nCategoryType = QUEST_CATEGORY_PREREQUISITE)
{
    if (nCategoryType != QUEST_CATEGORY_OBJECTIVE)
    {
        switch (nValueType)
        {
            case QUEST_VALUE_NONE: return "NONE";
            case QUEST_VALUE_ALIGNMENT: return "ALIGNMENT";
            case QUEST_VALUE_CLASS: return "CLASS";
            case QUEST_VALUE_GOLD: return "GOLD";
            case QUEST_VALUE_ITEM: return "ITEM";
            case QUEST_VALUE_LEVEL_MAX: return "LEVEL_MAX";
            case QUEST_VALUE_LEVEL_MIN: return "LEVEL_MIN";
            case QUEST_VALUE_QUEST: return "QUEST";
            case QUEST_VALUE_RACE: return "RACE";
            case QUEST_VALUE_XP: return "XP";
            case QUEST_VALUE_REPUTATION: return "REPUTATION";
            case QUEST_VALUE_MESSAGE: return "MESSAGE";
            case QUEST_VALUE_QUEST_STEP: return "QUEST_STEP";
            case QUEST_VALUE_SKILL: return "SKILL";
            case QUEST_VALUE_ABILITY: return "ABILITY";
            case QUEST_VALUE_VARIABLE: return "VARIABLE";
        }
    }
    else
        return ObjectiveTypeToString(nValueType);

    return "[NOT FOUND]";
}

string GetPrefix()
{
    return HexColorString("[quest] ", COLOR_GOLD);
}

void QuestDebug(string sMessage)
{
    Debug(GetPrefix() + sMessage);
}

void QuestNotice(string sMessage)
{
    Notice(GetPrefix() + sMessage);
}

void QuestWarning(string sMessage)
{
    Warning(GetPrefix() + sMessage);
}

void QuestError(string sMessage)
{
    Error(GetPrefix() + sMessage);
}

void QuestCriticalError(string sMessage)
{
    CriticalError(GetPrefix() + sMessage);
}

string PCToString(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return HexColorString("[NOT FOUND]", COLOR_RED_LIGHT);

    return HexColorString(GetName(oPC), COLOR_VIOLET);
}

string CategoryTypeToString(int nCategoryType)
{
    switch (nCategoryType)
    {
        case QUEST_CATEGORY_PREREQUISITE: return "PREREQUISITE";
        case QUEST_CATEGORY_OBJECTIVE: return "OBJECTIVE";
        case QUEST_CATEGORY_PREWARD: return "PREWARD";
        case QUEST_CATEGORY_REWARD: return "REWARD";
    }

    return "[NOT FOUND]";
}

string ResolutionToString(int bQualifies)
{
    string sResult = "Assignable";
    if (bQualifies)
        return HexColorString(sResult, COLOR_GREEN_LIGHT);
    else
        return HexColorString("NOT " + sResult, COLOR_RED_LIGHT);
}

string SkillToString(int nSkill)
{
    switch (nSkill)
    {
        case SKILL_ALL_SKILLS: return "ALL";
        case SKILL_ANIMAL_EMPATHY: return "ANIMAL EMPATHY";
        case SKILL_APPRAISE: return "APPRAISE";
        case SKILL_BLUFF: return "BLUFF";
        case SKILL_CONCENTRATION: return "CONCENTRATION";
        case SKILL_CRAFT_ARMOR: return "CRAFT ARMOR";
        case SKILL_CRAFT_TRAP: return "CRAFT TRAP";
        case SKILL_CRAFT_WEAPON: return "CRAFT WEAPON";
        case SKILL_DISABLE_TRAP: return "DISABLE TRAP";
        case SKILL_DISCIPLINE: return "DISCIPLINE";
        case SKILL_HEAL: return "HEAL";
        case SKILL_HIDE: return "HIDE";
        case SKILL_INTIMIDATE: return "INTIMIDATE";
        case SKILL_LISTEN: return "LISTEN";
        case SKILL_LORE: return "LORE";
        case SKILL_MOVE_SILENTLY: return "MOVE SILENTLY";
        case SKILL_OPEN_LOCK: return "OPEN LOCK";
        case SKILL_PARRY: return "PARRY";
        case SKILL_PERFORM: return "PERFORM";
        case SKILL_PERSUADE: return "PERSUADE";
        case SKILL_PICK_POCKET: return "PICK POCKET";
        case SKILL_RIDE: return "RIDE";
        case SKILL_SEARCH: return "SEARCH";
        case SKILL_SET_TRAP: return "SET TRAP";
        case SKILL_SPELLCRAFT: return "SPELLCRAFT";
        case SKILL_SPOT: return "SPOT";
        case SKILL_TAUNT: return "TAUNT";
        case SKILL_TUMBLE: return "TUMBLE";
        case SKILL_USE_MAGIC_DEVICE: return "USE MAGIC DEVICE";
    }

    return "[NOT FOUND]";
}

string VersionActionToString(int nQuestVersionAction)
{
    switch (nQuestVersionAction)
    {
        case QUEST_VERSION_ACTION_NONE: return "NONE";
        case QUEST_VERSION_ACTION_RESET: return "RESET";
        case QUEST_VERSION_ACTION_DELETE: return "DELETE";
    }

    return "[NOT FOUND]";
}

string TranslateCategoryValue(int nCategoryType, int nValueType, string sKey, string sValue, 
                              string sValueMax, string sData, int bParty)
{
    string sIndent = "            ";
    string sDelimiter = HexColorString(" | ", COLOR_GRAY);
    int nValue = StringToInt(sValue);
    int nValueMax = StringToInt(sValueMax);

    string sCategory = HexColorString(CategoryTypeToString(nCategoryType), COLOR_GREEN_LIGHT);
    string sValueType = ColorValue(ValueTypeToString(nValueType, nCategoryType));

    if (nCategoryType != QUEST_CATEGORY_OBJECTIVE)
    {
        switch (nValueType)
        {
            case QUEST_VALUE_ALIGNMENT:
                sKey = AlignmentAxisToString(StringToInt(sKey));
                //nValue = StringToInt(sValue);
                if (nValue == 0)
                    sValue = "Any";
                break;
            case QUEST_VALUE_CLASS:
                sKey = ClassToString(StringToInt(sKey));
                //nValue = StringToInt(sValue);
                if (nValue == -1)
                    sValue = "Any";
                else if (nValue == 0)
                    sValue = "Excluded";
                else
                    sValue = ">= " + IntToString(nValue) + " level" + (nValue == 1 ? "" : "s");
                break;
            case QUEST_VALUE_RACE:
                sKey = RaceToString(StringToInt(sKey));
                //nValue = StringToInt(sValue);
                if (nValue == 1)
                    sValue = "Included";
                else
                    sValue = "Excluded";
                break;
            case QUEST_VALUE_GOLD:
                sKey = " ";
                sValue += "gp";
                break;
            case QUEST_VALUE_LEVEL_MAX:
                sKey = " ";
                sValue = "<= " + sValue;
                break;
            case QUEST_VALUE_LEVEL_MIN:
                sKey = " ";
                sValue = ">= " + sValue;
                break;
            case QUEST_VALUE_ITEM:
                sValue = ">= " + sValue;
                break;
            case QUEST_VALUE_XP:
                sKey = " ";
                sValue += "xp";
                break;
            case QUEST_VALUE_MESSAGE:
                sKey = " ";
                break;
        }
    }

    if (sKey != " ")
        sKey = ColorValue(sKey);

    if (sValue == "")
        sValue = IntToString(nValue);

    if (nValue > 0 && nValueMax > nValue)
        sValue += " -> " + sValueMax;

    sValue = ColorValue(sValue);

    return
        sIndent + sCategory + sDelimiter + sValueType + sDelimiter +
        (sKey != " " ? sKey + sDelimiter : "") +
        sValue + (sData != "" ? sDelimiter + ColorValue(sData) : "");
}

string TranslateValue(int nValueType, string sKey, string sValue)
{
    string sValueType;
    string sKeyTitle;
    string sValueTitle;
    
    string sIndent = "   ";
    string sDelimiter = HexColorString(" | ", COLOR_GRAY);

    sValueType = HexColorString(ValueTypeToString(nValueType), COLOR_GREEN_LIGHT);
    switch (nValueType)
    {
        case QUEST_VALUE_ALIGNMENT:
            sKey = AlignmentAxisToString(StringToInt(sKey));
            if (sValue == "0")
                sValue = "Any";
            break;
        case QUEST_VALUE_CLASS:
            sKey = ClassToString(StringToInt(sKey));
            if (sValue == "-1")
                sValue = "Any";
            else if (sValue == "0")
                sValue = "Excluded";
            else
                sValue = ">= " + sValue + " level" + (sValue == "1" ? "" : "s");
            break;
        case QUEST_VALUE_RACE:
            sKey = RaceToString(StringToInt(sKey));
            if (sValue == "1")
                sValue = "Included";
            else
                sValue = "Excluded";
            break;
        case QUEST_VALUE_GOLD:
        {
            string sOperator = _GetKey(sValue);
            sValue = sOperator + " " + _GetValue(sValue) + "gp";

            sKey = " ";
            //sValue += "gp";
            break;
        }
        case QUEST_VALUE_LEVEL_MAX:
            sKey = " ";
            sValue = "<= " + sValue;
            break;
        case QUEST_VALUE_LEVEL_MIN:
            sKey = " ";
            sValue = ">= " + sValue;
            break;
        case QUEST_VALUE_ITEM:
            sValue = ">= " + sValue;
            break;
        case QUEST_VALUE_XP:
            sKey = " ";
            sValue += "xp";
            break;
        case QUEST_VALUE_REPUTATION:
            sKey = " ";
            sValue = (StringToInt(sValue) >= 0 ? ">=" : "<") + sValue;
            break;
        case QUEST_VALUE_VARIABLE:
            sKey = _GetKey(sKey) + " " + _GetValue(sKey);
            sValue = _GetKey(sValue) + " " + (_GetKey(sKey) == "STRING" ? "\"" + _GetValue(sValue) + "\"" :
                                                    _GetValue(sValue));
            break;
    }

    if (sKey != " ")
        sKey = ColorValue(sKey);

    sValue = ColorValue(sValue);

    return
        sIndent + sValueType + sDelimiter +
        (sKey != " " ? sKey + sDelimiter : "") +
        sValue;
}

string TimeVectorToString(string sTimeVector)
{
    string sUnit, sResult, sElement, sUnits = "Year, Month, Day, Hour, Minute, Second";

    int n, nCount = CountList(sTimeVector);
    for (n = 0; n < nCount; n++)
    {
        sElement = GetListItem(sTimeVector, n);
        sUnit = GetListItem(sUnits, n);

        if (sElement != "0")
            sResult += (sResult == "" ? "" : ", ") + sElement + " " + sUnit + (sElement == "1" ? "" : "s");
    }

    return sResult;
}

string _GetQuestTag(int nQuestID)
{
    string sQuery = "SELECT sTag FROM quest_quests " +
             "WHERE id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

string _QuestToString(int nQuestID)
{
    string sTag = _GetQuestTag(nQuestID);

    if (sTag == "")
        return "[NOT FOUND]";

    return HexColorString(sTag + " (ID " + IntToString(nQuestID) + ")", COLOR_ORANGE_LIGHT);
}

void HandleDebugging(string sType, string s1 = "", string s2 = "", string s3 = "", string s4 = "", 
                                   string s5 = "", string s6 = "", string s7 = "", string s8 = "")
{
    string sResult;
    string sKey = _GetKey(sType);
    string sValue = _GetValue(sType);

    if (sKey == "SQL") // SQL:type || s1 = result
    {
        int bSuccess = StringToInt(s1);
        string sQuest = _QuestToString(StringToInt(s2));

        if (sValue == "table")  // s2 = table name || s3 = target
        {
            if (bSuccess)
                sResult = "Created or confirmed existence of table '" + s2 + "' in sqlite database for " + s3;
            else
                QuestError("Error creating table '" + s2 + "' in sqlite database for " + s3);
        }
        else if (sValue == "retrieve-field") // s2 = questID || s3 = field name || s4 = target || s5 = result value
        {
            sResult = "Attempting to retrieve quest data from " + s4 +
                "\n  Quest -> " + sQuest +
                "\n  Field -> " + s3 +
                "\n  Result -> ";
            
            if (s5 != "")
                sResult += s5;
            else
                sResult += HexColorString("[NOT FOUND]", COLOR_RED_LIGHT);
        }
        else if (sValue == "set-field") // s2 = questID || s3 = field name || s4 = target || s5 = field value
        {
            sResult = "Attempting to set quest data for " + s4 +
                "\n  Quest -> " + sQuest +
                "\n  Field -> " + s3 +
                "\n  Value -> " + s5 +
                "\n  Result -> ";

            if (bSuccess)
                sResult += HexColorString("[Request Succeeded]", COLOR_GREEN_LIGHT);
            else
                sResult += HexColorString("[Request Failed]", COLOR_RED_LIGHT);
        }
        else if (sValue == "set-step") // s2 = questID || s3 = step || s4 = field name || s5 = field value
        {
            sResult = "Attempting to set quest step data for " + sQuest + "  " + StepToString(StringToInt(s3)) +
                "\n  Field -> " + s4 +
                "\n  Value -> " + s5 +
                "\n  Result -> ";

            if (bSuccess)
                sResult += HexColorString("[Request Succeeded]", COLOR_GREEN_LIGHT);
            else
                sResult += HexColorString("[Request Failed]", COLOR_RED_LIGHT);
        }
        else if (sValue == "retrieve-step") // s2 = questID || s3 = step || s4 = field name || s5 = result value
        {
            sResult = "Attempting to retrieve quest step data for " + sQuest + "  " + StepToString(StringToInt(s3)) +
                "\n  Field -> " + s4 +
                "\n  Result -> ";
            
            if (s5 != "")
                sResult += s5;
            else
                sResult += HexColorString("[NOT FOUND]", COLOR_RED_LIGHT);
        }
        else if (sValue == "set-step-property") // s2 = questID || s3 = step || s4 = category || s5 = value type || s6 = key || s7 = value || s8 = data
        {
            string sValue;        
            if (StringToInt(s4) == QUEST_CATEGORY_OBJECTIVE)
                sValue = ObjectiveTypeToString(StringToInt(s5));
            else
                sValue = ValueTypeToString(StringToInt(s5));
                          
            sResult = "Attempting to set property for " + _QuestToString(StringToInt(s2)) + "  " + StepToString(StringToInt(s3)) +
                "\n  Category -> " + CategoryTypeToString(StringToInt(s4)) +
                "\n  Value Type -> " + sValue +
                "\n  Key -> " + s6 +
                "\n  Value -> " + s7 +
                "\n  Data -> " + s8 +
                "\n  Result -> ";

            if (bSuccess)
                sResult += HexColorString("[Request Succeeded]", COLOR_GREEN_LIGHT);
            else
                sResult += HexColorString("[Request Failed]", COLOR_RED_LIGHT);
        }
    }

    if (sResult != "" && DISPLAY_DB_RETRIEVALS)
        QuestDebug(sResult);
}

void HandleSqlDebugging(sqlquery sql, string sType = "", string s2 = "", string s3 = "", string s4 = "", string s5 = "", string s6 = "", string s7 = "", string s8 = "")
{
    string s1, sError = SqlGetError(sql);
    if (sError == "") s1 = "1";
    else s1 = "0";

    if (sType == "ERROR" || sType == "" || sError != "")
    {
        if (sError != "")
            QuestCriticalError(sError);
    }
    else
        HandleDebugging(sType, s1, s2, s3, s4, s5, s6, s7, s8);
}
