# frozen_string_literal: true

module Ci
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true

    if Gitlab::Application.config.database_configuration[Rails.env]["ci"].present?
      connects_to database: { writing: :ci, reading: :ci }
    end
  end
end
