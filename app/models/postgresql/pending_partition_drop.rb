# frozen_string_literal: true

module Postgresql
  class PendingPartitionDrop < ApplicationRecord
    scope :ready_to_delete, -> { where('delete_after < ?', Time.current) }
  end
end
