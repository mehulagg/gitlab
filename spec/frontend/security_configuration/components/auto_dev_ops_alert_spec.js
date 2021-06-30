import { mountExtended } from 'helpers/vue_test_utils_helper';
import AutoDevopsAlert from '~/security_configuration/components/auto_dev_ops_alert.vue';

const autoDevopsDocsPath = '/autoDevopsDocsPath';
const enableAutoDevopsPath = '/enableAutoDevopsPath';

describe('AutoDevopsAlert component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = mountExtended(AutoDevopsAlert, {
      provide: {
        autoDevopsDocsPath,
        enableAutoDevopsPath,
      },
    });
  };

  const findByTestId = (id) => wrapper.findByTestId(id);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the slot correctly', () => {
    expect(findByTestId('auto-devops-alert-link').attributes('href')).toBe('/autoDevopsDocsPath');
    expect(findByTestId('auto-devops-alert-link').text()).toBe('Auto DevOps');
  });
});
