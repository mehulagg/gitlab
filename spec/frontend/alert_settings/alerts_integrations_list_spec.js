import { GlTable } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Tracking from '~/tracking';
import AlertIntegrationsList, {
  i18n,
} from '~/alerts_settings/components/alerts_integrations_list.vue';
import { trackAlertIntergrationsViewsOptions } from '~/alerts_settings/constants';

const mockIntegrations = [
  {
    status: true,
    name: 'Integration 1',
    type: 'HTTP endpoint',
  },
  {
    status: false,
    name: 'Integration 2',
    type: 'HTTP endpoint',
  },
];

describe('AlertIntegrationsList', () => {
  let wrapper;

  function mountComponent(propsData = {}) {
    wrapper = shallowMount(AlertIntegrationsList, {
      propsData: {
        integrations: mockIntegrations,
        ...propsData,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  beforeEach(() => {
    mountComponent();
  });

  const findTableComponent = () => wrapper.find(GlTable);

  it('renders a table', () => {
    expect(findTableComponent().exists()).toBe(true);
    expect(findTableComponent().attributes('empty-text')).toBe(i18n.emptyState);
  });

  describe('Snowplow tracking', () => {
    beforeEach(() => {
      jest.spyOn(Tracking, 'event');
      mountComponent();
    });

    it('should track alert list page views', () => {
      const { category, action } = trackAlertIntergrationsViewsOptions;
      expect(Tracking.event).toHaveBeenCalledWith(category, action);
    });
  });
});
