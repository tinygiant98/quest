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

/// temporary until configuration file
/// Used to allow customization of how to uniquely identify a player
/// [ ] put this into the configuration file
string quest_GetPC(object oPC)
{
    if (oPC != OBJECT_INVALID && GetIsObjectValid(oPC))
        return GetObjectUUID(oPC);
    else
        return "";
}

/// @private Central query preparation and supporting functions.
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
/// @param bForce If TRUE, the system schema will be reloaded.  This is used for testing
///     and should normally not be needed in production as it adds a lot of unnecessary
///     overhead.
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
                    END AS new_value,
                    replace(t.fullkey, '.fields', '') AS new_fullkey,
                    ROW_NUMBER() OVER (ORDER BY parent, id) AS row_num
                FROM schema_tree t
                ORDER BY parent, id
            ),
            schema_folded AS (
                SELECT row_num, new_value AS result
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
    if (bForce || (bIncludeItemTemplates == TRUE && jExpanded == JSON_NULL))
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
        SqlResetQuery(q, TRUE);

        SetLocalJson(GetModule(), "QUEST_SCHEMA_DEFS_EXPANDED", jExpanded);
    }

    SqlBindJson  (q, "@schema", quest_GetSystemSchema(bForce));
    SqlBindString(q, "@path", sPath);
    SqlBindInt   (q, "@includeItemTemplates", bIncludeItemTemplates);
    SqlBindJson  (q, "@itemTemplates", bIncludeItemTemplates ? jExpanded : JSON_NULL);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}

/// @private Split sPath into the following components:
///     (0) table name
///     (1) path to the final array
///     (2) path within final array
/// @param sPath The schema path to split.
/// @returns A json array containing the three elements defined above.  On error,
///     returns a json representation of sPath.  An error can be identified if
///     quest_SplitPath(sPath) == JsonString(sPath).
json quest_SplitPath(string sPath)
{
    string r = "^\\$\\.(\\w+)(?:\\.?(.*)\\[.*\\]|)\\.?(.*)$";
    json j = RegExpMatch(r, sPath);

    if (j == JSON_NULL || j == JSON_ARRAY)
        return JsonString(sPath);
    else
        return JsonArrayGetRange(j, 1, -1);
}

