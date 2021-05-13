# frozen_string_literal: true

class ProjectRepositoryState < NamespaceShard
  include ShaAttribute

  sha_attribute :repository_verification_checksum
  sha_attribute :wiki_verification_checksum

  belongs_to :project, inverse_of: :repository_state

  validates :project, presence: true, uniqueness: true

  scope :verification_failed_repos, -> { where.not(last_repository_verification_failure: nil) }
  scope :verification_failed_wikis, -> { where.not(last_wiki_verification_failure: nil) }
  scope :verified_repos, -> { where.not(repository_verification_checksum: nil).where(last_repository_verification_failure: nil) }
  scope :verified_wikis, -> { where.not(wiki_verification_checksum: nil).where(last_wiki_verification_failure: nil) }

  def self.pluck_project_key
    where(nil).pluck(:project_id)
  end
end
