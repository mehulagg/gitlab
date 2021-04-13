# frozen_string_literal: true

module RuboCop
  module Cop
    # Checks for comments in the mtric yaml files.
    # See https://gitlab.com/gitlab-org/gitlab/-/issues/324038
    class PreventBoilerplateCommentsInYaml < RuboCop::Cop::Cop
      MSG = 'Remove the boilerplate comments from the top of the file.'
    end
  end
end
