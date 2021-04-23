# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      Log = Struct.new(:migration, :content) do
        def to_s
          content.string
        end
      end
    end
  end
end
