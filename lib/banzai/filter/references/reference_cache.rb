# frozen_string_literal: true

module Banzai
  module Filter
    module References
      class ReferenceCache
        include Gitlab::Utils::StrongMemoize
        include RequestStoreReferenceCache

        attr_accessor :object_class, :parent_type, :parent, :filter, :context

        def initialize(object_class, parent_type, parent, filter, context)
          @object_class = object_class
          @parent_type = parent_type
          @parent = parent
          @filter = filter
          @context = context
        end

        def records_per_parent(nodes)
          @_records_per_project ||= {}

          @_records_per_project[object_class.to_s.underscore] ||= begin
            hash = Hash.new { |h, k| h[k] = {} }

            parent_per_reference(nodes).each do |path, parent|
              # binding.pry
              record_ids = references_per_parent(nodes)[path]

              filter.parent_records(parent, record_ids).each do |record|
                hash[parent][filter.record_identifier(record)] = record
              end
            end

            hash
          end
        end

        # Returns a Hash containing all object references (e.g. issue IDs) per the
        # project they belong to.
        def references_per_parent(nodes)
          @references_per ||= {}

          @references_per[parent_type] ||= begin
            refs = Hash.new { |hash, key| hash[key] = Set.new }

            nodes.each do |node|
              node.to_html.scan(regex) do
                path = if parent_type == :project
                         full_project_path($~[:namespace], $~[:project])
                       else
                         full_group_path($~[:group])
                       end

                refs[path] << filter.identifier($~)
              end
            end

            refs
          end
        end

        # Returns a Hash containing referenced projects grouped per their full
        # path.
        def parent_per_reference(nodes)
          @per_reference ||= {}

          @per_reference[parent_type] ||= begin
            refs = Set.new

            references_per_parent(nodes).each do |ref, _|
              refs << ref
            end

            find_for_paths(refs.to_a).index_by(&:full_path)
          end
        end

        def relation_for_paths(paths)
          klass = parent_type.to_s.camelize.constantize
          result = klass.where_full_path_in(paths)
          return result if parent_type == :group

          result.includes(:namespace) if parent_type == :project
        end

        # Returns projects for the given paths.
        def find_for_paths(paths)
          if Gitlab::SafeRequestStore.active?
            cache = refs_cache
            to_query = paths - cache.keys

            unless to_query.empty?
              records = relation_for_paths(to_query)

              found = []
              records.each do |record|
                ref = record.full_path
                get_or_set_cache(cache, ref) { record }
                found << ref
              end

              not_found = to_query - found
              not_found.each do |ref|
                get_or_set_cache(cache, ref) { nil }
              end
            end

            cache.slice(*paths).values.compact
          else
            relation_for_paths(paths)
          end
        end

        def current_parent_path
          strong_memoize(:current_parent_path) do
            parent&.full_path
          end
        end

        def current_project_namespace_path
          strong_memoize(:current_project_namespace_path) do
            project&.namespace&.full_path
          end
        end

        def full_project_path(namespace, project_ref)
          return current_parent_path unless project_ref

          namespace_ref = namespace || current_project_namespace_path
          "#{namespace_ref}/#{project_ref}"
        end

        def full_group_path(group_ref)
          return current_parent_path unless group_ref

          group_ref
        end

        private

        def project
          context[:project]
        end

        def regex
          strong_memoize(:regex) do
            [
              object_class.link_reference_pattern,
              object_class.reference_pattern
            ].compact.reduce { |a, b| Regexp.union(a, b) }
          end
        end

        def refs_cache
          Gitlab::SafeRequestStore["banzai_#{parent_type}_refs".to_sym] ||= {}
        end
      end
    end
  end
end
