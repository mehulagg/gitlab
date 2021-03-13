# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      #
      # ExpressionParser parses variable values and extracts variable references contained therein.
      #
      # Terminology:
      #   Bounded reference:      ${VAR} or %VAR%
      #   Unbounded reference:    $VAR
      #   Escaped character:      $$ or %%
      #   Valid active reference: when a variable reference is being gathered, and variable name is non-empty
      class ExpressionParser
        VAR_IDENTIFIER_FIRST_CHAR_REGEXP = /[a-zA-Z_]/.freeze
        VAR_IDENTIFIER_SUBSEQUENT_CHAR_REGEXP = /[a-zA-Z0-9_]/.freeze
        REF_CLOSER_SUFFIX = {
          '${' => '}',
          '%' => '%'
        }.freeze

        # Replacement is an utility class to keep track of replacements due on an expression
        class Replacement
          attr_reader :start_pos, :end_pos, :variable_name, :new_text

          def initialize(start_pos, end_pos, variable_name, new_text)
            @start_pos = start_pos
            @end_pos = end_pos
            @variable_name = variable_name
            @new_text = new_text
          end
        end

        def initialize(value)
          @value = value
        end

        def dependencies
          replacements = extract_replacements

          return [] unless replacements && replacements.any?

          replacements.map(&:variable_name)
            .reject(&:nil_or_empty?)
        end

        def expand(collection, keep_undefined)
          replacements = extract_replacements

          return @value unless replacements && replacements.any?

          # Build the output string with all the calculated replacements
          apply_replacements(@value, replacements, collection, keep_undefined)
        end

        private

        def possible_var_reference?
          return unless @value

          %w[$ %].any? { |symbol| @value.include?(symbol) }
        end

        def extract_replacements
          clear_ref_state

          return unless possible_var_reference?

          @active_ref_index = nil

          refs = @value.chars.map.with_index { |ch, pos| process_char(ch, pos) }
          refs.append(flush_active_ref(@value.length)) unless in_bounded_reference?
          refs.flatten(1).compact
        end

        def apply_replacements(value, replacements, collection, keep_undefined)
          seed = { value: '', last_index: 0 }
          v = replacements.reduce(seed) do |current_state, replacement|
            acc_value = current_state[:value]
            end_pos = replacement.start_pos - 1

            if replacement.variable_name
              replacement_value = collection[replacement.variable_name]&.value

              end_pos = replacement.end_pos if replacement_value.nil? && keep_undefined
            else
              replacement_value = replacement.new_text
            end

            unmodified_value_substring = value[current_state[:last_index]..end_pos] if end_pos >= 0

            {
              value: [acc_value, unmodified_value_substring, replacement_value].join,
              last_index: replacement.end_pos + 1
            }
          end

          v[:value] + value[v[:last_index]..]
        end

        def process_char(ch, pos)
          if char_terminates_ref?(ch)
            flush_active_ref(pos)
          elsif char_initiates_ref?(ch)
            # Flush if starting new reference and we have an existing unbounded reference
            entries = [flush_active_ref(pos)] if valid_unbounded_ref?

            if char_escaped?(ch)
              # Are we looking at '$$', or'%%' ?
              entries ||= []
              entries.append(new_replacement(pos, ch))
              clear_ref_state
            elsif in_bounded_reference?
              # Unexpected reference initiated, ignore
              clear_ref_state
            else
              # We're looking at building '$', '${', or '%'
              @active_ref_prefix.concat(ch)
              @active_ref_index ||= pos
            end

            entries
          elsif !@active_ref_prefix.empty? && valid_ref_char?(ch)
            @ref_var_name.concat(ch)
            nil
          else
            flush_active_ref(pos) if valid_unbounded_ref?
          end
        end

        def char_escaped?(ch)
          !@active_ref_prefix.empty? && char_initiates_ref?(ch) && ch == @active_ref_prefix
        end

        def char_initiates_ref?(ch)
          ch == '$' || ch == '%' || (@active_ref_prefix == '$' && ch == '{')
        end

        def char_terminates_ref?(ch)
          in_bounded_reference? && !@ref_var_name.empty? && ch == ref_closer
        end

        def valid_ref_char?(ch)
          return false if @active_ref_prefix.empty?
          return VAR_IDENTIFIER_FIRST_CHAR_REGEXP.match?(ch) if @ref_var_name.empty?

          VAR_IDENTIFIER_SUBSEQUENT_CHAR_REGEXP.match?(ch)
        end

        def in_bounded_reference?
          @active_ref_prefix == '${' || @active_ref_prefix == '%'
        end

        def in_unbounded_reference?
          @active_ref_prefix == '$'
        end

        def valid_unbounded_ref?
          in_unbounded_reference? && !@ref_var_name.empty?
        end

        def ref_closer
          REF_CLOSER_SUFFIX[@active_ref_prefix] || ''
        end

        def clear_ref_state
          @active_ref_index = nil
          @active_ref_prefix = +''
          @ref_var_name = +''
        end

        def flush_active_ref(pos)
          return if @active_ref_index.nil?
          return if @ref_var_name.empty?

          entry = new_variable_replacement(pos - 1 + ref_closer.length)

          clear_ref_state

          entry
        end

        def new_variable_replacement(end_pos)
          Replacement.new(@active_ref_index, end_pos, @ref_var_name, nil)
        end

        def new_replacement(end_pos, replacement)
          Replacement.new(@active_ref_index, end_pos, nil, replacement)
        end
      end
    end
  end
end
