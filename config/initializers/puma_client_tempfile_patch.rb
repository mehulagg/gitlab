# frozen_string_literal: true

if Gitlab::Runtime.puma?
  module Puma
    class Client
      module Tempfile
        def self.new(*args)
          ::Tempfile.new(*args).tap(&:unlink)
        end
      end
    end
  end
end
