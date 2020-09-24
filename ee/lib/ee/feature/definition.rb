# frozen_string_literal: true

module EE
  module Feature
    module Definition
      module ClassMethods
        extend ::Gitlab::Utils::Override

        override :paths
        def paths
          @ee_paths ||= [Rails.root.join('ee', 'config', 'feature_flags', '**', '*.yml')] + super
        end
      end

      def self.prepended(base)
        base.singleton_class.prepend ClassMethods
      end
    end
  end
end
