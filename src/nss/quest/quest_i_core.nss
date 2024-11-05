/// ----------------------------------------------------------------------------
/// @file   quest_i_core.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Quest System (core)
/// ----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_strings"
#include "util_i_schema"

#include "quest_i_const"
#include "quest_i_debug"

/// @private Central query preparation and supporting functions.
/// @note 
sqlquery quest_PrepareQuery(string s)
{
    s = SubstituteSubStrings(s, "\n", "");
    s = RegExpReplace("\\s+", s, " ");
    return SqlPrepareQueryCampaign(QUEST_DATABASE, s);
}

void quest_ExecuteQuery(string s) { SqlStep(quest_PrepareQuery(s)); }
void quest_BeginTransaction()     { quest_ExecuteQuery("BEGIN TRANSACTION;"); }
void quest_CommitTransaction()    { quest_ExecuteQuery("COMMIT TRANSACTION;"); }

/// @private Transforms the system schema into a compact json object containing only
///     keys and default values.  The result of this function is used as the default
///     value for the quest_data column in the quest_module table, but can serve to
///     summarize the quest system schema for other purposes.
/// @param bIncludeItemTemplates If TRUE, item templates (defs) will be included as part
///     of the returned json object.  This is primarily used when pathing keys.
/// @param bForce If TRUE, the system schema will be reloaded.
json quest_GetSchemaTemplate(string sPath = "", int bIncludeItemTemplates = FALSE, int bForce = FALSE)
{
    string s = r"
        WITH RECURSIVE
            schema_tree AS (
                SELECT json_tree.*
                FROM json_tree(json_extract(@schema, CASE WHEN @path = '' THEN '$' ELSE '$.' || @path END))
                WHERE json_tree.type = 'object'
                    AND NOT (@path = '' AND json_tree.fullkey LIKE '$.defs%')
            ),
            schema_defaults AS (
                SELECT t.*,
                    CASE
                        WHEN t.parent IS NULL THEN ''
                        ELSE
                            CASE
                                WHEN json_extract(t.value, '$.type') IS NULL THEN
                                    COALESCE(json_extract(t.value, '$.fields'), t.value)
                                ELSE
                                    CASE
                                        WHEN json_extract(t.value, '$.default') IS NOT NULL THEN
                                            CASE json_extract(t.value, '$.type')
                                                WHEN 'string' THEN json_quote(json_extract(t.value, '$.default'))
                                                ELSE json_extract(t.value, '$.default')
                                            END
                                        ELSE
                                            CASE json_extract(t.value, '$.type')
                                                WHEN 'integer' THEN 0
                                                WHEN 'float' THEN 0.0
                                                WHEN 'string' THEN json_quote('')
                                                WHEN 'boolean' THEN false
                                                WHEN 'array' THEN
                                                    IIF(@includeItemTemplates = 1,
                                                        json_array(json_extract(@itemTemplates, '$.' || SUBSTR(json_extract(t.value, '$.items.$ref'), 8))),
                                                        json_array()
                                                    )
                                                WHEN 'object' THEN 
                                                    COALESCE(json_extract(t.value, '$.fields'), json_object())
                                            END
                                    END
                            END
                    END AS new_value,
                    replace(t.fullkey, '.fields', '') AS new_fullkey,
                    ROW_NUMBER() OVER (ORDER BY parent, id) AS row_num
                FROM schema_tree t
                ORDER BY parent, id
            ),
            schema_folded AS (
                SELECT row_num, json_object() AS result
                    FROM schema_defaults
                    WHERE row_num = 1
                
                UNION ALL
                
                SELECT nr.row_num, json_set(schema_folded.result, nr.new_fullkey, json(nr.new_value)) AS result
                    FROM schema_defaults nr
                    JOIN schema_folded
                        ON nr.row_num = schema_folded.row_num + 1 
            )
        SELECT result
        FROM schema_folded
        WHERE row_num = (SELECT MAX(row_num) FROM schema_folded);
    ";
    sqlquery q = quest_PrepareQuery(s);

    json jExpanded = GetLocalJson(GetModule(), "QUEST_SCHEMA_DEFS_EXPANDED");
    if (bIncludeItemTemplates == TRUE && jExpanded == JSON_NULL)
    {
        SqlBindJson  (q, "@schema", quest_GetSystemSchema(bForce));
        SqlBindString(q, "@path", "defs");
        SqlBindInt   (q, "@includeItemTemplates", FALSE);
        SqlBindJson  (q, "@itemTemplates", JSON_NULL);

        json jCompact = SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
        SqlResetQuery(q, TRUE);
    
        SqlBindJson  (q, "@schema", quest_GetSystemSchema(bForce));
        SqlBindString(q, "@path", "defs");
        SqlBindInt   (q, "@includeItemTemplates", TRUE);
        SqlBindJson  (q, "@itemTemplates", jCompact);

        jExpanded = SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
        SetLocalJson(GetModule(), "QUEST_SCHEMA_DEFS_EXPANDED", jExpanded);
        SqlResetQuery(q, TRUE);
    }

    SqlBindJson  (q, "@schema", quest_GetSystemSchema(bForce));
    SqlBindString(q, "@path", sPath);
    SqlBindInt   (q, "@includeItemTemplates", bIncludeItemTemplates);
    SqlBindJson  (q, "@itemTemplates", bIncludeItemTemplates ? jExpanded : JSON_NULL);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}


