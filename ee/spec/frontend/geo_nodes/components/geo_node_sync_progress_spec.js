import { GlPopover } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeSyncProgress from 'ee/geo_nodes/components/geo_node_sync_progress.vue';
import StackedProgressBar from '~/vue_shared/components/stacked_progress_bar.vue';

describe('GeoNodeSyncProgress', () => {
  let wrapper;

  const MOCK_ITEM_VALUE = { successCount: 5, failureCount: 3, totalCount: 10 };
  MOCK_ITEM_VALUE.queuedCount =
    MOCK_ITEM_VALUE.totalCount - MOCK_ITEM_VALUE.successCount - MOCK_ITEM_VALUE.failureCount;

  const defaultProps = {
    itemTitle: 'GitLab version',
    itemValue: MOCK_ITEM_VALUE,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(GeoNodeSyncProgress, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findStackedProgressBar = () => wrapper.find(StackedProgressBar);
  const findGlPopover = () => wrapper.find(GlPopover);
  const findCounts = () => findGlPopover().findAll('div');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders StackedProgressbar always', () => {
      expect(findStackedProgressBar().exists()).toBeTruthy();
    });

    describe('GlPopover', () => {
      it('renders always', () => {
        expect(findGlPopover().exists()).toBeTruthy();
      });

      it('renders each row of popover correctly', () => {
        findCounts().wrappers.forEach(row => {
          expect(row.element).toMatchSnapshot();
        });
      });
    });
  });

  describe('computed', () => {
    describe.each`
      itemValue                                                          | expectedItemValue
      ${{ successCount: 5, failureCount: 3, totalCount: 10 }}            | ${{ successCount: 5, failureCount: 3, totalCount: 10 }}
      ${{ successCount: '5', failureCount: '3', totalCount: '10' }}      | ${{ successCount: 5, failureCount: 3, totalCount: 10 }}
      ${{ successCount: null, failureCount: null, totalCount: null }}    | ${{ successCount: 0, failureCount: 0, totalCount: 0 }}
      ${{ successCount: 'abc', failureCount: 'def', totalCount: 'ghi' }} | ${{ successCount: 0, failureCount: 0, totalCount: 0 }}
    `(`status counts`, ({ itemValue, expectedItemValue }) => {
      beforeEach(() => {
        createComponent({ itemValue });
      });

      it(`when itemValue.totalCount is ${
        itemValue.totalCount
      } (${typeof itemValue.totalCount}), it should compute to ${
        expectedItemValue.totalCount
      }`, () => {
        expect(wrapper.vm.totalCount).toBe(expectedItemValue.totalCount);
      });

      it(`when itemValue.successCount is ${
        itemValue.successCount
      } (${typeof itemValue.successCount}), it should compute to ${
        expectedItemValue.successCount
      }`, () => {
        expect(wrapper.vm.successCount).toBe(expectedItemValue.successCount);
      });

      it(`when itemValue.failureCount is ${
        itemValue.failureCount
      } (${typeof itemValue.failureCount}), it should compute to ${
        expectedItemValue.failureCount
      }`, () => {
        expect(wrapper.vm.failureCount).toBe(expectedItemValue.failureCount);
      });
    });

    describe('queuedCount', () => {
      beforeEach(() => {
        createComponent();
      });

      it('returns total - success - failure', () => {
        expect(wrapper.vm.queuedCount).toEqual(MOCK_ITEM_VALUE.queuedCount);
      });
    });
  });
});
