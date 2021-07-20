# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      module References
        # HTML filter that replaces iteration references with links.
        module IterationReferenceFilter
          include ::Gitlab::Utils::StrongMemoize

          def find_object(parent, id)
            return unless valid_context?(parent)

            find_iteration(parent, id: id)
          end

          def valid_context?(parent)
            group_context?(parent) || project_context?(parent)
          end

          def group_context?(parent)
            strong_memoize(:group_context) do
              parent.is_a?(Group)
            end
          end

          def project_context?(parent)
            strong_memoize(:project_context) do
              parent.is_a?(Project)
            end
          end

          def references_in(text, pattern = ::Iteration.reference_pattern)
            # We'll handle here the references that follow the `reference_pattern`.
            # Other patterns (for example, the link pattern) are handled by the
            # default implementation.
            return super(text, pattern) if pattern != ::Iteration.reference_pattern

            iterations = {}
            unescaped_html = unescape_html_entities(text).gsub(pattern) do |match|
              iteration = parse_and_find_iteration($~[:project], $~[:namespace], $~[:iteration_id], $~[:iteration_name])

              if iteration
                iterations[iteration.id] = yield match, iteration.id, $~[:project], $~[:namespace], $~
                "#{::Banzai::Filter::References::AbstractReferenceFilter::REFERENCE_PLACEHOLDER}#{iteration.id}"
              else
                match
              end
            end

            return text if iterations.empty?

            escape_with_placeholders(unescaped_html, iterations)
          end

          def parse_and_find_iteration(project_ref, namespace_ref, iteration_id, iteration_name)
            project_path = reference_cache.full_project_path(namespace_ref, project_ref)

            # Returns group if project is not found by path
            parent = parent_from_ref(project_path)

            return unless parent

            iteration_params = iteration_params(iteration_id, iteration_name)

            find_iteration(parent, iteration_params)
          end

          def iteration_params(id, name)
            if name
              { name: name.tr('"', '') }
            else
              { id: id.to_i }
            end
          end

          # rubocop: disable CodeReuse/ActiveRecord
          def find_iteration(parent, params)
            ::Iteration.for_projects_and_groups(project_ids(parent), group_and_ancestors_ids(parent)).find_by(**params)
          end
          # rubocop: enable CodeReuse/ActiveRecord

          def project_ids(parent)
            parent.id if project_context?(parent)
          end

          def group_and_ancestors_ids(parent)
            if group_context?(parent)
              parent.self_and_ancestors.select(:id)
            elsif project_context?(parent)
              parent.group&.self_and_ancestors&.select(:id)
            end
          end

          def url_for_object(iteration, _parent)
            ::Gitlab::Routing
                .url_helpers
                .iteration_url(iteration, only_path: context[:only_path])
          end

          def object_link_text(object, matches)
            iteration_link = escape_once(super)
            reference = object.project&.to_reference_base(project)

            if reference.present?
              "#{iteration_link} <i>in #{reference}</i>".html_safe
            else
              iteration_link
            end
          end

          def object_link_title(_object, _matches)
            'Iteration'
          end
        end
      end
    end
  end
end
