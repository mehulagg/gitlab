# frozen_string_literal: true

module Gitlab
  module Graphql
    module Visible
      extend ActiveSupport::Concern

      def visible?(context)
        return false if feature_flag.present? && !Feature.enabled?(feature_flag)

        super
      end

      private

      attr_reader :feature_flag

      def feature_documentation_message(key, description)
        "#{description} Available only when feature flag `#{key}` is enabled."
      end

      def check_feature_flag(args)
        args[:description] = feature_documentation_message(args[:feature_flag], args[:description]) if args[:feature_flag].present?
        args.delete(:feature_flag)

        args
      end
    end
  end
end