/// @private Retrieves the full path for the specified key in the system schema.
/// @param sPath The parent path where the key resides.
string quest_GetSchemaPath(string sKey, json jTemplate = JSON_NULL, string sMode = "set")
{
    string s = r"
        WITH schema_tree AS (
                SELECT json_tree.*
                FROM json_tree(@template)
            )
        SELECT fullkey
        FROM schema_tree
        WHERE key = @key;
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindJson(q, "@template", jTemplate == JSON_NULL ? quest_GetSchemaTemplate("", TRUE) : jTemplate);
    SqlBindString(q, "@key", sKey);

    string sPath = SqlStep(q) ? SqlGetString(q, 0) : "";
    return RegExpReplace("\\[0\\]", sPath, sMode == "get" ? "[#-1]" : "[#]");
}

/// @private
int quest_GetSchemaType(string sKey)
{
    string s = r"
        WITH 
            schema_tree AS (
                SELECT json_tree.*
                FROM json_tree(@schema)
            ),
            type AS (
                SELECT json_extract(schema_tree.value, '$.type') AS type
                FROM schema_tree
                WHERE key = @key
                ORDER BY parent, id
            )
        SELECT (
            SELECT CAST(json_each.key AS INTEGER)
            FROM json_each(json_array('null', 'object', 'array', 'string', 'integer', 'float', 'boolean'))
            WHERE json_each.value = type.type
        )
        FROM type;
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindJson(q, "@schema", quest_GetSystemSchema());
    SqlBindString(q, "@key", sKey);

    return SqlStep(q) ? SqlGetInt(q, 0) : -1;
}


