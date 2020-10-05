import { shallowMount } from '@vue/test-utils';
import PageWrapper from '~/vue_shared/components/page_wrapper/page_wrapper.vue';
import Tracking from '~/tracking';

describe('AlertManagementEmptyState', () => {
  let wrapper;

  function mountComponent({ props = {} } = {}) {
    wrapper = shallowMount(PageWrapper, {
      propsData: {
        ...props,
      },
    });
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('Snowplow tracking', () => {
    beforeEach(() => {
      jest.spyOn(Tracking, 'event');
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts } },
      });
    });

    it('should track alert list page views', () => {
      const { category, action } = trackAlertListViewsOptions;
      expect(Tracking.event).toHaveBeenCalledWith(category, action);
    });
  });

  describe('Empty state', () => {
    it('renders the empty state if there are no items present', () => {});

    it('renders the tabs selection', () => {});

    it('renders the header action buttons if present', () => {});

    it('renders a error alert if there are errors', () => {});

    it('renders a table of items if items are present', () => {});

    it('renders pagination if there items present in the table', () => {});
  });
});
