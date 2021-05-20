import { GlTab, GlTabs } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import FeatureCard from '~/security_configuration/components/feature_card.vue';
import RedesignedSecurityConfigurationApp from '~/security_configuration/components/redesigned_app.vue';

describe('NewApp component', () => {
  let wrapper;

  const createComponent = (propsData) => {
    wrapper = extendedWrapper(
      mount(RedesignedSecurityConfigurationApp, {
        propsData,
      }),
    );
  };

  const findMainHeading = () => wrapper.find('h1');
  const findSubHeading = () => wrapper.find('h4');
  const findTab = () => wrapper.find(GlTab);
  const findTabs = () => wrapper.findAll(GlTabs);
  const findByTestId = (id) => wrapper.findByTestId(id);
  const findFeatureCards = () => wrapper.findAll(FeatureCard);

  const securityFeaturesMock = [
    {
      name: 'Static Application Security Testing (SAST)',
      shortName: 'SAST',
      description: 'Analyze your source code for known vulnerabilities.',
      helpPath: '/help/user/application_security/sast/index',
      configurationHelpPath: '/help/user/application_security/sast/index#configuration',
      type: 'sast',
      available: true,
    },
  ];

  afterEach(() => {
    wrapper.destroy();
  });

  describe('basic structure', () => {
    beforeEach(() => {
      createComponent({
        securityFeatures: securityFeaturesMock,
      });
    });

    it('renders main-heading with correct text', () => {
      const mainHeading = findMainHeading();
      expect(mainHeading).toExist();
      expect(mainHeading.text()).toContain('Security Configuration');
    });

    it('renders GlTab Component ', () => {
      expect(findTab()).toExist();
    });

    it('renders right amount of tabs with correct title ', () => {
      expect(findTabs().length).toEqual(1);
    });

    it('renders security-testing tab', () => {
      expect(findByTestId('security-testing-tab')).toExist();
    });

    it('renders sub-heading with correct text', () => {
      const subHeading = findSubHeading();
      expect(subHeading).toExist();
      expect(subHeading.text()).toContain('Security testing');
    });

    it('renders right amount of feature cards for given props with correct props', () => {
      const cards = findFeatureCards();
      expect(cards.length).toEqual(1);
      expect(cards.at(0).props()).toEqual({ feature: securityFeaturesMock[0] });
    });
  });
});