/// @brief Create the database objects required to administer the system.
/// @note See comments within the function for future table modification
///     strategies.  The JSON methodology below will transform the version
///     1.0 system from a traditional relational database to a document
///     database.  This will allow for easier modification and expansion
///     of the system without having to modify the database table structure.
void quest_CreateTables(int bReset = FALSE)
{
    /// @brief The module quest table holds all non-player-specific quest
    ///     data.  This table will normally be dropped and re-created every
    ///     time the module is started to ensure quest data does not go stale.

    /// @note The default quest_data json object is retrieved from the quest
    ///     data schema held in QUEST_SYSTEM_SCHEMA.  All changes to the keys
    ///     contained in quest documents should be accomplished in the schema,
    ///     not in the table definitions below.

    /// @note The configurable default values contained within the schema are
    ///     sourced from `quest_i_const.nss`.  These values will be inserted
    ///     into the schema on module startup and do not need to be manually
    ///     inserted into the schema.
    string sModule = r"
        CREATE TABLE IF NOT EXISTS quest_module (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quest_tag TEXT NOT NULL DEFAULT '~' UNIQUE ON CONFLICT IGNORE,
            quest_data TEXT DEFAULT '$1'
        );
    ";
    sModule = SubstituteSubString(sModule, "$1", JsonDump(quest_GetSchemaTemplate("quest")));

    /// @brief Create a trigger on the quest_modules table to prevent insertion of duplicate
    ///     step numbers (ordinals) into the $.steps[#].properties.stepOrdinal field.
    /// @warning This trigger will raise a system wide sql error if a duplicated step number is
    ///     inserted into the quest_data field.
    string sTriggerDuplicate = r"
        CREATE TRIGGER quest_module_duplicate
            BEFORE UPDATE ON quest_module
                FOR EACH ROW
                    WHEN json_extract(OLD.quest_data, '$.steps[#-1].properties.$1') != 
                        json_extract(NEW.quest_data, '$.steps[#-1].properties.$1')
                        AND EXISTS (
                            SELECT 1
                            FROM json_each(OLD.quest_data, '$.steps')
                            WHERE json_extract(value, '$.properties.$1') = 
                                json_extract(NEW.quest_data, '$.steps[#-1].properties.$1')
                        )
                    BEGIN
                        SELECT RAISE(ABORT, 'Duplicate step ordinal found (quest = ' || NEW.quest_tag || '); check logs');
                    END;
    ";
    sTriggerDuplicate = SubstituteSubStrings(sTriggerDuplicate, "$1", QUEST_KEY_STEP_ORDINAL);

    string sTriggerIncrement = r"
        CREATE TRIGGER quest_module_increment_after
        AFTER UPDATE ON quest_module
        FOR EACH ROW
        WHEN json_extract(NEW.quest_data, '$.steps[#-1].properties.$1') = -1
        BEGIN
            UPDATE quest_module
            SET quest_data = json_set(quest_data, '$.steps[#-1].properties.$1', 
                IFNULL(
                    (SELECT MAX(json_extract(value, '$.properties.$1')) + 1
                     FROM json_each(quest_data, '$.steps')
                     WHERE json_extract(value, '$.properties.$1') != -1),
                    1
                )
            )
            WHERE quest_tag = NEW.quest_tag;
        END;
    ";
    sTriggerIncrement = SubstituteSubStrings(sTriggerIncrement, "$1", QUEST_KEY_STEP_ORDINAL);

    /// @brief The player quest table holds all of the player-related data.  Player data is
    ///     referenced by player uuid.  This mean that only one player-character can ever
    ///     access associated quest data.  However, given that sometimes character rebuilds
    ///     must be accomplished, quest data can be moved from one character to another by
    ///     modifying the uuid field en-masse.  A function is provided for this.

    /// @note This table is not as easily modifiable as the module quest table above because
    ///     the table is generally never re-created.  To make modification easier, we
    ///     hold all data in a single quest_data field which contains an empty array by
    ///     default.  As quest data requirements change, the functions that build the
    ///     json objects that are inserted into this array can be easily modified without
    ///     having to modify the table structure.

    ///     If a quest definition changes, having different fields in newer quest entries
    ///     should have no effect on the ability of the quest system to run.  Any queries
    ///     attempting to retrieve new data that doesn't exist in old records will simply
    ///     return empty or null values.

    /// @note Each json object added to the quest_data json array represents one quest
    ///     completion attempt for `player_uuid` and quest `quest_tag`.  Each additional
    ///     attempt, if allowed, will add another json object to `quest_data` array, with
    ///     the last entry being considered the active (or most recently completed) attempt.

    /// @warning Deleting, clearing or resetting this table will cause *ALL* players
    ///     to lose all quest-related data.  Do not reset this table unless you
    ///     have backed up your quest data.

    string sPlayer = r"
        CREATE TABLE IF NOT EXISTS quest_player (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pc_uuid TEXT NOT NULL default '~',
            quest_tag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE,
            quest_data TEXT DEFAULT '[]'
        );
    ";
    
    /// To support changing quests, should make a full copy of quest data in situ at the time
    ///     the quest is assigned and save for each attempt.  This lets us give the module owner
    ///     the option to allow the player to complete the quest as it existed when it was assigned
    ///     in addition to the normal options or resetting to current/new, deleting all progress.

    /// Expected structure (array of): [{
    ///     properties:
    ///         startTime, completeTime, completeType, version
    ///     variables: [
    ///         {type, name, value}
    ///     ]
    ///     steps: [
    ///         {ordinal, data, required, acquired, objectiveID, startTime, completeTime}
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

    if (bReset)
    {
        QuestDebug(HexColorString("Resetting", COLOR_RED_LIGHT) + " quest database tables");

        string sTables = "module,player,module_duplicate,module_increment";
        int n, nCount = CountList(sTables);  
        for (; n < nCount; n++)
        {
            string sTable = GetListItem(sTables, n);
            string s = r"
                DROP TABLE IF EXISTS quest_$1;
            ";
            quest_ExecuteQuery(SubstituteSubString(s, "$1", sTable));

            s = r"
                DROP TRIGGER IF EXISTS quest_$1;
            ";
            quest_ExecuteQuery(SubstituteSubString(s, "$1", sTable));
        }
    }

    sqlquery q = quest_PrepareQuery(sModule); SqlStep(q);
    HandleSqlDebugging(q, "SQL:table", "quest_module", "campaign");

    q = quest_PrepareQuery(sTriggerDuplicate); SqlStep(q);
    HandleSqlDebugging(q, "SQL:trigger", "quest_module_duplicate", "campaign");

    q = quest_PrepareQuery(sTriggerIncrement); SqlStep(q);
    HandleSqlDebugging(q, "SQL:trigger", "quest_module_increment", "campaign");

    q = quest_PrepareQuery(sPlayer); SqlStep(q);
    HandleSqlDebugging(q, "SQL:table", "quest_player", "campaign");
}

