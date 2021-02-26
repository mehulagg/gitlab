import { GlForm, GlFormInputGroup } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import axios from 'axios';
import AxiosMockAdapter from 'axios-mock-adapter';
import { nextTick } from 'vue';
import createFlash from '~/flash';
import httpStatus from '~/lib/utils/http_status';
import * as urlUtility from '~/lib/utils/url_utility';
import ForkForm from '~/pages/projects/forks/new/components/fork_form.vue';

jest.mock('~/flash');

describe('ForkForm component', () => {
  let wrapper;
  let axiosMock;

  const GON_GITLAB_URL = 'https://gitlab.com';
  const GON_API_VERSION = 'v7';

  const MOCK_NAMESPACES_RESPONSE = [
    {
      name: 'one',
      id: 1,
    },
    {
      name: 'two',
      id: 2,
    },
  ];

  const DEFAULT_PROPS = {
    endpoint: '/some/project-full-path/-/forks/new.json',
    newGroupPath: 'some/groups/path',
    projectFullPath: '/some/project-full-path',
    visibilityHelpPath: 'some/visibility/help/path',
    projectId: '10',
    projectName: 'Project Name',
    projectPath: 'project-name',
    projectDescription: 'some project description',
    projectVisibility: 'private',
  };

  const mockGetRequest = (data = {}, statusCode = httpStatus.OK) => {
    axiosMock.onGet(DEFAULT_PROPS.endpoint).replyOnce(statusCode, data);
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(ForkForm, {
      propsData: {
        ...DEFAULT_PROPS,
        ...props,
      },
      stubs: {
        GlFormInputGroup,
      },
    });
  };

  beforeEach(() => {
    axiosMock = new AxiosMockAdapter(axios);
    window.gon = {
      gitlab_url: GON_GITLAB_URL,
      api_version: GON_API_VERSION,
    };
  });

  afterEach(() => {
    wrapper.destroy();
    axiosMock.restore();
  });

  const findPrivateRadio = () => wrapper.find('[data-testid="radio-private"]');
  const findInternalRadio = () => wrapper.find('[data-testid="radio-internal"]');
  const findPublicRadio = () => wrapper.find('[data-testid="radio-public"]');
  const findForkNameInput = () => wrapper.find('[data-testid="fork-name-input"]');
  const findForkUrlInput = () => wrapper.find('[data-testid="fork-url-input"]');
  const findForkSlugInput = () => wrapper.find('[data-testid="fork-slug-input"]');
  const findForkDescriptionTextarea = () =>
    wrapper.find('[data-testid="fork-description-textarea"]');
  const findVisibilityRadioGroup = () =>
    wrapper.find('[data-testid="fork-visibility-radio-group"]');

  it('will go to projectFullPath when click cancel button', () => {
    mockGetRequest();
    createComponent();

    const { projectFullPath } = DEFAULT_PROPS;
    const cancelButton = wrapper.find('[data-testid="cancel-button"]');

    expect(cancelButton.attributes('href')).toBe(projectFullPath);
  });

  it('make POST request with project param', async () => {
    jest.spyOn(axios, 'post');

    mockGetRequest();
    createComponent();

    const namespaceId = 20;

    wrapper.setData({
      selectedNamespace: {
        id: namespaceId,
      },
    });

    wrapper.find(GlForm).vm.$emit('submit', { preventDefault: () => {} });

    const {
      projectId,
      projectDescription,
      projectName,
      projectPath,
      projectVisibility,
    } = DEFAULT_PROPS;

    const url = `/api/${GON_API_VERSION}/projects/${projectId}/fork`;
    const project = {
      description: projectDescription,
      id: projectId,
      name: projectName,
      namespace_id: namespaceId,
      path: projectPath,
      visibility: projectVisibility,
    };

    expect(axios.post).toHaveBeenCalledWith(url, project);
  });

  it('pre-populate form from project props', () => {
    mockGetRequest();
    createComponent();

    expect(findForkNameInput().attributes('value')).toBe(DEFAULT_PROPS.projectName);
    expect(findForkSlugInput().attributes('value')).toBe(DEFAULT_PROPS.projectPath);
    expect(findForkDescriptionTextarea().attributes('value')).toBe(
      DEFAULT_PROPS.projectDescription,
    );
  });

  it('sets project URL prepend text with gon.gitlab_url', () => {
    mockGetRequest();
    createComponent();

    expect(wrapper.find(GlFormInputGroup).text()).toContain(`${GON_GITLAB_URL}/`);
  });

  it('will have required attribute for required fields', () => {
    mockGetRequest();
    createComponent();

    expect(findForkNameInput().attributes('required')).not.toBeUndefined();
    expect(findForkUrlInput().attributes('required')).not.toBeUndefined();
    expect(findForkSlugInput().attributes('required')).not.toBeUndefined();
    expect(findVisibilityRadioGroup().attributes('required')).not.toBeUndefined();
    expect(findForkDescriptionTextarea().attributes('required')).toBeUndefined();
  });

  describe('forks namespaces', () => {
    beforeEach(() => {
      mockGetRequest({ namespaces: MOCK_NAMESPACES_RESPONSE });
      createComponent();
    });

    it('make GET request from endpoint', async () => {
      await axios.waitForAll();

      expect(axiosMock.history.get[0].url).toBe(DEFAULT_PROPS.endpoint);
    });

    it('generate default option', async () => {
      await axios.waitForAll();

      const optionsArray = findForkUrlInput().findAll('option');

      expect(optionsArray.at(0).text()).toBe('Select a namespace');
    });

    it('populate project url namespace options', async () => {
      await axios.waitForAll();

      const optionsArray = findForkUrlInput().findAll('option');

      expect(optionsArray.length).toBe(MOCK_NAMESPACES_RESPONSE.length + 1);
      expect(optionsArray.at(1).text()).toBe(MOCK_NAMESPACES_RESPONSE[0].name);
      expect(optionsArray.at(2).text()).toBe(MOCK_NAMESPACES_RESPONSE[1].name);
    });
  });

  describe('visibility level', () => {
    it.each`
      project       | namespace     | privateIsDisabled | internalIsDisabled | publicIsDisabled
      ${'private'}  | ${'private'}  | ${undefined}      | ${'true'}          | ${'true'}
      ${'private'}  | ${'internal'} | ${undefined}      | ${'true'}          | ${'true'}
      ${'private'}  | ${'public'}   | ${undefined}      | ${'true'}          | ${'true'}
      ${'internal'} | ${'private'}  | ${undefined}      | ${'true'}          | ${'true'}
      ${'internal'} | ${'internal'} | ${undefined}      | ${undefined}       | ${'true'}
      ${'internal'} | ${'public'}   | ${undefined}      | ${undefined}       | ${'true'}
      ${'public'}   | ${'private'}  | ${undefined}      | ${'true'}          | ${'true'}
      ${'public'}   | ${'internal'} | ${undefined}      | ${undefined}       | ${'true'}
      ${'public'}   | ${'public'}   | ${undefined}      | ${undefined}       | ${undefined}
    `(
      'sets appropriate radio button disabled state',
      async ({ project, namespace, privateIsDisabled, internalIsDisabled, publicIsDisabled }) => {
        mockGetRequest();
        createComponent({
          projectVisibility: project,
        });

        wrapper.setData({
          selectedNamespace: {
            visibility: namespace,
          },
        });

        await nextTick();

        expect(findPrivateRadio().attributes('disabled')).toBe(privateIsDisabled);
        expect(findInternalRadio().attributes('disabled')).toBe(internalIsDisabled);
        expect(findPublicRadio().attributes('disabled')).toBe(publicIsDisabled);
      },
    );
  });

  describe('onSubmit', () => {
    beforeEach(() => {
      jest.spyOn(urlUtility, 'redirectTo').mockImplementation();
    });

    it('redirect to POST web_url response', async () => {
      const webUrl = `new/fork-project`;

      jest.spyOn(axios, 'post').mockImplementation(() => {
        return Promise.resolve({
          data: {
            web_url: webUrl,
          },
        });
      });

      mockGetRequest();
      createComponent();

      await wrapper.vm.onSubmit();

      expect(urlUtility.redirectTo).toHaveBeenCalledWith(webUrl);
    });

    it('display flash when POST is unsuccessful', async () => {
      const dummyError = 'Fork project failed';

      jest.spyOn(axios, 'post').mockImplementation(() => {
        return Promise.reject(dummyError);
      });

      mockGetRequest();
      createComponent();

      await wrapper.vm.onSubmit();

      expect(urlUtility.redirectTo).not.toHaveBeenCalled();
      expect(createFlash).toHaveBeenCalledWith({
        message: dummyError,
      });
    });
  });
});
