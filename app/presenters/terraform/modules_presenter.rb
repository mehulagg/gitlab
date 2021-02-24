# frozen_string_literal: true

module Terraform
  class ModulesPresenter < Gitlab::View::Presenter::Simple
    attr_accessor :packages, :system

    presents :modules

    def initialize(packages, system)
      @packages = packages
      @project = packages.first.project
      @system = system
    end

    def modules
      modules = [
        {
          'source' => @project.web_url,
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
      end

      modules
    end
  end
end
