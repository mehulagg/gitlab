# frozen_string_literal: true

module EE
  module IssuableSidebarBasicEntity
    extend ActiveSupport::Concern

    prepended do
      expose :scoped_labels_available do |issuable|
        issuable.project&.feature_available?(:scoped_labels)
      end

      expose :supports_weight?, as: :supports_weight
      expose :supports_iterations?, as: :supports_iterations
    end
  end
end
