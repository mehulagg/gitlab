# frozen_string_literal: true
module Packages
  class CreateComposerPackageService < BaseService
    def execute
      body = JSON.parse(params)
      prepare_upload(body)
    end

    def prepare_upload(body)
      package = create_or_update_package(body)
      file = body['package_file']

      file_params = {
          file: CarrierWaveStringFile.new(Base64.decode64(file['contents'])),
          size: file['length'].to_i,
          file_sha1: body['json']['dist']['shasum'],
          file_name: file['filename']
      }

      ::Packages::CreatePackageFileService.new(package, file_params).execute
    end

    def create_or_update_package(body)
      package = project
        .packages
        .with_name_and_version(body['name'], body['version'])
        .first_or_initialize( # rubocop:disable CodeReuse/ActiveRecord
          name: body['name'],
          version: body['version'],
          package_type: 'composer',
          composer_metadatum_attributes: {}
        )

      package.composer_metadatum.attributes = {
        name: body['name'],
        version: body['version'],
        json: body['json']
      }

      clean_files = !package.new_record?

      package.save!

      # This will remove 2 files and 2 associactions max
      package.package_files.delete_all if clean_files

      package
    end
  end
end
