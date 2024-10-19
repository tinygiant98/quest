WITH RECURSIVE schema_tree AS (
    SELECT
        json_each.key,
        json_extract(json_each.value, '$.type') AS type,
        json_each.value,
        json_extract(json_each.value, '$.fields') AS fields,
		json_extract(json_each.value, '$.default') as dvalue,
		'$.' || json_each.key AS path
    FROM
        json_each(json_extract((SELECT schema FROM quest_schema LIMIT 1), '$.fields'))
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
	SELECT key FROM json_each(json_extract((SELECT schema FROM quest_schema LIMIT 1), '$.fields'))
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
WHERE schema_tree.key IN (SELECT key FROM parent_keys);