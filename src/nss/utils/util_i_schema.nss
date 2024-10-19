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

json GetDefaultDef(json jSchema, string sDef = "")
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
                json_each(json_extract(@schema, '$.fields'))
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
                                    WHEN 'object' THEN '{}'
                                    WHEN 'array' THEN '[]'
                                END
                            )
                        )
                        FROM schema_tree AS child
                        WHERE child.path LIKE '$.' || schema_tree.key || '.%'
                    )
                    WHEN schema_tree.type = 'array' THEN json_array()
                END
            ) AS value
        FROM
            schema_tree
        WHERE schema_tree.key IN (SELECT key FROM json_each(json_extract(@schema, '$.fields')));
    ";

    sqlquery q = schema_PrepareQuery(s);
    SqlBindJson(q, "@schema", jSchema);
    SqlBindString(q, "@def", sDef);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}

json GetSchemaDef(json jSchema, string sDef)
{
    string s = r"
        SELECT json_extract(@schema, '$.$defs.' || @def);
    ";
    sqlquery q = schema_PrepareQuery(s);
    SqlBindJson(q, "@schema", jSchema);
    SqlBindString(q, "@def", sDef);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}

/// @brief Create a default definition for any schema primary or item member.
/// @param jSchema JSON schema object.
/// @param sDef Sub-schema definition name to retrieve.  If blank, the primary
///     definition will be returned.
/// @returns JSON object with default values.
json GetDefaultDefTest(json jSchema, string sDef = "")
{
    string s = r"
        WITH RECURSIVE schema_tree AS (
            SELECT
                json_each.key,
                json_extract(json_each.value, '$.type') AS type,
                json_each.value,
                json_extract(json_each.value, '$.fields') AS fields,
                json_extract(json_each.value, '$.fields.' || json_each.key || '.default') as dvalue,
                '$.' || json_each.key AS path
            FROM
                json_each(
                    CASE
                        WHEN @def = '' THEN json_extract(@schema, '$.fields')
                        ELSE json_extract(@schema, '$.$defs.' || @def || '.fields')
                    END
                )
            UNION ALL
            SELECT
                json_each.key,
                json_extract(json_each.value, '$.type') AS type,
                json_each.value,
                json_extract(json_each.value, '$.fields') AS fields,
                json_extract(json_each.value, '$.fields.' || json_each.key || '.default') as dvalue,
                schema_tree.path || '.' || json_each.key AS path
            FROM 
                schema_tree,
                json_each(schema_tree.fields)
        ),
        parent_tree AS (
            SELECT *
            FROM
                json_each(
                    CASE
                        WHEN @def = '' THEN json_extract(@schema, '$.fields')
                        ELSE json_extract(@schema, '$.$defs.' || @def || '.fields')
                    END
                )
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
                                    WHEN 'object' THEN '{}'
                                    WHEN 'array' THEN '[]'
                                END
                            )
                        )
                        FROM schema_tree AS child
                        WHERE child.path LIKE '$.' || schema_tree.key || '.%'
                    )
                    WHEN schema_tree.type = 'array' THEN json_array()
                    ELSE COALESCE(
                        schema_tree.dvalue,
                        CASE schema_tree.type
                            WHEN 'integer' THEN 0
                            WHEN 'string' THEN ''
                            WHEN 'boolean' THEN false
                            WHEN 'float' THEN 0.0
                            WHEN 'object' THEN '{}'
                            WHEN 'array' THEN '[]'
                        END
                    )
                END
            ) AS value
        FROM
            schema_tree
        WHERE schema_tree.key IN (SELECT key FROM parent_tree);
    ";
    sqlquery q = schema_PrepareQuery(s);
    SqlBindJson(q, "@schema", jSchema);
    SqlBindString(q, "@def", sDef);

    return SqlStep(q) ? SqlGetJson(q, 0) : JSON_NULL;
}
