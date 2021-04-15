import { GlEmptyState, GlTable } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import SubscriptionsList from '~/jira_connect/components/subscriptions_list.vue';
import { mockSubscription } from '../mock_data';

describe('SubscriptionsList', () => {
  let wrapper;

  const createComponent = ({ provide = {} } = {}) => {
    wrapper = shallowMount(SubscriptionsList, {
      provide,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGlEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findGlTable = () => wrapper.findComponent(GlTable);

  describe('template', () => {
    it('renders GlEmptyState when subscriptions is empty', () => {
      createComponent();

      expect(findGlEmptyState().exists()).toBe(true);
      expect(findGlTable().exists()).toBe(false);
    });

    it('renders GlTable when subscriptions are present', () => {
      createComponent({
        provide: {
          subscriptions: [mockSubscription],
        },
      });

      expect(findGlEmptyState().exists()).toBe(false);
      expect(findGlTable().exists()).toBe(true);
    });
  });
});
