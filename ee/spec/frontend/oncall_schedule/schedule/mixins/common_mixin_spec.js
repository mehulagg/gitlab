import { shallowMount } from '@vue/test-utils';
import CommonMixin from 'ee/oncall_schedules/components/schedule/mixins/common_mixin';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { DAYS_IN_WEEK } from 'ee/oncall_schedules/components/schedule/constants';

describe('Schedule Common Mixins', () => {
  let wrapper;
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

  beforeEach(() => {
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

    wrapper = shallowMount(component, {
      propsData: {
        timeframeItem: mockTimeframeInitialDate,
      },
      data() {
        return {
          currentDate: new Date(),
        };
      },
    });
  });

  describe('data', () => {
    it('initializes currentDate default value', () => {
      const currentDate = new Date();
      expect(wrapper.vm.currentDate.getDate()).toBe(currentDate.getDate());
      expect(wrapper.vm.currentDate.getMonth()).toBe(currentDate.getMonth());
      expect(wrapper.vm.currentDate.getFullYear()).toBe(currentDate.getFullYear());
    });
  });
  describe('hasToday', () => {
    it('returns true when currentDate is within current week', async () => {
      await wrapper.setData({
        currentDate: mockTimeframeWeeks[0],
      });

      expect(wrapper.vm.hasToday).toBe(true);
    });

    it('returns false when currentDate is NOT within current week', async () => {
      await wrapper.setData({
        currentDate: mockTimeframeWeeks[1],
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
