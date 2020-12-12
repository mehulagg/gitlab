import { shallowMount } from '@vue/test-utils';
import CommonMixin from 'ee/oncall_schedules/components/schedule/mixins/common_mixin';
import { DAYS_IN_WEEK } from 'ee/oncall_schedules/components/schedule/constants';
import { useFakeDate } from 'helpers/fake_date';

describe('Schedule Common Mixins', () => {
  // January 3rd, 2018
  useFakeDate(2018, 0, 3);
  const today = new Date();

  let wrapper;

  const component = {
    template: `<span></span>`,
    props: {
      timeframeItem: {
        type: [Date, Object],
        required: true,
      },
    },
    mixins: [CommonMixin],
  };

  const mountComponent = (props = {}) => {
    wrapper = shallowMount(component, {
      propsData: {
        timeframeItem: today,
        ...props,
      },
    });
  };

  describe('data', () => {
    it('initializes currentDate default value', () => {
      mountComponent();

      expect(wrapper.vm.$options.currentDate).toEqual(today);
    });
  });
  describe('hasToday', () => {
    it('returns true when today (January 3rd, 2018) is within the set week (January 1st, 2018)', () => {
      // January 1st, 2018
      mountComponent({
        timeframeItem: new Date(2018, 0, 1),
      });

      expect(wrapper.vm.hasToday).toBe(true);
    });

    it('returns false when today (January 3rd, 2018) is NOT within the set week (January 8th, 2018)', () => {
      // February 1st, 2018
      mountComponent({
        timeframeItem: new Date(2018, 0, 8),
      });

      expect(wrapper.vm.hasToday).toBe(false);
    });
  });

  describe('getIndicatorStyles', () => {
    it('returns object containing `left` offset', () => {
      const left = 100 / DAYS_IN_WEEK / 2;
      expect(wrapper.vm.getIndicatorStyles()).toEqual(
        expect.objectContaining({
          left: `${left}%`,
        }),
      );
    });
  });
});
