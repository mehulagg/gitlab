import { GlAlert, GlLink } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { merge } from 'lodash';
import SecurityConfigurationApp from 'ee/security_configuration/components/app.vue';
import ConfigurationTable from 'ee/security_configuration/components/configuration_table.vue';
import { useLocalStorageSpy } from 'helpers/local_storage_helper';
import stubChildren from 'helpers/stub_children';
import { scanners } from '~/security_configuration/components/constants';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import { generateFeatures } from './helpers';

const propsData = {
  features: [],
  autoDevopsEnabled: false,
  latestPipelinePath: 'http://latestPipelinePath',
  autoDevopsHelpPagePath: 'http://autoDevopsHelpPagePath',
  autoDevopsPath: 'http://autoDevopsPath',
  helpPagePath: 'http://helpPagePath',
  gitlabCiPresent: false,
  gitlabCiHistoryPath: '/ci/history',
  autoFixSettingsProps: {},
};

describe('Security Configuration App', () => {
  let wrapper;
  const createComponent = (options = {}) => {
    wrapper = mount(
      SecurityConfigurationApp,
      merge(
        {},
        {
          stubs: {
            ...stubChildren(SecurityConfigurationApp),
            GlSprintf: false,
          },
          propsData,
        },
        options,
      ),
    );
  };

  beforeEach(() => {
    localStorage.clear();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const getPipelinesLink = () => wrapper.find({ ref: 'pipelinesLink' });
  const getConfigurationTable = () => wrapper.find(ConfigurationTable);
  const getAlert = () => wrapper.find(GlAlert);

  describe('header', () => {
    it.each`
      autoDevopsEnabled | expectedUrl
      ${true}           | ${propsData.autoDevopsHelpPagePath}
      ${false}          | ${propsData.latestPipelinePath}
    `(
      'displays a link to "$expectedUrl" when autoDevops is "$autoDevopsEnabled"',
      ({ autoDevopsEnabled, expectedUrl }) => {
        createComponent({ propsData: { autoDevopsEnabled } });

        expect(getPipelinesLink().attributes('href')).toBe(expectedUrl);
        expect(getPipelinesLink().attributes('target')).toBe('_blank');
      },
    );
  });

  describe('Auto DevOps alert', () => {
    describe.each`
      gitlabCiPresent | autoDevopsEnabled | canEnableAutoDevops | dismissed | shouldShowAlert
      ${false}        | ${false}          | ${true}             | ${false}  | ${true}
      ${false}        | ${false}          | ${true}             | ${true}   | ${false}
      ${true}         | ${false}          | ${true}             | ${false}  | ${false}
      ${false}        | ${true}           | ${true}             | ${false}  | ${false}
      ${false}        | ${false}          | ${false}            | ${false}  | ${false}
    `(
      'given gitlabCiPresent is $gitlabCiPresent, autoDevopsEnabled is $autoDevopsEnabled, dismissed is $dismissed, canEnableAutoDevops is $canEnableAutoDevops',
      ({ gitlabCiPresent, autoDevopsEnabled, canEnableAutoDevops, dismissed, shouldShowAlert }) => {
        beforeEach(() => {
          if (dismissed) {
            localStorage.setItem(SecurityConfigurationApp.autoDevopsAlertStorageKey, 'true');
          }

          createComponent({
            propsData: {
              gitlabCiPresent,
              autoDevopsEnabled,
              canEnableAutoDevops,
            },
            stubs: {
              LocalStorageSync,
            },
          });
        });

        it(`is${shouldShowAlert ? '' : ' not'} rendered`, () => {
          expect(getAlert().exists()).toBe(shouldShowAlert);
        });

        if (shouldShowAlert) {
          it('has the expected text', () => {
            expect(getAlert().text()).toMatchInterpolatedText(
              SecurityConfigurationApp.autoDevopsAlertMessage,
            );
          });

          it('has a link to the Auto DevOps docs', () => {
            const link = getAlert().find(GlLink);
            expect(link.attributes().href).toBe(propsData.autoDevopsHelpPagePath);
          });

          it('has the correct primary button', () => {
            expect(getAlert().props()).toMatchObject({
              title: 'Auto DevOps',
              primaryButtonText: 'Enable Auto DevOps',
              primaryButtonLink: propsData.autoDevopsPath,
            });
          });
        }
      },
    );

    describe('dismissing the alert', () => {
      useLocalStorageSpy();

      beforeEach(() => {
        createComponent({
          propsData: {
            gitlabCiPresent: false,
            autoDevopsEnabled: false,
            canEnableAutoDevops: true,
          },
          stubs: {
            LocalStorageSync,
          },
        });

        getAlert().vm.$emit('dismiss');
      });

      it('hides the alert', () => {
        expect(getAlert().exists()).toBe(false);
      });

      it('saves dismissal in localStorage', () => {
        expect(localStorage.setItem.mock.calls).toEqual([
          [SecurityConfigurationApp.autoDevopsAlertStorageKey, 'true'],
        ]);
      });
    });
  });

  describe('features table', () => {
    it('passes the expected features to the configuration table', () => {
      const features = generateFeatures(scanners.length);

      createComponent({ propsData: { features } });
      const table = getConfigurationTable();
      const receivedFeatures = table.props('features');

      scanners.forEach((scanner, i) => {
        expect(receivedFeatures[i]).toMatchObject({
          ...features[i],
          name: scanner.name,
          description: scanner.description,
          helpPath: scanner.helpPath,
        });
      });
    });

    it('passes the expected props data to the configuration table', () => {
      createComponent();

      expect(getConfigurationTable().props()).toMatchObject({
        autoDevopsEnabled: propsData.autoDevopsEnabled,
        gitlabCiPresent: propsData.gitlabCiPresent,
        gitlabCiHistoryPath: propsData.gitlabCiHistoryPath,
      });
    });
  });
});
