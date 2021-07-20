# frozen_string_literal: true

RSpec.shared_examples 'common merge request metric refresh for' do |metric_name|
  before do
    allow_next_instance_of(Analytics::MergeRequestMetricsCalculator, merge_request) do |instance|
      allow(instance).to receive(metric_name).and_return(calculated_value)
    end
  end

  it "updates #{metric_name}" do
    expect do
      subject.execute
      merge_request.metrics.reload
    end.to change { merge_request.metrics[metric_name] }.from(nil).to(calculated_value)
  end

  context "when #{metric_name} is already present" do
    before do
      merge_request.metrics.update!(metric_name => calculated_value - 10)
    end

    it "does not change #{metric_name}" do
      expect do
        subject.execute
        merge_request.metrics.reload
      end.not_to change { merge_request.metrics[metric_name] }
    end

    it "updates #{metric_name} if forced" do
      expect do
        subject.execute(force: true)
        merge_request.metrics.reload
      end.to change { merge_request.metrics[metric_name] }.to(calculated_value)
    end
  end

  context 'when no merge request metric is present' do
    before do
      merge_request.metrics.destroy!
      merge_request.reload
    end

    it 'creates one' do
      expect { subject.execute }
        .to change { merge_request.metrics && merge_request.metrics[metric_name] }.from(nil).to(calculated_value)
    end
  end
end
