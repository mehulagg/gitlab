# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserCreditCardValidation do
  it { is_expected.to belong_to(:user) }
end
