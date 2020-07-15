# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitlab::Json do
  before do
    stub_feature_flags(json_wrapper_legacy_mode: true)
  end

  shared_examples "json" do
    describe ".parse" do
      context "legacy_mode is disabled by default" do
        it "parses an object" do
          expect(subject.parse('{ "foo": "bar" }')).to eq({ "foo" => "bar" })
        end

        it "parses an array" do
          expect(subject.parse('[{ "foo": "bar" }]')).to eq([{ "foo" => "bar" }])
        end

        it "parses a string" do
          expect(subject.parse('"foo"', legacy_mode: false)).to eq("foo")
        end

        it "parses a true bool" do
          expect(subject.parse("true", legacy_mode: false)).to be(true)
        end

        it "parses a false bool" do
          expect(subject.parse("false", legacy_mode: false)).to be(false)
        end
      end

      context "legacy_mode is enabled" do
        it "parses an object" do
          expect(subject.parse('{ "foo": "bar" }', legacy_mode: true)).to eq({ "foo" => "bar" })
        end

        it "parses an array" do
          expect(subject.parse('[{ "foo": "bar" }]', legacy_mode: true)).to eq([{ "foo" => "bar" }])
        end

        it "raises an error on a string" do
          expect { subject.parse('"foo"', legacy_mode: true) }.to raise_error(JSON::ParserError)
        end

        it "raises an error on a true bool" do
          expect { subject.parse("true", legacy_mode: true) }.to raise_error(JSON::ParserError)
        end

        it "raises an error on a false bool" do
          expect { subject.parse("false", legacy_mode: true) }.to raise_error(JSON::ParserError)
        end
      end

      context "feature flag is disabled" do
        before do
          stub_feature_flags(json_wrapper_legacy_mode: false)
        end

        it "parses an object" do
          expect(subject.parse('{ "foo": "bar" }', legacy_mode: true)).to eq({ "foo" => "bar" })
        end

        it "parses an array" do
          expect(subject.parse('[{ "foo": "bar" }]', legacy_mode: true)).to eq([{ "foo" => "bar" }])
        end

        it "parses a string" do
          expect(subject.parse('"foo"', legacy_mode: true)).to eq("foo")
        end

        it "parses a true bool" do
          expect(subject.parse("true", legacy_mode: true)).to be(true)
        end

        it "parses a false bool" do
          expect(subject.parse("false", legacy_mode: true)).to be(false)
        end
      end
    end

    describe ".parse!" do
      context "legacy_mode is disabled by default" do
        it "parses an object" do
          expect(subject.parse!('{ "foo": "bar" }')).to eq({ "foo" => "bar" })
        end

        it "parses an array" do
          expect(subject.parse!('[{ "foo": "bar" }]')).to eq([{ "foo" => "bar" }])
        end

        it "parses a string" do
          expect(subject.parse!('"foo"', legacy_mode: false)).to eq("foo")
        end

        it "parses a true bool" do
          expect(subject.parse!("true", legacy_mode: false)).to be(true)
        end

        it "parses a false bool" do
          expect(subject.parse!("false", legacy_mode: false)).to be(false)
        end
      end

      context "legacy_mode is enabled" do
        it "parses an object" do
          expect(subject.parse!('{ "foo": "bar" }', legacy_mode: true)).to eq({ "foo" => "bar" })
        end

        it "parses an array" do
          expect(subject.parse!('[{ "foo": "bar" }]', legacy_mode: true)).to eq([{ "foo" => "bar" }])
        end

        it "raises an error on a string" do
          expect { subject.parse!('"foo"', legacy_mode: true) }.to raise_error(JSON::ParserError)
        end

        it "raises an error on a true bool" do
          expect { subject.parse!("true", legacy_mode: true) }.to raise_error(JSON::ParserError)
        end

        it "raises an error on a false bool" do
          expect { subject.parse!("false", legacy_mode: true) }.to raise_error(JSON::ParserError)
        end
      end

      context "feature flag is disabled" do
        before do
          stub_feature_flags(json_wrapper_legacy_mode: false)
        end

        it "parses an object" do
          expect(subject.parse!('{ "foo": "bar" }', legacy_mode: true)).to eq({ "foo" => "bar" })
        end

        it "parses an array" do
          expect(subject.parse!('[{ "foo": "bar" }]', legacy_mode: true)).to eq([{ "foo" => "bar" }])
        end

        it "parses a string" do
          expect(subject.parse!('"foo"', legacy_mode: true)).to eq("foo")
        end

        it "parses a true bool" do
          expect(subject.parse!("true", legacy_mode: true)).to be(true)
        end

        it "parses a false bool" do
          expect(subject.parse!("false", legacy_mode: true)).to be(false)
        end
      end
    end

    describe ".dump" do
      it "dumps an object" do
        expect(subject.dump({ "foo" => "bar" })).to eq('{"foo":"bar"}')
      end

      it "dumps an array" do
        expect(subject.dump([{ "foo" => "bar" }])).to eq('[{"foo":"bar"}]')
      end

      it "dumps a string" do
        expect(subject.dump("foo")).to eq('"foo"')
      end

      it "dumps a true bool" do
        expect(subject.dump(true)).to eq("true")
      end

      it "dumps a false bool" do
        expect(subject.dump(false)).to eq("false")
      end
    end

    describe ".generate" do
      let(:obj) do
        { test: true, "foo.bar" => "baz", is_json: 1, some: [1, 2, 3] }
      end

      it "generates JSON" do
        expected_string = <<~STR.chomp
          {"test":true,"foo.bar":"baz","is_json":1,"some":[1,2,3]}
        STR

        expect(subject.generate(obj)).to eq(expected_string)
      end

      it "allows you to customise the output" do
        opts = {
          indent: "  ",
          space: " ",
          space_before: " ",
          object_nl: "\n",
          array_nl: "\n"
        }

        json = subject.generate(obj, opts)

        expected_string = <<~STR.chomp
          {
            "test" : true,
            "foo.bar" : "baz",
            "is_json" : 1,
            "some" : [
              1,
              2,
              3
            ]
          }
        STR

        expect(json).to eq(expected_string)
      end
    end

    describe ".pretty_generate" do
      let(:obj) do
        {
          test: true,
          "foo.bar" => "baz",
          is_json: 1,
          some: [1, 2, 3],
          more: { test: true },
          multi_line_empty_array: [],
          multi_line_empty_obj: {}
        }
      end

      it "generates pretty JSON" do
        expected_string = <<~STR.chomp
          {
            "test": true,
            "foo.bar": "baz",
            "is_json": 1,
            "some": [
              1,
              2,
              3
            ],
            "more": {
              "test": true
            },
            "multi_line_empty_array": [

            ],
            "multi_line_empty_obj": {
            }
          }
        STR

        expect(subject.pretty_generate(obj)).to eq(expected_string)
      end

      it "allows you to customise the output" do
        opts = {
          space_before: " "
        }

        json = subject.pretty_generate(obj, opts)

        expected_string = <<~STR.chomp
          {
            "test" : true,
            "foo.bar" : "baz",
            "is_json" : 1,
            "some" : [
              1,
              2,
              3
            ],
            "more" : {
              "test" : true
            },
            "multi_line_empty_array" : [

            ],
            "multi_line_empty_obj" : {
            }
          }
        STR

        expect(json).to eq(expected_string)
      end
    end

    context "the feature table is missing" do
      before do
        allow(Feature::FlipperFeature).to receive(:table_exists?).and_return(false)
      end

      it "skips legacy mode handling" do
        expect(Feature).not_to receive(:enabled?).with(:json_wrapper_legacy_mode, default_enabled: true)

        subject.send(:handle_legacy_mode!, {})
      end

      it "skips oj feature detection" do
        expect(Feature).not_to receive(:enabled?).with(:oj_json, default_enabled: true)

        subject.send(:enable_oj?)
      end
    end

    context "the database is missing" do
      before do
        allow(Feature::FlipperFeature).to receive(:table_exists?).and_raise(PG::ConnectionBad)
      end

      it "still parses json" do
        expect(subject.parse("{}")).to eq({})
      end

      it "still generates json" do
        expect(subject.dump({})).to eq("{}")
      end
    end
  end

  context "oj gem" do
    before do
      stub_feature_flags(oj_json: true)
    end

    it_behaves_like "json"
  end

  context "json gem" do
    before do
      stub_feature_flags(oj_json: false)
    end

    it_behaves_like "json"
  end
end