/// @private Retrieves the specified segment from a segment[:=]segment[:=]... series.
string quest_GetSegment(string s, int n = 0)
{
    string r = "(?:.*?[:=]){" + IntToString(n) + "}(.*?)(?:[:=]|$)";
    return JsonGetString(JsonArrayGet(RegExpMatch(r, s), 1));
}

/// @private Convenience function for quest_GetSegment().
string quest_GetKey(string s) { return quest_GetSegment(s); }
string quest_GetValue(string s, int n = 1) { return quest_GetSegment(s, n);}

/// @private Clears module quest data.
void quest_OnModuleLoad()
{
    quest_ExecuteQuery("DELETE FROM quest_module;");
}

/// @private Compares quest versions with new data in `quest_module`
///     and updated/modified/deletes as optioned.
void quest_OnClientEnter()
{
    object o = GetEnteringObject();
    // [ ] Drop the primary quest table...

    // check pc quest versions against module versions and see what to do...
}

/// [ ] replace this with just trying to grab something from quest_getdata, no
///     need for a special query (?)
/// @private Determine is a specific quest exists.
/// @param sTag The tag of the quest to search for.
/// @warning This function does not determine if a quest has valid data, only
///     whether the quest entry exists in the `quest_module` table.
int quest_Exists(string sTag)
{
    string s = r"
        SELECT COUNT(id)
        FROM quest_module
        WHERE quest_tag = @sTag;
    ";
    sqlquery sql = quest_PrepareQuery(s);
    SqlBindString(sql, "@sTag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;    
}

json quest_GetData(string sTag)
{
    string s = r"
        SELECT quest_data
        FROM quest_module
        WHERE quest_tag = @sTag;
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}

int quest_CountChanges()
{
    string s = r"
        SELECT
            CASE
                WHEN changes() > 0 THEN 1
                ELSE 0
            END;
    ";
    sqlquery q = quest_PrepareQuery(s);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

/// @private Retrieve a json value from a key in the `quest_module` table.
/// @param sKey Schema-unique key to retrieve.
/// @param sTag The quest to retrieve the data from.
/// @param nIndex If retrieving an array element, the index to the element in the array.
///     If missing, will retrieve the value from the last element in the array.
json quest_GetProperty(string sKey, string sTag, int nIndex = -1)
{
    string sPath = quest_GetSchemaPath(sKey, quest_GetData(sTag), "get");
    if (sPath == "")
    {
        QuestError("[quest_GetProperty] Path for key '" + sKey + "'' not found; aborting");
        return JSON_NULL;
    }

    if (nIndex > -1)
        sPath = RegExpReplace("\\[#-1\\]", sPath, "[" + IntToString(nIndex) + "]");

    string s = r"
        SELECT json_extract(quest_data, @sPath)
        FROM quest_module
        WHERE quest_tag = @sTag;
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);
    SqlBindString(q, "@sPath", sPath);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}

/// @private Add a json value to a key in the `quest_module` table.
/// @param sKey Schema-unique key to set.
/// @param jValue The value to set.
/// @param sTag The quest to set the data on.  If missing, will use the quest currently
///     being built.
/// @param nIndex If setting an array element, the index to the element in the array.
///     If missing, will set the value to the last element in the array.
/// @warning This method will fail or have undefined behavior if called outside the quest
///     definition process and a quest tag is not passed.
/// @note If a step is being added to a quest, the step number passed must either be -1
///     (to automatically increment step numbers) or unique.  Otherwise the step will
///     silently fail to be inserted into the .steps array.  The step number must match
///     the step number in the associated journal entry, if used.
int quest_SetProperty(string sKey, json jValue, string sTag = "", int nIndex = -1)
{
    sTag = (sTag == "" ? quest_GetBuildQuest() : sTag);
    if (sTag == "" || !quest_Exists(sTag))
    {
        QuestError("[quest_SetProperty] Quest '" + sTag + "' does not exist; aborting");
        return FALSE;
    }

    string sPath = quest_GetSchemaPath(sKey, quest_GetData(sTag));
    if (sPath == "")
    {
        QuestError("[quest_SetProperty] Path for key '" + sKey + "' not found; aborting");
        return FALSE;
    }

    int nType = JsonGetType(jValue);
    int nSchemaType = quest_GetSchemaType(sKey);

    if (nType == JSON_TYPE_NULL)
    {
        QuestError("[quest_SetProperty] Value for key '" + sKey + "' is NULL; aborting");
        return FALSE;
    }
    else if (nType == JSON_TYPE_OBJECT && nSchemaType == JSON_TYPE_ARRAY)
        sPath += "[" + (nIndex == -1 ? "#" : IntToString(nIndex)) + "]";
    else if (nType == JSON_TYPE_ARRAY || nType != nSchemaType)
    {
        QuestError("[quest_SetProperty] Incorrect type for key '" + sKey + "'; aborting");
        return FALSE;
    }
    
    string s = r"
        UPDATE quest_module
        SET quest_data = json_set(quest_data, @sPath, json(@jValue))
        WHERE quest_tag = @sTag
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);
    SqlBindString(q, "@sPath", sPath);
    SqlBindJson  (q, "@jValue", jValue);
    
    if (SqlStep(q) && !quest_CountChanges())
    {
        QuestError("[quest_SetProperty] Failed to set property:" +
            "\n   sTag = " + sTag +
            "\n   sKey = " + sKey +
            "\n   sPath = " + sPath);
        return FALSE;
    }

    /// @note Step ordinals have special handling and are automatically incremented
    ///     via a table trigger as defined in `quest_CreateTables()`.  The incrementation
    ///     occurs after the step is added and can't be returned with a RETURNING
    ///     statement, so we need to retrieve the value manually.
    /// @note Since we should only have sKey == 'steps' when adding a step, the
    ///     index can safely be ignored for retrieving the step ordinal.
    if (sKey == "steps")
        return JsonGetInt(quest_GetProperty(QUEST_KEY_STEP_ORDINAL, sTag));

    return TRUE;
}


