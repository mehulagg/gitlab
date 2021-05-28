# frozen_string_literal: true

class ModifyProjectMembersIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::SchemaHelpers
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX = 'index_non_requested_project_members_on_source_id_and_type1'

  def up
    begin
      disable_statement_timeout do
        execute "CREATE INDEX CONCURRENTLY #{INDEX} ON members " \
          'USING btree (source_id, source_type) INCLUDE (user_id, invite_token, access_level)' \
          'WHERE ' \
          '(' \
            '(requested_at IS NULL) ' \
            'AND (' \
              "(type):: text = 'ProjectMember' :: text" \
            ')' \
          ')'
      end
    rescue ActiveRecord::StatementInvalid => ex
      raise "The index #{INDEX} couldn't be added: #{ex.message}"
    end

    create_comment(
      'INDEX',
      INDEX,
      'Included attributes help with the billed_project_members query'
    )
  end

  def down
    return unless index_exists_by_name?('members', INDEX)

    remove_concurrent_index_by_name('members', INDEX)
  end
end
