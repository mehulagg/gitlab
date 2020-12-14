import { mount } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import ProjectSelect from '~/boards/components/project_select.vue';
import { listObj } from './mock_data';
import httpStatus from '~/lib/utils/http_status';
import { featureAccessLevel } from '~/pages/projects/shared/permissions/constants';

const mockGroupId = 1;
const dummyGon = {
  api_version: 'v4',
  relative_url_root: '/gitlab',
};

const mockFetchData = [
  {
    id: 0,
    name: 'Foobar Project',
    name_with_namespace: 'Awesome Group / Foobar Project',
    path: 'awesome-group/foobar-project',
  },
];

describe('ProjectSelect component', () => {
  let wrapper;
  let mock;

  const findGlDropdown = () => wrapper.find(GlDropdown);
  const findGlDropdownItems = () => wrapper.findAll(GlDropdownItem);
  const findFirstGlDropdownItem = () => findGlDropdownItems().at(0);

  const mockGetRequest = (data = []) => {
    mock.onGet(`/gitlab/api/v4/groups/${mockGroupId}/projects.json`).reply(httpStatus.OK, data);
  };

  const createWrapper = async ({
    list = listObj,
    mockInitialFetch = [],
    mockMethods = {},
  } = {}) => {
    mockGetRequest(mockInitialFetch);

    wrapper = mount(ProjectSelect, {
      propsData: {
        list,
      },
      provide: {
        groupId: 1,
      },
      methods: {
        ...mockMethods,
      },
    });

    await axios.waitForAll();
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    window.gon = dummyGon;
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    jest.clearAllMocks();
  });

  describe('mounted', () => {
    it('calls `fetchProjects`', async () => {
      const fetchProjectSpy = jest.fn();

      await createWrapper({ mockMethods: { fetchProjects: fetchProjectSpy } });

      expect(fetchProjectSpy).toHaveBeenCalledTimes(1);
      expect(wrapper.vm.initialLoading).toBe(false);
      expect(wrapper.vm.isFetching).toBe(false);
    });
  });

  describe('computed', () => {
    describe('fetchOptions', () => {
      describe("when list type is defined and isn't backlog", () => {
        it('returns an additional fetch option (min_access_level)', async () => {
          await createWrapper({ list: { ...listObj, type: 'open' } });

          expect(wrapper.vm.fetchOptions).toEqual({
            ...wrapper.vm.$options.defaultFetchOptions,
            min_access_level: featureAccessLevel.EVERYONE,
          });
        });
      });

      describe("when list type isn't defined", () => {
        it('returns only the default fetch options', async () => {
          await createWrapper();

          expect(wrapper.vm.fetchOptions).toEqual(wrapper.vm.$options.defaultFetchOptions);
        });
      });
    });

    describe('isFetchResultEmpty', () => {
      it('returns true when this.project is empty', async () => {
        await createWrapper();

        expect(wrapper.vm.isFetchResultEmpty).toBe(true);
      });

      it('returns false when this.project is not empty', async () => {
        await createWrapper({ mockInitialFetch: mockFetchData });

        expect(wrapper.vm.isFetchResultEmpty).toBe(false);
      });
    });
  });

  describe('template', () => {
    beforeEach(async () => {
      await createWrapper({ mockInitialFetch: mockFetchData });
    });

    describe('GlDropdown', () => {
      it('is rendered with default text', () => {
        const defaultText = 'Select a project';

        expect(findGlDropdown().exists()).toBe(true);
        expect(findGlDropdown().text()).toContain(defaultText);
      });
    });

    describe('GlDropdownItem', () => {
      it("renders with the fetched project's name", () => {
        expect(findFirstGlDropdownItem().exists()).toBe(true);
        expect(findFirstGlDropdownItem().text()).toContain(mockFetchData[0].name);
      });
    });
  });

  describe('behaviors', () => {
    describe('when no project is selected', () => {
      beforeEach(async () => {
        await createWrapper({ mockInitialFetch: mockFetchData });
      });

      it('returns and renders the default text when no project is selected', async () => {
        const defaultText = 'Select a project';

        expect(wrapper.vm.selectedProjectName).toBe(defaultText);
        expect(findGlDropdown().text()).toContain(defaultText);
      });
    });

    describe('when a project is selected', () => {
      let selectProjectSpy;

      beforeEach(async () => {
        await createWrapper({ mockInitialFetch: mockFetchData });

        selectProjectSpy = jest.spyOn(wrapper.vm, 'selectProject');

        await findFirstGlDropdownItem()
          .find('button')
          .trigger('click');
      });

      it('selectProject method sets selectedProject and emits setSelectedProject event', () => {
        expect(selectProjectSpy).toHaveBeenCalledTimes(1);
        expect(wrapper.vm.selectedProject).toEqual(wrapper.vm.projects[0]);
      });

      it('selectedProjectName returns the name of the selected project', () => {
        expect(wrapper.vm.selectedProjectName).toBe(mockFetchData[0].name);
      });

      it('GlDropdown renders the name of the selected project', () => {
        expect(findGlDropdown().text()).toContain(mockFetchData[0].name);
      });
    });
  });
});
