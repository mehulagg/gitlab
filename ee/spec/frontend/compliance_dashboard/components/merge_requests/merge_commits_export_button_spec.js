import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';

import MergeCommitsExportButton from 'ee/compliance_dashboard/components/merge_requests/merge_commits_export_button.vue';

const CSV_EXPORT_PATH = '/merge_commit_reports';

describe('MergeCommitsExportButton component', () => {
  let wrapper;

  const findCsvExportButton = () => wrapper.find(GlButton);

  const createComponent = (props = {}) => {
    return shallowMount(MergeCommitsExportButton, {
      propsData: {
        mergeCommitsCsvExportPath: CSV_EXPORT_PATH,
        ...props,
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Merge commit CSV export button', () => {
    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders the merge commits csv export button', () => {
      expect(findCsvExportButton().exists()).toBe(true);
    });

    it('renders the export icon', () => {
      expect(findCsvExportButton().props('icon')).toBe('export');
    });

    it('links to the csv download path', () => {
      expect(findCsvExportButton().attributes('href')).toEqual(CSV_EXPORT_PATH);
    });
  });
});
