# frozen_string_literal: true

RSpec.shared_examples 'PyPi package creation' do |user_type, status, add_member = true|
  RSpec.shared_examples 'creating pypi package files' do
    it 'creates package files' do
      expect { subject }
          .to change { project.packages.pypi.count }.by(1)
          .and change { Packages::PackageFile.count }.by(1)
          .and change { Packages::PypiMetadatum.count }.by(1)
      expect(response).to have_gitlab_http_status(status)

      package = project.reload.packages.pypi.last

      expect(package.name).to eq params[:name]
      expect(package.version).to eq params[:version]
      expect(package.pypi_metadatum.required_python).to eq params[:requires_python]
    end
  end

  context "for user type #{user_type}" do
    before do
      project.send("add_#{user_type}", user) if add_member && user_type != :anonymous
    end

    it_behaves_like 'creating pypi package files'

    context 'with object storage disabled' do
      before do
        stub_package_file_object_storage(enabled: false)
      end

      context 'without a file from workhorse' do
        let(:send_rewritten_field) { false }

        it_behaves_like 'returning response status', :bad_request
      end

      context 'with correct params' do
        it_behaves_like 'package workhorse uploads'
        it_behaves_like 'creating pypi package files'
      end
    end

    context 'with object storage enabled' do
      let(:tmp_object) do
        fog_connection.directories.new(key: 'packages').files.create(
          key: "tmp/uploads/#{file_name}",
          body: 'content'
        )
      end
      let(:fog_file) { fog_to_uploaded_file(tmp_object) }
      let(:params) { base_params.merge(content: fog_file, 'content.remote_id' => file_name) }

      context 'and direct upload enabled' do
        let(:fog_connection) do
          stub_package_file_object_storage(direct_upload: true)
        end

        it_behaves_like 'creating pypi package files'

        ['123123', '../../123123'].each do |remote_id|
          context "with invalid remote_id: #{remote_id}" do
            let(:params) { base_params.merge(content: fog_file, 'content.remote_id' => remote_id) }

            it_behaves_like 'returning response status', :forbidden
          end
        end
      end

      context 'and direct upload disabled' do
        context 'and background upload disabled' do
          let(:fog_connection) do
            stub_package_file_object_storage(direct_upload: false, background_upload: false)
          end

          it_behaves_like 'creating pypi package files'
        end

        context 'and background upload enabled' do
          let(:fog_connection) do
            stub_package_file_object_storage(direct_upload: false, background_upload: true)
          end

          it_behaves_like 'creating pypi package files'
        end
      end
    end

    it_behaves_like 'background upload schedules a file migration'
  end
end

RSpec.shared_examples 'process PyPi api request' do |user_type, status, add_member = true|
  context "for user type #{user_type}" do
    before do
      project.send("add_#{user_type}", user) if add_member && user_type != :anonymous
    end

    it_behaves_like 'returning response status', status
  end
end

RSpec.shared_examples 'rejects PyPI access with unknown project id' do
  context 'with an unknown project' do
    let(:project) { OpenStruct.new(id: 1234567890) }

    context 'as anonymous' do
      it_behaves_like 'process PyPi api request', :anonymous, :unauthorized
    end

    context 'as authenticated user' do
      subject { get api(url), headers: build_basic_auth_header(user.username, personal_access_token.token) }

      it_behaves_like 'process PyPi api request', :anonymous, :not_found
    end
  end
end

RSpec.shared_examples 'rejects PyPI packages access with packages features disabled' do
  context 'with packages features disabled' do
    before do
      stub_licensed_features(packages: false)
    end

    it_behaves_like 'process PyPi api request', :anonymous, :forbidden
  end
end
