# frozen_string_literal: true

module EE
  module Gitlab
    module GonHelper
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override


      # Exposes if a licensed feature is available.
      #
      # name - The name of the licensed feature
      # obj  - the object to check the licensed feature on (project, namespace)
      override :push_licensed_feature
      def push_licensed_feature(name, obj = nil)
        enabled = if obj
                  obj.feature_available?(name)
                  else
                    ::License.feature_available?(name)
                  end

        push_to_gon_attributes(:licensed_features, name, enabled)
      end
    end
  end
end
