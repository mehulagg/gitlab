# frozen_string_literal: true

module Gitlab
  module Template
    class CustomGitlabCiSyntaxYmlTemplate < CustomTemplate
      class << self
        def extension
          '.yml'
        end

        def base_dir
          'gitlab-ci/'
        end
      end
    end
  end
end
