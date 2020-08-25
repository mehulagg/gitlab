# frozen_string_literal: true

module Elastic
  module Latest
    module GitClassProxy
      SHA_REGEX = /\A[0-9a-f]{5,40}\z/i.freeze

      def elastic_search(query, type: 'all', page: 1, per: 20, options: {})
        results = { blobs: [], commits: [] }

        case type
        when 'all'
          results[:commits] = search_commit(query, page: page, per: per, options: options.merge(features: 'repository'))
          results[:blobs] = search_blob(query, type: 'blob', page: page, per: per, options: options.merge(features: 'repository'))
          results[:wiki_blobs] = search_blob(query, type: 'wiki_blob', page: page, per: per, options: options.merge(features: 'wiki'))
        when 'commit'
          results[:commits] = search_commit(query, page: page, per: per, options: options.merge(features: 'repository'))
        when 'blob'
          results[:blobs] = search_blob(query, type: type, page: page, per: per, options: options.merge(features: 'repository'))
        when 'wiki_blob'
          results[:wiki_blobs] = search_blob(query, type: type, page: page, per: per, options: options.merge(features: 'wiki'))
        end

        results
      end

      # @return [Kaminari::PaginatableArray]
      def elastic_search_as_found_blob(query, page: 1, per: 20, options: {})
        # Highlight is required for parse_search_result to locate relevant line
        options = options.merge(highlight: true)

        elastic_search_and_wrap(query, type: es_type, page: page, per: per, options: options) do |result, project|
          ::Gitlab::Elastic::SearchResults.parse_search_result(result, project)
        end
      end

      private

      def options_filter_context(type, options)
        repository_ids = [options[:repository_id]].flatten
        languages = [options[:language]].flatten

        filters = []
        filters << { terms: { "#{type}.rid" => repository_ids } } if repository_ids.any?
        filters << { terms: { "#{type}.language" => languages } } if languages.any?
        filters << options[:additional_filter] if options[:additional_filter]

        { filter: filters }
      end

      def search_commit(query, page: 1, per: 20, options: {})
        page ||= 1
        fields = %w(message^10 sha^5 author.name^2 author.email^2 committer.name committer.email).map {|i| "commit.#{i}"}
        query_with_prefix = query.split(/\s+/).map { |s| s.gsub(SHA_REGEX) { |sha| "#{sha}*" } }.join(' ')

        bool_expr = Gitlab::Elastic::BoolExpr.new
        query_hash = {
          query: { bool: bool_expr },
          size: per,
          from: per * (page - 1),
          sort: [:_score]
        }

        # If there is a :current_user set in the `options`, we can assume
        # we need to do a project visibility check.
        #
        # Note that `:current_user` might be `nil` for a anonymous user
        query_hash = project_ids_filter(query_hash, options) if options.key?(:current_user)

        if query.blank?
          bool_expr[:must] = { match_all: {} }
          query_hash[:track_scores] = true
        else
          bool_expr[:must] = {
            simple_query_string: {
              fields: fields,
              query: query_with_prefix,
              default_operator: :and
            }
          }
        end

        # add the document type filter
        bool_expr[:filter] << { term: { type: 'commit' } }

        # add filters extracted from the options
        options_filter_context = options_filter_context(:commit, options)
        bool_expr[:filter] += options_filter_context[:filter] if options_filter_context[:filter].any?

        options[:order] = :default if options[:order].blank?

        if options[:highlight]
          es_fields = fields.map { |field| field.split('^').first }.each_with_object({}) do |field, memo|
            memo[field.to_sym] = {}
          end

          query_hash[:highlight] = {
            pre_tags: ["gitlabelasticsearch→"],
            post_tags: ["←gitlabelasticsearch"],
            fields: es_fields
          }
        end

        res = search(query_hash, options)
        {
          results: res.results,
          total_count: res.size
        }
      end

      def search_blob(query, type: 'blob', page: 1, per: 20, options: {})
        page ||= 1

        query = ::Gitlab::Search::Query.new(query) do
          filter :filename, field: :file_name
          filter :path, parser: ->(input) { "*#{input.downcase}*" }
          filter :extension, field: :path, parser: ->(input) { '*.' + input.downcase }
        end

        bool_expr = Gitlab::Elastic::BoolExpr.new
        query_hash = {
          query: { bool: bool_expr },
          size: per,
          from: per * (page - 1),
          sort: [:_score]
        }

        # add the term matching
        bool_expr[:must] = {
          simple_query_string: {
            query: query.term,
            default_operator: :and,
            fields: %w[blob.content blob.file_name]
          }
        }

        # If there is a :current_user set in the `options`, we can assume
        # we need to do a project visibility check.
        #
        # Note that `:current_user` might be `nil` for a anonymous user
        query_hash = project_ids_filter(query_hash, options) if options.key?(:current_user)

        # add the document type filter
        bool_expr[:filter] << { term: { type: type } }

        # add filters extracted from the query
        query_filter_context = query.elasticsearch_filter_context(:blob)
        bool_expr[:filter] += query_filter_context[:filter] if query_filter_context[:filter].any?
        bool_expr[:must_not] += query_filter_context[:must_not] if query_filter_context[:must_not].any?

        # add filters extracted from the `options`
        options_filter_context = options_filter_context(:blob, options)
        bool_expr[:filter] += options_filter_context[:filter] if options_filter_context[:filter].any?

        options[:order] = :default if options[:order].blank?

        if options[:highlight]
          query_hash[:highlight] = {
            pre_tags: ["gitlabelasticsearch→"],
            post_tags: ["←gitlabelasticsearch"],
            order: "score",
            fields: {
              "blob.content" => {},
              "blob.file_name" => {}
            }
          }
        end

        # inject the `id` part of repository as project id
        repository_ids = [options[:repository_id]].flatten
        options[:project_ids] = repository_ids.map { |id| id.to_s[/\d+/].to_i } if type == 'wiki_blob' && repository_ids.any?

        res = search(query_hash, options)

        {
          results: res.results,
          total_count: res.size
        }
      end

      # Wrap returned results into GitLab model objects and paginate
      #
      # @return [Kaminari::PaginatableArray]
      def elastic_search_and_wrap(query, type:, page: 1, per: 20, options: {}, preload_method: nil, &blk)
        response = elastic_search(
          query,
          type: type,
          page: page,
          per: per,
          options: options
        )[type.pluralize.to_sym][:results]

        items, total_count = yield_each_search_result(response, type, preload_method, &blk)

        # Before "map" we had a paginated array so we need to recover it
        offset = per * ((page || 1) - 1)
        Kaminari.paginate_array(items, total_count: total_count, limit: per, offset: offset)
      end

      def yield_each_search_result(response, type, preload_method)
        # Avoid one SELECT per result by loading all projects into a hash
        project_ids = response.map { |result| project_id_for_commit_or_blob(result, type) }.uniq
        projects = Project.with_route.id_in(project_ids)
        projects = projects.public_send(preload_method) if preload_method # rubocop:disable GitlabSecurity/PublicSend
        projects = projects.index_by(&:id)
        total_count = response.total_count

        items = response.map do |result|
          project_id = project_id_for_commit_or_blob(result, type)
          project = projects[project_id]

          if project.nil? || project.pending_delete?
            total_count -= 1
            next
          end

          yield(result, project)
        end

        # Remove results for deleted projects
        items.compact!

        [items, total_count]
      end

      # Indexed commit does not include project_id
      def project_id_for_commit_or_blob(result, type)
        result.dig('_source', 'project_id') || result.dig('_source', type, 'rid').to_i
      end
    end
  end
end
