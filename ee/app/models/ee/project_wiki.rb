# frozen_string_literal: true

module EE
  module ProjectWiki
    extend ActiveSupport::Concern

    prepended do
      # TODO: Move this into EE::Wiki once we implement ES support for group wikis.
      # https://gitlab.com/gitlab-org/gitlab/-/issues/207889
      include Elastic::WikiRepositoriesSearch
    end
  end
end
