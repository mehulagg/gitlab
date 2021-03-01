# frozen_string_literal: true

module Types
  class BaseArgument < GraphQL::Schema::Argument
    include Gitlab::Graphql::Visible
    include GitlabStyleDeprecations

    def initialize(*args, **kwargs, &block)
      @feature_flag = kwargs[:feature_flag]
      kwargs = check_feature_flag(kwargs)
      kwargs = gitlab_deprecation(kwargs)

      super(*args, **kwargs, &block)
    end
  end
end
