# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop only works if there are files from deprecation_toolkit. You can
      # generate these files by:
      #
      # 1. Running specs with RECORD_DEPRECATIONS=1
      # 1. Downloading the complete set of deprecations/ files from a CI
      # pipeline (see https://gitlab.com/gitlab-org/gitlab/-/merge_requests/47720)
      class LastKeywordArgument < Cop
        MSG = 'Using the last argument as keyword parameters is deprecated'.freeze

        DEPRECATIONS_GLOB = File.expand_path('../../../deprecations/**/*.yml', __dir__)
        KEYWORD_DEPRECATION_STR = 'maybe ** should be added to the call'

        def on_send(node)
          arg = get_last_argument(node)
          return unless arg

          return unless known_match?(processed_source.file_path, node.first_line, node.method_name.to_s)

          return if arg.children.first.respond_to?(:kwsplat_type?) && arg.children.first&.kwsplat_type?

          # parser thinks `a: :b, c: :d` is hash type, it's actually kwargs
          return if arg.hash_type? && !arg.source.match(/\A{/)

          add_offense(arg)
        end

        def autocorrect(arg)
          lambda do |corrector|
            if arg.hash_type?
              kwarg = arg.source.sub(/\A{\s*/, '').sub(/\s*}\z/, '')
              corrector.replace(arg, kwarg)
            elsif arg.splat_type?
              corrector.insert_before(arg, '*')
            else
              corrector.insert_before(arg, '**')
            end
          end
        end

        private

        def get_last_argument(node)
          last_arg = node.arguments.last
          return unless last_arg

          if last_arg.block_pass_type?
            node.arguments[-2]
          else
            last_arg
          end
        end

        def known_match?(file_path, line_number, method_name)
          file_path_from_root = file_path.sub(File.expand_path('../../..', __dir__), '')

          method_name = 'initialize' if method_name == 'new'

          self.class.keyword_warnings.any? do |warning|
            warning.include?("#{file_path_from_root}:#{line_number}") && warning.include?("called method `#{method_name}'")
          end
        end

        def self.keyword_warnings
          @keyword_warnings ||= keywords_list
        end

        def self.keywords_list
          hash = Dir.glob(DEPRECATIONS_GLOB).each_with_object({}) do |file, hash|
            hash.merge!(YAML.safe_load(File.read(file)))
          end

          hash.values.flatten.select { |str| str.include?(KEYWORD_DEPRECATION_STR) }.uniq
        end
      end
    end
  end
end
