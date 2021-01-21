import { GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SASTConfigurationApp from 'ee/security_configuration/sast/components/app.vue';
import ConfigurationForm from 'ee/security_configuration/sast/components/configuration_form.vue';
import { makeSastCiConfiguration } from './helpers';

const sastDocumentationPath = '/help/sast';
const projectPath = 'namespace/project';

describe('SAST Configuration App', () => {
  let wrapper;

  const createComponent = ({
    stubs = {},
    loading = true,
    hasLoadingError = false,
    sastCiConfiguration = null,
  } = {}) => {
    wrapper = shallowMount(SASTConfigurationApp, {
      mocks: { $apollo: { loading } },
      stubs,
      provide: {
        sastDocumentationPath,
        projectPath,
      },
      // While setting data is usually frowned upon, it is the documented way
      // of mocking GraphQL response data:
      // https://docs.gitlab.com/ee/development/fe_guide/graphql.html#testing
      data() {
        return {
          hasLoadingError,
          sastCiConfiguration,
        };
      },
    });
  };

  const findHeader = () => wrapper.find('header');
  const findSubHeading = () => findHeader().find('p');
  const findLink = (container = wrapper) => container.find(GlLink);
  const findConfigurationForm = () => wrapper.find(ConfigurationForm);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findErrorAlert = () => wrapper.find('[data-testid="error-alert"]');
  const findFeedbackAlert = () => wrapper.find('[data-testid="feedback-alert"]');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('feedback alert', () => {
    beforeEach(() => {
      createComponent({
        stubs: { GlSprintf },
      });
    });

    it('should be displayed', () => {
      expect(findFeedbackAlert().exists()).toBe(true);
    });

    it('links to the feedback issue', () => {
      const link = findFeedbackAlert().find(GlLink);
      expect(link.attributes()).toMatchObject({
        href: SASTConfigurationApp.feedbackIssue,
        target: '_blank',
      });
    });

    describe('when it is dismissed', () => {
      beforeEach(() => {
        findFeedbackAlert().vm.$emit('dismiss');
        return wrapper.vm.$nextTick();
      });

      it('should not be displayed', () => {
        expect(findFeedbackAlert().exists()).toBe(false);
      });
    });
  });

  describe('header', () => {
    beforeEach(() => {
      createComponent({
        stubs: { GlSprintf },
      });
    });

    it('displays a link to sastDocumentationPath', () => {
      expect(findLink(findHeader()).attributes('href')).toBe(sastDocumentationPath);
    });

    it('displays the subheading', () => {
      expect(findSubHeading().text()).toMatchInterpolatedText(SASTConfigurationApp.i18n.helpText);
    });
  });

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({
        loading: true,
      });
    });

    it('displays a loading spinner', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not display the configuration form', () => {
      expect(findConfigurationForm().exists()).toBe(false);
    });

    it('does not display an alert message', () => {
      expect(findErrorAlert().exists()).toBe(false);
    });
  });

  describe('when loading failed', () => {
    beforeEach(() => {
      createComponent({
        loading: false,
        hasLoadingError: true,
      });
    });

    it('does not display a loading spinner', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('does not display the configuration form', () => {
      expect(findConfigurationForm().exists()).toBe(false);
    });

    it('displays an alert message', () => {
      expect(findErrorAlert().exists()).toBe(true);
    });
  });

  describe('when loaded', () => {
    let sastCiConfiguration;

    beforeEach(() => {
      sastCiConfiguration = makeSastCiConfiguration();
      createComponent({
        loading: false,
        sastCiConfiguration,
      });
    });

    it('does not display a loading spinner', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('displays the configuration form', () => {
      expect(findConfigurationForm().exists()).toBe(true);
    });

    it('passes the sastCiConfiguration to the sastCiConfiguration prop', () => {
      expect(findConfigurationForm().props('sastCiConfiguration')).toBe(sastCiConfiguration);
    });

    it('does not display an alert message', () => {
      expect(findErrorAlert().exists()).toBe(false);
    });
  });
});
