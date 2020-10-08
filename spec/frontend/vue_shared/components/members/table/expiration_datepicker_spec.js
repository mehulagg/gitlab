import { mount } from '@vue/test-utils';
import { GlFormInput, GlDatepicker } from '@gitlab/ui';
import { useFakeDate } from 'helpers/fake_date';
import ExpirationDatepicker from '~/vue_shared/components/members/table/expiration_datepicker.vue';

describe('ExpirationDatepicker', () => {
  let wrapper;

  const createComponent = propsData => {
    wrapper = mount(ExpirationDatepicker, {
      propsData,
    });
  };

  const findInput = () => wrapper.find(GlFormInput);
  const findDatepicker = () => wrapper.find(GlDatepicker);

  describe('datepicker input', () => {
    it('sets `initialDate` prop as date', () => {
      createComponent({ initialDate: '2020-10-09T00:00:00.000-07:00' });

      expect(findInput().element.value).toBe('2020-10-09');
    });

    it('sets placeholder', () => {
      expect(findInput().attributes('placeholder')).toBe('Expiration date');
    });

    it('disables autocomplete to prevent overlapping popups', () => {
      expect(findInput().attributes('autocomplete')).toBe('off');
    });
  });

  it('sets first selectable date as tomorrow', () => {
    // March 15th, 2020 3:00
    useFakeDate(2020, 2, 15, 3);

    createComponent();

    expect(
      findDatepicker()
        .props('minDate')
        .toISOString(),
    ).toBe(new Date('2020-3-16').toISOString());
  });

  it('sets `target` prop as `null` so datepicker opens on focus', () => {
    expect(findDatepicker().props('target')).toBe(null);
  });

  it("sets `container` prop as `null` so table styles don't affect the datepicker styles", () => {
    expect(findDatepicker().props('container')).toBe(null);
  });
});
