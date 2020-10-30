# frozen_string_literal: true
module API
  class NpmInstancePackages < ::API::Base
    helpers ::API::Helpers::Packages::Npm

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_api_error!(e.message, 400)
    end

    namespace 'packages/npm' do
      include ::Packages::NpmEndpoints
    end
  end
end
