# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpamRecaptchaSupport do
  let(:klass) do
    Class.new do
      include SpamRecaptchaSupport
    end
  end

  describe '#ensure_spam_config_loaded!' do
    subject { klass.new }

    it "loads recaptcha configurations" do
      subject

      # Not the greatest test, but it's memoized and false in test env, so we can't test much more
      expect(Gitlab::Recaptcha.enabled?).to be false
    end
  end

  describe '#render_recaptcha?' do
    let(:spammable) { double(:spammable) }

    subject { klass.new.render_recaptcha?(spammable) }

    context 'when GitLab::Recaptcha.enabled? is false' do
      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'when GitLab::Recaptcha.enabled? is true' do
      let(:errors) { double(:errors) }

      before do
        expect(Gitlab::Recaptcha).to receive(:enabled?) { true }
        expect(spammable).to receive(:errors) { errors }
      end

      context 'when there are multiple errors on spammable' do
        before do
          expect(errors).to receive(:count) { 2 }
        end

        it 'returns false' do
          expect(subject).to eq(false)
        end
      end

      context 'when there are not multiple errors on spammable' do
        before do
          expect(errors).to receive(:count) { 1 }
        end

        context 'when spammable.needs_recaptcha? is true' do
          before do
            expect(spammable).to receive(:needs_recaptcha?) { true }
          end

          it 'returns false' do
            expect(subject).to eq(true)
          end
        end

        context 'when spammable.needs_recaptcha? is false' do
          before do
            expect(spammable).to receive(:needs_recaptcha?) { false }
          end

          it 'returns false' do
            expect(subject).to eq(false)
          end
        end
      end
    end
  end

  describe '#verify_spammable_recaptcha!' do
    let(:spammable) { double(:spammable) }
    let(:recaptcha_response) { double(:recaptcha_response) }

    subject { klass.new }

    it 'ensures spam config loaded and calls verify_recaptcha' do
      # NOTE: #ensure_spam_config_loaded! is memoized and false, so we have to
      # mock it on the class under test
      expect(subject).to receive(:ensure_spam_config_loaded!) { true }

      verify_recaptcha_options = { model: spammable, response: recaptcha_response }

      expect(subject).to receive(:verify_recaptcha).with(verify_recaptcha_options) { true }

      result = subject.verify_spammable_recaptcha!(spammable, recaptcha_response)
      expect(result).to be true
    end
  end
end
