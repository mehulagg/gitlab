import { GlAlert, GlLink } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { merge } from 'lodash';
import SecurityConfigurationApp from 'ee/security_configuration/components/app.vue';
import FeatureStatus from 'ee/security_configuration/components/feature_status.vue';
import ManageFeature from 'ee/security_configuration/components/manage_feature.vue';
import { useLocalStorageSpy } from 'helpers/local_storage_helper';
import stubChildren from 'helpers/stub_children';
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
  createSastMergeRequestPath: 'http://createSastMergeRequestPath',
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
            GlTable: false,
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
  const getFeaturesTable = () => wrapper.find({ ref: 'securityControlTable' });
  const getFeaturesRows = () => getFeaturesTable().findAll('tbody tr');
  const getAlert = () => wrapper.find(GlAlert);
  const getRowCells = row => {
    const [feature, status, manage] = row.findAll('td').wrappers;
    return { feature, status, manage };
  };

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
    it('passes the expected data to the GlTable', () => {
      const features = generateFeatures(5);

      createComponent({ propsData: { features } });

      expect(getFeaturesTable().classes('b-table-stacked-md')).toBeTruthy();
      const rows = getFeaturesRows();
      expect(rows).toHaveLength(5);

      for (let i = 0; i < features.length; i += 1) {
        const { feature, status, manage } = getRowCells(rows.at(i));
        expect(feature.text()).toMatch(features[i].name);
        expect(feature.text()).toMatch(features[i].description);
        expect(status.find(FeatureStatus).props()).toEqual({
          feature: features[i],
          gitlabCiPresent: propsData.gitlabCiPresent,
          gitlabCiHistoryPath: propsData.gitlabCiHistoryPath,
        });
        expect(manage.find(ManageFeature).props()).toEqual({
          feature: features[i],
          autoDevopsEnabled: propsData.autoDevopsEnabled,
          createSastMergeRequestPath: propsData.createSastMergeRequestPath,
        });
        expect(feature.find(GlLink).props('href')).toBe(features[i].href);
      }
    });
  });
});
