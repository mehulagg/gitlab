import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import component from '~/packages_and_registries/settings/group/components/group_settings_app.vue';
import SettingsBlock from '~/vue_shared/components/settings/settings_block.vue';
import {
  PACKAGE_SETTINGS_HEADER,
  PACKAGE_SETTINGS_DESCRIPTION,
} from '~/packages_and_registries/settings/group/constants';

import getGroupPackagesSettingsQuery from '~/packages_and_registries/settings/group/graphql/queries/get_group_packages_settings.query.graphql';
import { groupPackageSettingsMock } from '../mock_data';

const localVue = createLocalVue();

describe('Group Settings App', () => {
  let wrapper;
  let apolloProvider;

  const defaultProvide = {
    defaultExpanded: false,
    groupPath: 'foo_group_path',
  };

  const mountComponent = ({
    provide = defaultProvide,
    resolver = jest.fn().mockResolvedValue(groupPackageSettingsMock),
  } = {}) => {
    localVue.use(VueApollo);

    const requestHandlers = [[getGroupPackagesSettingsQuery, resolver]];

    apolloProvider = createMockApollo(requestHandlers);

    wrapper = shallowMount(component, {
      localVue,
      apolloProvider,
      provide,
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

  it('calls the graphql API with the proper variables', () => {
    const resolver = jest.fn().mockResolvedValue(groupPackageSettingsMock);
    mountComponent({ resolver });

    expect(resolver).toHaveBeenCalledWith({
      fullPath: defaultProvide.groupPath,
    });
  });
});
