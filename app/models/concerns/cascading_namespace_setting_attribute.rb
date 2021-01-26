# frozen_string_literal: true

module CascadingNamespaceSettingAttribute
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize

  class_methods do
    private

    def lockable_attr(*attributes)
      attributes.each do |attribute|
        define_attr_reader(attribute)
        define_lock(attribute)
        define_validators(attribute)
        define_after_update(attribute)

        alias_boolean(attribute)

        validate :"#{attribute}_changeable?"
        validate :"lock_#{attribute}_changeable?"

        after_update :"clear_descendant_#{attribute}_locks", if: -> { saved_change_to_attribute?("lock_#{attribute}", to: true) }
      end
    end

    def define_attr_reader(attribute)
      define_method(attribute) do
        strong_memoize(attribute.to_sym) do
          next self[attribute.to_sym] unless namespace.has_parent?

          locked_ancestor = self.class
                              .where("namespace_id IN (?) AND lock_#{attribute} = TRUE", namespace_ancestor_ids) # rubocop:disable GitlabSecurity/SqlInjection
                              .limit(1).load.first

          next self[attribute.to_sym] unless locked_ancestor

          instance_variable_set("@#{attribute}_locked", true)
          locked_ancestor.read_attribute(attribute.to_sym)
        end
      end
    end

    def define_lock(attribute)
      define_method("#{attribute}_locked?") do
        return false unless namespace.has_parent?

        self.send(attribute) # rubocop:disable GitlabSecurity/PublicSend
        !!instance_variable_get("@#{attribute}_locked")
      end
    end

    def define_validators(attribute)
      define_method("#{attribute}_changeable?") do
        return unless send("#{attribute}_changed?") && send("#{attribute}_locked?") # rubocop:disable GitlabSecurity/PublicSend

        errors.add(attribute.to_sym, _('is locked by an ancestor'))
      end

      define_method("lock_#{attribute}_changeable?") do
        return unless send("lock_#{attribute}_changed?") && send("#{attribute}locked?") # rubocop:disable GitlabSecurity/PublicSend

        errors.add("lock_#{attribute}", _('is locked by an ancestor'))
      end

      private :"#{attribute}_changeable?", :"lock_#{attribute}_changeable?"
    end

    def define_after_update(attribute)
      define_method("clear_descendant_#{attribute}_locks") do
        self.class.where('namespace_id IN (?)', descendants).update_all("lock_#{attribute}" => false)
      end

      private :"clear_descendant_#{attribute}_locks"
    end

    def alias_boolean(attribute)
      return unless self.type_for_attribute(attribute).type == :boolean

      alias_method :"#{attribute}?", attribute.to_sym
    end
  end

  private

  def namespace_ancestor_ids
    strong_memoize(:namespace_ancestor_ids) do
      namespace.self_and_ancestors_desc_hierarchy.select(:id).map(&:id)
    end
  end

  def descendants
    strong_memoize(:descendants) do
      namespace.descendants.select(:id).map(&:id)
    end
  end
end
