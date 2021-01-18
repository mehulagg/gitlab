import { shallowMount } from '@vue/test-utils';
import component from '~/packages_and_registries/settings/group/components/group_settings_app.vue';
import SettingsBlock from '~/vue_shared/components/settings/settings_block.vue';
import {
  PACKAGE_SETTINGS_HEADER,
  PACKAGE_SETTINGS_DESCRIPTION,
} from '~/packages_and_registries/settings/group/constants';

describe('Group Settings App', () => {
  let wrapper;

  const mountComponent = (defaultExpanded = false) => {
    wrapper = shallowMount(component, {
      provide: {
        defaultExpanded,
      },
      stubs: {
        SettingsBlock,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findSettingsBlock = () => wrapper.find(SettingsBlock);

  it('renders a settings block', () => {
    mountComponent();

    expect(findSettingsBlock().exists()).toBe(true);
  });

  it('passes the correct props to settings block', () => {
    mountComponent();

    expect(findSettingsBlock().props('defaultExpanded')).toBe(false);
  });

  it('has the correct header text', () => {
    mountComponent();

    expect(wrapper.text()).toContain(PACKAGE_SETTINGS_HEADER);
  });

  it('has the correct description text', () => {
    mountComponent();

    expect(wrapper.text()).toContain(PACKAGE_SETTINGS_DESCRIPTION);
  });
});
