# frozen_string_literal: true
class Packages::Push < ApplicationRecord
  delegate :project, to: :package_file

  belongs_to :package_file

  validates :sha, presence: true

  before_validation :set_sha, unless: :sha?

  private

  def set_sha
    self.sha = Digest::SHA1.hexdigest(package_file.id.to_s)
  end
end
