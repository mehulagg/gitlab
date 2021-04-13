import { GlButton, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import UsageStatistics from 'ee/other_storage_counter/components/usage_statistics.vue';
import UsageStatisticsCard from 'ee/other_storage_counter/components/usage_statistics_card.vue';
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
        GlLink,
      },
    });
  };

  const getStatisticsCards = () => wrapper.findAll(UsageStatisticsCard);
  const getStatisticsCard = (testId) => wrapper.find(`[data-testid="${testId}"]`);
  const findGlLinkInCard = (cardName) =>
    getStatisticsCard(cardName).find('[data-testid="statistics-card-footer"]').find(GlLink);

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

    it('renders URL in total usage card footer', () => {
      const url = findGlLinkInCard('total-usage');

      expect(url.attributes('href')).toBe('/help/user/usage_quotas');
    });

    it('renders URL in excess usage card footer', () => {
      const url = findGlLinkInCard('excess-usage');

      expect(url.attributes('href')).toBe('/help/user/usage_quotas#excess-storage-usage');
    });

    it('renders button in purchased usage card footer', () => {
      expect(getStatisticsCard('purchased-usage').find(GlButton).exists()).toBe(true);
    });
  });

  describe('with no purchaseStorageUrl', () => {
    beforeEach(() => {
      createComponent({
        purchaseStorageUrl: null,
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('does not render purchased usage card if purchaseStorageUrl is not provided', () => {
      expect(getStatisticsCard('purchased-usage').exists()).toBe(false);
    });
  });
});
