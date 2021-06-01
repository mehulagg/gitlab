# frozen_string_literal: true
class Packages::Push < ApplicationRecord
  delegate :project, to: :package_file

  belongs_to :package_file, inverse_of: :push
  has_one :pipeline, class_name: 'Ci::Pipeline', foreign_key: :sha, primary_key: :sha

  validates :sha, presence: true

  before_validation :set_sha, unless: :sha?

  scope :with_sha, ->(sha) { find_by(sha: sha) }

  private

  def set_sha
    self.sha = Digest::SHA1.hexdigest(package_file.id.to_s)
  end
end
