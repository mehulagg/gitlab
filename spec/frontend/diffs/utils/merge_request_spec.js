import { getDerivedMergeRequestInformation } from '~/diffs/utils/merge_request';
import { diffMetadata } from '../mock_data/diff_metadata';

describe('Merge Request utilities', () => {
  const derivedMrInfo = {
    mrPath: 'gitlab-org/gitlab-test/-/merge_requests/4',
    userOrGroup: 'gitlab-org',
    project: 'gitlab-test',
    id: '4',
  };

  describe('getDerivedMergeRequestInformation', () => {
    const endpoint = `${diffMetadata.latest_version_path}.json?searchParam=irrelevant`;

    it('generates the correct MR path based on the endpoint', () => {
      expect(getDerivedMergeRequestInformation({ endpoint })).toStrictEqual(derivedMrInfo);
    });
  });
});
