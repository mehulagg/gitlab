# frozen_string_literal: true
class Packages::ComposerMetadatum < ApplicationRecord
  belongs_to :package

  validates :package, presence: true

  validates :name,
    presence: true,
    format: { with: Gitlab::Regex.composer_package_name_regex }

  validates :version,
    presence: true,
    format: { with: Gitlab::Regex.composer_package_version_regex }

  validates :json,
    presence: true
end
