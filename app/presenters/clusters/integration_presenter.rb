# frozen_string_literal: true

module Clusters
  class IntegrationPresenter < Gitlab::View::Presenter::Delegated
    presents :integration

    def application_type
      integration.class.application_name
    end

    def enabled
      integration.externally_installed?
    end
  end
end
