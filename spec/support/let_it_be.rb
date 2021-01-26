# frozen_string_literal: true

TestProf::LetItBe.configure do |config|
  config.default_modifiers[:freeze] = true

  config.alias_to :let_it_be_with_refind, refind: true
  config.alias_to :let_it_be_with_reload, reload: true
end
