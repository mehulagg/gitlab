import { shallowMount } from '@vue/test-utils';
import { GlDaterangePicker } from '@gitlab/ui';

import DateRangeField from 'ee/audit_events/components/date_range_field.vue';
import { parsePikadayDate } from '~/lib/utils/datetime_utility';

describe('DateRangeField component', () => {
  let wrapper;

  const startDate = parsePikadayDate('2020-03-13');
  const endDate = parsePikadayDate('2020-03-14');

  const createComponent = (props = {}) => {
    wrapper = shallowMount(DateRangeField, {
      propsData: { ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('passes the startDate to the date picker as defaultStartDate', () => {
    createComponent({ startDate });

    expect(wrapper.find(GlDaterangePicker).props()).toMatchObject({
      defaultStartDate: startDate,
      defaultEndDate: null,
    });
  });

  it('passes the endDate to the date picker as defaultEndDate', () => {
    createComponent({ endDate });

    expect(wrapper.find(GlDaterangePicker).props()).toMatchObject({
      defaultStartDate: null,
      defaultEndDate: endDate,
    });
  });

  it('passes both startDate and endDate to the date picker as default dates', () => {
    createComponent({ startDate, endDate });

    expect(wrapper.find(GlDaterangePicker).props()).toMatchObject({
      defaultStartDate: startDate,
      defaultEndDate: endDate,
    });
  });

  it('should emit the "selected" event with startDate and endDate on input change', () => {
    createComponent();
    wrapper.find(GlDaterangePicker).vm.$emit('input', { startDate, endDate });

    return wrapper.vm.$nextTick(() => {
      expect(wrapper.emitted().selected).toBeTruthy();
      expect(wrapper.emitted().selected[0]).toEqual([
        {
          startDate,
          endDate,
        },
      ]);
    });
  });
});
