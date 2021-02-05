import { mount } from '@vue/test-utils';
import ConfigurationTable from '~/security_configuration/components/configuration_table.vue';
import { features } from '~/security_configuration/components/features_constants';

let wrapper;

const createComponent = () => {
  wrapper = mount(ConfigurationTable, {});
};

afterEach(() => {
  wrapper.destroy();
});

describe('Configuration Table Component', () => {
  beforeEach(() => {
    createComponent();
  });
  it.each(features)('should match strings', (feature) => {
    expect(wrapper.text()).toContain(feature.name);
    expect(wrapper.text()).toContain(feature.description);
  });
});