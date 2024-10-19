/// ----------------------------------------------------------------------------
/// @file   quest_i_const.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Quest System (constants)
/// ----------------------------------------------------------------------------

// Versioning
const string QUEST_SYSTEM_VERSION = "2.0.0";

// Variable names for event scripts
const string QUEST_CURRENT_QUEST = "QUEST_CURRENT_QUEST";
const string QUEST_CURRENT_STEP = "QUEST_CURRENT_STEP";
const string QUEST_CURRENT_EVENT = "QUEST_CURRENT_EVENT";

const string QUEST_DATABASE = "quest_database";

// Primary Keys
const string QUEST_KEY_PREFIX_STEP = "steps:";

const string QUEST_KEY_PROPERTIES = "properties";
const string QUEST_KEY_SCRIPTS = "scripts";
const string QUEST_KEY_JOURNAL = "journal";
const string QUEST_KEY_PREREQUISITES = "prerequisites";
const string QUEST_KEY_STEPS = "steps";
const string QUEST_KEY_VARIABLES = "variables";
const string QUEST_KEY_OBJECTIVES = "objectives";
const string QUEST_KEY_AWARDS = "awards";

// Secondary Keys
const string QUEST_KEY_ACTIVE = "active";
const string QUEST_KEY_REPETITIONS = "repetitions";
const string QUEST_KEY_TIME_LIMIT = "timeLimit";
const string QUEST_KEY_TIME_COOLDOWN = "timeCooldown";
const string QUEST_KEY_VERSION = "version";
const string QUEST_KEY_VERSION_ACTION = "versionAction";
const string QUEST_KEY_ALLOW_PRECOLLECTED = "allowPrecollectedItems";
const string QUEST_KEY_REMOVE_COMPLETED = "removeOnCompleted";
const string QUEST_KEY_JOURNAL_ENTRY = "journalEntry";
const string QUEST_KEY_JOURNAL_TITLE = "journalTitle";
const string QUEST_KEY_JOURNAL_HANDLER = "journalHandler";
const string QUEST_KEY_KEY = "key";
const string QUEST_KEY_VALUE = "value";
const string QUEST_KEY_PARTY_COMPLETION = "partyCompletion";
const string QUEST_KEY_PARTY_PROXIMITY = "partyProximity";
const string QUEST_KEY_TYPE = "type";
const string QUEST_KEY_NAME = "name";
const string QUEST_KEY_ORDINAL = "ordinal";
const string QUEST_KEY_OBJ_MIN_COUNT = "objCountMinimum";
const string QUEST_KEY_OBJ_RANDOM_COUNT = "objCountRandom";
const string QUEST_KEY_ON_ASSIGN = "onAssign";
const string QUEST_KEY_ON_ACCEPT = "onAccept";
const string QUEST_KEY_ON_ADVANCE = "onAdvance";
const string QUEST_KEY_ON_COMPLETE = "onComplete";
const string QUEST_KEY_ON_FAIL = "onFail";
const string QUEST_KEY_ON_ALL = "onAll";
const string QUEST_KEY_TAG = "tag";
const string QUEST_KEY_MAX = "max";
const string QUEST_KEY_DATA = "data";
const string QUEST_KEY_PARTY = "party";
const string QUEST_KEY_CATEGORY = "category";

// Quest Categories and Values
// Should these be bitwise?
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
const int QUEST_STEP_TYPE_PROGRESS = 0;
const int QUEST_STEP_TYPE_SUCCESS = 1;
const int QUEST_STEP_TYPE_FAIL = 2;

// Quest Advance Types
const int QUEST_ADVANCE_SUCCESS = 1;
const int QUEST_ADVANCE_FAIL = 2;

// Quest Objective Types
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

// Journal Locations
const int QUEST_JOURNAL_NONE = 0;
const int QUEST_JOURNAL_NWN = 1;
const int QUEST_JOURNAL_NWNX = 2;

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

// Other Variables
const string QUEST_VARIABLE_TABLES_INITIALIZED = "QUEST_VARIABLE_TABLES_INITIALIZED";