/// @private Retrieve a json object containing the default quest-level data,
///     including default settings.  This object is sourced from the quest
///     system schema.
/// @param sPath The path to the schema object to retrieve.
/// @param bIncludeItemTemplates If TRUE, item templates (defs) will be
///     included as part of the returned object.
json quest_GetTemplate(string sPath, int bIncludeItemTemplates = FALSE)
{
    return quest_GetSchemaTemplate(sPath, bIncludeItemTemplates);
}

/// @private Convenience function for retrieving the quest template.
json quest_GetQuestTemplate()
{ 
    return quest_GetTemplate("quest");
}

/// @private Convenience function for retrieving an item template.
/// @param sKey The key of the item object to retrieve.
json quest_GetItemTemplate(string sKey)
{
    return quest_GetTemplate("defs." + sKey);
}

json quest_GetDefaultData()
{
    // So the standard query doesn't handle this, even thogh the test setup
    //  does, so we'll just do this manually for now.  Since quests can change
    //  and admins have the option to allow players to run the old quest
    //  (assuming everythign else still works/exists, but that's outside our
    //      purview), we need to save all the data for each quest in addition
    //      to the pc's quest progress.  So the data for each quest should look
    //      like this:
    // 
    // [ // This will an array of all quest attempts for this quest_tag
    //      {   
    //          // quest_data will be static and is found at $[#].quest_data.(field)
    //          questData: {
    //              // All quest data for this attempt
    //              // This will essentially be a copy of all quest data
    //              //      at the time the quest was assigned
    //          },
    //          // step_data will be dynamic and is found at $[#].step_data[#].(field)
    //          stepData: [
    //              // All step data for this attempt
    //          ]
    //      },
    // ]

    json j = JsonObjectSet(JSON_OBJECT, "questData", JSON_OBJECT);
    JsonObjectSetInplace(j, "stepItem", JSON_ARRAY);

    return j;


    //return GetDefaultSchemaObject(quest_GetSystemSchema(TRUE), "pc_data");
}

