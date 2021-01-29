# frozen_string_literal: true

# Placeholder class for model that is implemented in EE
class Iteration < ApplicationRecord
  self.table_name = 'sprints'
end

Iteration.prepend_if_ee('EE::Iteration')
