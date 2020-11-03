# frozen_string_literal: true

module IncidentManagement
  class MetricImageUploader < GitlabUploader
    include RecordsUploads::Concern
    include ObjectStorage::Concern
    prepend ObjectStorage::Extension::RecordsUploads
    include UploaderHelper

    private

    def dynamic_segment
      File.join(model.class.underscore, mounted_as.to_s, model.id.to_s)
    end
  end
end
