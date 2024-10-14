/// ----------------------------------------------------------------------------
/// @file   quest_i_const.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Quest System (constants)
/// ----------------------------------------------------------------------------

// Versioning
const string QUEST_SYSTEM_VERSION = "1.2.3";

// Variable names for event scripts
const string QUEST_CURRENT_QUEST = "QUEST_CURRENT_QUEST";
const string QUEST_CURRENT_STEP = "QUEST_CURRENT_STEP";
const string QUEST_CURRENT_EVENT = "QUEST_CURRENT_EVENT";

const string QUEST_VARIABLE = "QUEST_VARIABLE";
const string QUEST_VARIABLE_PC = "QUEST_VARIABLE_PC";
const string QUEST_WEBHOOK = "QUEST_WEBHOOK_";

const string QUEST_DATABASE = "quest_database";

// Table column names
const string QUEST_ACTIVE = "nActive";
const string QUEST_REPETITIONS = "nRepetitions";
const string QUEST_SCRIPT_ON_ASSIGN = "sScriptOnAssign";
const string QUEST_SCRIPT_ON_ACCEPT = "sScriptOnAccept";
const string QUEST_SCRIPT_ON_ADVANCE = "sScriptOnAdvance";
const string QUEST_SCRIPT_ON_COMPLETE = "sScriptOnComplete";
const string QUEST_SCRIPT_ON_FAIL = "sScriptOnFail";
const string QUEST_TIME_LIMIT = "sTimeLimit";
const string QUEST_COOLDOWN = "sCooldown";
const string QUEST_TITLE = "sJournalTitle";
const string QUEST_JOURNAL_HANDLER = "nJournalHandler";
const string QUEST_JOURNAL_DELETE = "nRemoveJournalOnCompleted";
const string QUEST_PRECOLLECTED_ITEMS = "nAllowPrecollectedItems";
const string QUEST_DELETE = "nRemoveQuestOnCompleted";
const string QUEST_VERSION = "nQuestVersion";
const string QUEST_VERSION_ACTION = "nQuestVersionAction";

const string QUEST_STEP_JOURNAL_ENTRY = "sJournalEntry";
const string QUEST_STEP_TIME_LIMIT = "sTimeLimit";
const string QUEST_STEP_PARTY_COMPLETION = "nPartyCompletion";
const string QUEST_STEP_PROXIMITY = "nProximity";
const string QUEST_STEP_TYPE = "nStepType";
const string QUEST_STEP_OBJECTIVE_COUNT = "nObjectiveMinimumCount";
const string QUEST_STEP_RANDOM_OBJECTIVES = "nRandomObjectiveCount";

// Quest PC Variable Names
const string QUEST_PC_QUEST_TIME = "nQuestStartTime";
const string QUEST_PC_STEP_TIME = "nStepStartTime";
const string QUEST_PC_LAST_COMPLETE = "nLastCompleteTime";
const string QUEST_PC_LAST_COMPLETE_TYPE = "nLastCompleteType";
const string QUEST_PC_COMPLETIONS = "nCompletions";
const string QUEST_PC_STEP = "nStep";
const string QUEST_PC_VERSION = "nQuestVersion";
const string QUEST_PC_ATTEMPTS = "nAttempts";

// Quest Categories and Values
const int QUEST_CATEGORY_PREREQUISITE = 1;
const int QUEST_CATEGORY_OBJECTIVE = 2;
const int QUEST_CATEGORY_PREWARD = 3;
const int QUEST_CATEGORY_REWARD = 4;

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

// Interal Data Control
const string QUEST_BUILD_QUEST = "QUEST_BUILD_QUEST";
const string QUEST_BUILD_STEP = "QUEST_BUILD_STEP";
const string QUEST_BUILD_OBJECTIVE = "QUEST_BUILD_OBJECTIVE";

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
