import { GlDropdown, GlLoadingIcon, GlSearchBoxByType } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { createLocalVue } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import DevopsAdoptionAddDropdown from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_add_dropdown.vue';
import bulkEnableDevopsAdoptionNamespacesMutation from 'ee/analytics/devops_report/devops_adoption/graphql/mutations/bulk_enable_devops_adoption_namespaces.mutation.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import {
  groupNodes,
  groupGids,
  devopsAdoptionNamespaceData,
  genericDeleteErrorMessage,
} from '../mock_data';

const localVue = createLocalVue();
Vue.use(VueApollo);

const mutate = jest.fn().mockResolvedValue({
  data: {
    bulkEnableDevopsAdoptionNamespaces: {
      enabledNamespaces: [devopsAdoptionNamespaceData.nodes[0]],
      errors: [],
    },
  },
});
const mutateWithErrors = jest.fn().mockRejectedValue(genericDeleteErrorMessage);

describe('DevopsAdoptionAddDropdown', () => {
  let wrapper;

  const createComponent = ({ enableNamespaceSpy = mutate, provide = {}, props = {} } = {}) => {
    const mockApollo = createMockApollo([
      [bulkEnableDevopsAdoptionNamespacesMutation, enableNamespaceSpy],
    ]);

    wrapper = shallowMountExtended(DevopsAdoptionAddDropdown, {
      localVue,
      apolloProvider: mockApollo,
      propsData: {
        groups: [],
        ...props,
      },
      provide,
      directives: {
        GlTooltip: createMockDirective(),
      },
      stubs: {
        GlDropdown,
      },
    });
  };

  const findDropdown = () => wrapper.findComponent(GlDropdown);

  const clickFirstRow = () => wrapper.findByTestId('group-row').vm.$emit('click');

  describe('default behaviour', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays a dropdown component', () => {
      expect(findDropdown().exists()).toBe(true);
    });

    it('displays the correct text', () => {
      const dropdown = findDropdown();

      expect(dropdown.props('text')).toBe('Add group to table');
      expect(dropdown.props('headerText')).toBe('Add group');
    });

    it('is disabled', () => {
      expect(findDropdown().props('disabled')).toBe(true);
    });

    it('displays a tooltip', () => {
      const tooltip = getBinding(findDropdown().element, 'gl-tooltip');

      expect(tooltip).toBeDefined();
      expect(tooltip.value).toBe('This group has no sub-groups');
    });
  });

  describe('with isGroup === true', () => {
    it('displays the correct text', () => {
      createComponent({ provide: { isGroup: true } });

      const dropdown = findDropdown();

      expect(dropdown.props('text')).toBe('Add sub-group to table');
      expect(dropdown.props('headerText')).toBe('Add sub-group');
    });
  });

  describe('with sub-groups available', () => {
    describe('displays the correct components', () => {
      beforeEach(() => {
        createComponent({ props: { hasSubgroups: true } });
      });

      it('is enabled', () => {
        expect(findDropdown().props('disabled')).toBe(false);
      });

      it('does not display a tooltip', () => {
        const tooltip = getBinding(findDropdown().element, 'gl-tooltip');

        expect(tooltip.value).toBe(false);
      });

      it('displays the no results message', () => {
        const noResultsRow = wrapper.findByTestId('no-results');

        expect(noResultsRow.exists()).toBe(true);
        expect(noResultsRow.text()).toBe('No results…');
      });
    });

    describe('with group data', () => {
      it('displays the corrent number of rows', () => {
        createComponent({ props: { hasSubgroups: true, groups: groupNodes } });

        expect(wrapper.findAllByTestId('group-row')).toHaveLength(groupNodes.length);
      });

      describe('on row click', () => {
        describe.each`
          level      | groupGid
          ${'group'} | ${groupGids[0]}
          ${'admin'} | ${null}
        `('$level level sucessful request', ({ groupGid }) => {
          beforeEach(() => {
            createComponent({
              props: { hasSubgroups: true, groups: groupNodes },
              provide: { groupGid },
            });

            clickFirstRow();
          });

          it('makes a request to enable the selected group', () => {
            expect(mutate).toHaveBeenCalledWith({
              displayNamespaceId: groupGid,
              namespaceIds: ['gid://gitlab/Group/1'],
            });
          });

          it('emits the enabledNamespacesAdded event', () => {
            const [params] = wrapper.emitted().enabledNamespacesAdded[0];

            expect(params).toStrictEqual([devopsAdoptionNamespaceData.nodes[0]]);
          });
        });

        describe('on error', () => {
          beforeEach(() => {
            jest.spyOn(Sentry, 'captureException');

            createComponent({
              enableNamespaceSpy: mutateWithErrors,
              props: { hasSubgroups: true, groups: groupNodes },
            });

            clickFirstRow();
          });

          it('calls sentry', () => {
            expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(
              genericDeleteErrorMessage,
            );
          });

          it('does not emit the enabledNamespacesAdded event', () => {
            expect(wrapper.emitted().enabledNamespacesAdded).not.toBeDefined();
          });
        });
      });
    });

    describe('while loading', () => {
      beforeEach(() => {
        wrapper.setProps({ isLoadingGroups: true });
      });

      it('displays a loading icon', () => {
        expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
      });

      it('does not display any rows', () => {
        expect(wrapper.findAllByTestId('group-row')).toHaveLength(0);
      });
    });

    describe('searching', () => {
      it('emits the fetchGroups event ', () => {
        createComponent({ props: { hasSubgroups: true } });

        wrapper.findComponent(GlSearchBoxByType).vm.$emit('input', 'blah');

        jest.runAllTimers();

        const [params] = wrapper.emitted().fetchGroups[0];

        expect(params).toBe('blah');
      });
    });
  });
});