const string QUEST_MODULE_SCHEMA = r"{
    ""type"": ""object"",
    ""fields"": {
        ""properties"": {
            ""type"": ""object"",
            ""fields"": {
                ""active"": {""type"": ""boolean""},
                ""allowPrecollectedItems"": {""type"":""boolean""},
                ""removeOnCompleted"": {""type"":""boolean"", ""default"": true},
                ""repetitions"": {""type"": ""integer""},
                ""timeCooldown"": {""type"": ""string""},
                ""timeLimit"": {""type"": ""string""},
                ""version"": {""type"": ""integer""},
                ""versionAction"": {""type"": ""integer""}
            }
        },
        ""scripts"": {
            ""type"": ""object"",
            ""fields"": {
                ""onAccept"": {""type"": ""string""},
                ""onAdvance"": {""type"": ""string""},
                ""onAll"": {""type"": ""string""},
                ""onAssign"": {""type"": ""string""},
                ""onComplete"": {""type"": ""string""},
                ""onFail"": {""type"": ""string""}
            }
        },
        ""journal"": {
            ""type"": ""object"",
            ""fields"": {
                ""journalHandler"": {""type"": ""integer""},
                ""journalTitle"": {""type"": ""string""},
                ""removeOnCompleted"": {""type"": ""boolean""}
            }
        },
        ""prerequisites"": {
            ""type"": ""array"",
            ""items"": {
                ""$ref"": ""#/$defs/prerequisitesItem"",
                ""defaultCount"": 2
            }
        },
        ""steps"": {
            ""type"": ""array"",
            ""items"": {
                ""$ref"": ""#/$defs/stepItem""
            }
        },
        ""variables"": {
            ""type"": ""object"",
            ""additionalFields"": true
        }
    },
    ""$defs"": {
        ""stepItem"": {
            ""type"": ""object"",
            ""fields"": {
                ""awards"": {
                    ""type"": ""array"",
                    ""items"": {
                        ""$ref"": ""#/$defs/awardItem""
                    }
                },
                ""journal"": {
                    ""type"": ""object"",
                    ""fields"": {
                        ""entry"": {
                            ""type"": ""string"", 
                            ""default"": ""This one""
                        }
                    }
                },
                ""objectives"": {
                    ""type"": ""array"",
                    ""items"": {
                        ""$ref"": ""#/$defs/objectiveItem""
                    }
                },
                ""properties"": {
                    ""type"": ""object"",
                    ""fields"": {
                        ""active"": {""type"": ""boolean""},
                        ""objectiveMinimum"": {""type"": ""integer""},
                        ""objectiveRandom"": {""type"": ""integer""},
                        ""ordinal"": {""type"": ""integer""},
                        ""partyCompletion"": {""type"": ""boolean""},
                        ""partyProximity"": {""type"": ""boolean""},
                        ""timeLimit"": {""type"": ""string""},
                        ""type"": {""type"": ""integer""}
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
                ""category"": {""type"": ""integer""},
                ""type"": {""type"": ""integer""},
                ""key"": {""type"": ""string""},
                ""value"": {""type"": ""string""},
                ""party"": {""type"": ""boolean""}
            }
        },
        ""objectiveItem"": {
            ""type"": ""object"",
            ""fields"": {
                ""type"": {""type"": ""integer""},
                ""tag"": {""type"": ""string""},
                ""value"": {""type"": ""integer""},
                ""max"": {""type"": ""integer""},
                ""data"": {""type"": ""string""}
            }
        },
        ""prerequisitesItem"": {
            ""type"": ""object"",
            ""fields"": {
                ""type"": {""type"": ""integer""},
                ""key"": {""type"": ""string""},
                ""value"": {""value"": ""string""}
            }
        }
    }
}
";

json quest_GetModuleSchema(int bForce = FALSE)
{
    json jSchema = GetLocalJson(GetModule(), "QUEST_MODULE_SCHEMA");
    if (jSchema == JSON_NULL || bForce)
    {
        string s = SubstituteSubStrings(QUEST_MODULE_SCHEMA, "\n", "");
        s = RegExpReplace("\\s*([{}\\[\\]:,])\\s*", s, "$1");
        
        jSchema = JsonParse(s);
        SetLocalJson(GetModule(), "QUEST_MODULE_SCHEMA", jSchema);
    }

    return jSchema;
}

// -----------------------------------------------------------------------------
//                             Quest System Configuration
// -----------------------------------------------------------------------------

// [ ] Move to its own file ...

// Set this value to the standard journal handler you'd like to use.  If you use a combination,
// set this to the one you use most often.  For any journal entries that don't use the
// handler set below, you must specifically designate its handler with SetQuestJournalHandler().
const int QUEST_CONFIG_JOURNAL_HANDLER = QUEST_JOURNAL_NWN;

// For semi-randomized quest objectives, you can override the standard journal entry with
// the custom message created for the random objectives.  To override the step's normal
// journal entry, set this value to TRUE.
const int QUEST_CONFIG_USE_CUSTOM_MESSAGE = TRUE;
