import {
  GlButton,
  GlDeprecatedDropdown,
  GlDeprecatedDropdownItem,
  GlFormInput,
  GlSearchBoxByType,
  GlLoadingIcon,
} from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';

import CreateIssueForm from 'ee/related_items_tree/components/create_issue_form.vue';
import createDefaultStore from 'ee/related_items_tree/store';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';

import { mockInitialConfig, mockParentItem } from '../mock_data';

const mockProjects = getJSONFixture('static/projects.json');

const localVue = createLocalVue();
localVue.use(Vuex);

const createComponent = () => {
  const store = createDefaultStore();

  store.dispatch('setInitialConfig', mockInitialConfig);
  store.dispatch('setInitialParentItem', mockParentItem);

  return shallowMount(CreateIssueForm, {
    localVue,
    store,
  });
};

describe('CreateIssueForm', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('data', () => {
    it('initializes data props with default values', () => {
      expect(wrapper.vm.selectedProject).toBeNull();
      expect(wrapper.vm.searchKey).toBe('');
      expect(wrapper.vm.title).toBe('');
      expect(wrapper.vm.preventDropdownClose).toBe(false);
    });
  });

  describe('computed', () => {
    describe('dropdownToggleText', () => {
      it('returns project name with namespace when `selectedProject` is not empty', () => {
        wrapper.setData({
          selectedProject: mockProjects[0],
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.dropdownToggleText).toBe(mockProjects[0].name_with_namespace);
        });
      });
    });
  });

  describe('methods', () => {
    describe('cancel', () => {
      it('emits event `cancel` on component', () => {
        wrapper.vm.cancel();

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.emitted('cancel')).toBeTruthy();
        });
      });
    });

    describe('createIssue', () => {
      it('emits event `submit` on component when `selectedProject` is not empty', () => {
        wrapper.setData({
          selectedProject: {
            ...mockProjects[0],
            _links: {
              issues: 'foo',
            },
          },
          title: 'Some issue',
        });

        wrapper.vm.createIssue();

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.emitted('submit')[0]).toEqual(
            expect.arrayContaining([{ issuesEndpoint: 'foo', title: 'Some issue' }]),
          );
        });
      });
    });

    describe('handleDropdownShow', () => {
      it('sets `searchKey` prop to empty string and calls action `fetchProjects`', () => {
        const handleDropdownShow = jest
          .spyOn(wrapper.vm, 'fetchProjects')
          .mockImplementation(jest.fn());

        wrapper.vm.handleDropdownShow();

        expect(wrapper.vm.searchKey).toBe('');
        expect(handleDropdownShow).toHaveBeenCalled();
      });
    });

    describe('handleDropdownHide', () => {
      it('sets `searchKey` prop to empty string and calls action `fetchProjects`', () => {
        const event = {
          preventDefault: jest.fn(),
        };
        const preventDefault = jest.spyOn(event, 'preventDefault');

        wrapper.setData({
          preventDropdownClose: true,
        });
        wrapper.vm.handleDropdownHide(event);

        return wrapper.vm.$nextTick(() => {
          expect(preventDefault).toHaveBeenCalled();
          expect(wrapper.vm.preventDropdownClose).toBe(false);
        });
      });
    });

    describe('handleSearchInputContainerClick', () => {
      it('sets `preventDropdownClose` to `true` when target element contains class `gl-icon`', () => {
        const target = document.createElement('span');
        target.setAttribute('class', 'gl-icon');

        wrapper.vm.handleSearchInputContainerClick({ target });

        expect(wrapper.vm.preventDropdownClose).toBe(true);
      });

      it('sets `preventDropdownClose` to `true` when target element href contains text `clear`', () => {
        const target = document.createElement('user');
        target.setAttribute('href', 'foo.svg#clear');

        wrapper.vm.handleSearchInputContainerClick({ target });

        expect(wrapper.vm.preventDropdownClose).toBe(true);
      });
    });
  });

  describe('templates', () => {
    it('renders Issue title input field', () => {
      const issueTitleFieldLabel = wrapper.findAll('label').at(0);
      const issueTitleFieldInput = wrapper.find(GlFormInput);

      expect(issueTitleFieldLabel.text()).toBe('Title');
      expect(issueTitleFieldInput.attributes('placeholder')).toBe('New issue title');
    });

    it('renders Projects dropdown field', () => {
      const projectsDropdownLabel = wrapper.findAll('label').at(1);
      const projectsDropdownButton = wrapper.find(GlDeprecatedDropdown);

      expect(projectsDropdownLabel.text()).toBe('Project');
      expect(projectsDropdownButton.props('text')).toBe('Select a project');
    });

    it('renders Projects dropdown contents', () => {
      wrapper.vm.$store.dispatch('receiveProjectsSuccess', mockProjects);

      return wrapper.vm.$nextTick(() => {
        const projectsDropdownButton = wrapper.find(GlDeprecatedDropdown);
        const dropdownItems = projectsDropdownButton.findAll(GlDeprecatedDropdownItem);

        expect(projectsDropdownButton.find(GlSearchBoxByType).exists()).toBe(true);
        expect(projectsDropdownButton.find(GlLoadingIcon).exists()).toBe(true);
        expect(dropdownItems).toHaveLength(mockProjects.length);
        expect(dropdownItems.at(0).text()).toContain(mockProjects[0].name);
        expect(dropdownItems.at(0).text()).toContain(mockProjects[0].namespace.name);
        expect(
          dropdownItems
            .at(0)
            .find(ProjectAvatar)
            .exists(),
        ).toBe(true);
      });
    });

    it('renders Projects dropdown contents containing only matching project when searchKey is provided', () => {
      const searchKey = 'Underscore';
      const filteredMockProjects = mockProjects.filter(project => project.name === searchKey);
      jest.spyOn(wrapper.vm, 'fetchProjects').mockImplementation(jest.fn());

      wrapper.find(GlDeprecatedDropdown).trigger('click');

      wrapper.setData({
        searchKey,
      });

      return wrapper.vm
        .$nextTick()
        .then(() => {
          wrapper.vm.$store.dispatch('receiveProjectsSuccess', filteredMockProjects);
        })
        .then(() => {
          expect(wrapper.findAll(GlDeprecatedDropdownItem)).toHaveLength(1);
        });
    });

    it('renders Projects dropdown contents containing string string "No matches found" when searchKey provided does not match any project', () => {
      const searchKey = "this-project-shouldn't exist";
      const filteredMockProjects = mockProjects.filter(project => project.name === searchKey);
      jest.spyOn(wrapper.vm, 'fetchProjects').mockImplementation(jest.fn());

      wrapper.find(GlDeprecatedDropdown).trigger('click');

      wrapper.setData({
        searchKey,
      });

      return wrapper.vm
        .$nextTick()
        .then(() => {
          wrapper.vm.$store.dispatch('receiveProjectsSuccess', filteredMockProjects);
        })
        .then(() => {
          expect(wrapper.find('.dropdown-contents').text()).toContain('No matches found');
        });
    });

    it('renders `Create issue` button', () => {
      const createIssueButton = wrapper.findAll(GlButton).at(0);

      expect(createIssueButton.exists()).toBe(true);
      expect(createIssueButton.text()).toBe('Create issue');
    });

    it('renders loading icon within `Create issue` button when `itemCreateInProgress` is true', () => {
      wrapper.vm.$store.dispatch('requestCreateItem');

      return wrapper.vm.$nextTick(() => {
        const createIssueButton = wrapper.findAll(GlButton).at(0);

        expect(createIssueButton.exists()).toBe(true);
        expect(createIssueButton.props('disabled')).toBe(true);
        expect(createIssueButton.props('loading')).toBe(true);
      });
    });

    it('renders `Cancel` button', () => {
      const cancelButton = wrapper.findAll(GlButton).at(1);

      expect(cancelButton.exists()).toBe(true);
      expect(cancelButton.text()).toBe('Cancel');
    });
  });
});
