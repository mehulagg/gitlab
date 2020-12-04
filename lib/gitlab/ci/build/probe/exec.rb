# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Probe
        class Exec
          attr_reader :command

          def initialize(probe)
            @command = probe[:command]
          end
        end
      end
    end
  end
end
