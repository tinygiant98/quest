/// ----------------------------------------------------------------------------
/// @file   quest_i_const.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Quest System (constants)
/// ----------------------------------------------------------------------------

/// @brief The quest system is a flexible and powerful system for creating and
///     managing quests in Neverwinter Nights.  The system is designed to be
///     easy to use and flexible enough to handle a wide variety of quest types.

/// @note This version of the quest system requires some compiler and game
///     features recently added to NWN:EE.

/// @warning Minimum Game Version: 36.12

// -----------------------------------------------------------------------------
//                             Quest System Configuration
// -----------------------------------------------------------------------------

/// @note All values set below are default values and can be overriden on a
///     per-quest or per-set basis during the quest definition process.

/// @brief The quest system can use either the standard NWN journal system or
///     the NWNX journal system.  Quests can be built to use existing journal
///     entries, or custom journal entries can be added during the definition
///     process.  Set QUEST_CONFIG_JOURNAL_HANDLER to one of the following
///     three values.
/// @note This is a default value and can be change per-quest during the quest
///     definition process.
const int QUEST_JOURNAL_NONE = 0;
const int QUEST_JOURNAL_NWN  = 1;
const int QUEST_JOURNAL_NWNX = 2;

const int QUEST_CONFIG_JOURNAL_HANDLER = QUEST_JOURNAL_NWN;

/// @brief Set the following value to TRUE to have new quests active by default.
const int QUEST_CONFIG_QUEST_ACTIVE = TRUE;

/// @brief Set the following value to TRUE to have new quest steps active by default.
const int QUEST_CONFIG_STEP_ACTIVE = TRUE;

// For semi-randomized quest objectives, you can override the standard journal entry with
// the custom message created for the random objectives.  To override the step's normal
// journal entry, set this value to TRUE.
const int QUEST_CONFIG_USE_CUSTOM_MESSAGE = TRUE;

// -----------------------------------------------------------------------------
//                      END - Quest System Configuration
//                    DO NOT CHANGE ANTYING BELOW THIS LINE
// -----------------------------------------------------------------------------

#include "util_i_debug"
#include "util_i_constants"
#include "util_i_strings"

const string THIS = "quest_i_const";

// Versioning
const string QUEST_SYSTEM_VERSION = "2.0.0";

// Variable names for event scripts
// THESE ARE USED BY THE SYSTEM
const string QUEST_CURRENT_QUEST = "QUEST_CURRENT_QUEST";
const string QUEST_CURRENT_STEP = "QUEST_CURRENT_STEP";
const string QUEST_CURRENT_EVENT = "QUEST_CURRENT_EVENT";

const string QUEST_DATABASE = "quest_database";

/// @brief These key values are used to replace placeholders in the quest schema.
///     These are the keys that will be used within the quest documents to
///     store quest definition and progression data.
/// @warning These values can be modified, but should only be modified before
///     the first use of the quest system within a specific module.  There are
///     no methods provided to update these values in records that have already
///     been saved to the database.   DO NOT CHANGE THESE VALUES UNLESS YOU
///     UNDERSTAND THE RAMIFICATIONS OF DOING SO, and really, there is no reason
///     to do so.
/// @warning All keys must be unique.  Repeated keys could lead to inaccurate
///     value pathing, causing data integrity to be lost.
/// @warning Adding or deleting keys should only be accomplished if the quest
///     system schema is modified to reflect the changes.
const string QUEST_KEY_ACTIVE = "questActive";
const string QUEST_KEY_PRECOLLECTED = "questAllowPrecollected";
const string QUEST_KEY_JOURNAL_HANDLER = "questJournalHandler";
const string QUEST_KEY_JOURNAL_TITLE = "questJournalTitle";
const string QUEST_KEY_JOURNAL_REMOVE = "questJournalRemoveOnCompleted";
const string QUEST_KEY_REMOVE = "questRemoveOnCompleted";
const string QUEST_KEY_REPETITIONS = "questRepetitions";
const string QUEST_KEY_TIME_COOLDOWN = "questTimeCooldown";
const string QUEST_KEY_TIME_LIMIT = "questTimeLimit";
const string QUEST_KEY_VERSION_VERSION = "questVersion";
const string QUEST_KEY_VERSION_ACTION = "questVersionAction";

