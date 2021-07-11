module Geo
  class UploadState < ApplicationRecord
    self.primary_key = :upload_id

    belongs_to :upload, inverse_of: :upload_state
  end
end
