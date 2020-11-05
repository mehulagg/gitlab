# frozen_string_literal: true

module IncidentManagement
  class MetricImage < ApplicationRecord
    include Gitlab::FileTypeDetection
    include FileStoreMounter

    belongs_to :incident, class_name: 'Issue', foreign_key: 'issue_id', inverse_of: :metrics

    default_value_for(:file_store) { MetricImageUploader.default_store }

    mount_file_store_uploader MetricImageUploader

    validates :incident, presence: true
    validates :file, presence: true
    validate :validate_file_is_image
    validates :url, length: { maximum: 255 }

    def retrieve_upload(_identifier, paths)
      Upload.find_by(model: self, path: paths)
    end

    def filename
      file&.filename
    end

    def file_path
      @file_path ||= file&.url
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
        errors.add(:file, message)
      end
    end
  end
end