const string QUEST_KEY_ON_ACCEPT = "onAccept";
const string QUEST_KEY_ON_ADVANCE = "onAdvance";
const string QUEST_KEY_ON_ALL = "onAll";
const string QUEST_KEY_ON_ASSIGN = "onAssign";
const string QUEST_KEY_ON_COMPLETE = "onComplete";
const string QUEST_KEY_ON_FAIL = "onFail";

const string QUEST_KEY_STEP_ACTIVE = "stepActive";
const string QUEST_KEY_STEP_JOURNAL_ENTRY = "stepJournalEntry";
const string QUEST_KEY_STEP_OBJECTIVE_MINIMUM = "stepObjectiveMinimum";
const string QUEST_KEY_STEP_OBJECTIVE_RANDOM = "stepObjectiveRandom";
const string QUEST_KEY_STEP_ORDINAL = "stepOrdinal";
const string QUEST_KEY_STEP_PARTY_COMPLETION = "stepPartyCompletion";
const string QUEST_KEY_STEP_PARTY_PROXIMITY = "stepPartyProximity";
const string QUEST_KEY_STEP_TIME_LIMIT = "stepTimeLimit";
const string QUEST_KEY_STEP_TYPE = "stepType";

const string QUEST_KEY_CATEGORY_CATEGORY = "category";
const string QUEST_KEY_CATEGORY_TYPE = "categoryType";
const string QUEST_KEY_CATEGORY_KEY = "categoryKey";
const string QUEST_KEY_CATEGORY_VALUE = "categoryValue";
const string QUEST_KEY_CATEGORY_PARTY = "categoryParty";

const string QUEST_KEY_OBJECTIVE_TYPE = "objectiveType";
const string QUEST_KEY_OBJECTIVE_TAG = "objectiveTag";
const string QUEST_KEY_OBJECTIVE_VALUE = "objectiveValue";
const string QUEST_KEY_OBJECTIVE_MAX = "objectiveMax";
const string QUEST_KEY_OBJECTIVE_DATA = "objectiveData";

const string QUEST_KEY_PREREQUISITE_TYPE = "prerequisiteType";
const string QUEST_KEY_PREREQUISITE_KEY = "prerequisiteKey";
const string QUEST_KEY_PREREQUISITE_VALUE = "prerequisiteValue";






// Quest Categories and Values
// Should these be bitwise?
// Or can we use hash values here and change to string
//      value to make reading json easier?
const int QUEST_CATEGORY_PREREQUISITE = 1;
const int QUEST_CATEGORY_OBJECTIVE = 2;
const int QUEST_CATEGORY_PREWARD = 3;
const int QUEST_CATEGORY_REWARD = 4;

// Should these be bitwise?
const int QUEST_VALUE_NONE = 0;
const int QUEST_VALUE_ALIGNMENT = 1;
const int QUEST_VALUE_CLASS = 2;
const int QUEST_VALUE_GOLD = 3;
const int QUEST_VALUE_ITEM = 4;
const int QUEST_VALUE_LEVEL_MAX = 5;
const int QUEST_VALUE_LEVEL_MIN = 6;
const int QUEST_VALUE_QUEST = 7;
const int QUEST_VALUE_RACE = 8;
const int QUEST_VALUE_XP = 9;
const int QUEST_VALUE_REPUTATION = 10;
const int QUEST_VALUE_MESSAGE = 11;
const int QUEST_VALUE_QUEST_STEP = 12;
const int QUEST_VALUE_SKILL = 13;
const int QUEST_VALUE_ABILITY = 14;
const int QUEST_VALUE_VARIABLE = 15;
const int QUEST_VALUE_FLOATINGTEXT = 16;

// Quest Step Types
// again with text/hash?
const int QUEST_STEP_TYPE_PROGRESS = 0;
const int QUEST_STEP_TYPE_SUCCESS = 1;
const int QUEST_STEP_TYPE_FAIL = 2;

// Quest Advance Types
// again with the text/hash

const int QUEST_ADVANCE_SUCCESS = 1;
const int QUEST_ADVANCE_FAIL = 2;

