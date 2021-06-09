# frozen_string_literal: true

module Gitlab
  module Kubernetes
    module Helm
      KUBECTL_VERSION = '1.13.12'
      NAMESPACE = 'gitlab-managed-apps'
      NAMESPACE_LABELS = { 'app.gitlab.com/managed_by' => :gitlab }.freeze
    end
  end
end
