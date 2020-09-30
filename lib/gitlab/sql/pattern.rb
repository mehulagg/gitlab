# frozen_string_literal: true

module Gitlab
  module SQL
    module Pattern
      extend ActiveSupport::Concern

      MIN_CHARS_FOR_PARTIAL_MATCHING = 3
      REGEX_QUOTED_WORD = /(?<=\A| )"[^"]+"(?= |\z)/.freeze

      class_methods do
        def fuzzy_search(query, columns, use_minimum_char_limit: true)
          arel_columns = columns.map { |column| arel_table[column] }

          # Using OR to search multiple text columns performs badly for some
          # reason. Using concatenation to avoid needing the OR is a significant
          # performance win.
          target = if arel_columns.size > 1
            Arel::Nodes::NamedFunction.new('CONCAT', arel_columns),
          else
            arel_columns.first
          end

          where(fuzzy_arel_match(target, query, use_minimum_char_limit: use_minimum_char_limit))
        end

        def to_pattern(query, use_minimum_char_limit: true)
          if partial_matching?(query, use_minimum_char_limit: use_minimum_char_limit)
            "%#{sanitize_sql_like(query)}%"
          else
            sanitize_sql_like(query)
          end
        end

        def min_chars_for_partial_matching
          MIN_CHARS_FOR_PARTIAL_MATCHING
        end

        def partial_matching?(query, use_minimum_char_limit: true)
          return true unless use_minimum_char_limit

          query.length >= min_chars_for_partial_matching
        end

        # target - The column name / Arel column / expression to search in.
        # query - The text to search for.
        # lower_exact_match - When set to `true` we'll fall back to using
        #                     `LOWER(column) = query` instead of using `ILIKE`.
        def fuzzy_arel_match(target, query, lower_exact_match: false, use_minimum_char_limit: true)
          query = query.squish
          return unless query.present?

          target = arel_table[target] if target.is_a?(Symbol) || target.is_a?(String)

          words = select_fuzzy_words(query, use_minimum_char_limit: use_minimum_char_limit)

          if words.any?
            words.map { |word| target.matches(to_pattern(word, use_minimum_char_limit: use_minimum_char_limit)) }.reduce(:and)
          else
            # No words of at least 3 chars, but we can search for an exact
            # case insensitive match with the query as a whole
            if lower_exact_match
              Arel::Nodes::NamedFunction
                .new('LOWER', [target])
                .eq(query)
            else
              target.matches(sanitize_sql_like(query))
            end
          end
        end

        def select_fuzzy_words(query, use_minimum_char_limit: true)
          quoted_words = query.scan(REGEX_QUOTED_WORD)

          query = quoted_words.reduce(query) { |q, quoted_word| q.sub(quoted_word, '') }

          words = query.split

          quoted_words.map! { |quoted_word| quoted_word[1..-2] }

          words.concat(quoted_words)

          words.select { |word| partial_matching?(word, use_minimum_char_limit: use_minimum_char_limit) }
        end
      end
    end
  end
end
