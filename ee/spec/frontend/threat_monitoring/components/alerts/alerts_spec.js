import { shallowMount } from '@vue/test-utils';
import Alerts from 'ee/threat_monitoring/components/alerts/alerts.vue';
import AlertFilters from 'ee/threat_monitoring/components/alerts/alert_filters.vue';
import AlertsList from 'ee/threat_monitoring/components/alerts/alerts_list.vue';
import { DEFAULT_FILTERS } from 'ee/threat_monitoring/components/alerts/constants';

describe('Alerts component', () => {
  let wrapper;

  const findAlertFilters = () => wrapper.find(AlertFilters);
  const findAlertsList = () => wrapper.find(AlertsList);

  const createWrapper = () => {
    wrapper = shallowMount(Alerts);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('shows threat monitoring alert filters', () => {
      expect(findAlertFilters().exists()).toBe(true);
    });

    it('shows threat monitoring alerts list', () => {
      expect(findAlertsList().exists()).toBe(true);
    });

    it('does have the default filters initially', () => {
      expect(wrapper.vm.filters).toBe(DEFAULT_FILTERS);
    });

    it('does update its filters on filter event emitted', async () => {
      expect(wrapper.vm.filters).toBe(DEFAULT_FILTERS);
      findAlertFilters().vm.$emit('filter-change', {});
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.filters).toBe({});
    });
  });
});
