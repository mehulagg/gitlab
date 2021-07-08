# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Billings > Trial', :js do
  context 'with paid subscription' do
    context 'when expired' do
      it_behaves_like 'a reactivatable trial'
    end

    context 'when not expired' do
      it_behaves_like 'a non-reactivatable trial'
    end
  end

  context 'without a subscription' do
    it_behaves_like 'a non-reactivatable trial'
  end

  context 'with active trial' do
    it_behaves_like 'an extendable trial'
    it_behaves_like 'a non-reactivatable trial'
  end

  context 'with extended trial' do
    it_behaves_like 'a non-extendable trial'
  end

  context 'with expired trial' do
    it_behaves_like 'a reactivatable trial'
  end
end
