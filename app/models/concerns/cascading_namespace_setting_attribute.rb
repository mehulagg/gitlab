# frozen_string_literal: true

#
# Cascading attributes enables managing settings in a flexible way.
#
# - Instance administrator can define an instance-wide default setting, or
#   lock the setting to prevent change by group owners.
# - Group maintainers/owners can define a default setting for their group, or
#   lock the setting to prevent change by sub-group maintainers/owners.
#
# Behavior:
#
# - When a group does not have a value (value is `nil`), cascade up the
#   hierarchy to find the first non-nil value.
# - Settings can be locked at any level to prevent groups/sub-groups from
#   overriding.
# - If the setting isn't locked, the default can be overridden.
# - An instance administrator or group maintainer/owner can push settings values
#   to groups/sub-groups to override existing values, even when the setting
#   is not otherwise locked.
#
# Enforcement can happen at the instance level or any level in
# the namespace hierarchy.
#
module CascadingNamespaceSettingAttribute
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize

  class_methods do
    private

    # Similar to Rails `attr_accessor`, this method facilitates the cascading
    # lookup of values and defines convenience methods such as a reader,
    # writer, and validators.
    #
    # Example: `cascading_attr :delayed_project_removal`
    #
    # Methods defined:
    # - `delayed_project_removal`
    # - `delayed_project_removal=`
    # - `delayed_project_removal?` (only defined for boolean attributes)
    # - `delayed_project_removal_locked?`
    #
    # Defined validators ensure attribute value cannot be updated if locked by
    # an ancestor.
    #
    # Requires database columns be present in both `namespace_settings` and
    # `application_settings`. See <documentation> for details.
    def cascading_attr(*attributes)
      attributes.each do |attribute|
        define_attr_reader(attribute)
        define_attr_writer(attribute)
        define_lock(attribute)
        define_validators(attribute)
        define_after_update(attribute)

        alias_boolean(attribute)

        validate :"#{attribute}_changeable?"
        validate :"lock_#{attribute}_changeable?"

        after_update :"clear_descendant_#{attribute}_locks", if: -> { saved_change_to_attribute?("lock_#{attribute}", to: true) }
      end
    end

    # The cascading attribute reader method handles lookups
    # with the following criteria:
    #
    # 1. Returns the dirty value, if the attribute has changed.
    # 2. Return locked ancestor value.
    # 3. Return locked instance-level application settings value.
    # 4. Return this namespace's attribute, if not nil.
    # 5. Return value from nearest ancestor where value is not nil.
    # 6. Return instance-level application setting.
    def define_attr_reader(attribute)
      define_method(attribute) do
        strong_memoize(attribute.to_sym) do
          next self[attribute.to_sym] if will_save_change_to_attribute?(attribute)

          locked_ancestor = self.class
                              .select("lock_#{attribute}", attribute)
                              .where("namespace_id IN (?) AND lock_#{attribute} = TRUE", namespace_ancestor_ids) # rubocop:disable GitlabSecurity/SqlInjection
                              .limit(1).load.first

          locked_ancestor ||= ApplicationSetting.current.public_send("lock_#{attribute}") # rubocop:disable GitlabSecurity/PublicSend

          if locked_ancestor
            instance_variable_set("@#{attribute}_locked", true)
            next locked_ancestor.read_attribute(attribute.to_sym)
          end

          next self[attribute.to_sym] unless self[attribute.to_sym].nil?

          # rubocop:disable GitlabSecurity/SqlInjection
          cascaded_value = self.class
                             .select(attribute.to_sym)
                             .joins("join unnest(ARRAY[#{namespace_ancestor_ids.join(',')}]) with ordinality t(namespace_id, ord) USING (namespace_id)")
                             .where("#{attribute} IS NOT NULL")
                             .order('t.ord')
                             .limit(1).first&.read_attribute(attribute.to_sym)
          # rubocop:enable GitlabSecurity/SqlInjection

          cascaded_value || ApplicationSetting.current.public_send(attribute.to_sym) # rubocop:disable GitlabSecurity/PublicSend
        end
      end
    end

    def define_attr_writer(attribute)
      define_method("#{attribute}=") do |value|
        clear_memoization(attribute.to_sym)

        super(value)
      end
    end

    def define_lock(attribute)
      define_method("#{attribute}_locked?") do
        return false unless namespace.has_parent?

        # Call the attr reader to initialize the instance variable, if locked
        # Make this better - create new methods to retrieve/store the
        # locked_ancestor values so we don't have to call the attr reader.
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
        return unless send("lock_#{attribute}_changed?") && send("#{attribute}_locked?") # rubocop:disable GitlabSecurity/PublicSend

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
      namespace.self_and_ancestors(hierarchy_order: :asc).pluck(:id)
    end
  end

  def descendants
    strong_memoize(:descendants) do
      namespace.descendants.pluck(:id)
    end
  end
end
