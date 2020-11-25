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

    # expand_runner_variables expands an array of variables, ignoring unknown variable references.
    # If a circular variable reference is found, the original array is returned
    def expand_runner_variables(variables, project)
      return variables if Feature.disabled?(:variable_inside_variable, project)

      sorter = Gitlab::Ci::Variables::Collection::Sorted.new(variables, project)

      sorted_variables = sorter.sort
      return sorted_variables unless sorter.valid?

      expand_sorted_runner_variables(sorted_variables)
    end

    def possible_var_reference?(value)
      return unless value

      value.include?('$')
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
      ref_var_name = last_match[1] || variables[2]
      ref_var = variables[ref_var_name]
      return ref_var if ref_var.is_a?(String)

      ref_var[:value] if ref_var && !ref_var[:protected]
    end

    def match_or_original_value(variables, last_match)
      match_or_blank_value(variables, last_match) || last_match[0]
    end

    def transform_variables(variables)
      # Lazily initialise variables
      variables = variables.call if variables.is_a?(Proc)

      # Convert hash array to hash of variables
      if variables.is_a?(Array)
        variables = variables.reduce({}) do |hash, variable|
          hash[variable[:key]] = variable
          hash
        end
      end

      variables
    end

    def expand_sorted_runner_variables(sorted_variables)
      expanded_vars = {}

      sorted_variables.map do |env|
        value = env[:value]
        value = expand_existing(value, expanded_vars) if possible_var_reference?(value)
        expanded_vars.store(env[:key], env.merge(value: value))
      end
    end
  end
end
