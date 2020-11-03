# frozen_string_literal: true

module IncidentManagement
  class Metric < ApplicationRecord
    # include Gitlab::FileTypeDetection
    include FileStoreMounter

    # TODO tablename
    self.table_name = 'metric_image_uploads'

    # TODO external metrics?
    belongs_to :incident, class_name: 'Issue', foreign_key: 'issue_id', inverse_of: :metrics

    # default_value_for(:file_store) { MetricImageUploader.default_store }

    mount_file_store_uploader MetricImageUploader

    validates :incident, presence: true

    def retrieve_upload
      # TODO
      # Upload.find_by(model: self, path: paths)
    end

    private

    def valid_file_extensions
      SAFE_IMAGE_EXT
    end

    def validate_file_is_image
      unless image? || (dangerous_image? && allow_dangerous_images?)
        message = _('does not have a supported extension. Only %{extension_list} are supported') % {
          extension_list: valid_file_extensions.to_sentence
        }
        errors.add(:filename, message)
      end
    end

  end
end
