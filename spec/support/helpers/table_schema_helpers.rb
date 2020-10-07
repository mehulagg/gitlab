# frozen_string_literal: true

module TableSchemaHelpers
  def table_type(name)
    connection.select_value(<<~SQL)
      SELECT
        CASE class.relkind
        WHEN 'r' THEN 'normal'
        WHEN 'p' THEN 'partitioned'
        ELSE 'other'
        END as table_type
      FROM pg_catalog.pg_class class
      WHERE class.relname = '#{name}'
    SQL
  end

  def sequence_owned_by(table_name, column_name)
    connection.select_value(<<~SQL)
      SELECT
        sequence.relname as name
      FROM pg_catalog.pg_class as sequence
      INNER JOIN pg_catalog.pg_depend depend
        ON depend.objid = sequence.relfilenode
      INNER JOIN pg_catalog.pg_class class
        ON class.relfilenode = depend.refobjid
      INNER JOIN pg_catalog.pg_attribute attribute
        ON attribute.attnum = depend.refobjsubid
        AND attribute.attrelid = depend.refobjid
      WHERE class.relname = '#{table_name}'
        AND attribute.attname = '#{column_name}'
    SQL
  end

  def default_expression_for(table_name, column_name)
    connection.select_value(<<~SQL)
      SELECT
        pg_get_expr(attrdef.adbin, attrdef.adrelid) AS default_value
      FROM pg_catalog.pg_attribute attribute
      INNER JOIN pg_catalog.pg_attrdef attrdef
        ON attribute.attrelid = attrdef.adrelid
        AND attribute.attnum = attrdef.adnum
      WHERE attribute.attrelid = '#{table_name}'::regclass
        AND attribute.attname = '#{column_name}'
    SQL
  end

  def primary_key_constraint_name(table_name)
    connection.select_value(<<~SQL)
      SELECT
        conname AS constraint_name
      FROM pg_catalog.pg_constraint
      WHERE conrelid = '#{table_name}'::regclass
        AND contype = 'p'
    SQL
  end
end
