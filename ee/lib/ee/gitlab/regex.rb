# frozen_string_literal: true

module EE
  module Gitlab
    module Regex
      extend ActiveSupport::Concern

      class_methods do
        def conan_file_name_regex
          @conan_file_name_regex ||=
            %r{\A#{(::Packages::ConanFileMetadatum::RECIPE_FILES + ::Packages::ConanFileMetadatum::PACKAGE_FILES).join("|")}\z}.freeze
        end

        def conan_package_reference_regex
          @conan_package_reference_regex ||= %r{\A[A-Za-z0-9]+\z}.freeze
        end

        def conan_revision_regex
          @conan_revision_regex ||= %r{\A0\z}.freeze
        end

        def conan_recipe_component_regex
          @conan_recipe_component_regex ||= %r{\A(\w[.+-]?)+\z}.freeze
        end

        def package_name_regex
          @package_name_regex ||= %r{\A\@?(([\w\-\.\+]*)\/)*([\w\-\.]+)@?(([\w\-\.\+]*)\/)*([\w\-\.]*)\z}.freeze
        end

        def maven_file_name_regex
          @maven_file_name_regex ||= %r{\A[A-Za-z0-9\.\_\-\+]+\z}.freeze
        end

        def maven_path_regex
          @maven_path_regex ||= %r{\A\@?(([\w\-\.]*)/)*([\w\-\.\+]*)\z}.freeze
        end

        def maven_app_name_regex
          @maven_app_name_regex ||= /\A[\w\-\.]+\z/.freeze
        end

        def maven_app_group_regex
          maven_app_name_regex
        end

        def feature_flag_regex
          /\A[a-z]([-_a-z0-9]*[a-z0-9])?\z/
        end

        def composer_package_name_regex
          %r{\A([a-zA-Z\-\_0-9]*)\/([a-zA-Z\-\_0-9]*)\z}.freeze
        end

        def composer_package_version_regex
          %r{(\Av?(\d{1,5})(\.\d++)?(\.\d++)?(\.\d++)?(-[a-zA-Z]*)?|\A(dev\-[a-zA-Z\-\_0-9]*))}.freeze
        end

        def feature_flag_regex_message
          "can contain only lowercase letters, digits, '_' and '-'. " \
          "Must start with a letter, and cannot end with '-' or '_'"
        end
      end
    end
  end
end
