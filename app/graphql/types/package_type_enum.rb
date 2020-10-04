# frozen_string_literal: true

module Types
  class PackageTypeEnum < BaseEnum
    PACKAGE_TYPE_NAMES = {
      pypi: 'PyPi',
      npm: 'NPM'
    }.freeze

    ::Packages::Package.package_types.keys.each do |package_type|
      type_name = PACKAGE_TYPE_NAMES[package_type.to_sym] || package_type.capitalize
      value package_type.to_s.upcase, "Packages from the #{type_name} package manager", value: package_type.to_s
    end
  end
end
