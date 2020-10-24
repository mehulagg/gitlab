# frozen_string_literal: true

module StubENV
  def stub_env(key_or_hash, value = nil)
    stubbed_hash =
      if key_or_hash.is_a?(Hash)
        key_or_hash
      else
        { key_or_hash => value }
      end

    stub_const('ENV', ENV.to_h.merge(stubbed_hash))
  end
end
