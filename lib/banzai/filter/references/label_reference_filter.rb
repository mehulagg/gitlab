# frozen_string_literal: true

module Banzai
  module Filter
    module References
      # HTML filter that replaces label references with links.
      class LabelReferenceFilter < AbstractReferenceFilter
        self.reference_type = :label
        self.object_class   = Label

        def parent_records(parent, ids)
          return unless parent.is_a?(Project) || parent.is_a?(Group)

          x = find_labels(parent)
          label_ids = ids.map {|y| y[:label_id]}.compact
          label_names = ids.map {|y| y[:label_name]}.compact
          id_relation = x.where(id: label_ids)
          label_relation = x.where(title: label_names)
          Label.from_union([id_relation, label_relation])
        end

        def find_object(parent_object, id)
          key = if id[:label_id]
                  reference_cache.records_per_parent[parent_object].keys.find {|i| i[:label_id] == id[:label_id].to_i }
                elsif id[:label_name]
                  reference_cache.records_per_parent[parent_object].keys.find {|i| i[:label_name] == id[:label_name] }
                else
                  nil
                end

          reference_cache.records_per_parent[parent_object][key] if key
        end

        # Transform a symbol extracted from the text to a meaningful value
        # In most cases these will be integers, so we call #to_i by default
        #
        # This method has the contract that if a string `ref` refers to a
        # record `record`, then `parse_symbol(ref) == record_identifier(record)`.
        def parse_symbol(symbol, match_data)
          { label_id: match_data[:label_id], label_name: match_data[:label_name] }
        end

        # We assume that most classes are identifying records by ID.
        #
        # This method has the contract that if a string `ref` refers to a
        # record `record`, then `class.parse_symbol(ref) == record_identifier(record)`.
        def record_identifier(record)
          # record.id
          { label_id: record.id, label_name: record.title }
        end

        def references_in(text, pattern = Label.reference_pattern)
          # text.gsub(pattern) do |match|
          #   if ident = identifier($~)
          #     yield match, ident, $~[:project], $~[:namespace], $~
          #   else
          #     match
          #   end
          # end

          labels = {}
          index = 0
          # binding.pry
          unescaped_html = unescape_html_entities(text).gsub(pattern) do |match|
            if ident = identifier($~)
              index +=1
              # label = find_object(parent_object, id)
              labels[index] = yield match, ident, $~[:project], $~[:namespace], $~
              # labels[label.id] = yield match, label.id, project, namespace, $~
              "#{REFERENCE_PLACEHOLDER}#{index}"
            else
              match
            end
            #
            # namespace = $~[:namespace]
            # project = $~[:project]
            # project_path = reference_cache.full_project_path(namespace, project)
            # label = find_label_cached(project_path, $~[:label_id], $~[:label_name])
            #
            # if label
            #   labels[label.id] = yield match, label.id, project, namespace, $~
            #   "#{REFERENCE_PLACEHOLDER}#{label.id}"
            # else
            #   match
            # end
          end

          return text if labels.empty?

          escape_with_placeholders(unescaped_html, labels)
        end

        def find_label_cached(parent_ref, label_id, label_name)
          cached_call(:banzai_find_label_cached, label_name&.tr('"', '') || label_id, path: [object_class, parent_ref]) do
            find_label(parent_ref, label_id, label_name)
          end
        end

        def find_label(parent_ref, label_id, label_name)
          binding.pry
          parent = parent_from_ref(parent_ref)
          return unless parent

          label_params = label_params(label_id, label_name)
          find_labels(parent).find_by(label_params)
        end

        def find_labels(parent)
          params = if parent.is_a?(Group)
                     { group_id: parent.id,
                       include_ancestor_groups: true,
                       only_group_labels: true }
                   else
                     { project: parent,
                       include_ancestor_groups: true }
                   end

          LabelsFinder.new(nil, params).execute(skip_authorization: true)
        end

        # Parameters to pass to `Label.find_by` based on the given arguments
        #
        # id   - Integer ID to pass. If present, returns {id: id}
        # name - String name to pass. If `id` is absent, finds by name without
        #        surrounding quotes.
        #
        # Returns a Hash.
        def label_params(id, name)
          if name
            { name: name.tr('"', '') }
          else
            { id: id.to_i }
          end
        end

        def url_for_object(label, parent)
          label_url_method =
            if context[:label_url_method]
              context[:label_url_method]
            elsif parent.is_a?(Project)
              :project_issues_url
            end

          return unless label_url_method

          Gitlab::Routing.url_helpers.public_send(label_url_method, parent, label_name: label.name, only_path: context[:only_path]) # rubocop:disable GitlabSecurity/PublicSend
        end

        def object_link_text(object, matches)
          label_suffix = ''
          parent = project || group

          if project || full_path_ref?(matches)
            project_path    = reference_cache.full_project_path(matches[:namespace], matches[:project])
            parent_from_ref = from_ref_cached(project_path)
            reference       = parent_from_ref.to_human_reference(parent)

            label_suffix = " <i>in #{ERB::Util.html_escape(reference)}</i>" if reference.present?
          end

          presenter = object.present(issuable_subject: parent)
          LabelsHelper.render_colored_label(presenter, suffix: label_suffix)
        end

        def wrap_link(link, label)
          presenter = label.present(issuable_subject: project || group)
          LabelsHelper.wrap_label_html(link, small: true, label: presenter)
        end

        def full_path_ref?(matches)
          matches[:namespace] && matches[:project]
        end

        def reference_class(type, tooltip: true)
          super + ' gl-link gl-label-link'
        end

        def object_link_title(object, matches)
          presenter = object.present(issuable_subject: project || group)
          LabelsHelper.label_tooltip_title(presenter)
        end
      end
    end
  end
end

Banzai::Filter::References::LabelReferenceFilter.prepend_mod_with('Banzai::Filter::References::LabelReferenceFilter')
