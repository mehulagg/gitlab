# frozen_string_literal: true

if Gitlab::Runtime.puma? && ::Puma.cli_config.options[:workers].to_i == 0
  if Gitlab.com?
    raise 'Puma is only supported in Clustered mode (workers > 0)'
  else
    warn 'WARNING: Puma is running in Single mode (workers = 0). Some features may not work. Please refer to https://gitlab.com/groups/gitlab-org/-/epics/5303 for info.'
  end
end
