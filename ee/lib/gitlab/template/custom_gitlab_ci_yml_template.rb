# frozen_string_literal: true

module Gitlab
  module Template
    class CustomGitlabCiYmlTemplate < CustomTemplate
      def metadata
        # To be supported
      end

      def has_metadata?
        # To be supported
      end

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
