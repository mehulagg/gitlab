# frozen_string_literal: true

module Matchers
  module HavePipeline
    RSpec::Matchers.define :have_pipeline do |pipeline|
      match do |page_object|
        page_object.has_pipeline?(pipeline)
      end

      match_when_negated do |page_object|
        page_object.has_no_pipeline?(pipeline)
      end
    end
  end
end
