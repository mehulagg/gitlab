# frozen_string_literal: true

module EE
  module UploadsController
    extend ActiveSupport::Concern

    EE_MODEL_CLASSES = {
      'issuable_metric_image' => IssuableMetricImage
    }.freeze

    class_methods do
      extend ::Gitlab::Utils::Override

      override :model_classes
      def model_classes
        super.merge(EE_MODEL_CLASSES)
      end
    end
  end
end