// Quest Objective Types
// again with the text/hash?
const int QUEST_OBJECTIVE_GATHER = 1;
const int QUEST_OBJECTIVE_KILL = 2;
const int QUEST_OBJECTIVE_DELIVER = 3;
const int QUEST_OBJECTIVE_SPEAK = 4;
const int QUEST_OBJECTIVE_DISCOVER = 5;

// Quest Award Bitmasks
const int AWARD_ALL = 0x000;
const int AWARD_GOLD = 0x001;
const int AWARD_XP = 0x002;
const int AWARD_ITEM = 0x004;
const int AWARD_ALIGNMENT = 0x008;
const int AWARD_QUEST = 0x010;
const int AWARD_MESSAGE = 0x020;
const int AWARD_VARIABLE = 0x040;
const int AWARD_REPUTATION = 0x080;
const int AWARD_FLOATINGTEXT = 0x100;

// Quest Events
const int QUEST_EVENT_ON_ASSIGN = 1;
const int QUEST_EVENT_ON_ACCEPT = 2;
const int QUEST_EVENT_ON_ADVANCE = 3;
const int QUEST_EVENT_ON_COMPLETE = 4;
const int QUEST_EVENT_ON_FAIL = 5;


// Variable Validity
const string REQUEST_INVALID = "REQUEST_INVALID";

// Odds & Ends
const int QUEST_PAIR_KEYS = 1;
const int QUEST_PAIR_VALUES = 2;

// Quest Matching
const int QUEST_MATCH_NONE = 0;
const int QUEST_MATCH_PC = 1;
const int QUEST_MATCH_PARTY = 2;
const int QUEST_MATCH_ALL = 3;

// Time Format
const string QUEST_TIME_FORMAT = "MMM d, yyyy @ HH:mm:ss";

// Other crap
const string QUEST_DESCRIPTOR = "DESCRIPTOR_";
const string QUEST_DESCRIPTION = "DESCRIPTION_";
const string QUEST_CUSTOM_MESSAGE = "CUSTOM_MESSAGE";
const string QUEST_FEEDBACK = "FEEDBACK_";

// Build state variables.
const string QUEST_BUILD_QUEST = "QUEST_BUILD_QUEST";
const string QUEST_BUILD_STEP = "QUEST_BUILD_STEP";
const string QUEST_BUILD_OBJECTIVE = "QUEST_BUILD_OBJECTIVE";

/// @private Clear state-machine build variables.
void quest_ClearBuildVariables()
{
    object o = GetModule();
    DeleteLocalInt(o, QUEST_BUILD_QUEST);
    DeleteLocalInt(o, QUEST_BUILD_STEP);
    DeleteLocalInt(o, QUEST_BUILD_OBJECTIVE);
}

/// @private Build state setters/getters.
void quest_SetBuildQuest(string s)  { SetLocalString(GetModule(), QUEST_BUILD_QUEST, s); }
void quest_SetBuildStep(int n)      { SetLocalInt   (GetModule(), QUEST_BUILD_STEP, n); }
void quest_SetBuildObjective(int n) { SetLocalInt   (GetModule(), QUEST_BUILD_OBJECTIVE, n); }

string quest_GetBuildQuest()     { return GetLocalString(GetModule(), QUEST_BUILD_QUEST); }
int    quest_GetBuildStep()      { return GetLocalInt   (GetModule(), QUEST_BUILD_STEP); }
int    quest_GetBuildObjective() { return GetLocalInt   (GetModule(), QUEST_BUILD_OBJECTIVE); }

void quest_DeleteBuildQuest()     { DeleteLocalString(GetModule(), QUEST_BUILD_QUEST); }
void quest_DeleteBuildStep()      { DeleteLocalInt   (GetModule(), QUEST_BUILD_STEP); }
void quest_DeleteBuildObjective() { DeleteLocalInt(GetModule(), QUEST_BUILD_OBJECTIVE); }

// Quest Version Actions
const int QUEST_VERSION_ACTION_NONE = 0;
const int QUEST_VERSION_ACTION_DELETE = 1;
const int QUEST_VERSION_ACTION_RESET = 2;

