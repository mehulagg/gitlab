# frozen_string_literal: true

module Gitlab
  module Template
    class GitlabCiYmlTemplate < BaseTemplate
      class Metadata
        attr_reader :name, :desc, :stages, :maintainers, :categories, :usage, :inclusion_type

        def initialize(hash)
          @name = hash[:name]
          @desc = hash[:desc]
          @stages = hash[:stages]
          @maintainers = hash[:maintainers]
          @categories = hash[:categories]
          @usage = hash[:usage]
          @inclusion_type = hash[:inclusion_type]
        end
      end
    end
  end
end
