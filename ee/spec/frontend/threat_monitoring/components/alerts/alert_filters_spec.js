import AlertFilters from 'ee/threat_monitoring/components/alerts/alert_filters.vue';
import { DEFAULT_FILTERS } from 'ee/threat_monitoring/components/alerts/constants';
import { GlFormCheckbox } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

describe('AlertFilters component', () => {
  let wrapper;

  const defaultProps = { filters: DEFAULT_FILTERS };
  const findGlFormCheckbox = () => wrapper.find(GlFormCheckbox);

  const createWrapper = ({ data = {}, props = defaultProps } = {}) => {
    wrapper = shallowMount(AlertFilters, {
      propsData: props,
      data() {
        return data;
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('does show the checked, hide dismissed alerts checkbox', () => {
      const checkbox = findGlFormCheckbox();
      expect(checkbox.exists()).toBe(true);
      expect(checkbox.attributes('checked')).toBeTruthy();
    });

    it('does emit an event with no filters on filter deselect', async () => {
      findGlFormCheckbox().vm.$emit('change');
      await wrapper.vm.$nextTick();
      const checkbox = findGlFormCheckbox();
      expect(checkbox.attributes('checked')).toBeFalsy();
      expect(wrapper.emitted('filter-change')).toEqual([[{}]]);
    });
  });

  describe('hiding dismissed alerts', () => {
    beforeEach(() => {
      createWrapper({ data: { filterDismissed: false }, props: { filters: {} } });
    });

    it('does emit an event with the default filters on filter select', async () => {
      const checkbox = findGlFormCheckbox();
      expect(checkbox.attributes('checked')).toBeFalsy();
      findGlFormCheckbox().vm.$emit('change');
      await wrapper.vm.$nextTick();
      expect(checkbox.attributes('checked')).toBeTruthy();
      expect(wrapper.emitted('filter-change')).toEqual([[DEFAULT_FILTERS]]);
    });
  });
});