// Comparison constants
const string EQUAL_TO = "=";
const string GREATER_THAN = ">";
const string LESS_THAN = "<";
const string GREATER_THAN_OR_EQUAL_TO = ">=";
const string LESS_THAN_OR_EQUAL_TO = "<=";
const string NOT_EQUAL_TO = "!=";

const string QUEST_SYSTEM_SCHEMA = r"
{
    ""type"": ""object"",
    ""quest"": {
        ""properties"": {
            ""type"": ""object"",
            ""fields"": {
                QUEST_KEY_ACTIVE: {
                    ""type"": ""boolean"",
                    ""default"": QUEST_CONFIG_QUEST_ACTIVE
                },
                QUEST_KEY_PRECOLLECTED: {
                    ""type"": ""boolean""
                },                
                QUEST_KEY_JOURNAL_HANDLER: {
                    ""type"": ""integer"",
                    ""default"": QUEST_CONFIG_JOURNAL_HANDLER
                },
                QUEST_KEY_JOURNAL_TITLE: {
                    ""type"": ""string""
                },
                QUEST_KEY_JOURNAL_REMOVE: {
                    ""type"": ""boolean"",
                    ""default"": true
                },
                QUEST_KEY_REMOVE: {
                    ""type"": ""boolean"",
                    ""default"": true
                },
                QUEST_KEY_REPETITIONS: {
                    ""type"": ""integer""
                },
                QUEST_KEY_TIME_COOLDOWN: {
                    ""type"": ""string""
                },
                QUEST_KEY_TIME_LIMIT: {
                    ""type"": ""string""
                },
                QUEST_KEY_VERSION_VERSION: {
                    ""type"": ""integer""
                },
                QUEST_KEY_VERSION_ACTION: {
                    ""type"": ""integer""
                }
            }
        },
        ""scripts"": {
            ""type"": ""object"",
            ""fields"": {
                QUEST_KEY_ON_ACCEPT: {
                    ""type"": ""string""
                },
                QUEST_KEY_ON_ADVANCE: {
                    ""type"": ""string""
                },
                QUEST_KEY_ON_ALL: {
                    ""type"": ""string""
                },
                QUEST_KEY_ON_ASSIGN: {
                    ""type"": ""string""
                },
                QUEST_KEY_ON_COMPLETE: {
                    ""type"": ""string""
                },
                QUEST_KEY_ON_FAIL: {
                    ""type"": ""string""
                }
            }
        },
        ""prerequisites"": {
            ""type"": ""array"",
            ""items"": {
                ""$ref"": ""#/defs/prerequisiteItem"",
                ""defaultCount"": 2
            }
        },
        ""steps"": {
            ""type"": ""array"",
            ""items"": {
                ""$ref"": ""#/defs/stepItem""
            }
        },
        ""variables"": {
            ""type"": ""object"",
            ""additionalFields"": true
        }
    },
    ""defs"": {
        ""stepItem"": {
            ""type"": ""object"",
            ""fields"": {
                ""awards"": {
                    ""type"": ""array"",
                    ""items"": {
                        ""$ref"": ""#/defs/awardItem""
                    }
                },
                ""objectives"": {
                    ""type"": ""array"",
                    ""items"": {
                        ""$ref"": ""#/defs/objectiveItem""
                    }
                },
                ""properties"": {
                    ""type"": ""object"",
                    ""fields"": {
                        QUEST_KEY_STEP_ACTIVE: {
                            ""type"": ""boolean"",
                            ""default"": QUEST_CONFIG_STEP_ACTIVE
                        },
                        QUEST_KEY_STEP_JOURNAL_ENTRY: {
                            ""type"": ""string""
                        },
                        QUEST_KEY_STEP_OBJECTIVE_MINIMUM: {
                            ""type"": ""integer""
                        },
                        QUEST_KEY_STEP_OBJECTIVE_RANDOM: {
                            ""type"": ""integer""
                        },
                        QUEST_KEY_STEP_ORDINAL: {
                            ""type"": ""integer"",
                            ""default"": -1
                        },
                        QUEST_KEY_STEP_PARTY_COMPLETION: {
                            ""type"": ""boolean""
                        },
                        QUEST_KEY_STEP_PARTY_PROXIMITY: {
                            ""type"": ""boolean""
                        },
                        QUEST_KEY_STEP_TIME_LIMIT: {
                            ""type"": ""string""
                        },
                        QUEST_KEY_STEP_TYPE: {
                            ""type"": ""integer""
                        }
                    }
                },
                ""variables"": {
                    ""type"": ""object"",
                    ""additionalFields"": true
                }
            }
        },
        ""awardItem"": {
            ""type"": ""object"",
            ""fields"": {
                QUEST_KEY_CATEGORY_CATEGORY: {
                    ""type"": ""integer""
                },
                QUEST_KEY_CATEGORY_TYPE: {
                    ""type"": ""integer""
                },
                QUEST_KEY_CATEGORY_KEY: {
                    ""type"": ""string""
                },
                QUEST_KEY_CATEGORY_VALUE: {
                    ""type"": ""string""
                },
                QUEST_KEY_CATEGORY_PARTY: {
                    ""type"": ""boolean""
                }
            }
        },
        ""objectiveItem"": {
            ""type"": ""object"",
            ""fields"": {
                QUEST_KEY_OBJECTIVE_TYPE: {
                    ""type"": ""integer""
                },
                QUEST_KEY_OBJECTIVE_TAG: {
                    ""type"": ""string""
                },
                QUEST_KEY_OBJECTIVE_VALUE: {
                    ""type"": ""integer""
                },
                QUEST_KEY_OBJECTIVE_MAX: {
                    ""type"": ""integer""
                },
                QUEST_KEY_OBJECTIVE_DATA: {
                    ""type"": ""string""
                }
            }
        },
        ""prerequisiteItem"": {
            ""type"": ""object"",
            ""fields"": {
                QUEST_KEY_PREREQUISITE_TYPE: {
                    ""type"": ""integer""
                },
                QUEST_KEY_PREREQUISITE_KEY: {
                    ""type"": ""string""
                },
                QUEST_KEY_PREREQUISITE_VALUE: {
                    ""type"": ""string""
                }
            }
        }
    }
}
";

