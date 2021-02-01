import { GlFormCheckbox } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AlertFilters from 'ee/threat_monitoring/components/alerts/alert_filters.vue';
import { DEFAULT_FILTERS } from 'ee/threat_monitoring/components/alerts/constants';

describe('AlertFilters component', () => {
  let wrapper;

  const findGlFormCheckbox = () => wrapper.find(GlFormCheckbox);

  const createWrapper = () => {
    wrapper = shallowMount(AlertFilters);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    it('"hide dismissed checkbox" is checked', () => {
      createWrapper();
      const checkbox = findGlFormCheckbox();
      expect(checkbox.exists()).toBe(true);
      expect(checkbox.attributes('checked')).toBeTruthy();
    });
  });

  describe('dismissed alerts filter', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('emits an event with no filters on filter deselect', async () => {
      const checkbox = findGlFormCheckbox();
      checkbox.vm.$emit('change', false);
      await wrapper.vm.$nextTick();
      expect(wrapper.emitted('filter-change')).toEqual([[{}]]);
    });

    it('emits an event with the default filters on filter select', async () => {
      const checkbox = findGlFormCheckbox();
      checkbox.vm.$emit('change', true);
      await wrapper.vm.$nextTick();
      expect(wrapper.emitted('filter-change')).toEqual([[DEFAULT_FILTERS]]);
    });
  });
});
