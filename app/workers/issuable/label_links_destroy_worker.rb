# frozen_string_literal: true

module Issuable
  class LabelLinksDestroyWorker
    include ApplicationWorker

    idempotent!

    def perform(target_id, target_type)
      ::Issuable::DestroyLabelLinksService.new(target_id, target_type).execute
    end
  end
end
