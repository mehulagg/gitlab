import { shallowMount } from '@vue/test-utils';
import SidebarJobDetailsContainer from '~/jobs/components/sidebar_job_details_container.vue';
import DetailRow from '~/jobs/components/sidebar_detail_row.vue';
import createStore from '~/jobs/store';
import { extendedWrapper } from '../../helpers/vue_test_utils_helper';
import job from '../mock_data';

describe('Sidebar Job Details Container', () => {
  let store;
  let wrapper;

  const findJobTimeout = () => wrapper.findByTestId('job-timeout');
  const findAllDetailsRow = () => wrapper.findAll(DetailRow);

  const createWrapper = ({ props = {} } = {}) => {
    store = createStore();
    wrapper = extendedWrapper(
      shallowMount(SidebarJobDetailsContainer, {
        propsData: props,
        store,
        stubs: {
          DetailRow,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when no details are available', () => {
    it('should render an empty container', () => {
      createWrapper();

      expect(wrapper.isEmpty()).toBe(true);
    });
  });

  describe('when some of the details are available', () => {
    beforeEach(createWrapper);

    it.each([
      ['duration', 'duration', 'Duration: 6 seconds', 1],
      ['erased_at', 'erased', 'Erased: 3 weeks ago', 1],
      ['finished_at', 'finished', 'Finished: 3 weeks ago', 1],
      ['queued', 'queued', 'Queued: 9 seconds', 1],
      ['runner', 'runner', 'Runner: local ci runner (#1)', 1],
      ['coverage', 'coverage', 'Coverage: 20%', 1],
      ['tags', 'tags', 'Tags: tag', 0],
    ])('uses %s to render job-%s', async (detail, testIdPart, value, remaining) => {
      await store.dispatch('receiveJobSuccess', { [detail]: value });

      expect(wrapper.isEmpty()).toBe(false);
      expect(findAllDetailsRow()).toHaveLength(remaining);
      expect(wrapper.findByTestId(`job-${testIdPart}`).exists()).toBe(true);
    });

    it('uses metadata to render timeout', async () => {
      await store.dispatch('receiveJobSuccess', { metadata: { timeout_human_readable: '1m 40s' } });

      expect(wrapper.isEmpty()).toBe(false);
      expect(findAllDetailsRow()).toHaveLength(1);
      expect(wrapper.findByTestId(`job-timeout`).exists()).toBe(true);
    });
  });

  describe('when all the details are available', () => {
    beforeEach(() => {
      createWrapper();
      return store.dispatch('receiveJobSuccess', job);
    });

    it.each([
      ['duration', 'Duration: 6 seconds'],
      ['erased', 'Erased: 3 weeks ago'],
      ['finished', 'Finished: 3 weeks ago'],
      ['queued', 'Queued: 9 seconds'],
      ['runner', 'Runner: local ci runner (#1)'],
      ['timeout', 'Timeout: 1m 40s (from runner)'],
      ['coverage', 'Coverage: 20%'],
      ['tags', 'Tags: tag'],
    ])('does render %s', (testIdPart, text) => {
      expect(wrapper.isEmpty()).toBe(false);
      expect(wrapper.findByTestId(`job-${testIdPart}`).text()).toBe(text);
    });

    it('should pass the help URL', async () => {
      const helpUrl = 'fakeUrl';
      const props = {
        runnerHelpUrl: helpUrl,
      };
      createWrapper({ props });
      await store.dispatch('receiveJobSuccess', job);
      expect(findJobTimeout().props('helpUrl')).toBe(helpUrl);
    });
  });
});
