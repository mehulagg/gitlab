# frozen_string_literal: true

class UploadService
  def initialize(model, file, uploader_class = FileUploader, **uploader_context)
    @model, @file, @uploader_class, @uploader_context = model, file, uploader_class, uploader_context
  end

  # Temporarily introduced for upload API
  def set_max_attachment_size(max_attachment_size)
    @override_max_attachment_size = max_attachment_size
  end

  def execute
    return unless file && file.size <= max_attachment_size

    uploader = uploader_class.new(model, nil, **uploader_context)
    uploader.store!(file)

    uploader
  end

  private

  attr_reader :model, :file, :uploader_class, :uploader_context

  def max_attachment_size
    return @override_max_attachment_size if @override_max_attachment_size

    Gitlab::CurrentSettings.max_attachment_size.megabytes.to_i
  end
end
