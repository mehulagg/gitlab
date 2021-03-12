# frozen_string_literal: true

RSpec.shared_examples 'common trace features' do
  describe '#archive!' do
    subject { trace.archive! }

    context 'when build status is success' do
      let!(:build) { create(:ci_build, :success, :trace_live) }

      context 'when archives' do
        it 'has an archived trace' do
          puts "*1" * 50
          subject
          puts "*2" * 50

          build.reload
          expect(build.job_artifacts_trace).to be_exist
        end
      end
    end
  end
end

RSpec.shared_examples 'trace with disabled live trace feature' do
  it_behaves_like 'common trace features'
end
