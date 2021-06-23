# frozen_string_literal: true

class CreateIssueCustomTypes < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  class IssueCustomType < ActiveRecord::Base
    enum issue_type: {
      issue: 0,
      incident: 1,
      test_case: 2
    }
  end

  DOWNTIME = false

  def up
    create_table_with_constraints :issue_custom_types do |t|
      t.text :name, null: false
      t.text :summary, null: true
      t.text :description # rubocop:disable Migration/AddLimitToTextColumns
      t.text :description_html # rubocop:disable Migration/AddLimitToTextColumns
      t.integer :cached_markdown_version
      t.integer :issue_type, limit: 2, default: 0, null: false
      t.text :icon_name, null: true
      t.references :namespace, foreign_key: { on_delete: :cascade }, index: true, null: true
      t.timestamps_with_timezone null: false

      t.text_limit :name, 255
      t.text_limit :summary, 255
      t.text_limit :icon_name, 255
    end

    # create default types
    IssueCustomType.create(name: 'Bug', namespace_id: nil, issue_type: :issue, icon_name: 'bug')
    IssueCustomType.create(name: 'Enhancement', namespace_id: nil, issue_type: :issue, icon_name: 'enhancement')
    IssueCustomType.create(name: 'Feature', namespace_id: nil, issue_type: :issue, icon_name: 'feature')
    IssueCustomType.create(name: 'Tech Debt', namespace_id: nil, issue_type: :issue, icon_name: 'tech-debt')
  end

  def down
    drop_table :issue_custom_types
  end
end
