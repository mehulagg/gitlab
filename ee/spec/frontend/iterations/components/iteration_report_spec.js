import { GlDropdown, GlDropdownItem, GlEmptyState, GlLoadingIcon, GlTab, GlTabs } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IterationForm from 'ee/iterations/components/iteration_form.vue';
import IterationReport from 'ee/iterations/components/iteration_report.vue';
import IterationReportTabs from 'ee/iterations/components/iteration_report_tabs.vue';
import { Namespace } from 'ee/iterations/constants';

describe('Iterations report', () => {
  let wrapper;
  const defaultProps = {
    fullPath: 'gitlab-org',
    iterationIid: '3',
    labelsFetchPath: '/gitlab-org/gitlab-test/-/labels.json?include_ancestor_groups=true',
  };

  const findTopbar = () => wrapper.find({ ref: 'topbar' });
  const findTitle = () => wrapper.find({ ref: 'title' });
  const findDescription = () => wrapper.find({ ref: 'description' });
  const findActionsDropdown = () => wrapper.find('[data-testid="actions-dropdown"]');
  const clickEditButton = () => {
    findActionsDropdown().vm.$emit('click');
    wrapper.find(GlDropdownItem).vm.$emit('click');
  };

  const mountComponent = ({ props = defaultProps, loading = false } = {}) => {
    wrapper = shallowMount(IterationReport, {
      propsData: props,
      mocks: {
        $apollo: {
          queries: { iteration: { loading } },
        },
      },
      stubs: {
        GlLoadingIcon,
        GlTab,
        GlTabs,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('shows spinner while loading', () => {
    mountComponent({
      loading: true,
    });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
  });

  describe('empty state', () => {
    it('shows empty state if no item loaded', () => {
      mountComponent({
        loading: false,
      });

      expect(wrapper.find(GlEmptyState).exists()).toBe(true);
      expect(wrapper.find(GlEmptyState).props('title')).toEqual('Could not find iteration');
      expect(findTitle().exists()).toBe(false);
      expect(findDescription().exists()).toBe(false);
      expect(findActionsDropdown().exists()).toBe(false);
    });
  });

  describe('item loaded', () => {
    const iteration = {
      title: 'June week 1',
      id: 'gid://gitlab/Iteration/2',
      descriptionHtml: 'The first week of June',
      startDate: '2020-06-02',
      dueDate: '2020-06-08',
      state: 'opened',
    };

    describe('user without edit permission', () => {
      beforeEach(() => {
        mountComponent({
          loading: false,
        });

        wrapper.setData({
          iteration,
        });
      });

      it('shows status and date in header', () => {
        expect(findTopbar().text()).toContain('Open');
        expect(findTopbar().text()).toContain('Jun 2, 2020');
        expect(findTopbar().text()).toContain('Jun 8, 2020');
      });

      it('hides empty region and loading spinner', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
        expect(wrapper.find(GlEmptyState).exists()).toBe(false);
      });

      it('shows title and description', () => {
        expect(findTitle().text()).toContain(iteration.title);
        expect(findDescription().text()).toContain(iteration.descriptionHtml);
      });

      it('hides actions dropdown', () => {
        expect(findActionsDropdown().exists()).toBe(false);
      });

      it('shows IterationReportTabs component', () => {
        const iterationReportTabs = wrapper.find(IterationReportTabs);

        expect(iterationReportTabs.props()).toEqual({
          fullPath: defaultProps.fullPath,
          iterationId: iteration.id,
          labelsFetchPath: defaultProps.labelsFetchPath,
          namespaceType: Namespace.Group,
        });
      });
    });

    describe('user with edit permission', () => {
      describe('loading report view', () => {
        beforeEach(() => {
          mountComponent({
            props: {
              ...defaultProps,
              canEdit: true,
            },
            loading: false,
          });

          wrapper.setData({
            iteration,
          });
        });

        it('updates URL when loading form', async () => {
          jest.spyOn(window.history, 'pushState').mockImplementation(() => {});

          clickEditButton();

          await wrapper.vm.$nextTick();

          expect(window.history.pushState).toHaveBeenCalledWith(
            { prev: 'viewIteration' },
            null,
            '/edit',
          );
        });
      });

      describe('loading edit form directly', () => {
        beforeEach(() => {
          mountComponent({
            props: {
              ...defaultProps,
              canEdit: true,
              initiallyEditing: true,
            },
            loading: false,
          });

          wrapper.setData({
            iteration,
          });
        });

        it('updates URL when cancelling form submit', async () => {
          jest.spyOn(window.history, 'pushState').mockImplementation(() => {});
          wrapper.find(IterationForm).vm.$emit('cancel');

          await wrapper.vm.$nextTick();

          expect(window.history.pushState).toHaveBeenCalledWith(
            { prev: 'editIteration' },
            null,
            '/',
          );
        });

        it('updates URL after form submitted', async () => {
          jest.spyOn(window.history, 'pushState').mockImplementation(() => {});
          wrapper.find(IterationForm).vm.$emit('updated');

          await wrapper.vm.$nextTick();

          expect(window.history.pushState).toHaveBeenCalledWith(
            { prev: 'editIteration' },
            null,
            '/',
          );
        });
      });
    });

    describe('actions dropdown to edit iteration', () => {
      describe.each`
        description                    | canEdit  | namespaceType        | canEditIteration
        ${'has permissions'}           | ${true}  | ${Namespace.Group}   | ${true}
        ${'has permissions'}           | ${true}  | ${Namespace.Project} | ${false}
        ${'does not have permissions'} | ${false} | ${Namespace.Group}   | ${false}
        ${'does not have permissions'} | ${false} | ${Namespace.Project} | ${false}
      `(
        'when user $description and they are viewing an iteration within a $namespaceType',
        ({ canEdit, namespaceType, canEditIteration }) => {
          beforeEach(() => {
            mountComponent({
              props: {
                ...defaultProps,
                canEdit,
                namespaceType,
              },
            });

            wrapper.setData({
              iteration,
            });
          });

          it(`${canEditIteration ? 'is shown' : 'is hidden'}`, () => {
            expect(wrapper.find(GlDropdown).exists()).toBe(canEditIteration);
          });
        },
      );
    });
  });
});
