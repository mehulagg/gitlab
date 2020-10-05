import { mount } from '@vue/test-utils';
import SecuritySummary from 'ee/vue_shared/security_reports/components/security_summary.vue';

describe('Severity Summary', () => {
  let wrapper;

  const createWrapper = message => {
    wrapper = mount({
      components: {
        SecuritySummary,
      },
      data() {
        return {
          message,
        };
      },
      template: `<div><security-summary :message="message" /></div>`,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.each([
    '',
    'foo',
    '%{criticalStart}1 critical%{criticalEnd}',
    '%{highStart}1 high%{highEnd}',
    '%{criticalStart}1 critical%{criticalEnd} and %{highStart}2 high%{highEnd}',
  ])('given the message %p', message => {
    beforeEach(() => {
      createWrapper(message);
    });

    it('interpolates correctly', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });
});
