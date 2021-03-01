# frozen_string_literal: true

RSpec.shared_examples 'search query applies joins based on migrations shared examples' do |migration_name|
  context 'using joins for global permission checks', :elastic do
    let(:es_host) { Gitlab::CurrentSettings.elasticsearch_url[0] }
    let(:search_url) { Addressable::Template.new("#{es_host}/{index}/doc/_search{?params*}") }

    context "when #{migration_name} migration is finished" do
      before do
        allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
                                                  .with(migration_name)
                                                  .and_return(true)
      end

      it 'does not use joins to apply permissions' do
        request = a_request(:get, search_url).with do |req|
          expect(req.body).not_to include("has_parent")
        end

        results

        expect(request).to have_been_made
      end
    end

    context "when #{migration_name} migration is not finished" do
      before do
        allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
                                                  .with(migration_name)
                                                  .and_return(false)
      end

      it 'uses joins to apply permissions' do
        request = a_request(:get, search_url).with do |req|
          expect(req.body).to include("has_parent")
        end

        results

        expect(request).to have_been_made
      end
    end
  end
end
