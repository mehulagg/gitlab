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

    # expand_variables_collection expands a Gitlab::Ci::Variables::Collection, ignoring unknown variable references.
    # If a circular variable reference is found, the original Collection is returned
    def expand_variables_collection(variables, project)
      return Gitlab::Ci::Variables::Collection.new(variables) if
        Feature.disabled?(:variable_inside_variable, project)

      sorted_variables = variables.sorted_collection(project)
      return sorted_variables if sorted_variables.errors

      expand_sorted_variables_collection(sorted_variables)
    end

    def possible_var_reference?(value)
      return unless value

      %w[$ %].any? { |symbol| value.include?(symbol) }
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
      ref_var_name = last_match[1] || last_match[2]
      ref_var = variables[ref_var_name]
      return ref_var if ref_var.is_a?(String) # if entry is a simple "key" => "value" hash

      ref_var[:value] if ref_var
    end

    def match_or_original_value(variables, last_match)
      match_or_blank_value(variables, last_match) || last_match[0]
    end

    def transform_variables(variables)
      # Lazily initialise variables
      variables = variables.call if variables.is_a?(Proc)

      # Convert Collection to variables
      variables = variables.to_hash if variables.is_a?(Gitlab::Ci::Variables::Collection)

      # Convert hash array to hash of variables
      if variables.is_a?(Array)
        variables = variables.reduce({}) do |hash, variable|
          hash[variable[:key]] = variable
          hash
        end
      end

      variables
    end

    def expand_sorted_variables_collection(sorted_variables)
      expanded_vars = {}

      sorted_variables.each_with_object(Gitlab::Ci::Variables::Collection.new) do |item, collection|
        item = item.merge(value: expand_existing(item.value, expanded_vars)) if item.depends_on

        expanded_vars.store(item[:key], item)
        collection.append(item)
      end
    end
  end
end
