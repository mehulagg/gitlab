# frozen_string_literal: true

module EE
  module ProjectSnippetPolicy
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      rule { auditor }.enable :read_snippet
    end
  end
end