/// @private Retrieves the full path for the specified key in jTemplate.
/// @param sKey The key to search for.
/// @param sTemplate The json object to search for sKey.  If missing,
///     the full system schema will be searched.
/// @note If an array is present in the resultant path, the array index
///     will be replaced with a reference to the last element in the array.
string quest_GetPath(string sKey, json jTemplate = JSON_NULL)
{
    string s = r"
        WITH
            schema_tree AS (
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

    return RegExpReplace("\\[0\\]", SqlStep(q) ? SqlGetString(q, 0) : "", "[#-1]");
}

/// @private Determine the type of json object expected by sKey in the system schema.
json quest_GetSchemaTypes(string sKey)
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
            ),
            type_map AS (
                SELECT CAST(json_each.key AS INTEGER) AS type_id
                FROM json_each(json_array('null', 'object', 'array', 'string', 'integer', 'float', 'boolean'))
                JOIN type ON json_each.value = type.type
            )
        SELECT json_group_array(type_map.type_id) AS types_array
        FROM type_map;
    ";

    sqlquery q = quest_PrepareQuery(s);
    SqlBindJson(q, "@schema", quest_GetSystemSchema());
    SqlBindString(q, "@key", sKey);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
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
    sModule = SubstituteSubString(sModule, "$1", JsonDump(quest_GetSchemaTemplate("module")));

    /// @brief Create a trigger on the quest_modules table to prevent insertion of duplicate
    ///     step numbers (ordinals) into the $.questSteps[#].stepProperties.stepOrdinal field.
    /// @warning This trigger will raise a system wide sql error if a duplicated step number is
    ///     inserted into the quest_data field.
    string sTriggerDuplicate = r"
        CREATE TRIGGER quest_module_duplicate
            BEFORE UPDATE ON quest_module
                FOR EACH ROW
                    WHEN json_extract(OLD.quest_data, '$.questSteps[#-1].stepProperties.$1') != 
                        json_extract(NEW.quest_data, '$.questSteps[#-1].stepProperties.$1')
                        AND EXISTS (
                            SELECT 1
                            FROM json_each(OLD.quest_data, '$.questSteps')
                            WHERE json_extract(value, '$.stepProperties.$1') = 
                                json_extract(NEW.quest_data, '$.questSteps[#-1].stepProperties.$1')
                        )
                        BEGIN
                            SELECT RAISE(ABORT, 'Duplicate step ordinal found');
                        END;
    ";
    sTriggerDuplicate = SubstituteSubStrings(sTriggerDuplicate, "$1", QUEST_KEY_STEP_ORDINAL);



    /// @brief Create a trigger on the quest_modules table that will automatically increment
    ///     the QUEST_KEY_STEP_ORDINAL field when a new step is added to the quest, assuming
    ///     the provided step ordinal is -1.  If the provided step ordinal is not -1, the
    ///     field will not be incremented and the duplicate field trigger will prevent the
    ///     insertion of a duplicate value.
    string sTriggerIncrement = r"
        CREATE TRIGGER quest_module_increment_after
        AFTER UPDATE ON quest_module
        FOR EACH ROW
            WHEN json_extract(NEW.quest_data, '$.questSteps[#-1].stepProperties.$1') = -1
                BEGIN
                    UPDATE quest_module
                    SET quest_data = json_set(quest_data, '$.questSteps[#-1].stepProperties.$1', 
                        IFNULL(
                            (SELECT MAX(json_extract(value, '$.stepProperties.$1')) + 1
                            FROM json_each(quest_data, '$.questSteps')
                            WHERE json_extract(value, '$.stepProperties.$1') != -1),
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
    ///     return empty or null values, so when new functionality is added to system,
    ///     data usage function should check for null values.

    /// @note Each json object added to the quest_data json array represents one quest
    ///     completion attempt for `pc_uuid` and quest `quest_tag`.  Each additional
    ///     attempt, if allowed, will add another json object to `quest_data` array, with
    ///     the last entry being considered the active (or most recently completed) attempt.

    /// @warning Deleting, clearing or resetting this table will cause *ALL* players
    ///     to lose all quest-related data.  Do not reset this table unless you
    ///     have backed up your quest data.

    string sPlayer = r"
        CREATE TABLE IF NOT EXISTS quest_player (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pc_uuid TEXT NOT NULL,
            quest_tag TEXT NOT NULL,
            quest_data TEXT DEFAULT '[]',
            UNIQUE (pc_uuid, quest_tag) ON CONFLICT IGNORE
        );
    ";
    
    /// To support changing quests, should make a full copy of quest data in situ at the time
    ///     the quest is assigned and save for each attempt.  This lets us give the module owner
    ///     the option to allow the player to complete the quest as it existed when it was assigned
    ///     in addition to the normal options or resetting to current/new, deleting all progress.

    /// Expected structure (array of): [{
    ///     properties:
    ///         startTime, completeTime, completeType, version
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
    ///     the real world creates.  Ummmmmmm - how to get the uuids (?).  Can we pick apart
    ///     the bic file?

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
///     The quest_GetKey function will always return the first segment.
///     The quest_GetValue function will always return the second segment, unless
///         a specified segment is requested.
/// @param s The string to parse.
/// @param n The segment index to retrieve (base 0).
string quest_GetSegment(string s, int n = 0)
{
    string r = "(?:.*?[:=]){" + IntToString(n) + "}(.*?)(?:[:=]|$)";
    return JsonGetString(JsonArrayGet(RegExpMatch(r, s), 1));
}

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

/// @private Sorts array found at sKey in j by sSortKey.
/// @returns The sorted array, or an empty array on error.
json quest_SortArray(json j, string sKey, string sSortKey)
{
    string sPath = quest_GetPath(sKey, j);
    string s = r"
        SELECT json_group_array(value) AS sorted_array
        FROM (
            SELECT value
            FROM json_each(@object, @path)
            ORDER BY json_extract(value, @sortKey)
        );
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@path", sPath);
    SqlBindString(q, "@sortKey", "$." + sSortKey);
    SqlBindJson(q, "@object", j);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_ARRAY;
}

/// @private Retrieves the entire quest_data fields from either
///     the `quest_module` or `quest_player` tables.
json quest_GetData(string sTag, object oPC = OBJECT_INVALID)
{
    string s = r"
        SELECT quest_data
        FROM quest_$1
        WHERE quest_tag = @sTag
            $2
    ";
    s = SubstituteSubString(s, "$1", oPC == OBJECT_INVALID ? "module" : "player");
    s = SubstituteSubString(s, "$2", oPC == OBJECT_INVALID ? "" : "AND pc_uuid = @pc_uuid");
    
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);
    
    if (oPC != OBJECT_INVALID)
        SqlBindString(q, "@pc_uuid", quest_GetPC(oPC));

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}

int quest_CountChanges()
{
    sqlquery q = quest_PrepareQuery("SELECT changes()");
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

/// @private Determine the index of an array element given a specified
///     key and value within that array.
/// @param sKey The key containing an array-unique value.
/// @param jValue The value to search sKey for.
/// @param sTag The quest to search for the array in.  If missing, the
///     query currently being defined will be used.
/// @param oPC The player in question.  If missing, the module quest data
///     will be used as the source.
int quest_GetArrayIndex(string sKey, json jValue, string sTag = "", object oPC = OBJECT_INVALID)
{   
    sTag = (sTag == "" ? quest_GetBuildQuest() : sTag);
    json jPath = quest_SplitPath(quest_GetPath(sKey));

    string sq = oPC == OBJECT_INVALID ?
        r"
            SELECT json_each.value AS obj
            FROM quest_module, json_each(quest_data, 
                CASE
                    WHEN @arrayPath = '' THEN '$' 
                    ELSE '$.' || @arrayPath
                END
            )
            WHERE quest_tag = @sTag
        " :
        r"  
            SELECT json_each.value AS obj
            FROM quest_player, json_each(quest_data, 
                CASE
                    WHEN @arrayPath = '' THEN '$' 
                    ELSE '$.' || @arrayPath
                END
            )
            WHERE quest_tag = @sTag
                AND pc_uuid = @pc_uuid
        ";

    string s = r"
        WITH 
            json_array AS (
                $1
            ),
            indexed_array AS (
                SELECT 
                    row_number() OVER () - 1 AS idx,
                    json_extract(obj, '$.' || @path) AS extracted_value
                FROM json_array
            )
        SELECT idx
        FROM indexed_array
        WHERE extracted_value = @value ->> '$';
    "; 
    s = SubstituteSubStrings(s, "$1", sq);

    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);
    SqlBindString(q, "@path", JsonGetString(JsonArrayGet(jPath, 2)));
    SqlBindString(q, "@arrayPath", JsonGetString(JsonArrayGet(jPath, 1)));
    SqlBindJson(q, "@value", jValue);

    if (oPC != OBJECT_INVALID)
        SqlBindString(q, "@pc_uuid", quest_GetPC(oPC));

    return SqlStep(q) ? SqlGetInt(q, 0) : -1;
}

/// @private Determine if a specific quest exists.
/// @param sTag The tag of the quest to search for.
/// @warning This function does not determine if quest data was
///     populated, only if sTag exists in the `quest_module` table.
///     By definition, any existing quest will have at least the
///     default data populated.
int quest_Exists(string sTag, object oPC = OBJECT_INVALID)
{
    return quest_GetData(sTag, oPC) != JSON_NULL;
}

/// @private Determine whether a specified path exists in the
///     quest document for sTag.
/// @param sPath The path to search for.
/// @param sTag The quest to search for the path in.
/// @returns TRUE if the path exists, FALSE otherwise.
/// @warning This function should only be used internally as it
///     requires specific formatting for sPath.
int quest_PathExists(string sPath, string sTag = "")
{
    sTag = (sTag == "" ? quest_GetBuildQuest() : sTag);
    if (sTag == "" || !quest_Exists(sTag))
    {
        QuestError("Quest '" + sTag + "' does not exist; aborting");
        return FALSE;
    }

    string s = r"
        SELECT 
            CASE 
                WHEN json_extract(quest_data, @sPath) IS NOT NULL THEN 1
                ELSE 0
            END
        FROM quest_module
        WHERE quest_tag = @sTag;
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);
    SqlBindString(q, "@sPath", sPath);

    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

/// @private Retrieve a json value from a key in the `quest_module` table.
/// @param sKey Schema-unique key to retrieve.
/// @param sTag The quest to retrieve the data from.
/// @param nStep If retrieving an array element, the index to the element in the array.
///     If missing (-1), will retrieve the value from the last element in the array.
json quest_GetProperty(string sKey = "", string sTag = "", int nIndex = -1)
{
    sTag = (sTag == "" ? quest_GetBuildQuest() : sTag);
    if (sTag == "" || !quest_Exists(sTag)) // <- maybe not this as it's possible for
    //      players to have quests that no longer exist in the module, so it
    //      probably shoult be quest_Exists(module) || quest_Exists(player)
    {
        QuestError("Quest '" + sTag + "' does not exist");
        return JSON_NULL;
    }

    string sPath = sKey == "" ? "$" : quest_GetPath(sKey, quest_GetData(sTag));
    if (sPath == "")
    {
        QuestError("Path for key '" + sKey + "' not found");
        return JSON_NULL;
    }

    if (nIndex > -1)
        sPath = RegExpReplace("\\[#-1\\]", sPath, "[" + IntToString(nIndex) + "]");

    if (!quest_PathExists(sPath, sTag))
    {
        QuestError("Path '" + sPath + "' does not exist in quest '" + sTag + "'");
        return JSON_NULL;
    }

    string s = r"
        SELECT 
            CASE 
                WHEN json_type(quest_data, @sPath) = 'text' 
                    THEN json_quote(json_extract(quest_data, @sPath))
                ELSE json_extract(quest_data, @sPath)
            END
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
///     silently fail to be inserted into the .questSteps array.  The step number must match
///     the step number in the associated journal entry, if used.
int quest_SetProperty(string sKey, json jValue, string sTag = "", int nIndex = -1)
{
    sTag = (sTag == "" ? quest_GetBuildQuest() : sTag);
    if (sTag == "" || !quest_Exists(sTag))
    {
        QuestError("Quest '" + sTag + "' does not exist; aborting", __FUNCTION__);
        return FALSE;
    }

    string sPath = quest_GetPath(sKey, quest_GetData(sTag));
    if (sPath == "")
    {
        QuestError("Path for key '" + sKey + "' not found; aborting");
        return FALSE;
    }

    int nType = JsonGetType(jValue);
    json jTypes = quest_GetSchemaTypes(sKey);

    /// @brief jValue's type should never be NULL
    if (nType == JSON_TYPE_NULL)
    {
        QuestError("Value for key '" + sKey + "' is NULL; aborting");
        return FALSE;
    }
    /// @brief json objects are only used for adding new objects to an array
    ///     or adding a variable to a list
    else if (nType == JSON_TYPE_OBJECT)
    {
        /// @brief Receiving a json object against a json array is most likely
        ///     adding an entire object to the referenced array; however, check
        ///     to see if it may be a variable
        if (JsonFind(jTypes, JsonInt(JSON_TYPE_ARRAY)) != JSON_NULL)
        {
            if (JsonGetLength(jValue) == 1)
            {
                /// @brief Although this doesn't cover edge cases, there are no
                ///     json objects sent to this function by this system which
                ///     are one element in length and are not variables; so
                ///     assume this is a variable
                string sKey = JsonGetString(JsonArrayGet(JsonObjectKeys(jValue), 0));
                sPath += "[#-1]." + sKey;
                jValue = JsonObjectGet(jValue, sKey);
            }
            else
                /// @brief This is not a variable; add the json object as a new
                ///     element in the referenced array
                sPath += "[" + (nIndex == -1 ? "#" : IntToString(nIndex)) + "]";
        }
        else if (JsonFind(jTypes, JsonInt(JSON_TYPE_OBJECT)) != JSON_NULL)
        {
            /// @brief Variables are passed in as a json object with a single
            ///     key-value pair; pull the key-value pair out and add it to
            ///     the path-referenced json object
            if (JsonGetLength(jValue) == 1)
            {
                string sKey = JsonGetString(JsonArrayGet(JsonObjectKeys(jValue), 0));
                sPath += "." + sKey;
                jValue = JsonObjectGet(jValue, sKey);
            }
            else
            {
                QuestError("Incorrect object size for key '" + sKey + "'; aborting");
                return FALSE;
            }
        }
    }
    else if (nType == JSON_TYPE_ARRAY || JsonFind(jTypes, JsonInt(nType)) == JSON_NULL)
    {
        QuestError("Incorrect type for key '" + sKey + "'; aborting");
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
        QuestError("Failed to set property:" +
            "\n   sTag = " + sTag +
            "\n   sKey = " + sKey +
            "\n   sPath = " + sPath);
        return FALSE;
    }

    /// @note Step ordinals have special handling and are automatically incremented
    ///     via a table trigger as defined in `quest_CreateTables()`.  The incrementation
    ///     occurs after the step is added and can't be returned with a RETURNING
    ///     statement, so we need to retrieve the value manually.
    /// @note Since we should only have sKey == 'questSteps' when adding a step, the
    ///     index can safely be ignored for retrieving the step ordinal.
    if (sKey == "questSteps")
        return JsonGetInt(quest_GetProperty(QUEST_KEY_STEP_ORDINAL, sTag));

    return TRUE;
}

/// @private Retrieve a json object containing the default schema-level data,
///     including default settings.  This object is sourced from the quest
///     system schema.
/// @param sPath The path to the schema object to retrieve.  If missing, the
///     entire schema object will be returned.
/// @param bIncludeItemTemplates If TRUE, item templates (defs) will be
///     included as part of the returned object.
json quest_GetTemplate(string sPath = "", int bIncludeItemTemplates = FALSE)
{
    return quest_GetSchemaTemplate(sPath, bIncludeItemTemplates);
}

/// @private Convenience function for retrieving a quest template for inclusion
///     in `quest_module`.
json quest_GetModuleTemplate(int bIncludeItemTemplates = FALSE)
{ 
    return quest_GetTemplate("module", bIncludeItemTemplates);
}

/// @private Convenience function for retrieving a quest template for inclusion
///     in `quest_player`.
json quest_GetPlayerTemplate(int bIncludeItemTemplates = FALSE)
{
    return quest_GetTemplate("player", bIncludeItemTemplates);
}

/// @private Convenience function for retrieving an item template.
/// @param sKey The key of the item object to retrieve.  If missing, all defs
///     will be returned as a single object.
json quest_GetItemTemplate(string sKey, int bIncludeItemTemplates = FALSE)
{
    return quest_GetTemplate("defs" + (sKey == "" ? "" : "." + sKey), bIncludeItemTemplates);
}

/// @private Add a quest to the `quest_module` table.  This is the beginning of the quest
///     definition process.
/// @param sTag The tag of the quest being added.  Must be module-unique.
/// @param sTitle The title of the associated journal entry.
/// @returns TRUE/FALSE whether the quest was successfully added.
int quest_AddQuest(string sTag, string sTitle = "")
{
    string s = r"
        INSERT INTO quest_module (quest_tag)
        VALUES (@sTag)
        RETURNING id;
    ";
    sqlquery q = quest_PrepareQuery(s);
    SqlBindString(q, "@sTag", sTag);

    if (SqlStep(q))
    {
        quest_SetBuildQuest(sTag);
        if (sTitle != "")
            quest_SetProperty(QUEST_KEY_JOURNAL_TITLE, JsonString(sTitle));
        
        return TRUE;
    }
    else
    {
        QuestError("Failed to add quest '" + sTag + "'");
        return FALSE;
    }
}

/// @private Add a quest step to the quest currently being defined.
/// @returns If nStep == -1, the incremented step number, nStep if nStep
///     is unique to this quest, or FALSE if nStep is not unique.
/// @warning This function is designed for use during the quest definition
///     process.  Calling this function outside of that process may have
///     unintended consequences and could cause data modification or loss.
int quest_AddStep(int nStep = -1)
{
    json j = GetLocalJson(GetModule(), "QUEST_DEFAULT_STEP");
    if (j == JSON_NULL)
    {
        j = quest_GetItemTemplate("modStepItem");
        SetLocalJson(GetModule(), "QUEST_DEFAULT_STEP", j);
    }

    if (nStep > 0)
    {
        string s = r"
            SELECT json_set(@stepItem, @path, json(@step));
        ";
        sqlquery q = quest_PrepareQuery(s);
        SqlBindString(q, "@path", "$.stepProperties." + QUEST_KEY_STEP_ORDINAL);
        SqlBindJson  (q, "@stepItem", j);
        SqlBindInt   (q, "@step", nStep);

        j = SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
    }

    if (nStep == 0 || nStep < -1)
    {
        QuestError("Attempt to add step " + quest_StepToString(nStep) + " to quest '" + quest_QuestToString() + "' failed");
        return FALSE;
    }
    else
        return quest_SetProperty("questSteps", j);
}

/// @private Add a prerequisite to the quest currently being defined.
/// @param nType QUEST_VALUE_*.
/// @param sKey Prerequisite-specific data.
/// @param sValue Prerequisite-specific data.
/// @note See QUEST_SYSTEM_SCHEMA for json structure.
int quest_AddPrerequisite(json j)
{
    if (!quest_SetProperty("questPrerequisites", j))
    {
        QuestError("Failed to add prerequisite to quest '" + quest_GetBuildQuest() + "'");
        return FALSE;
    }

    return TRUE;
}

/// @private An an objective to the quest step currently being defined.
/// @param nType QUEST_OBJECTIVE_*.
/// @param sTag Target object tag.
/// @param nValue Amount of sTag required to complete objective.
/// @param nMax Maximum amount of sTag allowed.
/// @param sData Objective-specific data.
/// @note See QUEST_SYSTEM_SCHEMA for json structure.
int quest_AddObjective(json j)
{
    if (!quest_SetProperty("stepObjectives", j))
    {
        QuestError("Failed to add objective to quest '" + quest_GetBuildQuest() + "'");
        return FALSE;
    }

    return TRUE;
}

/// @private Add a [p]reward object to the quest step currently being defined.
/// @param nCategory QUEST_CATEGORY_*.
/// @param nType QUEST_VALUE_*.
/// @param sKey [p]reward-specific data.
/// @param sValue [p]reward-specific data.
/// @param bParty Provide [p]reward to entire party.
/// @note See QUEST_SYSTEM_SCHEMA for json structure.
int quest_AddReward(json j)
{
    if (!quest_SetProperty("stepAwards", j))
    {
        QuestError("Failed to add reward to quest '" + quest_GetBuildQuest() + "'");
        return FALSE;
    }

    return TRUE;
}

int quest_AddVariable(string sKey, json jValue, string sPath = "questVariables", string sTag = "", int nIndex = -1)
{
    return quest_SetProperty(sPath, JsonObjectSet(JSON_OBJECT, sKey, jValue), sTag, nIndex);
}

/// @private Retrieve the script associated with a specific event.
/// @param sScriptEvent QUEST_EVENT_ON_*.
/// @note If no script is set for sScriptEvent, the system will attempt
///     to find a script set for all events in the scripts.onAll key.
///     If neither script is set, an empty string is returned.
string quest_GetScript(string sScriptEvent, string sTag = "")
{
    sTag = (sTag == "" ? quest_GetBuildQuest() : sTag);
    string s = r"
        SELECT COALESCE(
            json_extract(quest_data, '$.questScripts.$1'), 
            json_extract(quest_data, '$.questScripts.onAll')
        )
        FROM quest_module
        WHERE quest_tag = @sTag;
    ";
    s = SubstituteSubString(s, "$1", sScriptEvent);
    sqlquery q = quest_PrepareQuery(s);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

/// @private Get the total individual or party item count for a specific item tag.
/// @note Accomplishing this task via sqlite takes approximately 400 times longer!
int quest_GetItemCount(object oPC, string sTag, int bParty = FALSE)
{
    object o = GetFirstFactionMember(oPC, TRUE);
    int n; while (GetIsObjectValid(o))
    {
        if (bParty || o == oPC)
        {
            object oItem = GetFirstItemInInventory(o);
            while (GetIsObjectValid(oItem))
            {
                if (GetStringLowerCase(GetTag(oItem)) == GetStringLowerCase(sTag))
                    n++;
                oItem = GetNextItemInInventory(o);
            }
        }
        o = GetNextFactionMember(oPC, TRUE);
    }

    return n;
}

/// @private Retrieve either a unix timestamp or a duration.
/// @note If passed, t should generally be a time value in the past.  If t is
///     in the future, the result of this function will be negative.
int quest_Time(int t = 0)
{
    sqlquery q = quest_PrepareQuery("SELECT strftime('%s', 'now')");
    return (SqlStep(q) ? SqlGetInt(q, 0) : 0) - t;
}

/// @private Evaluate a simple conditional relationship between
///     nBase and nCompare.
int quest_EvaluateCondition(int nBase, int nCompare, string sOp)
{
    if ((sOp == "=" || sOp == "==") && nBase == nCompare)
        return TRUE;
    else if (sOp == ">" && nBase > nCompare)
        return TRUE;
    else if (sOp == ">=" && nBase >= nCompare)
        return TRUE;
    else if (sOp == "<" && nBase < nCompare)
        return TRUE;
    else if (sOp == "<=" && nBase <= nCompare)
        return TRUE;
    else if (sOp == "!=" && nBase != nCompare)
        return TRUE;
    else
        return FALSE;
}

/*
// Awards quest sTag step nStep [p]rewards.  The awards type will be limited by nAwardType and can be
// provided to the entire party with bParty.  nCategoryType is a QUEST_CATEGORY_* constant.
void quest_DistributeAllotments(object oPC, string sTag, int nStep, string sType, int nType = AWARD_ALL)
{
    int nValueType, nAllotmentCount, bParty;
    string sKey, sValue, sData;

    QuestDebug("Awarding quest step allotments for " + quest_QuestToString(sTag) +
        " " + quest_StepToString(nStep) + " of type " + CategoryTypeToString(sCategory) +
        " to " + quest_PCToString(oPC));

    json jAllotments = quest_GetProperty("stepAwards", sTag, nStep);


    sqlquery sPairs = GetQuestStepPropertySets(nQuestID, nStep, nCategoryType);
    while (SqlStep(sPairs))
    {
        nAllotmentCount++;
        nValueType = SqlGetInt(sPairs, 0);
        sKey = SqlGetString(sPairs, 1);
        sValue = SqlGetString(sPairs, 2);
        sData = SqlGetString(sPairs, 3);
        bParty = SqlGetInt(sPairs, 4);

        QuestDebug("  " + HexColorString("Allotment #" + _i(nAllotmentCount), COLOR_CYAN) + " " +
            "  Value Type -> " + ColorValue(ValueTypeToString(nValueType)));            

        switch (nValueType)
        {
            case QUEST_VALUE_MESSAGE:
            {
                if ((nAwardType & AWARD_MESSAGE) || nAwardType == AWARD_ALL)
                {
                    string sMessage;

                    // If this is a random quest, we need to override the
                    // preward message
                    if (StringToInt("";//_GetQuestStepData(nQuestID, nStep, QUEST_STEP_RANDOM_OBJECTIVES)) != -1 &&
                        nCategoryType == QUEST_CATEGORY_PREWARD)
                    {
                        string sQuestTag = quest_GetTag(nQuestID);
                        string sCustomMessage = GetPCQuestString(oPC, sQuestTag, QUEST_CUSTOM_MESSAGE, nStep);
                        if (sCustomMessage == "")
                            QuestDebug("Custom preward message for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) +
                                " not created; there is no preward message to build from");
                        else
                        {
                            sMessage = sCustomMessage;
                            QuestDebug("Overriding standard preward message for " + quest_QuestToString(nQuestID) + " " +
                                quest_StepToString(nStep) + " with customized preward message for random quest creation: " +
                                ColorValue(sMessage));
                        }                            
                    }

                    if (sMessage == "")
                        sMessage = sValue;
                    
                    sMessage = HexColorString(sMessage, COLOR_CYAN);
                    SendMessageToPC(oPC, sMessage);
                }
                continue;
            }
            case QUEST_VALUE_FLOATINGTEXT:
            {
                if ((nAwardType & AWARD_FLOATINGTEXT || nAwardType == AWARD_ALL))
                {
                    string sMessage = sValue;
                    int nPartyOnly = StringToInt(quest_GetKey(sKey));
                    int nChatDisplay = StringToInt(quest_GetValue(sKey));
                    _AwardFloatingText(oPC, sMessage, nPartyOnly, nChatDisplay, bParty);
                }
                continue;
            }
            case QUEST_VALUE_GOLD:
            {
                if ((nAwardType & AWARD_GOLD) || nAwardType == AWARD_ALL)
                {
                    int nGold = StringToInt(sValue);
                    _AwardGold(oPC, nGold, bParty);
                }
                continue;
            }
            case QUEST_VALUE_XP:
            {
                if ((nAwardType & AWARD_XP) || nAwardType == AWARD_ALL)
                {
                    int nXP = StringToInt(sValue);
                    _AwardXP(oPC, nXP, bParty);
                }
                continue;
            }
            case QUEST_VALUE_ALIGNMENT:
            {
                if ((nAwardType & AWARD_ALIGNMENT) || nAwardType == AWARD_ALL)
                {
                    int nAxis = StringToInt(sKey);
                    int nShift = StringToInt(sValue);
                    _AwardAlignment(oPC, nAxis, nShift, bParty);
                }
                continue;
            }  
            case QUEST_VALUE_ITEM:
            {
                if ((nAwardType & AWARD_ITEM) || nAwardType == AWARD_ALL)
                {
                    string sResref = sKey;     
                    int nQuantity = StringToInt(sValue);
                    _AwardItem(oPC, sResref, nQuantity, bParty);
                }
                continue;
            }
            case QUEST_VALUE_QUEST:
            {
                if ((nAwardType & AWARD_QUEST) || nAwardType == AWARD_ALL)
                {
                    int nValue = StringToInt(sValue);
                    int nFlag = StringToInt(sValue);
                    _AwardQuest(oPC, nValue, nFlag, bParty);
                }
                continue;
            }
            case QUEST_VALUE_REPUTATION:
            {
                if ((nAwardType & AWARD_REPUTATION) || nAwardType == AWARD_ALL)
                {
                    string sFaction = sKey;
                    int nChange = StringToInt(sValue);

                    object oFactionMember = GetObjectByTag(sFaction);
                    AdjustReputation(oPC, oFactionMember, nChange);
                }
                continue;
            }
            case QUEST_VALUE_VARIABLE:
            {
                if ((nAwardType & AWARD_VARIABLE || nAwardType == AWARD_ALL))
                {
                    string sType = quest_GetKey(sKey);
                    string sVarName = quest_GetValue(sKey);
                    string sOperator = quest_GetKey(sValue);
                    sValue = quest_GetValue(sValue);

                    if (sType == "STRING")
                    {
                        string sPC = GetLocalString(oPC, sVarName);

                        if (sOperator == "=")
                            sPC = sValue;
                        else if (sOperator == "+")
                            sPC += sValue;
                        
                        if (sOperator != "x" && sOperator != "X")
                        {
                            QuestDebug("Awarding variable " + sVarName + " with value " + sPC +
                                "to " + quest_PCToString(oPC));      
                            SetLocalString(oPC, sVarName, sPC);
                        }
                        else
                        {
                            QuestDebug("Deleting variable " + sVarName + " from " +
                                quest_PCToString(oPC));
                            DeleteLocalString(oPC, sVarName);
                        }
                    }
                    else if (sType == "INT")
                    {
                        int nPC = GetLocalInt(oPC, sVarName);
                        int nValue = StringToInt(sValue);

                        if (sOperator == "=")
                            nPC = nValue;
                        else if (sOperator == "+")
                            nPC += nValue;
                        else if (sOperator == "-")
                            nPC -= nValue;
                        else if (sOperator == "++")
                            nPC++;
                        else if (sOperator == "--")
                            nPC--;
                        else if (sOperator == "*")
                            nPC *= nValue;
                        else if (sOperator == "/")
                            nPC /= nValue;
                        else if (sOperator == "%")
                            nPC %= nValue;
                        else if (sOperator == "|")
                            nPC |= nValue;
                        else if (sOperator == "&")
                            nPC = nPC & nValue;
                        else if (sOperator == "~")
                            nPC = ~nPC;          
                        else if (sOperator == "^")
                            nPC = nPC ^ nValue;
                        else if (sOperator == ">>")
                            nPC = nPC >> nValue;
                        else if (sOperator == "<<")
                            nPC = nPC << nValue;
                        else if (sOperator == ">>>")
                            nPC = nPC >>> nValue;
                        
                        if (sOperator != "x" && sOperator != "X")
                            SetLocalInt(oPC, sVarName, nPC);
                        else
                            DeleteLocalInt(oPC, sVarName);
                    }
                }
            }
        }
    }

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        QuestDebug("Found " + _i(nAllotmentCount) + " allotments for " + quest_QuestToString(nQuestID) + " " + quest_StepToString(nStep) +
            (nAllotmentCount > 0 ?          
                "\n  Category -> " + ColorValue(CategoryTypeToString(nCategoryType)) +
                "\n  Award -> " + ColorValue(AwardTypeToString(nAwardType)) : ""));
        
        if (nAllotmentCount > 0)
            QuestDebug("Awarded " + _i(nAllotmentCount) + " allotments to " + quest_PCToString(oPC) + (bParty ? " and party members" : ""));
        else
            QuestDebug("No allotments to award, no action taken");
    }
}
*/



/*
string GetQuestTimeStamp()
{
    sqlquery sql = quest_PrepareQuery("SELECT CURRENT_TIMESTAMP;");
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
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
