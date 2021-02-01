# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Bridge
        class WaitingForResource < Status::Build::WaitingForResource
        end
      end
    end
  end
end
