# frozen_string_literal: true

TestProf::LetItBe.configure do |config|
  # The :freeze modifier actually deep freezes the record and currently loaded
  # associations, which results in too many failures
  config.register_modifier :light_freeze do |record, val|
    next record unless val

    if record.respond_to?(:freeze)
      record.freeze
    end

    record
  end

  config.alias_to :let_it_be_with_refind, refind: true
  config.alias_to :let_it_be_with_reload, reload: true
end
