class CiBase < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    primary: { writing: :primary, reading: :primary },
    ci: { writing: :ci, reading: :ci }
  }
end
