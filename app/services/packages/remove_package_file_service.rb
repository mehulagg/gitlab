# frozen_string_literal: true

module Packages
  class RemovePackageFileService < BaseService
    def initialize(package_file)
      raise ArgumentError, "Package file must be set" if package_file.blank?

      @package_file = package_file
    end

    def execute
      package_file.destroy
    end

    private

    attr_reader :package_file
  end
end
