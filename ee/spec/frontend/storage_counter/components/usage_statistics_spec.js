import { shallowMount } from '@vue/test-utils';
import { GlButton, GlLink } from '@gitlab/ui';
import UsageStatistics from 'ee/storage_counter/components/usage_statistics.vue';
import UsageStatisticsCard from 'ee/storage_counter/components/usage_statistics_card.vue';
import { withRootStorageStatistics } from '../mock_data';

let wrapper;

const createComponent = () => {
  wrapper = shallowMount(UsageStatistics, {
    propsData: {
      rootStorageStatistics: withRootStorageStatistics.rootStorageStatistics,
    },
    stubs: {
      UsageStatisticsCard,
      GlLink,
    },
  });
};

const getStatisticsCards = () => wrapper.findAll(UsageStatisticsCard);
const getStatisticsCard = testId => wrapper.find(`[data-testid="${testId}"]`);

describe('Usage Statistics component', () => {
  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders three statistics cards', () => {
    expect(getStatisticsCards()).toHaveLength(3);
  });

  it('renders link in total usage', () => {
    expect(
      getStatisticsCard('totalUsage')
        .find(GlLink)
        .exists(),
    ).toBe(true);
  });

  it('renders link in excess usage', () => {
    expect(
      getStatisticsCard('excessUsage')
        .find(GlLink)
        .exists(),
    ).toBe(true);
  });

  it('renders button in purchased usage', () => {
    expect(
      getStatisticsCard('purchasedUsage')
        .find(GlButton)
        .exists(),
    ).toBe(true);
  });
});
