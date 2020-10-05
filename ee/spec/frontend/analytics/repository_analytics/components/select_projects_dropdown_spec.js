import { shallowMount, createLocalVue } from '@vue/test-utils';
import {
  GlDropdown,
  GlDropdownItem,
  GlIntersectionObserver,
  GlLoadingIcon,
  GlIcon,
} from '@gitlab/ui';
import SelectProjectsDropdown from 'ee/analytics/repository_analytics/components/select_projects_dropdown.vue';

const localVue = createLocalVue();

describe('Select projects dropdown component', () => {
  let wrapper;

  const findSelectAllProjects = () => wrapper.find('[data-testid="select-all-projects"]');
  const findProjectById = id => wrapper.find(`[data-testid="select-project-${id}"]`);
  const selectAllProjects = () => findSelectAllProjects().trigger('click');
  const selectProjectById = id => findProjectById(id).trigger('click');
  const findIntersectionObserver = () => wrapper.find(GlIntersectionObserver);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);

  const createComponent = ({ data = {}, apolloGroupProjects = {} } = {}) => {
    wrapper = shallowMount(SelectProjectsDropdown, {
      localVue,
      data() {
        return {
          groupProjects: [
            { id: 1, name: '1', isSelected: false },
            { id: 2, name: '2', isSelected: false },
          ],
          projectsPageInfo: {
            hasNextPage: false,
            endCursor: null,
          },
          ...data,
        };
      },
      provide: {
        groupFullPath: 'gitlab-org',
      },
      mocks: {
        $apollo: {
          queries: {
            groupProjects: {
              fetchMore: jest.fn().mockResolvedValue(),
              ...apolloGroupProjects,
            },
          },
        },
      },
      stubs: { GlDropdown, GlDropdownItem, GlIcon },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when selecting all project', () => {
    beforeEach(() => {
      createComponent({ data: { groupProjects: [{ id: 1, name: '1', isSelected: true }] } });
    });

    it('should reset all selected projects', () => {
      selectAllProjects();

      return wrapper.vm.$nextTick().then(() => {
        expect(
          findProjectById(1)
            .find(GlIcon)
            .classes(),
        ).toContain('gl-visibility-hidden');
      });
    });

    it('should emit select-all-projects event', () => {
      jest.spyOn(wrapper.vm, '$emit');
      selectAllProjects();

      expect(wrapper.vm.$emit).toHaveBeenCalledWith('select-all-projects', [
        { id: 1, name: '1', isSelected: false },
      ]);
    });
  });

  describe('when selecting a project', () => {
    beforeEach(() => {
      createComponent({
        data: { groupProjects: [{ id: 1, name: '1', isSelected: false }], selectAllProjects: true },
      });
    });

    it('should check selected project', () => {
      selectProjectById(1);

      return wrapper.vm.$nextTick().then(() => {
        expect(
          findProjectById(1)
            .find(GlIcon)
            .classes(),
        ).not.toContain('gl-visibility-hidden');
      });
    });

    it('should uncheck select all projects', () => {
      selectProjectById(1);

      return wrapper.vm.$nextTick().then(() => {
        expect(
          findSelectAllProjects()
            .find(GlIcon)
            .classes(),
        ).toContain('gl-visibility-hidden');
      });
    });

    it('should emit select-project event', () => {
      jest.spyOn(wrapper.vm, '$emit');
      selectProjectById(1);

      expect(wrapper.vm.$emit).toHaveBeenCalledWith('select-project', {
        id: 1,
        name: '1',
        isSelected: true,
      });
    });
  });

  describe('when there is only one page of projects', () => {
    it('should not render the intersection observer component', () => {
      createComponent();

      expect(findIntersectionObserver().exists()).toBe(false);
    });
  });

  describe('when there is more than a page of projects', () => {
    beforeEach(() => {
      createComponent({ data: { projectsPageInfo: { hasNextPage: true } } });
    });

    it('should render the intersection observer component', () => {
      expect(findIntersectionObserver().exists()).toBe(true);
    });

    describe('when the intersection observer component appears in view', () => {
      it('makes a query to fetch more projects', () => {
        jest
          .spyOn(wrapper.vm.$apollo.queries.groupProjects, 'fetchMore')
          .mockImplementation(jest.fn().mockResolvedValue());

        findIntersectionObserver().vm.$emit('appear');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.vm.$apollo.queries.groupProjects.fetchMore).toHaveBeenCalledTimes(1);
        });
      });

      describe('when the fetchMore query throws an error', () => {
        it('emits an error event', () => {
          jest.spyOn(wrapper.vm, '$emit');
          jest
            .spyOn(wrapper.vm.$apollo.queries.groupProjects, 'fetchMore')
            .mockImplementation(jest.fn().mockRejectedValue());

          findIntersectionObserver().vm.$emit('appear');
          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.vm.$emit).toHaveBeenCalledWith('projects-query-error');
          });
        });
      });
    });

    describe('when a query is loading a new page of projects', () => {
      it('should render the loading spinner', () => {
        createComponent({
          data: { projectsPageInfo: { hasNextPage: true } },
          apolloGroupProjects: {
            loading: true,
          },
        });

        expect(findLoadingIcon().exists()).toBe(true);
      });
    });
  });
});
