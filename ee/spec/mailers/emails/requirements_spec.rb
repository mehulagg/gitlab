# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emails::Requirements do
  include EmailSpec::Matchers

  describe "#import_requirements_csv_email" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }

    subject { Notify.import_requirements_csv_email(user.id, project.id, @results) }

    it "shows number of successful requirements imported" do
      @results = { success: 165, error_lines: [], parse_error: false }

      expect(subject).to have_body_text "165 requirements imported"
    end

    it "shows error when file is invalid" do
      @results = { success: 0, error_lines: [], parse_error: true }

      expect(subject).to have_body_text "Error parsing CSV"
    end

    it "shows line numbers with errors" do
      @results = { success: 0, error_lines: [23, 34, 58], parse_error: false }

      expect(subject).to have_body_text "23, 34, 58"
    end

    context 'with header and footer' do
      let(:results) { { success: 165, error_lines: [], parse_error: false } }

      subject { Notify.import_requirements_csv_email(user.id, project.id, results) }

      it_behaves_like 'appearance header and footer enabled'
      it_behaves_like 'appearance header and footer not enabled'
    end
  end
end
