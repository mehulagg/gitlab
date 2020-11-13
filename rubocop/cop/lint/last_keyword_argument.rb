module RuboCop
  module Cop
    module Lint
      class LastKeywordArgument < Cop
        MSG = 'Using the last argument as keyword parameters is deprecated'.freeze

        def on_send(node)
          arg = node.arguments.last
          return unless arg

          return unless keyword_warnings.any? do |warning|
            warning.include? "#{processed_source.file_path}:#{node.first_line}"
          end

          return if arg.children.first&.kwsplat_type?

          add_offense(arg)
        end

        private

        def keyword_warnings
          @keyword_warnings ||= keywords_list
        end

        def keywords_list
          return [] unless File.exist?(keywords_file_path)

          File.readlines(keywords_file_path)
        end

        def keywords_file_path
          File.expand_path('../../../tmp/keyword_warn.txt', __dir__)
        end
      end
    end
  end
end
