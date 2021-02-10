# frozen_string_literal: true

if Gitlab::Runtime.puma? && Gitlab::Runtime.max_puma_workers == 0
  raise 'Puma is only supported in Clustered mode (workers > 0)' if Gitlab.com?

  warn 'WARNING: Puma is running in Single mode (workers = 0). Some features may not work. Please refer to https://gitlab.com/groups/gitlab-org/-/epics/5303 for info.'
end
