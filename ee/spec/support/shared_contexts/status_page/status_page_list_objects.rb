# frozen_string_literal: true

RSpec.shared_context 'list_objects_v2 result' do
  let(:key_list_1) { ['key_prefix/1', 'key_prefix/2'] }
  let(:key_list_2) { ['key_prefix/3'] }

  before do
    # AWS s3 client responses for list_objects is paginated
    # stub_responses allows multiple responses as arguments and they will be returned in sequence
    stub_responses(
      :list_objects_v2,
      list_objects_data(key_list: key_list_1, next_continuation_token: '12345', is_truncated: true),
      list_objects_data(key_list: key_list_2, next_continuation_token: nil, is_truncated: false)
    )
  end
end

RSpec.shared_context 'oversized list_objects_v2 result' do
  let(:keys_page_1) { random_keys(desired_size: Gitlab::StatusPage::Storage::MAX_KEYS_PER_PAGE) }
  let(:keys_page_2) { random_keys(desired_size: Gitlab::StatusPage::Storage::MAX_KEYS_PER_PAGE) }

  before do
    stub_const("Gitlab::StatusPage::Storage::MAX_KEYS_PER_PAGE", 2)
    stub_const("Gitlab::StatusPage::Storage::MAX_PAGES", 1)
    stub_const("Gitlab::StatusPage::Storage::MAX_UPLOADS", Gitlab::StatusPage::Storage::MAX_PAGES * Gitlab::StatusPage::Storage::MAX_KEYS_PER_PAGE)
    # AWS s3 client responses for list_objects is paginated
    # stub_responses allows multiple responses as arguments and they will be returned in sequence
    stub_responses(
      :list_objects_v2,
      list_objects_data(key_list: keys_page_1, next_continuation_token: '12345', is_truncated: true),
      list_objects_data(key_list: keys_page_2, next_continuation_token: nil, is_truncated: true)
    )
  end

  def random_keys(desired_size:)
    (0...desired_size).to_a.map { |_| SecureRandom.hex }
  end
end

RSpec.shared_context 'no objects list_objects_v2 result' do
  let(:key_list_no_objects) { [] }

  before do
    stub_responses(
      :list_objects_v2,
      list_objects_data(key_list: key_list_no_objects, next_continuation_token: nil, is_truncated: false)
    )
  end
end
