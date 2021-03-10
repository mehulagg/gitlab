# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Seed
        Context = Struct.new(:pipeline, :root_variables)
      end
    end
  end
end
