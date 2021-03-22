import { GlFormCheckbox, GlSearchBoxByType } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AlertFilters from 'ee/threat_monitoring/components/alerts/alert_filters.vue';
import { DEFAULT_FILTERS } from 'ee/threat_monitoring/components/alerts/constants';

describe('AlertFilters component', () => {
  let wrapper;

  const findGlFormCheckbox = () => wrapper.find(GlFormCheckbox);
  const findGlSearch = () => wrapper.find(GlSearchBoxByType);

  const createWrapper = (filters = DEFAULT_FILTERS) => {
    wrapper = shallowMount(AlertFilters, { propsData: { filters } });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('Policy Name Filter', () => {
    beforeEach(() => {
      createWrapper();
    });

    describe('default state', () => {
      it('shows policy name search box', () => {
        const search = findGlSearch();
        expect(search.exists()).toBe(true);
        expect(search.attributes('value')).toBe('');
      });

      it('does emit an event with a user-defined string', async () => {
        const searchTerm = 'abc';
        const search = findGlSearch();
        search.vm.$emit('input', searchTerm);
        await wrapper.vm.$nextTick();
        expect(wrapper.emitted('filter-change')).toStrictEqual([
          [{ ...DEFAULT_FILTERS, searchTerm }],
        ]);
      });
    });
  });

  describe('Hide Dismissed Filter', () => {
    describe('default state', () => {
      it('"hide dismissed checkbox" is checked', () => {
        createWrapper();
        const checkbox = findGlFormCheckbox();
        expect(checkbox.exists()).toBe(true);
        expect(checkbox.attributes('checked')).toBeTruthy();
      });
    });

    describe('dismissed alerts filter', () => {
      it('emits an event with no filters on filter deselect', async () => {
        createWrapper();
        const checkbox = findGlFormCheckbox();
        checkbox.vm.$emit('change', false);
        await wrapper.vm.$nextTick();
        expect(wrapper.emitted('filter-change')).toStrictEqual([[{ statuses: [] }]]);
      });

      it('emits an event with the default filters on filter select', async () => {
        createWrapper({});
        const checkbox = findGlFormCheckbox();
        checkbox.vm.$emit('change', true);
        await wrapper.vm.$nextTick();
        expect(wrapper.emitted('filter-change')).toEqual([[DEFAULT_FILTERS]]);
      });
    });
  });
});
