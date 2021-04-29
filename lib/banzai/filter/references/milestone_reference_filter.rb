# frozen_string_literal: true

module Banzai
  module Filter
    module References
      # HTML filter that replaces milestone references with links.
      class MilestoneReferenceFilter < AbstractReferenceFilter
        include Gitlab::Utils::StrongMemoize

        self.reference_type = :milestone
        self.object_class   = Milestone

        def parent_records(parent, ids)
          # parent.issues.where(iid: ids.to_a)

          # find_milestone_with_finder(parent, id: ids)
          ids.map do |id|
            find_milestone(id[:project], id[:namespace], id[:iid], id[:name])
          end
        end

        def parse_symbol(raw, match_data)
          namespace = match_data[:namespace]
          project = match_data[:project]
          name = match_data[:milestone_name]
          iid = match_data[:milestone_iid].to_i
          # Identifier.new(filename: CGI.unescape(filename), issue_iid: iid)
          { namespace: namespace, project: project, name: name, iid: iid }
        end

        def record_identifier(milestone)
          # Identifier.new(filename: design.filename, issue_iid: design.issue.iid)
          { namespace: milestone.group, project: milestone.project, name: milestone.name, iid: milestone.iid }
        end

        # Links to project milestones contain the IID, but when we're handling
        # 'regular' references, we need to use the global ID to disambiguate
        # between group and project milestones.
        def find_object(parent, id)
          return unless valid_context?(parent)

          @cache.records_per_parent(nodes)[parent][id]
          # find_milestone_with_finder(parent, id: id)
        end

        def find_object_from_link(parent, iid)
          return unless valid_context?(parent)

          find_milestone_with_finder(parent, iid: iid)
        end

        def valid_context?(parent)
          strong_memoize(:valid_context) do
            group_context?(parent) || project_context?(parent)
          end
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

        # def loaded_milestones(project, namespace, iid, name)
        #   BatchLoader.for({ project: project, namespace: namespace, iid: iid, name: name }).batch do |stones, loader|
        #     # Milestone.where(title: titles).each {|milestone| loader.call(milestone.title, milestone) }
        #     stones.each do |stone|
        #       ms = find_milestone(stone[:project], stone[:namespace], stone[:iid], stone[:name])
        #
        #       # loader.call({ project: ms.project, namespace: ms.group, iid: ms.iid, name: ms.name }, ms) if ms
        #       loader.call(stone, ms)
        #     end
        #   end
        # end
        #
        # # Returns all milestones referenced in the current document.
        # def milestone_references
        #   refs = []
        #
        #   nodes.each do |node|
        #     unescape_html_entities(node.to_html).scan(Milestone.reference_pattern) do
        #       refs << { project: $~[:project], namespace: $~[:namespace], iid: $~[:milestone_iid], name: $~[:milestone_name] }
        #     end
        #   end
        #
        #   refs
        # end

        def references_in(text, pattern = Milestone.reference_pattern)
          # We'll handle here the references that follow the `reference_pattern`.
          # Other patterns (for example, the link pattern) are handled by the
          # default implementation.
          return super(text, pattern) if pattern != Milestone.reference_pattern

          milestones = {}
          unescaped_html = unescape_html_entities(text).gsub(pattern).with_index do |match, index|
            # binding.pry
            # symbol = $~[object_sym]
            # object_class.reference_valid?(symbol)

            # milestone = find_milestone($~[:project], $~[:namespace], $~[:milestone_iid], $~[:milestone_name])

            if ident = identifier($~)
              milestones[index] = yield match, ident, $~[:project], $~[:namespace], $~
              "#{REFERENCE_PLACEHOLDER}#{index}"
            else
              match
            end
          end

          # x = milestone_references.map do |stone|
          #   loaded_milestones(stone[:project], stone[:namespace], stone[:iid], stone[:name])
          # end
          #
          # binding.pry

          return text if milestones.empty?

          escape_with_placeholders(unescaped_html, milestones)
        end

        def references_in2(text, pattern = object_class.reference_pattern)
          text.gsub(pattern) do |match|
            symbol = $~[object_sym]
            if object_class.reference_valid?(symbol)
              yield match, symbol.to_i, $~[:project], $~[:namespace], $~
            else
              match
            end
          end
        end

        def find_milestone(project_ref, namespace_ref, milestone_id, milestone_name)
          project_path = full_project_path(namespace_ref, project_ref)

          # Returns group if project is not found by path
          parent = parent_from_ref(project_path)

          return unless parent

          milestone_params = milestone_params(milestone_id, milestone_name)

          find_milestone_with_finder(parent, milestone_params)
        end

        def milestone_params(iid, name)
          if name
            { name: name.tr('"', '') }
          else
            { iid: iid.to_i }
          end
        end

        def find_milestone_with_finder(parent, params)
          finder_params = milestone_finder_params(parent, params[:iid].present?)

          MilestonesFinder.new(finder_params).find_by(params)
        end

        def milestone_finder_params(parent, find_by_iid)
          { order: nil, state: 'all' }.tap do |params|
            params[:project_ids] = parent.id if project_context?(parent)

            # We don't support IID lookups because IIDs can clash between
            # group/project milestones and group/subgroup milestones.
            params[:group_ids] = self_and_ancestors_ids(parent) unless find_by_iid
          end
        end

        def self_and_ancestors_ids(parent)
          if group_context?(parent)
            parent.self_and_ancestors.select(:id)
          elsif project_context?(parent)
            parent.group&.self_and_ancestors&.select(:id)
          end
        end

        def url_for_object(milestone, project)
          Gitlab::Routing
            .url_helpers
            .milestone_url(milestone, only_path: context[:only_path])
        end

        def object_link_text(object, matches)
          milestone_link = escape_once(super)
          reference = object.project&.to_reference_base(project)

          if reference.present?
            "#{milestone_link} <i>in #{reference}</i>".html_safe
          else
            milestone_link
          end
        end

        def object_link_title(object, matches)
          nil
        end
      end
    end
  end
end
