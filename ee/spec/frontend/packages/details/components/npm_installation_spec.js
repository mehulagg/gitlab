import { mount } from '@vue/test-utils';
import NpmInstallation from 'ee/packages/details/components/npm_installation.vue';
import { TrackingActions, TrackingLabels } from 'ee/packages/details/constants';
import Tracking from '~/tracking';

describe('NpmInstallation', () => {
  let wrapper;

  const packageScope = '@fake-scope';
  const packageName = 'my-package';
  const packageScopeName = `${packageScope}/${packageName}`;
  const registryUrl = 'https://gitlab.com/api/v4/packages/npm/';

  const defaultProps = {
    name: packageScopeName,
    registryUrl: `${registryUrl}package_name`,
    helpUrl: 'foo',
  };

  const npmInstall = `npm i ${packageScopeName}`;
  const npmSetup = `echo ${packageScope}:registry=${registryUrl} >> .npmrc`;
  const yarnInstall = `yarn add ${packageScopeName}`;
  const yarnSetup = `echo \\"${packageScope}:registry\\" \\"${registryUrl}\\" >> .yarnrc`;

  const installationTab = () => wrapper.find('.js-installation-tab > a');
  const setupTab = () => wrapper.find('.js-setup-tab > a');
  const installCommand = type => wrapper.find(`.js-${type}-install > input`);
  const setupCommand = type => wrapper.find(`.js-${type}-setup > input`);

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = mount(NpmInstallation, {
      propsData,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  describe('registry url', () => {
    it('creates the correct registry url', () => {
      const testRegistryUrl = 'https://foo/baz/';

      createComponent({
        registryUrl: testRegistryUrl,
      });

      expect(wrapper.vm.packageRegistryUrl).toBe(testRegistryUrl);
    });

    it('creates the correct registry url when the url already contains package_name', () => {
      createComponent({
        registryUrl: 'https://package_name/package_name/',
      });

      expect(wrapper.vm.packageRegistryUrl).toBe('https://package_name/');
    });
  });

  describe('installation commands', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the correct npm commands', () => {
      expect(installCommand('npm').element.value).toBe(npmInstall);
      expect(setupCommand('npm').element.value).toBe(npmSetup);
    });

    it('renders the correct yarn commands', () => {
      expect(installCommand('yarn').element.value).toBe(yarnInstall);
      expect(setupCommand('yarn').element.value).toBe(yarnSetup);
    });
  });

  describe('tab change tracking', () => {
    let eventSpy;
    const label = TrackingLabels.NPM_INSTALLATION;

    beforeEach(() => {
      eventSpy = jest.spyOn(Tracking, 'event');
      createComponent();
    });

    it('should track when the setup tab is clicked', () => {
      setupTab().trigger('click');

      expect(eventSpy).toHaveBeenCalledWith(undefined, TrackingActions.REGISTRY_SETUP, {
        label,
      });
    });

    it('should track when the installation tab is clicked', () => {
      setupTab().trigger('click');

      return wrapper.vm
        .$nextTick()
        .then(() => {
          installationTab().trigger('click');
        })
        .then(() => {
          expect(eventSpy).toHaveBeenCalledWith(undefined, TrackingActions.INSTALLATION, {
            label,
          });
        });
    });
  });
});
