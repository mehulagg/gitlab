import { GlEmptyState } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import EscalationPoliciesWrapper, {
  i18n,
} from 'ee/escalation_policies/components/escalation_policies_wrapper.vue';

describe('AlertManagementEmptyState', () => {
  let wrapper;
  const emptyEscalationPoliciesSvgPath = 'illustration/path.svg';

  function mountComponent() {
    wrapper = shallowMount(EscalationPoliciesWrapper, {
      provide: {
        emptyEscalationPoliciesSvgPath,
      },
    });
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findEmptyState = () => wrapper.findComponent(GlEmptyState);

  describe('Empty state', () => {
    it('shows empty state and passed correct attributes to it', () => {
      expect(findEmptyState().exists()).toBe(true);
      expect(findEmptyState().attributes()).toEqual({
        title: i18n.emptyState.title,
        description: i18n.emptyState.description,
        svgpath: emptyEscalationPoliciesSvgPath,
      });
    });
  });
});
