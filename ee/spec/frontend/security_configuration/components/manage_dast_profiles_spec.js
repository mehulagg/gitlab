import { shallowMount } from '@vue/test-utils';
import ManageDastProfiles from 'ee/security_configuration/components/manage_dast_profiles.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { generateFeatures } from './helpers';

describe('ManageDastProfiles component', () => {
  let wrapper;

  const createComponent = (propsData) => {
    wrapper = extendedWrapper(shallowMount(ManageDastProfiles, { propsData }));
  };

  const findButton = () => wrapper.findByTestId('manage-button');

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the DAST Profiles manage button', () => {
    const [feature] = generateFeatures(1, { configuration_path: '/foo' });
    createComponent({ feature });

    const button = findButton();
    expect(button.text()).toBe('Manage');
    expect(button.attributes('href')).toBe(feature.configuration_path);
  });
});
