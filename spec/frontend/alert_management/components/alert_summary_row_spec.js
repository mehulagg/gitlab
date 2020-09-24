import { shallowMount } from '@vue/test-utils';
import AlertSummaryRow from '~/alert_management/components/alert_summary_row.vue';

describe('app/assets/javascripts/alert_management/components/alert_summary_row.vue', () => {
  let wrapper;

  function mountComponent({ mountMethod = shallowMount, props, defaultSlot } = {}) {
    wrapper = mountMethod(AlertSummaryRow, {
      propsData: props,
      scopedSlots: {
        default: defaultSlot,
      },
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('Alert Summary Row', () => {
    beforeEach(() => {
      mountComponent({
        props: {
          label: 'a label:',
        },
        defaultSlot: '<span class="value">a value</span>',
      });
    });

    it('should display a label and a value', () => {
      expect(
        wrapper
          // .findAll('div')
          // .at(0)
          .text(),
      ).toBe('a label: a value');
    });
  });
});