json quest_GetSystemSchema(int bForce = FALSE)
{
    json jSchema = GetLocalJson(GetModule(), "QUEST_SYSTEM_SCHEMA");
    if (jSchema == JSON_NULL || bForce)
    {
        string s = SubstituteSubStrings(QUEST_SYSTEM_SCHEMA, "\n", "");
        s = RegExpReplace("\\s*([{}\\[\\]:,])\\s*", s, "$1");
        
        string r = "(int|string|float)\\s+(QUEST_(?:KEY|CONFIG)_[A-Z_]+)\\s*=\\s*(\"[^\"]*\"|[^\\s;]+)\\s*;";
        json jConfig = RegExpIterate(r, ResManGetFileContents("quest_i_const", RESTYPE_NSS));

        int n; for (; n < JsonGetLength(jConfig); n++)
        {
            json jOption = JsonArrayGet(jConfig, n);
            string sType = JsonGetString(JsonArrayGet(jOption, 1));
            string sOption = JsonGetString(JsonArrayGet(jOption, 2));
            string sValue = JsonGetString(JsonArrayGet(jOption, 3));

            if (sValue == "TRUE" || sValue == "FALSE")
                sValue = GetStringLowerCase(sValue);
            else if (GetStringUpperCase(sValue) == sValue && !GetIsNumeric(sValue))
            {
                struct CONSTANT c;
                if (sType == "int")
                {
                    c = GetConstantInt(sValue, THIS);
                    sValue = IntToString(c.nValue);
                }
                else if (sType == "float")
                {
                    c = GetConstantFloat(sValue, THIS);
                    sValue = FormatFloat(c.fValue, "%!f");
                }
                else if (sType == "string")
                {
                    c = GetConstantString(sValue, THIS);
                    sValue = c.sValue;
                }
            }

            s = RegExpReplace(sOption, s, sValue);
        }

        jSchema = JsonParse(s);
        SetLocalJson(GetModule(), "QUEST_SYSTEM_SCHEMA", jSchema);
    }

    return jSchema;
}

