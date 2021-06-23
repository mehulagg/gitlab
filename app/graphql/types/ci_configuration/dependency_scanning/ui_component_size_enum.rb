# frozen_string_literal: true

module Types
  module CiConfiguration
    module DependencyScanning
      class UiComponentSizeEnum < BaseEnum
        graphql_name 'DependencyScanningUiComponentSize'
        description 'Size of UI component in Dependency Scanning configuration page'

        value 'SMALL', description: "The size of UI component in Dependency Scanning configuration page is small."
        value 'MEDIUM', description: "The size of UI component in Dependency Scanning configuration page is medium."
        value 'LARGE', description: "The size of UI component in Dependency Scanning configuration page is large."
      end
    end
  end
end
