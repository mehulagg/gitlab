import { shallowMount, createLocalVue } from '@vue/test-utils';

import { GlLink } from '@gitlab/ui';
import SecurityConfigurationApp from 'ee/security_configuration/components/app.vue';

const localVue = createLocalVue();

describe('Security Configuration App', () => {
  let wrapper;
  const createComponent = (props = {}) => {
    wrapper = shallowMount(SecurityConfigurationApp, {
      sync: false,
      localVue,

      propsData: {
        features: [],
        autoDevopsEnabled: false,
        latestPipelinePath: 'http://latestPipelinePath',
        autoDevopsHelpPagePath: 'http://autoDevopsHelpPagePath',
        helpPagePath: 'http://helpPagePath',
        pipelinesHelpPagePath: 'http://pipelineHelpPagePath',
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const generateFeatures = n =>
    [...Array(n).keys()].map(i => ({
      name: `name-feature-${i}`,
      description: `description-feature-${i}`,
      link: `link-feature-${i}`,
    }));

  const getHelpLink = () => wrapper.find('header').find(GlLink);
  const getNotification = () => wrapper.find({ ref: 'callout' });
  const getPipelinesLink = () => getNotification().find('a');
  const getFeaturesTable = () => wrapper.find({ ref: 'featuresTable' });
  const getFeatureConfigStatus = () => wrapper.find({ ref: 'featureConfigStatus' });

  describe('header', () => {
    it('displays a link to the given help page', () => {
      const helpPagePath = 'http://foo';

      createComponent({ helpPagePath });

      expect(getHelpLink().attributes('href')).toBe(helpPagePath);
    });

    it.each`
      autoDevopsEnabled | latestPipelinePath         | expectedUrl
      ${true}           | ${'http://latestPipeline'} | ${'http://autoDevopsHelpPagePath'}
      ${false}          | ${'http://latestPipeline'} | ${'http://latestPipeline'}
      ${false}          | ${undefined}               | ${'http://pipelineHelpPagePath'}
    `(
      'displays a link to "$expectedUrl" when autoDevops is "$autoDevopsEnabled" and pipelinesPath is $latestPipelinePath',
      ({ autoDevopsEnabled, latestPipelinePath, expectedUrl }) => {
        createComponent({ autoDevopsEnabled, latestPipelinePath });

        expect(getPipelinesLink().attributes('href')).toBe(expectedUrl);
        expect(getPipelinesLink().attributes('rel')).toBe('noopener');
      },
    );
  });

  describe('features table', () => {
    it('displays a row for each given feature', () => {
      const features = generateFeatures(5);

      createComponent({ features });

      expect(wrapper.findAll({ ref: 'featureRow' }).length).toBe(5);
    });

    it('displays a given feature', () => {
      const features = generateFeatures(1);

      createComponent({ features });

      expect(getFeaturesTable().element).toMatchSnapshot();
    });

    it.each`
      configured | statusText
      ${true}    | ${'Configured'}
      ${false}   | ${'Not yet configured'}
    `(
      `displays "$statusText" if the given feature's configuration status is: "$configured"`,
      ({ configured, statusText }) => {
        const features = [{ configured }];

        createComponent({ features });

        expect(getFeatureConfigStatus().text()).toBe(statusText);
      },
    );
  });
});
