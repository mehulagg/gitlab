# frozen_string_literal: true

class InstanceMetadata
  attr_reader :version, :revision

  def initialize(version: Gitlab::VERSION, revision: Gitlab.revision)
    @version = version
    @revision = revision
    @kas_enabled = Gitlab.config.gitlab_kas.enabled
    @kas_external_address = Gitlab.config.gitlab_kas.external_url
  end
end
