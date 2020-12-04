import { shallowMount, createLocalVue } from '@vue/test-utils';
import DownloadTestCoverage from 'ee/analytics/repository_analytics/components/download_test_coverage.vue';
import GroupRepositoryAnalytics from 'ee/analytics/repository_analytics/components/group_repository_analytics.vue';

const localVue = createLocalVue();

describe('Group repository analytics app', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(GroupRepositoryAnalytics, { localVue });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('test coverage', () => {
    it('renders test coverage header', () => {
      const header = wrapper.find('[data-testid="test-coverage-header"]');

      expect(header.exists()).toBe(true);
    });

    it('renders the download test coverage component', () => {
      expect(wrapper.find(DownloadTestCoverage).exists()).toBe(true);
    });
  });
});