/// @private Build a prerequisite json object.
/// @param nType QUEST_VALUE_*.
/// @param sKey Prerequisite-specific data.
/// @param sValue Prerequisite-specific data.
/// @note See QUEST_SYSTEM_SCHEMA for json structure.
json quest_BuildPrerequisite(int nType, string sKey, string sValue)
{
    json j = GetLocalJson(GetModule(), "QUEST_DEFAULT_PREREQUISITE");
    if (j == JSON_NULL)
    {
        j = quest_GetItemTemplate("prerequisiteItem");
        SetLocalJson(GetModule(), "QUEST_DEFAULT_PREREQUISITE", j);
    }

    j = JsonObjectSet(j, QUEST_KEY_PREREQUISITE_TYPE, JsonInt(nType));
    j = JsonObjectSet(j, QUEST_KEY_PREREQUISITE_KEY, JsonString(sKey));
    return JsonObjectSet(j, QUEST_KEY_PREREQUISITE_VALUE, JsonString(sValue));
}

/// @private Build an objective json object.
/// @param nType QUEST_OBJECTIVE_*.
/// @param sTag Target object tag.
/// @param nValue Amount of sTag required to complete objective.
/// @param nMax Maximum amount of sTag allowed.
/// @param sData Objective-specific data.
/// @note See QUEST_SYSTEM_SCHEMA for json structure.
json quest_BuildObjective(int nType, string sTag, int nValue, int nMax, string sData = "")
{
    json j = GetLocalJson(GetModule(), "QUEST_DEFAULT_OBJECTIVE");
    if (j == JSON_NULL)
    {
        j = quest_GetItemTemplate("objectiveItem");
        SetLocalJson(GetModule(), "QUEST_DEFAULT_OBJECTIVE", j);
    }

    j = JsonObjectSet(j, QUEST_KEY_OBJECTIVE_TYPE, JsonInt(nType));
    j = JsonObjectSet(j, QUEST_KEY_OBJECTIVE_TAG, JsonString(sTag));
    j = JsonObjectSet(j, QUEST_KEY_OBJECTIVE_VALUE, JsonInt(nValue));
    j = JsonObjectSet(j, QUEST_KEY_OBJECTIVE_MAX, JsonInt(nMax));
    return JsonObjectSet(j, QUEST_KEY_OBJECTIVE_DATA, JsonString(sData));
}

