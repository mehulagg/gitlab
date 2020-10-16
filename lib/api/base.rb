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

    def self.route(methods, paths = ['/'], route_options = {}, &block)
      if category = route_options.delete(:feature_category)
        feature_category(category, Array(paths).map { |path| "#{namespace}/#{path}".chomp('/').chomp('/') })
      end

      super
    end
  end
end
