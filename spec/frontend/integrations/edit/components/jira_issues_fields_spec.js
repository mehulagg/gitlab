import { mount } from '@vue/test-utils';

import { GlFormCheckbox, GlFormInput } from '@gitlab/ui';

import JiraIssuesFields from '~/integrations/edit/components/jira_issues_fields.vue';

describe('JiraIssuesFields', () => {
  let wrapper;

  const defaultProps = {
    showJiraIssuesIntegration: true,
    editProjectPath: '/edit',
  };

  const createComponent = (props, options = {}) => {
    wrapper = mount(JiraIssuesFields, {
      propsData: { ...defaultProps, ...props },
      ...options,
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findEnableCheckbox = () => wrapper.find(GlFormCheckbox);
  const findProjectKey = () => wrapper.find(GlFormInput);
  const expectedBannerText = 'This is a Premium feature';
  const findJiraForVulnerabilities = () => wrapper.find('[data-testid="jiraForVulnerabilities"]');
  const setEnableCheckbox = async (isEnabled = true) => {
    findEnableCheckbox().vm.$emit('input', isEnabled);
    await wrapper.vm.$nextTick();
  };

  describe('template', () => {
    describe('upgrade banner for non-Premium user', () => {
      beforeEach(() => {
        createComponent({ initialProjectKey: '', showJiraIssuesIntegration: false });
      });

      it('shows upgrade banner', () => {
        expect(wrapper.text()).toContain(expectedBannerText);
      });

      it('does not show checkbox and input field', () => {
        expect(findEnableCheckbox().exists()).toBe(false);
        expect(findProjectKey().exists()).toBe(false);
      });
    });

    describe('Enable Jira issues checkbox', () => {
      beforeEach(() => {
        createComponent({ initialProjectKey: '' });
      });

      it('does not show upgrade banner', () => {
        expect(wrapper.text()).not.toContain(expectedBannerText);
      });

      // As per https://vuejs.org/v2/guide/forms.html#Checkbox-1,
      // browsers don't include unchecked boxes in form submissions.
      it('includes issues_enabled as false even if unchecked', () => {
        expect(wrapper.find('input[name="service[issues_enabled]"]').exists()).toBe(true);
      });

      it('disables project_key input', () => {
        expect(findProjectKey().attributes('disabled')).toBe('disabled');
      });

      it('does not require project_key', () => {
        expect(findProjectKey().attributes('required')).toBeUndefined();
      });

      describe('on enable issues', () => {
        it('enables project_key input', async () => {
          await setEnableCheckbox(true);

          expect(findProjectKey().attributes('disabled')).toBeUndefined();
        });

        it('requires project_key input', async () => {
          await setEnableCheckbox(true);

          expect(findProjectKey().attributes('required')).toBe('required');
        });
      });
    });

    it('contains link to editProjectPath', () => {
      createComponent();

      expect(wrapper.find(`a[href="${defaultProps.editProjectPath}"]`).exists()).toBe(true);
    });

    describe('GitLab issues warning', () => {
      const expectedText = 'Consider disabling GitLab issues';

      it('contains warning when GitLab issues is enabled', () => {
        createComponent();

        expect(wrapper.text()).toContain(expectedText);
      });

      it('does not contain warning when GitLab issues is disabled', () => {
        createComponent({ gitlabIssuesEnabled: false });

        expect(wrapper.text()).not.toContain(expectedText);
      });
    });

    describe('Vulnerabilities creation', () => {
      beforeEach(async () => {
        createComponent(
          { showJiraIssuesIntegration: true },
          { provide: { glFeatures: { jiraForVulnerabilities: true } } },
        );
      });

      it.each([true, false])(
        'shows the section correctly when jira issues enables is: %s',
        async hasJiraIssuesEnabled => {
          await setEnableCheckbox(hasJiraIssuesEnabled);

          expect(findJiraForVulnerabilities().exists()).toBe(hasJiraIssuesEnabled);
        },
      );

      describe('with "" feature flag disabled', () => {
        beforeEach(async () => {
          createComponent(
            { showJiraIssuesIntegration: true },
            { provide: { glFeatures: { jiraForVulnerabilities: false } } },
          );
        });
        it('does not show section', () => {
          expect(findJiraForVulnerabilities().exists()).toBe(false);
        });
      });
    });
  });
});
