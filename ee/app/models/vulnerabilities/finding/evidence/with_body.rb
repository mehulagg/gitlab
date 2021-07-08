# frozen_string_literal: true

module Vulnerabilities
  class Finding
    class Evidence
      module WithBody
        extend ActiveSupport::Concern

        MAX_BODY_LENGTH = 2048

        included do
          before_validation :truncate_body

          validates :body, length: { maximum: MAX_BODY_LENGTH }
        end

        private

        def truncate_body
          return unless self.body

          self.body = self.body.truncate(MAX_BODY_LENGTH, omission: "---- TRUNCATED(Total Length: #{self.body.length} characters) ----")
        end
      end
    end
  end
end
