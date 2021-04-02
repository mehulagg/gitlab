import { GlBadge, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ProjectList from 'ee/security_dashboard/components/first_class_project_manager/project_list.vue';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';

const getArrayWithLength = (n) => [...Array(n).keys()];
const generateMockProjects = (projectsCount, mockProject = {}) =>
  getArrayWithLength(projectsCount).map((id) => ({ id, ...mockProject }));

describe('Project List component', () => {
  let wrapper;

  const createWrapper = ({ loading = false } = {}) => {
    wrapper = shallowMount(ProjectList, {
      mocks: {
        $apollo: {
          queries: {
            projects: {
              loading,
            },
          },
        },
      },
    });
  };

  const getAllProjectItems = () => wrapper.findAll('.js-projects-list-project-item');
  const getFirstProjectItem = () => wrapper.find('.js-projects-list-project-item');
  const getFirstRemoveButton = () => getFirstProjectItem().find('.js-projects-list-project-remove');

  afterEach(() => wrapper.destroy());

  it('shows an empty state if there are no projects', () => {
    createWrapper();

    expect(wrapper.find('.js-projects-list-empty-message').exists()).toBe(true);
  });

  it.each`
    phrase             | loading
    ${'shows'}         | ${true}
    ${'does not show'} | ${false}
  `('$phrase the loading indicator when Apollo query loading is $loading', ({ loading }) => {
    createWrapper({ loading });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(loading);
  });

  it.each([0, 1, 2])(
    'renders a list of projects and displays the correct count for %s projects',
    async (projectsCount) => {
      createWrapper();
      await wrapper.setData({ projects: generateMockProjects(projectsCount) });

      expect(getAllProjectItems()).toHaveLength(projectsCount);
      expect(wrapper.find(GlBadge).text()).toBe(projectsCount.toString());
    },
  );

  it('renders a project item with an avatar', async () => {
    createWrapper();
    await wrapper.setData({ projects: generateMockProjects(1) });

    expect(getFirstProjectItem().find(ProjectAvatar).exists()).toBe(true);
  });

  it('renders a project item with a project name', async () => {
    const nameWithNamespace = 'foo';
    createWrapper();
    await wrapper.setData({ projects: generateMockProjects(1, { nameWithNamespace }) });

    expect(getFirstProjectItem().text()).toContain(nameWithNamespace);
  });

  it('renders a project item with a remove button', async () => {
    createWrapper();
    await wrapper.setData({ projects: generateMockProjects(1) });

    expect(getFirstRemoveButton().exists()).toBe(true);
  });

  it(`emits a 'projectRemoved' event when a project's remove button has been clicked`, async () => {
    const projects = generateMockProjects(1);

    createWrapper();
    await wrapper.setData({ projects });
    getFirstRemoveButton().vm.$emit('click');

    expect(wrapper.emitted('projectRemoved')).toHaveLength(1);
    expect(wrapper.emitted('projectRemoved')[0][0]).toEqual(projects[0]);
  });
});
