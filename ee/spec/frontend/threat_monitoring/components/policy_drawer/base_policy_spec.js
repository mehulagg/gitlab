import BasePolicy from 'ee/threat_monitoring/components/policy_drawer/base_policy.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('BasePolicy component', () => {
  let wrapper;

  const findPolicyType = () => wrapper.findByTestId('policy-type');
  const findEnforcementStatusLabel = () => wrapper.findByTestId('enforcement-status-label');

  const factory = (propsData = {}) => {
    wrapper = shallowMountExtended(BasePolicy, {
      propsData,
      slots: {
        type: 'Policy type',
      },
      scopedSlots: {
        default:
          '<span data-testid="enforcement-status-label">{{ props.enforcementStatusLabel }}</span>',
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the policy type', () => {
    factory();

    expect(findPolicyType().text()).toBe('Policy type');
  });

  it.each`
    description   | enabled  | expectedLabel
    ${'enabled'}  | ${true}  | ${'Enabled'}
    ${'disabled'} | ${false} | ${'Disabled'}
  `(
    'renders the enforcement status label when policy is $description',
    ({ enabled, expectedLabel }) => {
      factory({
        policy: {
          enabled,
        },
      });

      expect(findEnforcementStatusLabel().text()).toBe(expectedLabel);
    },
  );
});
