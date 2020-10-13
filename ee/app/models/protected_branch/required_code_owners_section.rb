# frozen_string_literal: true

class ProtectedBranch::RequiredCodeOwnersSection < ApplicationRecord
  self.table_name = 'required_code_owners_sections'

  belongs_to :protected_branch
end
