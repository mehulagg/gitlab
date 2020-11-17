import { mount } from '@vue/test-utils';
import { GlDatepicker } from '@gitlab/ui';
import { member } from 'jest/vue_shared/components/members/mock_data';
import ExpirationDatepicker from '~/vue_shared/components/members/table/expiration_datepicker.vue';

describe('ExpirationDatepicker', () => {
  let wrapper;

  const createComponent = (propsData = {}) => {
    wrapper = mount(ExpirationDatepicker, {
      propsData,
    });
  };

  const findDatepicker = () => wrapper.find(GlDatepicker);

  afterEach(() => {
    wrapper.destroy();
  });

  it.each`
    canOverride | isOverridden | expected
    ${true}     | ${true}      | ${false}
    ${true}     | ${false}     | ${true}
    ${false}    | ${false}     | ${false}
  `(
    'sets `disabled` prop to $expected when `canOverride` is $canOverride and `member.isOverridden` is $isOverridden',
    ({ canOverride, isOverridden, expected }) => {
      createComponent({
        permissions: {
          canUpdate: true,
          canOverride,
        },
        member: { ...member, isOverridden },
      });

      expect(findDatepicker().props('disabled')).toBe(expected);
    },
  );
});
