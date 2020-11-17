# frozen_string_literal: true

class Geo::PackageFileRegistry < Geo::BaseRegistry
  include ::Geo::ReplicableRegistry
  include ShaAttribute

  MODEL_CLASS = ::Packages::PackageFile
  MODEL_FOREIGN_KEY = :package_file_id

  belongs_to :package_file, class_name: 'Packages::PackageFile'

  sha_attribute :verification_checksum
  sha_attribute :verification_checksum_mismatched
end
