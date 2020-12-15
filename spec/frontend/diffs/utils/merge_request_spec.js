import { getDerivedMergeRequestInformation } from '~/diffs/utils/merge_request';
import { diffMetadata } from '../mock_data/diff_metadata';

describe('Merge Request utilities', () => {
  describe('getDerivedMergeRequestInformation', () => {
    const endpoint = `${diffMetadata.latest_version_path}.json?searchParam=irrelevant`;
    const mrPath = diffMetadata.latest_version_path.replace(/\/diffs$/, '');

    it('generates the correct MR path based on the endpoint', () => {
      expect(getDerivedMergeRequestInformation({ endpoint })).toStrictEqual({ mrPath });
    });
  });
});
