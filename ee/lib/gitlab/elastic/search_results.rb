# frozen_string_literal: true

module Gitlab
  module Elastic
    class SearchResults
      include Gitlab::Utils::StrongMemoize

      DEFAULT_PER_PAGE = Gitlab::SearchResults::DEFAULT_PER_PAGE

      attr_reader :current_user, :query, :public_and_internal_projects, :sort, :filters

      # Limit search results by passed projects
      # It allows us to search only for projects user has access to
      attr_reader :limit_project_ids

      def initialize(current_user, query, limit_project_ids = nil, public_and_internal_projects: true, sort: nil, filters: {})
        @current_user = current_user
        @query = query
        @limit_project_ids = limit_project_ids
        @public_and_internal_projects = public_and_internal_projects
        @sort = sort
        @filters = filters
      end

      def objects(scope, page: 1, per_page: DEFAULT_PER_PAGE, preload_method: nil)
        page = (page || 1).to_i

        case scope
        when 'projects'
          eager_load(projects, page, per_page, preload_method, [:route, :namespace])
        when 'issues'
          eager_load(issues, page, per_page, preload_method, project: [:route, :namespace], labels: [], timelogs: [], assignees: [])
        when 'merge_requests'
          eager_load(merge_requests, page, per_page, preload_method, target_project: [:route, :namespace])
        when 'milestones'
          eager_load(milestones, page, per_page, preload_method, project: [:route, :namespace])
        when 'notes'
          eager_load(notes, page, per_page, preload_method, project: [:route, :namespace])
        when 'blobs'
          blobs(page: page, per_page: per_page)
        when 'wiki_blobs'
          wiki_blobs(page: page, per_page: per_page)
        when 'commits'
          commits(page: page, per_page: per_page, preload_method: preload_method)
        else
          Kaminari.paginate_array([])
        end
      end

      # Pull the highlight attribute out of Elasticsearch results
      # and map it to the result id
      def highlight_map(scope)
        results = case scope
                  when 'projects'
                    projects
                  when 'issues'
                    issues
                  when 'merge_requests'
                    merge_requests
                  when 'milestones'
                    milestones
                  when 'notes'
                    notes
                  end

        results.to_h { |x| [x[:_source][:id], x[:highlight]] } if results.present?
      end

      def formatted_count(scope)
        case scope
        when 'projects'
          projects_count.to_s
        when 'notes'
          notes_count.to_s
        when 'blobs'
          blobs_count.to_s
        when 'wiki_blobs'
          wiki_blobs_count.to_s
        when 'commits'
          commits_count.to_s
        when 'issues'
          issues_count.to_s
        when 'merge_requests'
          merge_requests_count.to_s
        when 'milestones'
          milestones_count.to_s
        end
      end

      def projects_count
        @projects_count ||= projects.total_count
      end

      def notes_count
        @notes_count ||= notes.total_count
      end

      def blobs_count
        @blobs_count ||= blobs.total_count
      end

      def wiki_blobs_count
        @wiki_blobs_count ||= wiki_blobs.total_count
      end

      def commits_count
        @commits_count ||= commits.total_count
      end

      def issues_count
        @issues_count ||= issues.total_count
      end

      def merge_requests_count
        @merge_requests_count ||= merge_requests.total_count
      end

      def milestones_count
        @milestones_count ||= milestones.total_count
      end

      # mbergeron: these aliases act as an adapter to the Gitlab::SearchResults
      # interface, which is mostly implemented by this class.
      alias_method :limited_projects_count, :projects_count
      alias_method :limited_notes_count, :notes_count
      alias_method :limited_blobs_count, :blobs_count
      alias_method :limited_wiki_blobs_count, :wiki_blobs_count
      alias_method :limited_commits_count, :commits_count
      alias_method :limited_issues_count, :issues_count
      alias_method :limited_merge_requests_count, :merge_requests_count
      alias_method :limited_milestones_count, :milestones_count

      def self.parse_search_result(result, project)
        ref = result["_source"]["blob"]["commit_sha"]
        path = result["_source"]["blob"]["path"]
        extname = File.extname(path)
        basename = path.sub(/#{extname}$/, '')
        content = result["_source"]["blob"]["content"]
        project_id = result['_source']['project_id'].to_i
        total_lines = content.lines.size

        highlight_content = result.dig('highlight', 'blob.content')&.first || ''

        found_line_number = 0
        highlight_found = false

        highlight_content.each_line.each_with_index do |line, index|
          if line.include?(::Elastic::Latest::GitClassProxy::HIGHLIGHT_START_TAG)
            found_line_number = index
            highlight_found = true
            break
          end
        end

        from = if found_line_number >= 2
                 found_line_number - 2
               else
                 found_line_number
               end

        to = if (total_lines - found_line_number) > 3
               found_line_number + 2
             else
               found_line_number
             end

        data = content.lines[from..to]
        # only send highlighted line number if a highlight was returned by Elasticsearch
        highlight_line = highlight_found ? found_line_number + 1 : nil

        ::Gitlab::Search::FoundBlob.new(
          path: path,
          basename: basename,
          ref: ref,
          startline: from + 1,
          highlight_line: highlight_line,
          data: data.join,
          project: project,
          project_id: project_id
        )
      end

      private

      # Apply some eager loading to the `records` of an ES result object without
      # losing pagination information. Also, take advantage of preload method if
      # provided by the caller.
      def eager_load(es_result, page, per_page, preload_method, eager)
        paginated_base = es_result.page(page).per(per_page)
        relation = paginated_base.records.includes(eager) # rubocop:disable CodeReuse/ActiveRecord
        relation = relation.public_send(preload_method) if preload_method # rubocop:disable GitlabSecurity/PublicSend

        Kaminari.paginate_array(
          relation.to_a,
          total_count: paginated_base.total_count,
          limit: per_page,
          offset: per_page * (page - 1)
        )
      end

      def base_options
        {
          current_user: current_user,
          project_ids: limit_project_ids,
          public_and_internal_projects: public_and_internal_projects,
          sort: sort
        }
      end

      def projects
        strong_memoize(:projects) do
          Project.elastic_search(query, options: base_options)
        end
      end

      def issues
        strong_memoize(:issues) do
          options = base_options.merge(filters.slice(:sort, :confidential, :state))

          Issue.elastic_search(query, options: options)
        end
      end

      def milestones
        strong_memoize(:milestones) do
          # Must pass 'issues' and 'merge_requests' to check
          # if any of the features is available for projects in ApplicationClassProxy#project_ids_query
          # Otherwise it will ignore project_ids and return milestones
          # from projects with milestones disabled.
          options = base_options
          options[:features] = [:issues, :merge_requests]

          Milestone.elastic_search(query, options: options)
        end
      end

      def merge_requests
        strong_memoize(:merge_requests) do
          options = base_options.merge(filters.slice(:sort, :state))

          MergeRequest.elastic_search(query, options: options)
        end
      end

      def notes
        strong_memoize(:notes) do
          Note.elastic_search(query, options: base_options)
        end
      end

      def blobs(page: 1, per_page: DEFAULT_PER_PAGE)
        return Kaminari.paginate_array([]) if query.blank?

        strong_memoize(:blobs) do
          Repository.__elasticsearch__.elastic_search_as_found_blob(
            query,
            page: (page || 1).to_i,
            per: per_page,
            options: base_options
          )
        end
      end

      def wiki_blobs(page: 1, per_page: DEFAULT_PER_PAGE)
        return Kaminari.paginate_array([]) if query.blank?

        strong_memoize(:wiki_blobs) do
          ProjectWiki.__elasticsearch__.elastic_search_as_wiki_page(
            query,
            page: (page || 1).to_i,
            per: per_page,
            options: base_options
          )
        end
      end

      # We're only memoizing once because this object only ever gets used to show a single page of results
      # during its lifetime. We _must_ memoize the page we want because `#commits_count` does not have any
      # inkling of the current page we're on - if we were to memoize with dynamic parameters we would end up
      # hitting ES twice for any page that's not page 1, and that's something we want to avoid.
      #
      # It is safe to memoize the page we get here because this method is _always_ called before `#commits_count`
      def commits(page: 1, per_page: DEFAULT_PER_PAGE, preload_method: nil)
        return Kaminari.paginate_array([]) if query.blank?

        strong_memoize(:commits) do
          Repository.find_commits_by_message_with_elastic(
            query,
            page: (page || 1).to_i,
            per_page: per_page,
            options: base_options,
            preload_method: preload_method
          )
        end
      end

      def default_scope
        'projects'
      end
    end
  end
end
