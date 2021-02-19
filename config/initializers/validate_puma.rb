# frozen_string_literal: true

def max_puma_workers
  return 2 unless Puma.respond_to?(:cli_config)

  Puma.cli_config.options[:workers].to_i
end

if Gitlab::Runtime.puma? && !Gitlab::Runtime.puma_in_clustered_mode?
  raise 'Puma is only supported in Clustered mode (workers > 0)' if Gitlab.com?

  warn 'WARNING: Puma is running in Single mode (workers = 0). Some features may not work. Please refer to https://gitlab.com/groups/gitlab-org/-/epics/5303 for info.'
end
