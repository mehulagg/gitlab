# frozen_string_literal: true

class Geo::PackageFileRegistry < Geo::BaseRegistry
  include ::Geo::ReplicableRegistry
  include ::Geo::VerifiableRegistry

  MODEL_CLASS = ::Packages::PackageFile
  MODEL_FOREIGN_KEY = :package_file_id

  belongs_to :package_file, class_name: 'Packages::PackageFile'
end
