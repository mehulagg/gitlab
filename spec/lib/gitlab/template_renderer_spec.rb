# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::TemplateRenderer do
  let(:described_class_with_module) { Class.new { include Gitlab::TemplateRenderer } }

  let_it_be(:template_renderer_path) { 'lib/template_renderer/path' }
  let_it_be(:template_file_name) { 'template_file_name.md' }

  describe "the class interface" do
    it "allows setting the base template path" do
      described_class_with_module.set_template_renderer_path(nil)
      expect(subject.template_renderer_path).to be_a(Pathname)
    end

    it "handles when a string is provided for the base template renderer path" do
      described_class_with_module.set_template_renderer_path(template_renderer_path)

      expect(described_class_with_module.template_renderer_path).to be_a(Pathname)
      expect(described_class_with_module.template_renderer_path).to eq(Rails.root.join(template_renderer_path))
    end

    it "handles when an array is provided for the base template renderer path" do
      described_class_with_module.set_template_renderer_path(template_renderer_path.split('/'))

      expect(described_class_with_module.template_renderer_path).to be_a(Pathname)
      expect(described_class_with_module.template_renderer_path).to eq(Rails.root.join(template_renderer_path))
    end
  end

  describe "rendering template files" do
    subject { described_class_with_module.new }

    let_it_be(:full_template_file_name) { "#{template_file_name}.#{described_class::DEFAULT_TEMPLATE_FILE_EXT}" }

    before do
      described_class_with_module.set_template_renderer_path(template_renderer_path)

      allow(File).to receive(:read).and_call_original
    end

    it "renders template files with ERB using the correct binding" do
      subject.instance_variable_set(:@variable, '_variable_')

      expected_template_file = described_class_with_module.template_renderer_path.join(full_template_file_name)
      expect(File).to receive(:read).with(expected_template_file).and_return(<<~ERB)
        we can render a <%= @variable %> within our template files.
      ERB

      expect(subject.render_template_file(template_file_name)).to eq(<<~ERB)
        we can render a _variable_ within our template files.
      ERB
    end

    it "allows customized template file extensions" do
      expected_template_file = described_class_with_module.template_renderer_path.join("#{template_file_name}.template")
      expect(File).to receive(:read).with(expected_template_file).and_return('_rendered_template_content_')

      expect(subject.render_template_file(template_file_name, ext: 'template')).to eq('_rendered_template_content_')
    end

    context "when the template renderer path hasn't been set" do
      before do
        described_class_with_module.remove_instance_variable(:@template_renderer_path)
      end

      it "raises an ArgumentError" do
        expect { subject.render_template_file(template_file_name) }.to raise_error(
          ArgumentError,
          'no template renderer path has been set using `set_template_renderer_path`'
        )
      end
    end
  end

  describe "rendering template content" do
    subject { described_class_with_module.new }

    it "renders template contents with ERB using the correct binding" do
      subject.instance_variable_set(:@variable, '_variable_')

      template_content = <<~ERB
        we can render a <%= @variable %> within
        our template content.
      ERB

      expect(subject.render_template_content(template_content)).to eq(<<~TEXT)
        we can render a _variable_ within
        our template content.
      TEXT
    end
  end
end
