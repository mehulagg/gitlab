class Geo::ProjectRegistry < Geo::BaseRegistry
  include ::EachBatch

  belongs_to :project

  validates :project, presence: true, uniqueness: true

  scope :dirty, -> { where(arel_table[:resync_repository].eq(true).or(arel_table[:resync_wiki].eq(true))) }
  scope :failed_repos, -> { where(arel_table[:repository_retry_count].gt(0)) }
  scope :failed_wikis, -> { where(arel_table[:wiki_retry_count].gt(0)) }
  scope :verification_failed_repos, -> { where(arel_table[:last_repository_verification_failed].eq(true)) }
  scope :verification_failed_wikis, -> { where(arel_table[:last_wiki_verification_failed].eq(true)) }

  def self.failed
    repository_sync_failed = arel_table[:repository_retry_count].gt(0)
    wiki_sync_failed = arel_table[:wiki_retry_count].gt(0)

    where(repository_sync_failed.or(wiki_sync_failed))
  end

  def self.verification_failed
    repository_verification_failed = arel_table[:last_repository_verification_failed].eq(true)
    wiki_verification_failed = arel_table[:last_wiki_verification_failed].eq(true)

    where(repository_verification_failed.or(wiki_verification_failed))
  end

  def self.retry_due
    where(
      arel_table[:repository_retry_at].lt(Time.now)
        .or(arel_table[:wiki_retry_at].lt(Time.now))
        .or(arel_table[:repository_retry_at].eq(nil))
        .or(arel_table[:wiki_retry_at].eq(nil))
    )
  end

  def self.synced_repos
    where.not(last_repository_synced_at: nil, last_repository_successful_sync_at: nil)
        .where(resync_repository: false)
  end

  def self.synced_wikis
    where.not(last_wiki_synced_at: nil, last_wiki_successful_sync_at: nil)
        .where(resync_wiki: false)
  end

  def self.verified_repos
    where.not(last_repository_verification_at: nil, repository_verification_checksum: nil)
        .where(last_repository_verification_failed: false)
  end

  def self.verified_wikis
    where.not(last_wiki_verification_at: nil, wiki_verification_checksum: nil)
        .where(last_wiki_verification_failed: false)
  end

  def repository_sync_due?(scheduled_time)
    never_synced_repository? || repository_sync_needed?(scheduled_time)
  end

  def wiki_sync_due?(scheduled_time)
    project.wiki_enabled? && (never_synced_wiki? || wiki_sync_needed?(scheduled_time))
  end

  delegate :repository_state, to: :project
  delegate :repository_verification_checksum, :last_repository_verification_at,
           :wiki_verification_checksum, :last_wiki_verification_at,
           to: :repository_state, allow_nil: true, prefix: :project

  def repository_path(type)
    repo_path = project.disk_path

    case type
    when :repository
      repo_path
    when :wiki
      "#{repo_path}.wiki"
    end
  end

  private

  def never_synced_repository?
    last_repository_synced_at.nil?
  end

  def never_synced_wiki?
    last_wiki_synced_at.nil?
  end

  def repository_sync_needed?(timestamp)
    return false unless resync_repository?
    return false if repository_retry_at && timestamp < repository_retry_at

    last_repository_synced_at && timestamp > last_repository_synced_at
  end

  def wiki_sync_needed?(timestamp)
    return false unless resync_wiki?
    return false if wiki_retry_at && timestamp < wiki_retry_at

    last_wiki_synced_at && timestamp > last_wiki_synced_at
  end
end
