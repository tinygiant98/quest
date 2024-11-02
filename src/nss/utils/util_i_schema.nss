/// ----------------------------------------------------------------------------
/// @file   util_i_schema.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Json Schema Functions
/// ----------------------------------------------------------------------------

#include "util_i_strings"

sqlquery schema_PrepareQuery(string s)
{
    s = SubstituteSubStrings(s, "\n", "");
    s = RegExpReplace("\\s+", s, " ");
    return SqlPrepareQueryObject(GetModule(), s);
}

/// @brief Retrieve the full path for a specified key
///     from the supplied schema.
/// @warning This function assumes all keys are
///     schema-unique, however, if there are multiple keys
///     with the same name in the schema, a hint can be
///     provided to narrow the search.  The hint should
///     be a string that is present within the path (such as
///     as upstream key) that will determine which of the
///     downstream keys to return.
string GetKeyPath(json jSchema, string sKey, string sHint = "")
{
    string s = r"
        SELECT fullkey
        FROM json_tree(@schema, '$') 
        WHERE key = @sKey
            AND fullkey LIKE '%' || @sHint || '%'
        LIMIT 1;
    ";
    sqlquery q = schema_PrepareQuery(s);
    SqlBindJson(q, "@schema", jSchema);
    SqlBindString(q, "@sKey", sKey);
    SqlBindString(q, "@sHint", sHint);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

/// @brief Create a default definition for any schema primary or item member.
/// @param jSchema JSON schema object.
/// @param sDef Sub-schema definition name to retrieve.  If blank, the primary
///     definition will be returned.
/// @returns JSON object with default values.
/// @warning This query works, but is very-system specific and does not work
///     for json objects nested more than two level deep.  I'm too lazy to
///     work on it and probably too stupid to figure it out.
json GetDefaultSchemaObject(json jSchema, string sDef = "fields")
{
    string s = r"
        WITH RECURSIVE schema_tree AS (
            SELECT
                json_each.key,
                json_extract(json_each.value, '$.type') AS type,
                json_each.value,
                json_extract(json_each.value, '$.fields') AS fields,
                json_extract(json_each.value, '$.default') as dvalue,
                '$.' || json_each.key AS path
            FROM
                json_each(json_extract(@schema, '$.' || @def))
            UNION ALL
            SELECT
                json_each.key,
                json_extract(json_each.value, '$.type') AS type,
                json_each.value,
                json_extract(json_each.value, '$.fields') AS fields,
                json_extract(json_each.value, '$.default') as dvalue,
                schema_tree.path || '.' || json_each.key AS path
            FROM 
                schema_tree,
                json_each(schema_tree.fields)
        ),
        parent_keys AS (
            SELECT key FROM json_each(json_extract(@schema, '$.' || @def))
        )
        SELECT
            json_group_object(
                schema_tree.key,
                CASE
                    WHEN schema_tree.type = 'object' THEN (
                        SELECT json_group_object(
                            child.key,
                            COALESCE(
                                child.dvalue,
                                CASE child.type
                                    WHEN 'integer' THEN 0
                                    WHEN 'string' THEN ''
                                    WHEN 'boolean' THEN false
                                    WHEN 'float' THEN 0.0
                                    WHEN 'object' THEN (
                                        SELECT json_group_object(
                                            grandchild.key,
                                            COALESCE(
                                                grandchild.dvalue,
                                                CASE grandchild.type
                                                    WHEN 'integer' THEN 0
                                                    WHEN 'string' THEN ''
                                                    WHEN 'boolean' THEN false
                                                    WHEN 'float' THEN 0.0
                                                    WHEN 'object' THEN json_object()
                                                    WHEN 'array' THEN json_array()
                                                END
                                            )
                                        )
                                        FROM schema_tree AS grandchild
                                        WHERE grandchild.path LIKE '$.' || schema_tree.key || '.' || child.key || '.' || grandchild.key
                                    )
                                            
                                    WHEN 'array' THEN json_array()
                                END
                            )
                        )
                        FROM schema_tree AS child
                        WHERE child.path LIKE '$.' || schema_tree.key || '.' || child.key
                    )
                    WHEN schema_tree.type = 'array' THEN json_array()
                END
        ) AS value
        FROM
            schema_tree
        WHERE schema_tree.key IN (SELECT key FROM parent_keys);
    ";
    sqlquery q = schema_PrepareQuery(s);
    SqlBindJson(q, "@schema", jSchema);
    SqlBindString(q, "@def", sDef);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}

        SELECT t.*,
			IIF(json_extract(t.value, '$.type') IS NOT NULL,
				IIF(json_extract(t.value, '$.default') IS NOT NULL,
					IIF(json_type(json_extract(t.type, '$.default')) = json_extract(t.type, '$.type'),
						json_extract(t.type, '$.default'), 
						CASE json_extract(t.value, '$.type')
							WHEN 'integer' THEN 0
							WHEN 'float' THEN 0.0
							WHEN 'string' THEN ''
							WHEN 'boolean' THEN false
							WHEN 'object' THEN json_object()
							WHEN 'array' THEN json_array()
						END
					),
					CASE json_extract(t.value, '$.type')
						WHEN 'integer' THEN 0
						WHEN 'float' THEN 0.0
						WHEN 'string' THEN ''
						WHEN 'boolean' THEN false
						WHEN 'object' THEN json_object()
						WHEN 'array' THEN json_array()
					END
				),
				''
			) AS new_value