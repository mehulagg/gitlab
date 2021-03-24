# frozen_string_literal: true

require "fast_spec_helper"
require "rspec/parameterized"

RSpec.describe Gitlab::Utils::MimeType do
  describe ".from_io" do
    subject { described_class.from_io(io) }

    context "input isn't an IO" do
      let(:io) { "test" }

      it "raises an error" do
        expect { subject }.to raise_error(Gitlab::Utils::MimeType::Error)
      end
    end

    context "input is a file" do
      using RSpec::Parameterized::TableSyntax

      where(:fixture, :mime_type) do
        "csv_comma.csv"         | "text/plain"
        "csv_empty.csv"         | nil
        "group.json"            | "text/plain"
        "audio_sample.wav"      | "audio/x-wav"
        "banana_sample.gif"     | "image/gif"
        "invalid_manifest.xml"  | "text/plain"
        "rails_sample.jpg"      | "image/jpeg"
        "pages.zip"             | "application/zip"
        "git-cheat-sheet.pdf"   | "text/plain"
        "fuzzy.po"              | "text/x-po"
      end

      with_them do
        let(:io) { File.open(File.join(__dir__, "../../../fixtures", fixture)) }

        it { is_expected.to eq(mime_type) }
      end
    end
  end

  describe ".from_string" do
    subject { described_class.from_string(str) }

    context "input isn't a string" do
      let(:str) { nil }

      it "raises an error" do
        expect { subject }.to raise_error(Gitlab::Utils::MimeType::Error)
      end
    end

    context "input is a string" do
      let(:str) { "plain text" }

      it { is_expected.to eq("text/plain") }
    end
  end
end
