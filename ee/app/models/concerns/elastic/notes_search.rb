# frozen_string_literal: true

module Elastic
  module NotesSearch
    extend ActiveSupport::Concern

    included do
      include ApplicationSearch

      # Since we can't have multiple types in ES6, but want to be able to use JOINs, we must declare all our
      # fields together instead of per model
      mappings do
        ### Shared fields
        indexes :id, type: :integer
        indexes :created_at, type: :date
        indexes :updated_at, type: :date

        # ES6 requires a single type per index, so we implement our own "type"
        indexes :type, type: :keyword

        indexes :iid, type: :integer

        indexes :title, type: :text,
                        index_options: 'offsets'
        indexes :description, type: :text,
                              index_options: 'offsets'
        indexes :state, type: :text
        indexes :project_id, type: :integer
        indexes :author_id, type: :integer

        ### NOTES
        indexes :note, type: :text,
                       index_options: 'offsets'

        indexes :issue do
          indexes :assignee_id, type: :integer
          indexes :author_id, type: :integer
          indexes :confidential, type: :boolean
        end

        # ES6 gets rid of "index: :not_analyzed" option, but a keyword type behaves the same
        # as it is not analyzed and is only searchable by its exact value.
        indexes :noteable_type, type: :keyword
        indexes :noteable_id, type: :keyword
      end

      def self.inherited(subclass)
        super

        subclass.__elasticsearch__.index_name = self.index_name
        subclass.__elasticsearch__.document_type = self.document_type
        subclass.__elasticsearch__.instance_variable_set(:@mapping, self.mapping.dup)
      end

      def es_type
        'note'
      end

      def as_indexed_json(options = {})
        data = {}

        # We don't use as_json(only: ...) because it calls all virtual and serialized attributtes
        # https://gitlab.com/gitlab-org/gitlab-ee/issues/349
        [:id, :note, :project_id, :noteable_type, :noteable_id, :created_at, :updated_at].each do |attr|
          data[attr.to_s] = safely_read_attribute_for_elasticsearch(attr)
        end

        if noteable.is_a?(Issue)
          data['issue'] = {
            assignee_id: noteable.assignee_ids,
            author_id: noteable.author_id,
            confidential: noteable.confidential
          }
        end

        data.merge(generic_attributes)
      end

      def self.nested?
        true
      end

      def self.elastic_search(query, options: {})
        options[:in] = ['note']

        query_hash = basic_query_hash(%w[note], query)
        query_hash = project_ids_filter(query_hash, options)
        query_hash = confidentiality_filter(query_hash, options[:current_user])

        query_hash[:sort] = [
          { updated_at: { order: :desc } },
          :_score
        ]

        query_hash[:highlight] = highlight_options(options[:in])

        self.__elasticsearch__.search(query_hash)
      end

      def self.confidentiality_filter(query_hash, current_user)
        return query_hash if current_user && current_user.full_private_access?

        filter = {
          bool: {
            should: [
              { bool: { must_not: [{ exists: { field: :issue } }] } },
              { term: { "issue.confidential" => false } }
            ]
          }
        }

        if current_user
          filter[:bool][:should] << {
            bool: {
              must: [
                { term: { "issue.confidential" => true } },
                {
                  bool: {
                    should: [
                      { term: { "issue.author_id" => current_user.id } },
                      { term: { "issue.assignee_id" => current_user.id } },
                      { terms: { "project_id" => current_user.authorized_projects(Gitlab::Access::REPORTER).pluck(:id) } }
                    ]
                  }
                }
              ]
            }
          }
        end

        query_hash[:query][:bool][:filter] << filter
        query_hash
      end
    end
  end
end
