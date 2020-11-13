# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ButtonHelper do
  describe 'clipboard_button' do
    include IconsHelper

    let(:user) { create(:user) }
    let(:project) { build_stubbed(:project) }

    def element(data = {})
      element = helper.clipboard_button(data)
      Nokogiri::HTML::DocumentFragment.parse(element).first_element_child
    end

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'with default options' do
      context 'when no `text` attribute is not provided' do
        it 'shows copy to clipboard button with default configuration and no text set to copy' do
          expect(element.attr('class')).to eq('btn btn-clipboard btn-transparent')
          expect(element.attr('type')).to eq('button')
          expect(element.attr('aria-label')).to eq('Copy')
          expect(element.attr('data-toggle')).to eq('tooltip')
          expect(element.attr('data-placement')).to eq('bottom')
          expect(element.attr('data-container')).to eq('body')
          expect(element.attr('data-clipboard-text')).to eq(nil)
          expect(element.inner_text).to eq("")

          expect(element.to_html).to include sprite_icon('copy-to-clipboard')
        end
      end

      context 'when `text` attribute is provided' do
        it 'shows copy to clipboard button with provided `text` to copy' do
          expect(element(text: 'Hello World!').attr('data-clipboard-text')).to eq('Hello World!')
        end
      end

      context 'when `title` attribute is provided' do
        it 'shows copy to clipboard button with provided `title` as tooltip' do
          expect(element(title: 'Copy to my clipboard!').attr('aria-label')).to eq('Copy to my clipboard!')
        end
      end
    end

    context 'with `button_text` attribute provided' do
      it 'shows copy to clipboard button with provided `button_text` as button label' do
        expect(element(button_text: 'Copy text').inner_text).to eq('Copy text')
      end
    end

    context 'with `hide_tooltip` attribute provided' do
      it 'shows copy to clipboard button without tooltip support' do
        expect(element(hide_tooltip: true).attr('data-placement')).to eq(nil)
        expect(element(hide_tooltip: true).attr('data-toggle')).to eq(nil)
        expect(element(hide_tooltip: true).attr('data-container')).to eq(nil)
      end
    end

    context 'with `hide_button_icon` attribute provided' do
      it 'shows copy to clipboard button without tooltip support' do
        expect(element(hide_button_icon: true).to_html).not_to include sprite_icon('duplicate')
      end
    end
  end
end
