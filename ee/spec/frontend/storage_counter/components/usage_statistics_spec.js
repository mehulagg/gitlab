import { shallowMount } from '@vue/test-utils';
import { GlButton, GlLink } from '@gitlab/ui';
import UsageStatistics from 'ee/storage_counter/components/usage_statistics.vue';
import UsageStatisticsCard from 'ee/storage_counter/components/usage_statistics_card.vue';
import { withRootStorageStatistics } from '../mock_data';

describe('Usage Statistics component', () => {
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

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders three statistics cards', () => {
    expect(getStatisticsCards()).toHaveLength(3);
  });

  it.each`
    cardName            | componentName | componentType
    ${'totalUsage'}     | ${'GlLink'}   | ${GlLink}
    ${'excessUsage'}    | ${'GlLink'}   | ${GlLink}
    ${'purchasedUsage'} | ${'GlButton'} | ${GlButton}
  `('renders $componentName in $cardName', ({ cardName, componentType }) => {
    expect(
      getStatisticsCard(cardName)
        .find(componentType)
        .exists(),
    ).toBe(true);
  });
});
