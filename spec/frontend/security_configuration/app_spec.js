import { shallowMount } from '@vue/test-utils';
import app from '~/security_configuration/components/app.vue';

let wrapper;

const createComponent = () => {
  wrapper = shallowMount(app, {});
};

const findPrimaryHeading = () =>
  wrapper.find('[data-test-id="security-configuration-primary-heading"]');
const findSecondaryHeading = () =>
  wrapper.find('[data-test-id="security-configuration-secondary-heading"]');
const findConfigurationTable = () => wrapper.find('configuration-table-stub');

afterEach(() => {
  wrapper.destroy();
});

describe('app Component', () => {
  it('renders correct primary Heading', () => {
    createComponent();
    expect(findPrimaryHeading().text()).toEqual('Security Configuration');
  });

  it('renders correct secondary Heading', () => {
    createComponent();
    expect(findSecondaryHeading().text()).toEqual('Testing & Compliance');
  });

  it('renders ConfigurationTable Component', () => {
    createComponent();
    expect(findConfigurationTable().exists()).toBeTruthy();
  });
});
