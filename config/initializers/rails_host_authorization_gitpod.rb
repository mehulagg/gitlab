if Rails.env.development? && ENV['GITPOD_WORKSPACE_ID'].present?
  gitpod_host = URI(%x(gp url 3000).strip).host
  Rails.application.config.hosts += [gitpod_host]
end
