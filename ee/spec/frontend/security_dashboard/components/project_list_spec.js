import { shallowMount, createLocalVue } from '@vue/test-utils';

import { GlBadge, GlButton, GlLoadingIcon } from '@gitlab/ui';
import ProjectList from 'ee/security_dashboard/components/project_list.vue';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';

const localVue = createLocalVue();

const getArrayWithLength = n => [...Array(n).keys()];
const generateMockProjects = (projectsCount, mockProject = {}) =>
  getArrayWithLength(projectsCount).map(id => ({ id, ...mockProject }));

describe('Project List component', () => {
  let wrapper;

  const factory = ({ projects = [], stubs = {}, showLoadingIndicator = false } = {}) => {
    wrapper = shallowMount(ProjectList, {
      stubs,
      localVue,
      propsData: {
        projects,
        showLoadingIndicator,
      },
      sync: false,
    });
  };

  const getAllProjectItems = () => wrapper.findAll('.js-projects-list-project-item');
  const getFirstProjectItem = () => wrapper.find('.js-projects-list-project-item');
  const getFirstRemoveButton = () => getFirstProjectItem().find('.js-projects-list-project-remove');

  afterEach(() => wrapper.destroy());

  it('shows an empty state if there are no projects', () => {
    factory();

    expect(wrapper.text()).toContain(
      'Select a project to add by using the project search field above.',
    );
  });

  it('does not show a loading indicator when showLoadingIndicator = false', () => {
    factory();

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
  });

  it('shows a loading indicator when showLoadingIndicator = true', () => {
    factory({ showLoadingIndicator: true });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
  });

  it.each([0, 1, 2])(
    'renders a list of projects and displays a count of how many there are',
    projectsCount => {
      factory({ projects: generateMockProjects(projectsCount) });

      expect(getAllProjectItems().length).toBe(projectsCount);
      expect(wrapper.find(GlBadge).text()).toBe(`${projectsCount}`);
    },
  );

  it('renders a project-item with an avatar', () => {
    factory({ projects: generateMockProjects(1) });

    expect(
      getFirstProjectItem()
        .find(ProjectAvatar)
        .exists(),
    ).toBe(true);
  });

  it('renders a project-item with the project name', () => {
    const projectNameWithNamespace = 'foo';

    factory({
      projects: generateMockProjects(1, { name_with_namespace: projectNameWithNamespace }),
    });

    expect(getFirstProjectItem().text()).toContain(projectNameWithNamespace);
  });

  it('renders a project-item with a remove button', () => {
    factory({ projects: generateMockProjects(1) });

    expect(getFirstRemoveButton().exists()).toBe(true);
  });

  it(`emits a 'projectRemoved' event when a project's remove button has been clicked`, () => {
    const mockProjects = generateMockProjects(1);
    const [projectData] = mockProjects;

    factory({ projects: mockProjects, stubs: { GlButton } });

    getFirstRemoveButton().trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.emitted('projectRemoved')).toHaveLength(1);
      expect(wrapper.emitted('projectRemoved')).toEqual([[projectData]]);
    });
  });
});
