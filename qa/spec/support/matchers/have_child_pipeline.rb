# frozen_string_literal: true

module Matchers
  module HaveChildPipeline
    RSpec::Matchers.define :have_child_pipeline do |child_pipeline|
      match do |page_object|
        page_object.has_child_pipeline?(child_pipeline)
      end

      match_when_negated do |page_object|
        page_object.has_child_pipeline?(child_pipeline)
      end
    end
  end
end


