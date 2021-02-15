# frozen_string_literal: true

RSpec.configure do |config|
  config.define_derived_metadata(factory_default: :keep) do |metadata|
    metadata[:let_it_be_modifiers] ||= {freeze: true}
  end

  config.after do |ex|
    TestProf::FactoryDefault.reset unless ex.metadata[:factory_default] == :keep
  end

  config.after(:all) do
    TestProf::FactoryDefault.reset
  end
end