/// @private Build a [p]reward object.
/// @param nCategory QUEST_CATEGORY_*.
/// @param nType QUEST_VALUE_*.
/// @param sKey [p]reward-specific data.
/// @param sValue [p]reward-specific data.
/// @param bParty Provide [p]reward to entire party.
/// @note See QUEST_SYSTEM_SCHEMA for json structure.
json quest_BuildReward(int nCategory, int nType, string sKey, string sValue, int bParty)
{
    json j = GetLocalJson(GetModule(), "QUEST_DEFAULT_REWARD");
    if (j == JSON_NULL)
    {
        j = quest_GetItemTemplate("rewardItem");
        SetLocalJson(GetModule(), "QUEST_DEFAULT_REWARD", j);
    }

    j = JsonObjectSet(j, QUEST_KEY_CATEGORY_CATEGORY, JsonInt(nCategory));
    j = JsonObjectSet(j, QUEST_KEY_CATEGORY_TYPE, JsonInt(nType));
    j = JsonObjectSet(j, QUEST_KEY_CATEGORY_KEY, JsonString(sKey));
    j = JsonObjectSet(j, QUEST_KEY_CATEGORY_VALUE, JsonString(sValue));
    return JsonObjectSet(j, QUEST_KEY_CATEGORY_PARTY, JsonBool(bParty));
}

/// @private Build a step object.
/// @param nStep The next step number.  This number should be -1 (if numbering
///     sequentially/incrementally) or a quest-unique step number.  It must
///     match the associated journal entry, if used.
json quest_BuildStep(int nStep)
{
    json j = GetLocalJson(GetModule(), "QUEST_DEFAULT_STEP");
    if (j == JSON_NULL)
        j = quest_GetItemTemplate("stepItem");

    SetLocalJson(GetModule(), "QUEST_DEFAULT_STEP", j);

    if (nStep > -1)
    {
        string s = r"
            SELECT json_set(@stepItem, @path, json(@step));
        ";
        sqlquery q = quest_PrepareQuery(s);
        SqlBindJson(q, "@stepItem", j);
        SqlBindString(q, "@path", "$.properties.ordinal");
        SqlBindInt(q, "@step", nStep);
    }

    return j;
}

/// @private Add a quest to the `quest_module` table.  This is the beginning of the quest
///     definition process.
/// @param sTag The tag of the quest being added.  Must be unique.
/// @param sTitle The title of the associated journal entry.
/// @return TRUE/FALSE whether the quest was successfully added.
int quest_AddQuest(string sTag, string sTitle = "")
{
    string s = r"
        INSERT INTO quest_module (quest_tag)
        VALUES (@sTag);
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);
    SqlStep(q);

    if (quest_Exists(sTag))
    {
        quest_SetBuildQuest(sTag);
        quest_DeleteBuildStep();
        quest_DeleteBuildObjective();

        if (sTitle != "")
            quest_SetProperty(QUEST_KEY_JOURNAL_TITLE, JsonString(sTitle));
        
        return TRUE;
    }
    else
    {
        QuestError("Failed to add quest");
        return FALSE;
    }
}

/// @private Add a quest step to the quest currently being defined.
/// @returns If nStep == -1, the incremented step number, otherwise nStep.
/// @warning This function is designed for use during the quest definition
///     process.  Calling this function outside of that process may have
///     unintended consequences and could cause data modification or loss.
int quest_AddStep(int nStep)
{


    //nStep = quest_SetProperty(QUEST_KEY_STEPS, "", quest_BuildStep(nStep));
    //SetLocalInt(GetModule(), QUEST_BUILD_STEP, nStep);

    return 0;//nStep;
}

/// @private Retrieve the script associated with a specific event.
/// @param sScriptEvent QUEST_EVENT_ON_*.
/// @note If no script is set for sScriptEvent, the system will attempt
///     to find a script set for all events in the script.onAll key.
///     If neither script is set, an empty string is returned.
string quest_GetScript(string sScriptEvent)
{
    string s = r"
        SELECT COALESCE(
            json_extract(quest_data, '$.scripts.$1'), 
            json_extract(quest_data, '$.scripts.onAll')
        )
        FROM quest_module;
    ";
    s = SubstituteSubString(s, "$1", sScriptEvent);
    sqlquery q = quest_PrepareQuery(s);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}












/*



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

*/

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
