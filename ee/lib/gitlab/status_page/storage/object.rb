# frozen_string_literal: true

module Gitlab
  module StatusPage
    module Storage
      # Represents a platform-agnostic object class.
      Object = Struct.new(:key, :content, :modified_at, keyword_init: true)
    end
  end
end
