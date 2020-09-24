# frozen_string_literal: true

class LDAPKey < Key
  include UsageStatistics

  def can_delete?
    false
  end
end
