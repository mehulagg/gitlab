# frozen_string_literal: true
class Packages::ComposerMetadatum < ApplicationRecord
  belongs_to :package, -> { where(package_type: Packages::Package::COMPOSER) }

  validates :package, presence: true
  validate :composer_package_type

  validates :name,
    presence: true,
    format: { with: Gitlab::Regex.composer_package_name_regex }

  validates :version,
    presence: true,
    format: { with: Gitlab::Regex.composer_package_version_regex }

  validates :json,
    presence: true

  private

  def composer_package_type
    unless package && package.package_type == Packages::Package::COMPOSER
      errors.add(:base, 'Package type must be Composer')
    end
  end
end
