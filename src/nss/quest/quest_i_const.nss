// -----------------------------------------------------------------------------
//    File: quest_i_const.nss
//  System: Quest Persistent World Subsystem (constants)
// -----------------------------------------------------------------------------
// Description:
//  Constants for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

// Variable names for event scripts
const string QUEST_CURRENT_QUEST = "QUEST_CURRENT_QUEST";
const string QUEST_CURRENT_STEP = "QUEST_CURRENT_STEP";
const string QUEST_CURRENT_EVENT = "QUEST_CURRENT_EVENT";

// Table column names
const string QUEST_ACTIVE = "nActive";
const string QUEST_REPETITIONS = "nRepetitions";
const string QUEST_STEP_ORDER = "nStepOrder";
const string QUEST_TITLE = "sJournalTitle";
const string QUEST_TIME_LIMIT = "sTimeLimit";
const string QUEST_SCRIPT_ON_ACCEPT = "sScriptOnAccept";
const string QUEST_SCRIPT_ON_ADVANCE = "sScriptOnAdvance";
const string QUEST_SCRIPT_ON_COMPLETE = "sScriptOnComplete";
const string QUEST_SCRIPT_ON_FAIL = "sScriptOnFail";
const string QUEST_COOLDOWN = "sCooldown";
const string QUEST_JOURNAL_LOCATION = "nJournalLocation";
const string QUEST_JOURNAL_DELETE = "nRemoveJournalOnComplete";
const string QUEST_PRECOLLECTED_ITEMS = "nAllowPrecollectedItems";
const string QUEST_USE_RESREFS = "nUseResrefs";

const string QUEST_STEP_JOURNAL_ENTRY = "sJournalEntry";
const string QUEST_STEP_TIME_LIMIT = "sTimeLimit";
const string QUEST_STEP_PARTY_COMPLETION = "nPartyCompletion";
const string QUEST_STEP_PROXIMITY = "nProximity";
const string QUEST_STEP_TYPE = "nStepType";
const string QUEST_STEP_OBJECTIVE_COUNT = "nObjectiveMinimumCount";
const string QUEST_STEP_RANDOM_OBJECTIVES = "nRandomObjectiveCount";
const string QUEST_STEP_USE_RESREFS = "nUseResrefs";

const string QUEST_STEP_PROPERTY_USE_RESREFS = "nUseResrefs";

// Quest PC Variable Names
const string QUEST_PC_QUEST_TIME = "nQuestStartTime";
const string QUEST_PC_STEP_TIME = "nStepStartTime";
const string QUEST_PC_LAST_COMPLETE = "nLastCompleteTime";
const string QUEST_PC_LAST_COMPLETE_TYPE = "nLastCompleteType";
const string QUEST_PC_COMPLETIONS = "nCompletions";
const string QUEST_PC_STEP = "nStep";

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
const int QUEST_VALUE_FACTION = 10;
const int QUEST_VALUE_MESSAGE = 11;
const int QUEST_VALUE_QUEST_STEP = 12;
const int QUEST_VALUE_SKILL = 13;
const int QUEST_VALUE_ABILITY = 14;

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
const int AWARD_ALL = 0;
const int AWARD_GOLD = 1;
const int AWARD_XP = 2;
const int AWARD_ITEM = 3;
const int AWARD_ALIGNMENT = 4;
const int AWARD_QUEST = 5;
const int AWARD_MESSAGE = 6;

// Quest Script Types
const int QUEST_SCRIPT_TYPE_ON_ACCEPT = 1;
const int QUEST_SCRIPT_TYPE_ON_ADVANCE = 2;
const int QUEST_SCRIPT_TYPE_ON_COMPLETE = 3;
const int QUEST_SCRIPT_TYPE_ON_FAIL = 4;

// Quest Events
const int QUEST_EVENT_ON_ACCEPT = 1;
const int QUEST_EVENT_ON_ADVANCE = 2;
const int QUEST_EVENT_ON_COMPLETE = 3;
const int QUEST_EVENT_ON_FAIL = 4;

// Step Order
const int QUEST_STEP_ORDER_SEQUENTIAL = 1;
const int QUEST_STEP_ORDER_RANDOM = 2;

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

// Versioning
const string QUEST_SYSTEM_VERSION = "1.0.3";

// Other crap
const string QUEST_DESCRIPTOR = "DESCRIPTOR_";
const string QUEST_DESCRIPTION = "DESCRIPTION_";
const string QUEST_CUSTOM_MESSAGE = "CUSTOM_MESSAGE";

// Interal Data Control
const string QUEST_BUILD_QUEST = "QUEST_BUILD_QUEST";
const string QUEST_BUILD_STEP = "QUEST_BUILD_STEP";
const string QUEST_BUILD_OBJECTIVE = "QUEST_BUILD_OBJECTIVE";
