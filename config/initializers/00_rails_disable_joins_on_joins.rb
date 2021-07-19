module DisableJoinsOnJoins
  module Reflection
    extend ActiveSupport::Concern

    EagerJoinDisallowed = Class.new(ArgumentError)

    def check_eager_loadable!
      # active_record: source
      # klass: target

      super

      return unless options[:disable_joins]

      return if options[:disable_joins].is_a?(Proc) && options[:disable_joins].call

      source_ci = active_record < Ci::ApplicationRecord
      target_ci = klass < Ci::ApplicationRecord

      unless source_ci == target_ci
        raise EagerJoinDisallowed, <<-MSG.squish
          The association scope '#{active_record.name}.#{name}' is cross shard.
          Eager loading / joining is disallowed.
        MSG
      end
    end
  end
end

ActiveRecord::Reflection::AssociationReflection.prepend(DisableJoinsOnJoins::Reflection)
