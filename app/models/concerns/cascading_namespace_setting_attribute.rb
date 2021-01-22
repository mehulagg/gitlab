# frozen_string_literal: true

module CascadingNamespaceSettingAttribute
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize

  class_methods do
    private

    def cascading_attr_reader(*attributes, **options)
      attributes.each do |attribute|
        define_method(attribute) do
          strong_memoize(attribute.to_sym) do
            locked_ancestor = self.class
                                .joins("join unnest(ARRAY#{namespace_ancestor_ids}::int[]) with ordinality t(namespace_id, ord) USING (namespace_id)")
                                .where("namespace_id IN (?) AND lock_#{attribute} = TRUE", namespace_ancestor_ids) # rubocop:disable GitlabSecurity/SqlInjection
                                .order('t.ord').limit(1).load.first

            next self[attribute.to_sym] unless locked_ancestor
            next unless namespace.has_parent?

            locked_ancestor.read_attribute(attribute.to_sym)
          end
        end

        alias_method :"#{attribute}?", attribute.to_sym if options[:boolean]
      end
    end
  end

  private

  def namespace_ancestor_ids
    strong_memoize(:namespace_ancestor_ids) do
      namespace.self_and_ancestors_desc_hierarchy.select(:id).map(&:id)
    end
  end
end
