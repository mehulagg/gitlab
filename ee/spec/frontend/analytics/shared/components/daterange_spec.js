import { mount } from '@vue/test-utils';
import Daterange from 'ee/analytics/shared/components/daterange.vue';
import { GlDaterangePicker } from '@gitlab/ui';

const defaultProps = {
  startDate: new Date(2019, 8, 1),
  endDate: new Date(2019, 8, 11),
};

describe('Daterange component', () => {
  let wrapper;

  const factory = (props = defaultProps) => {
    wrapper = mount(Daterange, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  beforeEach(() => {
    jest.spyOn(global.Date, 'now').mockImplementation(() => new Date('2019-09-25T00:00:00Z'));
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findDaterangePicker = () => wrapper.find(GlDaterangePicker);

  const findDateRangeIndicator = () => wrapper.find('.daterange-indicator');

  describe('template', () => {
    describe('when show is false', () => {
      it('does not render the daterange picker', () => {
        factory({ show: false });
        expect(findDaterangePicker().exists()).toBe(false);
      });
    });

    describe('when show is true', () => {
      it('renders the daterange picker', () => {
        factory({ show: true });
        expect(findDaterangePicker().exists()).toBe(true);
      });
    });

    describe('with a minDate being set', () => {
      it('emits the change event with the minDate when the user enters a start date before the minDate', () => {
        const startDate = new Date('2019-09-01');
        const endDate = new Date('2019-09-30');
        const minDate = new Date('2019-06-01');

        factory({ show: true, startDate, endDate, minDate });

        const input = findDaterangePicker().find('input');

        input.setValue('2019-01-01');
        input.trigger('change');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted().change).toEqual([[{ startDate: minDate, endDate }]]);
        });
      });
    });

    describe('with a maxDateRange being set', () => {
      beforeEach(() => {
        factory({ maxDateRange: 30 });
      });

      it('displays the max date range indicator', () => {
        expect(findDateRangeIndicator().exists()).toBe(true);
      });

      it('displays the correct number of selected days in the indicator', () => {
        expect(
          findDateRangeIndicator()
            .find('span')
            .text(),
        ).toBe('10 days');
      });
    });
  });

  describe('computed', () => {
    describe('dateRange', () => {
      beforeEach(() => {
        factory({ show: true });
      });

      describe('set', () => {
        it('emits the change event with an object containing startDate and endDate', () => {
          const startDate = new Date('2019-10-01');
          const endDate = new Date('2019-10-05');
          wrapper.vm.dateRange = { startDate, endDate };

          expect(wrapper.emitted().change).toEqual([[{ startDate, endDate }]]);
        });
      });

      describe('get', () => {
        it("returns value of dateRange from state's startDate and endDate", () => {
          expect(wrapper.vm.dateRange).toEqual({
            startDate: defaultProps.startDate,
            endDate: defaultProps.endDate,
          });
        });
      });
    });
  });
});
