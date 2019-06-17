require 'spec_helper'

describe Gitlab::Geo::FileTransfer do
  let(:user) { create(:user, avatar: fixture_file_upload('spec/fixtures/dk.png', 'image/png')) }
  let(:upload) { Upload.find_by(model: user, uploader: 'AvatarUploader') }

  subject { described_class.new(:file, upload) }

  describe '#execute' do
    context 'user avatar' do
      it 'sets an absolute path' do
        expect(subject.file_type).to eq(:file)
        expect(subject.file_id).to eq(upload.id)
        expect(subject.filename).to eq(upload.absolute_path)
        expect(Pathname.new(subject.filename).absolute?).to be_truthy
        expect(subject.request_data).to eq({ id: upload.model_id,
                                             type: 'User',
                                             checksum: upload.checksum,
                                             file_id: upload.id,
                                             file_type: :file })
      end
    end
  end
end
