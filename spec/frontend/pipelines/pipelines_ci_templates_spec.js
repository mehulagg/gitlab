import { shallowMount } from '@vue/test-utils';
import Api from '~/api';
import PipelinesCiTemplate from '~/pipelines/components/pipelines_list/pipelines_ci_templates.vue';

const TEST_RESPONSE = {
  data: [
    {
      key: '5-Minute-Production-App',
      name: '5-Minute-Production-App',
    },
    {
      key: 'Android',
      name: 'Android',
    },
    {
      key: 'Bash',
      name: 'Bash',
    },
    {
      key: 'C++',
      name: 'C++',
    },
  ],
};
const TEST_PROJECT_ID = '100';
const addCiYmlPath = "/-/new/master?commit_message='Add%20.gitlab-ci.yml'";

describe('Pipelines CI Templates', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(PipelinesCiTemplate, {
      provide: {
        addCiYmlPath,
        projectId: TEST_PROJECT_ID,
      },
    });
  };

  const findTemplateDescriptions = () => wrapper.findAll('[data-testid="template-description"]');
  const findTemplateLinks = () => wrapper.findAll('[data-testid="template-link"]');
  const findTemplateLogos = () => wrapper.findAll('[data-testid="template-logo"]');
  const findLoadingIcon = () => wrapper.findAll('[data-testid="loading-icon"]');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when fetching templates', () => {
    beforeEach(() => {
      jest.spyOn(Api, 'projectTemplates').mockReturnValue(new Promise(() => {}));

      wrapper = createWrapper();
    });

    it('shows a loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });
  });

  describe('when fetching templates errors', () => {
    beforeEach(() => {
      jest.spyOn(Api, 'projectTemplates').mockReturnValue(Promise.reject(new Error('Error')));

      wrapper = createWrapper();
    });

    it('shows an error message', () => {
      expect(wrapper.text()).toContain('An error occurred. Please try again');
    });
  });

  describe('when templates are fetched', () => {
    let spy;

    beforeEach(() => {
      spy = jest.spyOn(Api, 'projectTemplates').mockReturnValue(Promise.resolve(TEST_RESPONSE));

      wrapper = createWrapper();
    });

    it('calls the Api with the right params', () => {
      expect(spy).toHaveBeenCalledWith(TEST_PROJECT_ID, 'gitlab_ci_ymls', { per_page: 100 });
    });

    it('does not show a loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('renders only the template listed in the suggested templates', () => {
      const content = wrapper.text();

      expect(wrapper.findAll('[data-testid="template-link"]')).toHaveLength(3);
      expect(content).toContain('Android', 'Bash', 'C++');
      expect(content).not.toContain('5-Minute-Production-App');
    });

    it('links to the correct template', () => {
      expect(findTemplateLinks().at(0).attributes('href')).toEqual(
        addCiYmlPath.concat('&template=Android'),
      );
    });

    it('has the description of the template', () => {
      expect(findTemplateDescriptions().at(0).text()).toEqual(
        'Continuous deployment template to test and deploy your Android project.',
      );
    });

    it('has the right logo of the template', () => {
      expect(findTemplateLogos().at(0).attributes('src')).toEqual(
        '/assets/illustrations/logos/android.svg',
      );
    });
  });
});
