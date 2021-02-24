# frozen_string_literal: true

module Terraform
  class ModulesPresenter < Gitlab::View::Presenter::Simple
    attr_accessor :packages, :system

    presents :modules

    def initialize(packages, system)
      @packages = packages
      @system = system
    end

    def modules
      modules = [
        {
          'versions' => []
        }
      ]

      @packages.each do |package|
        version = {
          'version' => package.version,
          'submodules' => [],
          'root' => {
            'dependencies' => [],
            'providers' => [
              {
                'name' => @system,
                'version' => ''
              }
            ]
          }
        }
        modules[0]['versions'].push(version)
        modules[0]['source'] = package.project.web_url unless modules[0].has_key?('source')
      end

      modules
    end
  end
end
