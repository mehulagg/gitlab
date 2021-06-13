import { GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Cookie from 'js-cookie';
import QrtlyReconciliationAlert from 'ee/admin/components/qrtly_reconciliation_alert.vue';

jest.mock('js-cookie', () => ({
  set: jest.fn(),
}));

describe('Qrtly Reconciliation Alert', () => {
  let wrapper;
  const reconciliationDate = new Date('2020-07-10');

  const createComponent = () => {
    return shallowMount(QrtlyReconciliationAlert, {
      propsData: {
        cookieKey: 'key',
        date: reconciliationDate,
      },
    });
  };

  const findAlert = () => wrapper.find(GlAlert);

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Rendering', () => {
    it('renders alert title with date', () => {
      expect(findAlert().attributes('title')).toContain(`occur on 2020-07-10`);
    });

    it('has the correct link to the help page', () => {
      expect(findAlert().attributes('primarybuttonlink')).toBe(
        '/help/subscriptions/self_managed/index#quarterly-subscription-reconciliation',
      );
    });

    it('has the correct link to contact support', () => {
      expect(findAlert().attributes('secondarybuttonlink')).toBe(
        'https://about.gitlab.com/support/#contact-support',
      );
    });
  });

  describe('methods', () => {
    it('sets the cookie on dismis', () => {
      findAlert().vm.$emit('dismiss');

      expect(Cookie.set).toHaveBeenCalledTimes(1);
      expect(Cookie.set).toHaveBeenCalledWith('key', true, { expires: 4 });
    });
  });
});
