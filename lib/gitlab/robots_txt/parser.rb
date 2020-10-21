# frozen_string_literal: true

module Gitlab
  module RobotsTxt
    class Parser
      attr_reader :disallow_rules, :allow_rules

      def initialize(content)
        @raw_content = content

        @disallow_rules, @allow_rules = parse_raw_content!
      end

      def disallowed?(path)
        return false if allow_rules.any? { |rule| path =~ rule }

        disallow_rules.any? { |rule| path =~ rule }
      end

      private
        DISALLOW_TOKEN = 'Disallow:'
        ALLOW_TOKEN = 'Allow:'

      # This parser is very basic as it only knows about `Disallow:`
      # and `Allow:` lines, and simply ignores all other lines.
      #
      # `Allow` takes precedence over `Disallow`
      def parse_raw_content!
        disallowed = []
        allowed = []

        @raw_content.each_line.each do |line|
          if line.start_with?(DISALLOW_TOKEN)
            disallowed << get_rule(line, DISALLOW_TOKEN)
          elsif line.start_with?(ALLOW_TOKEN)
            allowed << get_rule(line, ALLOW_TOKEN)
          end
        end

        [disallowed, allowed]
      end

      def get_rule(line, rule_type)
        value = line.sub(rule_type, '').strip
        value = Regexp.escape(value).gsub('\*', '.*')
        Regexp.new("^#{value}")
      end
    end
  end
end
