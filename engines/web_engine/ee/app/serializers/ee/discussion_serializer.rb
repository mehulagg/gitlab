# frozen_string_literal: true

module EE
  module DiscussionSerializer
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :with_additional_opts
    # rubocop:disable Gitlab/ModuleWithInstanceVariables
    def with_additional_opts(opts)
      return opts unless @request.project

      super
    end
    # rubocop:enable Gitlab/ModuleWithInstanceVariables
  end
end
