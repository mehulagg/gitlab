# frozen_string_literal: true

module API
  class Version < ::API::Base
    helpers ::API::Helpers::GraphqlHelpers
    include APIGuard

    allow_access_with_scope :read_user, if: -> (request) { request.get? }

    before { authenticate! }

    feature_category :not_owned

    desc 'Get the version information of the GitLab instance.' do
      detail 'This feature was introduced in GitLab 8.13.'
    end
    get '/version' do
      ::InstanceMetadata.new
    end
  end
end
