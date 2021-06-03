import { GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import QrtlyReconciliationAlert from 'ee/admin/components/qrtly_reconciliation_alert.vue';

describe('Qrtly Reconciliation Alert', () => {
  let wrapper;
  const reconciliationDate = new Date('2020-01-01');

  const createComponent = () => {
    return shallowMount(QrtlyReconciliationAlert, {
      propsData: {
        date: reconciliationDate,
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Rendering', () => {
    it('renders alert title with date', () => {
      expect(wrapper.find(GlAlert).attributes('title')).toContain(`occur on ${reconciliationDate}`);
    });
  });
});
