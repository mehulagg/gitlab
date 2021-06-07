import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import EscalationPoliciesWrapper from 'ee/escalation_policies/components/escalation_policies_wrapper.vue';
import EscalationPolicy from 'ee/escalation_policies/components/escalation_policy.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('Escalation Policies Wrapper', () => {
  let wrapper;
  const emptyEscalationPoliciesSvgPath = 'illustration/path.svg';
  const projectPath = 'group/project';
  const mockEscalationPolicies = [{ name: 'policy1' }, { name: 'policy2' }];

  function mountComponent({ loading = false, escalationPolicies = [] } = {}) {
    const $apollo = {
      queries: {
        escalationPolicies: {
          loading,
        },
      },
    };
    wrapper = extendedWrapper(
      shallowMount(EscalationPoliciesWrapper, {
        provide: {
          emptyEscalationPoliciesSvgPath,
          projectPath,
        },
        mocks: {
          $apollo,
        },
        data() {
          return {
            escalationPolicies,
          };
        },
      }),
    );
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findLoader = () => wrapper.findComponent(GlLoadingIcon);
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findEscalationPolicies = () => wrapper.findAllComponents(EscalationPolicy);
  const findAddPolicyBtn = () => wrapper.findByTestId('add-additional-policy-button');

  describe('When', () => {
    describe.each`
      state             | loading  | escalationPolicies        | showsEmptyState | showsLoader
      ${'is loading'}   | ${true}  | ${[]}                     | ${false}        | ${true}
      ${'is empty'}     | ${false} | ${[]}                     | ${true}         | ${false}
      ${'has policies'} | ${false} | ${mockEscalationPolicies} | ${false}        | ${false}
    `(``, ({ state, loading, escalationPolicies, showsEmptyState, showsLoader }) => {
      describe(`${state}`, () => {
        beforeEach(() => {
          mountComponent({
            loading,
            escalationPolicies,
          });
        });

        it(`does ${loading ? 'show' : 'not show'} a loader`, () => {
          expect(findLoader().exists()).toBe(showsLoader);
        });

        it(`does ${showsEmptyState ? 'show' : 'not show'} an empty state`, () => {
          expect(findEmptyState().exists()).toBe(showsEmptyState);
        });

        it(`does ${escalationPolicies.length ? 'show' : 'not show'} escalation policies`, () => {
          expect(findEscalationPolicies()).toHaveLength(escalationPolicies.length);
        });

        it(`does ${escalationPolicies.length ? 'show' : 'not show'} "Add policy" button`, () => {
          expect(findAddPolicyBtn().exists()).toBe(Boolean(escalationPolicies.length));
        });
      });
    });
  });
});
