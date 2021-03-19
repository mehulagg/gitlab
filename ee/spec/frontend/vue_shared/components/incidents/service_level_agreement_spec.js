import { shallowMount } from '@vue/test-utils';
import ServiceLevelAgreementCell from 'ee/vue_shared/components/incidents/service_level_agreement.vue';
import { calculateRemainingMilliseconds, formatTime } from '~/lib/utils/datetime_utility';

jest.mock('~/lib/utils/datetime_utility', () => ({
  calculateRemainingMilliseconds: jest.fn(() => 1000),
  formatTime: jest.fn(() => '00:00:00'),
}));

const mockDateString = '2020-10-15T02:42:27Z';

describe('Incidents Published Cell', () => {
  let wrapper;

  function mountComponent(props) {
    wrapper = shallowMount(ServiceLevelAgreementCell, {
      propsData: {
        ...props,
      },
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe('Service Level Agreement Cell', () => {
    it('renders an empty cell by default', () => {
      mountComponent();
      expect(wrapper.html()).toBe('');
    });

    it('renders a empty cell for an invalid date', () => {
      mountComponent({ slaDueAt: 'dfsgsdfg' });
      expect(wrapper.html()).toBe('');
    });

    it('displays the correct time when displaying an SLA', () => {
      formatTime.mockImplementation(() => '12:34:56');

      mountComponent({ slaDueAt: mockDateString });

      expect(wrapper.text()).toBe('12:34');
    });

    describe('tooltips', () => {
      const hoursInMilliseconds = 60 * 60 * 1000;
      const minutesInMilliseconds = 60 * 1000;

      it.each`
        hours | minutes | expectedMessage
        ${5}  | ${7}    | ${'5 hours, 7 minutes remaining'}
        ${5}  | ${0}    | ${'5 hours, 0 minutes remaining'}
        ${0}  | ${7}    | ${'7 minutes remaining'}
        ${0}  | ${0}    | ${'0 minutes remaining'}
      `(
        'returns the correct message for: hours: "$hours", hinutes: "$minutes"',
        ({ hours, minutes, expectedMessage }) => {
          const testTime = hours * hoursInMilliseconds + minutes * minutesInMilliseconds;
          calculateRemainingMilliseconds.mockImplementation(() => testTime);

          mountComponent({ slaDueAt: mockDateString });

          expect(wrapper.attributes('title')).toBe(expectedMessage);
        },
      );
    });
  });
});
