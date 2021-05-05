# frozen_string_literal: true

module RuboCop
  module Cop
    module Gitlab
      # This cop tracks the usage of feature flags among the codebase.
      #
      # The files set in `tmp/feature_flags/*.used` can then be used for verification purpose.
      #
      class MarkUsedFeatureFlags < RuboCop::Cop::Cop
        FEATURE_OBSERVED_METHODS = %i[enabled? disabled?].freeze
        SELF_OBSERVED_METHODS = %i[push_frontend_feature_flag].freeze

        def on_send(node)
          return unless trackable_flag?(node)

          if flag_arg_is_static?(node)
            if caller_is_feature_gitaly?(node)
              save_used_feature_flag("gitaly_#{flag_value(node)}")
            else
              save_used_feature_flag(flag_value(node))
            end
          else
            str_prefix = flag_arg(node).children[0]
            rest_children = flag_arg(node).children[1..]

            if str_prefix.str_type? && rest_children.none? { |child| child.str_type? }
              matching_feature_flags = self.class.defined_feature_flags.select { |flag| flag.start_with?(str_prefix.value) }
              matching_feature_flags.each do |matching_feature_flag|
                puts "The #{matching_feature_flag} starts with '#{str_prefix.value}', so we'll optimistically mark it as used."
                save_used_feature_flag(matching_feature_flag)
              end
            else
              puts "Dynamic feature flag name has multiple static string parts, we'll not track it."
            end
          end
        end

        private

        def save_used_feature_flag(feature_flag_name)
          FileUtils.touch(File.expand_path("../../../tmp/feature_flags/#{feature_flag_name}.used", __dir__))
        end

        def class_caller(node)
          node.children[0]&.const_name.to_s
        end

        def method_name(node)
          node.children[1]
        end

        def flag_arg(node)
          node.children[2]
        end

        def flag_value(node)
          return flag_arg(node).value.to_s if flag_arg(node).respond_to?(:value)

          flag_arg(node).to_s.tr("\n", ' ')
        end

        def flag_arg_is_static?(node)
          flag = flag_arg(node)
          flag.str_type? || flag.sym_type?
        end

        def caller_is_feature?(node)
          class_caller(node) == "Feature"
        end

        def caller_is_feature_gitaly?(node)
          class_caller(node) == "Feature::Gitaly"
        end

        def feature_observable_method?(node)
          FEATURE_OBSERVED_METHODS.include?(method_name(node)) && (caller_is_feature?(node) || caller_is_feature_gitaly?(node))
        end

        def self_observable_method?(node)
          SELF_OBSERVED_METHODS.include?(method_name(node)) && class_caller(node).empty?
        end

        def trackable_flag?(node)
          feature_observable_method?(node) || self_observable_method?(node)
        end

        def self.defined_feature_flags
          @defined_feature_flags ||= begin
            flags_paths = [
              'config/feature_flags/**/*.yml'
            ]

            # For EE additionally process `ee/` feature flags
            if File.exist?(File.expand_path('../../../ee/app/models/license.rb', __dir__)) && !%w[true 1].include?(ENV['FOSS_ONLY'].to_s)
              flags_paths << 'ee/config/feature_flags/**/*.yml'
            end

            # Iterate all defined feature flags
            # to discover which were used
            flags_paths.each_with_object([]) do |flags_path, memo|
              flags_path = File.expand_path("../../../#{flags_path}", __dir__)
              Dir.glob(flags_path).each do |path|
                feature_flag_name = File.basename(path, '.yml')

                memo << feature_flag_name
              end
            end
          end
        end
      end
    end
  end
end
