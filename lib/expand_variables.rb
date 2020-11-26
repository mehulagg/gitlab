# frozen_string_literal: true

module ExpandVariables
  VARIABLES_REGEXP = /\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/.freeze

  class << self
    def expand(value, variables)
      replace_with(value, variables) do |vars_hash, last_match|
        match_or_blank_value(vars_hash, last_match)
      end
    end

    def expand_existing(value, variables)
      replace_with(value, variables) do |vars_hash, last_match|
        match_or_original_value(vars_hash, last_match)
      end
    end

    def each_variable_reference(value, variables)
      raise ArgumentError, "`#{variables}` must be of type Hash or Proc, while it was: #{variables.class}" unless
        variables.is_a?(Proc) || variables.is_a?(Hash)

      value.scan(VARIABLES_REGEXP) do |var_ref|
        # Lazily initialise variables
        variables = variables.call if variables.is_a?(Proc)

        ref_var_name = var_ref.compact.first
        yield ref_var_name if variables.key?(ref_var_name)
      end
    end

    private

    def replace_with(value, variables)
      variables_hash = nil

      value.gsub(VARIABLES_REGEXP) do
        variables_hash ||= transform_variables(variables)
        yield(variables_hash, Regexp.last_match)
      end
    end

    def match_or_blank_value(variables, last_match)
      variables[last_match[1] || last_match[2]]
    end

    def match_or_original_value(variables, last_match)
      match_or_blank_value(variables, last_match) || last_match[0]
    end

    def transform_variables(variables)
      # Lazily initialise variables
      variables = variables.call if variables.is_a?(Proc)

      # Convert hash array to variables
      if variables.is_a?(Array)
        variables = variables.reduce({}) do |hash, variable|
          hash[variable[:key]] = variable[:value]
          hash
        end
      end

      variables
    end
  end
end
