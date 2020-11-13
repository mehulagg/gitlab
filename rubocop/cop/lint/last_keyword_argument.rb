# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      class LastKeywordArgument < Cop
        MSG = 'Using the last argument as keyword parameters is deprecated'.freeze

        def on_send(node)
          arg = node.arguments.last
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
            else
              corrector.insert_before(arg, '**')
            end
          end
        end

        private

        def known_match?(file_path, line_number, method_name)
          file_path_from_root = file_path.sub(File.expand_path('../../..', __dir__), '')

          keyword_warnings.any? do |warning|
            warning.include?("#{file_path_from_root}:#{line_number}") && warning.include?("called method `#{method_name}'")
          end
        end

        def keyword_warnings
          @keyword_warnings ||= keywords_list
        end

        def keywords_list
          return [] unless File.exist?(keywords_file_path)

          File.read(keywords_file_path).split("----\n")
        end

        def keywords_file_path
          File.expand_path('../../../tmp/keyword_warn.txt', __dir__)
        end
      end
    end
  end
end
