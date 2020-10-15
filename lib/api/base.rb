# frozen_string_literal: true

module API
  class Base < Grape::API::Instance # rubocop:disable API/Base
    include ::Gitlab::WithFeatureCategory

    def self.feature_category_for_app(app)
      feature_category_for_action(path_for_app(app))
    end

    def self.path_for_app(app)
      "#{app.namespace}/#{app.options[:path].first}".chomp('/').chomp('/')
    end
  end
end
