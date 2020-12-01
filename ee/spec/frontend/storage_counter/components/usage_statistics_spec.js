import { GlButton, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import UsageStatistics from 'ee/storage_counter/components/usage_statistics.vue';
import UsageStatisticsCard from 'ee/storage_counter/components/usage_statistics_card.vue';
import { withRootStorageStatistics } from '../mock_data';

describe('Usage Statistics component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(UsageStatistics, {
      propsData: {
        rootStorageStatistics: {
          totalRepositorySize: withRootStorageStatistics.totalRepositorySize,
          actualRepositorySizeLimit: withRootStorageStatistics.actualRepositorySizeLimit,
          totalRepositorySizeExcess: withRootStorageStatistics.totalRepositorySizeExcess,
          additionalPurchasedStorageSize: withRootStorageStatistics.additionalPurchasedStorageSize,
        },
        ...props,
      },
      stubs: {
        UsageStatisticsCard,
        GlSprintf,
      },
    });
  };

  const getStatisticsCards = () => wrapper.findAll(UsageStatisticsCard);
  const getStatisticsCard = testId => wrapper.find(`[data-testid="${testId}"]`);

  describe('with purchaseStorageUrl passed', () => {
    beforeEach(() => {
      createComponent({
        purchaseStorageUrl: 'some-fancy-url',
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders three statistics cards', () => {
      expect(getStatisticsCards()).toHaveLength(3);
    });

    it('renders text in total usage card footer', () => {
      expect(
        getStatisticsCard('totalUsage')
          .find('[data-testid="statisticsCardFooter"]')
          .text(),
      ).toMatchInterpolatedText(
        'This is the total amount of storage used across your projects within this namespace.',
      );
    });

    it('renders text in excess usage card footer', () => {
      expect(
        getStatisticsCard('excessUsage')
          .find('[data-testid="statisticsCardFooter"]')
          .text(),
      ).toMatchInterpolatedText(
        'This is the total amount of storage used by projects above the free 978.8KiB storage limit.',
      );
    });

    it('renders button in purchased usage card footer', () => {
      expect(
        getStatisticsCard('purchasedUsage')
          .find(GlButton)
          .exists(),
      ).toBe(true);
    });
  });

  describe('with no purchaseStorageUrl', () => {
    beforeEach(() => {
      createComponent({
        purchaseStorageUrl: null,
      });
    });
    it('does not render purchased usage card if purchaseStorageUrl is not provided', () => {
      expect(getStatisticsCard('purchasedUsage').exists()).toBe(false);
    });
  });
});
