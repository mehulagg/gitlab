describe Gitlab::QA::Slack::PostToSlack do
  describe '#invoke!' do
    it 'requires message' do
      expect { subject.invoke! }.to raise_error(ArgumentError, "missing keyword: message")
    end

    it 'requires SLACK_QA_CHANNEL env variable to be set' do
      subject = described_class.new(message: 'message')

      expect { subject.invoke! }.to raise_error(ArgumentError, 'Please provide SLACK_QA_CHANNEL')
    end

    it 'requires SLACK_QA_BOT_TOKEN env variable to be set' do
      ClimateControl.modify(SLACK_QA_CHANNEL: 'abc') do
        subject = described_class.new(message: 'message')

        expect { subject.invoke! }.to raise_error(ArgumentError, 'Please provide SLACK_QA_BOT_TOKEN')
      end
    end

    it 'accepts a message' do
      ClimateControl.modify(SLACK_QA_CHANNEL: 'abc', SLACK_QA_BOT_TOKEN: 'def') do
        subject = described_class.new(message: 'message')

        allow(Gitlab::QA::Support::HttpRequest).to receive(:make_http_request)

        expect { subject.invoke! }.not_to raise_error
      end
    end
  end
end
