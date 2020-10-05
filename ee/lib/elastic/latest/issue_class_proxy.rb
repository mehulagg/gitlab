# frozen_string_literal: true

module Elastic
  module Latest
    class IssueClassProxy < ApplicationClassProxy
      include StateFilter

      def elastic_search(query, options: {})
        query_hash =
          if query =~ /#(\d+)\z/
            iid_query_hash(Regexp.last_match(1))
          else
            fields = %w(title^2 description)

            # We can only allow searching the iid field if the query is
            # just a number, otherwise Elasticsearch will error since this
            # field is type integer.
            fields << "iid^3" if query =~ /\A\d+\z/

            basic_query_hash(fields, query)
          end

        options[:features] = 'issues'
        query_hash = project_ids_filter(query_hash, options)
        query_hash = confidentiality_filter(query_hash, options)
        query_hash = state_filter(query_hash, options)
        query_hash = apply_sort(query_hash, options)

        search(query_hash, options)
      end

      private

      def confidentiality_filter(query_hash, options)
        current_user = options[:current_user]
        project_ids = options[:project_ids]
        confidential_filter = options[:confidential]

        if Feature.enabled?(:search_filter_by_confidential) && confidential_filter.present? && %w(yes no).include?(confidential_filter)
          query_hash[:query][:bool][:filter] << { term: { confidential: confidential_filter == 'yes' } }
        end

        return query_hash if current_user&.can_read_all_resources?

        scoped_project_ids = scoped_project_ids(current_user, project_ids)
        authorized_project_ids = authorized_project_ids(current_user, options)

        # we can shortcut the filter if the user is authorized to see
        # all the projects for which this query is scoped on
        unless scoped_project_ids == :any || scoped_project_ids.empty?
          return query_hash if authorized_project_ids.to_set == scoped_project_ids.to_set
        end

        filter = { term: { confidential: false } }

        if current_user
          filter = {
              bool: {
                should: [
                  { term: { confidential: false } },
                  {
                    bool: {
                      must: [
                        { term: { confidential: true } },
                        {
                          bool: {
                            should: [
                              { term: { author_id: current_user.id } },
                              { term: { assignee_id: current_user.id } },
                              { terms: { project_id: authorized_project_ids } }
                            ]
                          }
                        }
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
