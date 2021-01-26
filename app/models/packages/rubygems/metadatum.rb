# frozen_string_literal: true

class Packages::Rubygems::Metadatum < ApplicationRecord
  self.primary_key = :package_id

  belongs_to :package, -> { where(package_type: :rubygems) }, inverse_of: :rubygems_metadatum

  validates :package, presence: true

  validate :rubygems_package_type

  private

  def pypi_package_type
    unless package&.rubygems?
      errors.add(:base, _('Package type must be RubyGems'))
    end
  end
end
