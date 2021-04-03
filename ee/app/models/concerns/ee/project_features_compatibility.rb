# frozen_string_literal: true

module EE
  module ProjectFeaturesCompatibility
    extend ActiveSupport::Concern

    # TODO: remove in API v5, replaced by *_access_level
    def requirements_enabled=(value)
      write_feature_attribute_boolean(:requirements_access_level, value)
    end

    def requirements_access_level=(value)
      write_feature_attribute_string(:requirements_access_level, value)
    end
  end
end
