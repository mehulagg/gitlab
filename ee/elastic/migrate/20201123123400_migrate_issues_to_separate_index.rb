# frozen_string_literal: true

class MigrateIssuesToSeparateIndex < Elastic::Migration
  FIELDS = %w(
    id
    iid
    title
    description
    created_at
    updated_at
    state
    project_id
    author_id
    confidential
    assignee_id
    visibility_level
    issues_access_level
  ).freeze

  def migrate
    helper.create_standalone_indices unless helper.index_exists?(index_name: issues_index_name)

    body = query(slice: 0, max_slices: 5)

    puts body

    response = client.reindex(body: body, wait_for_completion: true)

    raise "Reindexing failed with #{response['failures']}" if response['failures'].present?
  end

  def completed?
    true
  end

  private

  def query(slice:, max_slices:)
    {
      source: {
        index: default_index_name,
        _source: FIELDS,
        query: {
          match: {
            type: 'issue'
          }
        },
        slice: {
          id: slice,
          max: max_slices
        }
      },
      dest: {
        index: issues_index_name
      }
    }
  end

  def default_index_name
    helper.target_name
  end

  def issues_index_name
    "#{default_index_name}-issues"
  end
end
