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
      package_exists = project.packages.with_name_and_version(body['name'], body['version'])

      package_exists.blank? ? create_package(body) : update_package(package_exists, body)
    end

    def create_package(body)
      project.packages.create!(
        name: body['name'],
        version: body['version'],
        package_type: 'composer',
        composer_metadatum_attributes: {
          name: body['name'],
          version: body['version'],
          json: body['json']
        }
      )
    end

    def update_package(package, body)
      package = package.first

      package.update(name: body['name'], version: body['version'], package_type: 'composer')
      package.composer_metadatum.update( name: body['name'], version: body['version'], json: body['json'])

      # This will remove 2 files and 2 associactions max
      package.package_files.destroy_all # rubocop:disable Cop/DestroyAll

      package
    end
  end
end
