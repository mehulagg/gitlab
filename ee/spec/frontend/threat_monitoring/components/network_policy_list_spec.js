import { mount } from '@vue/test-utils';
import createStore from 'ee/threat_monitoring/store';
import NetworkPolicyList from 'ee/threat_monitoring/components/network_policy_list.vue';
import { GlTable } from '@gitlab/ui';
import { PREDEFINED_NETWORK_POLICIES } from 'ee/threat_monitoring/constants';
import { useFakeDate } from 'helpers/fake_date';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { mockPoliciesResponse } from '../mock_data';

const mockData = mockPoliciesResponse.map(policy => convertObjectPropsToCamelCase(policy));

describe('NetworkPolicyList component', () => {
  useFakeDate();

  let store;
  let wrapper;

  const factory = ({ propsData, state, data, provide } = {}) => {
    store = createStore();
    Object.assign(store.state.networkPolicies, {
      isLoadingPolicies: false,
      policies: mockData,
      ...state,
    });

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = mount(NetworkPolicyList, {
      propsData: {
        documentationPath: 'documentation_path',
        newPolicyPath: 'new_policy_path',
        ...propsData,
      },
      data,
      store,
      provide,
    });
  };

  const findEnvironmentsPicker = () => wrapper.find({ ref: 'environmentsPicker' });
  const findPoliciesTable = () => wrapper.find(GlTable);
  const findTableEmptyState = () => wrapper.find({ ref: 'tableEmptyState' });
  const findEditorDrawer = () => wrapper.find({ ref: 'editorDrawer' });
  const findPolicyEditor = () => wrapper.find({ ref: 'policyEditor' });
  const findPolicyToggle = () => wrapper.find('[data-testid="policyToggle"]');
  const findApplyButton = () => wrapper.find({ ref: 'applyButton' });
  const findCancelButton = () => wrapper.find({ ref: 'cancelButton' });
  const findAutodevopsAlert = () => wrapper.find('[data-testid="autodevopsAlert"]');

  beforeEach(() => {
    factory({});
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders EnvironmentPicker', () => {
    expect(findEnvironmentsPicker().exists()).toBe(true);
  });

  it('does not render the new policy button', () => {
    const button = wrapper.find('[data-testid="new-policy"]');
    expect(button.exists()).toBe(false);
  });

  describe('given the networkPolicyEditor feature flag is enabled', () => {
    beforeEach(() => {
      factory({
        provide: {
          glFeatures: {
            networkPolicyEditor: true,
          },
        },
      });
    });

    it('renders the new policy button', () => {
      const button = wrapper.find('[data-testid="new-policy"]');
      expect(button.exists()).toBe(true);
    });
  });

  it('renders policies table', () => {
    expect(findPoliciesTable().element).toMatchSnapshot();
  });

  it('renders closed editor drawer', () => {
    const editorDrawer = findEditorDrawer();
    expect(editorDrawer.exists()).toBe(true);
    expect(editorDrawer.props('open')).toBe(false);
  });

  it('renders opened editor drawer on row selection', () => {
    findPoliciesTable()
      .find('td')
      .trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      const editorDrawer = findEditorDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(true);
    });
  });

  it('does not render autodevops alert', () => {
    expect(findAutodevopsAlert().exists()).toBe(false);
  });

  describe('given there is a selected policy', () => {
    beforeEach(() => {
      factory({
        data: () => ({
          selectedPolicyName: 'policy',
          initialManifest: mockData[0].manifest,
          initialEnforcementStatus: mockData[0].isEnabled,
        }),
      });
    });

    it('renders opened editor drawer', () => {
      const editorDrawer = findEditorDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(true);
    });

    it('renders network policy editor with manifest', () => {
      const policyEditor = findPolicyEditor();
      expect(policyEditor.exists()).toBe(true);
      expect(policyEditor.props('value')).toBe(mockData[0].manifest);
    });

    it('renders network policy toggle', () => {
      const policyToggle = findPolicyToggle();
      expect(policyToggle.exists()).toBe(true);
      expect(policyToggle.props('value')).toBe(mockData[0].isEnabled);
    });

    it('renders disabled apply button', () => {
      const applyButton = findApplyButton();
      expect(applyButton.exists()).toBe(true);
      expect(applyButton.props('disabled')).toBe(true);
    });

    it('renders closed editor drawer on Cancel button click', () => {
      const cancelButton = findCancelButton();
      expect(cancelButton.exists()).toBe(true);
      cancelButton.vm.$emit('click');

      return wrapper.vm.$nextTick().then(() => {
        const editorDrawer = findEditorDrawer();
        expect(editorDrawer.exists()).toBe(true);
        expect(editorDrawer.props('open')).toBe(false);
      });
    });

    describe('given there is a policy change', () => {
      beforeEach(() => {
        findPolicyEditor().vm.$emit('input', 'foo');
      });

      it('renders enabled apply button', () => {
        const applyButton = findApplyButton();
        expect(applyButton.exists()).toBe(true);
        expect(applyButton.props('disabled')).toBe(false);
      });

      it('dispatches updatePolicy action on apply button click', () => {
        findApplyButton().vm.$emit('click');

        expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/updatePolicy', {
          environmentId: -1,
          policy: mockData[0],
        });
      });

      describe('given there is an updatePolicy error', () => {
        beforeEach(() => {
          jest.spyOn(store, 'dispatch').mockRejectedValue();
        });

        it('reverts isEnabled change', () => {
          const initial = mockData[0].isEnabled;

          findApplyButton().vm.$emit('click');

          const policyToggle = findPolicyToggle();
          expect(policyToggle.exists()).toBe(true);
          expect(policyToggle.props('value')).toBe(initial);
        });
      });

      describe('given theres is a predefined policy change', () => {
        beforeEach(() => {
          factory({
            data: () => ({
              selectedPolicyName: 'drop-outbound',
              initialManifest: mockData[0].manifest,
              initialEnforcementStatus: mockData[0].isEnabled,
            }),
          });
        });

        it('dispatches createPolicy action on apply button click', () => {
          findApplyButton().vm.$emit('click');

          expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/createPolicy', {
            environmentId: -1,
            policy: PREDEFINED_NETWORK_POLICIES[0],
          });
        });
      });
    });

    describe('given there is a policy enforcement status change', () => {
      beforeEach(() => {
        findPolicyToggle().vm.$emit('change', false);
      });

      it('renders enabled apply button', () => {
        const applyButton = findApplyButton();
        expect(applyButton.exists()).toBe(true);
        expect(applyButton.props('disabled')).toBe(false);
      });
    });
  });

  describe('given there is a default environment with no data to display', () => {
    beforeEach(() => {
      factory({
        state: {
          policies: [],
        },
      });
    });

    it('shows the table empty state', () => {
      expect(findTableEmptyState().element).toMatchSnapshot();
    });
  });

  describe('given autodevops selected policy', () => {
    beforeEach(() => {
      const policies = mockPoliciesResponse;
      policies[0].isAutodevops = true;
      factory({
        state: { policies },
        data: () => ({ selectedPolicyName: 'policy' }),
      });
    });

    it('renders autodevops alert', () => {
      expect(findAutodevopsAlert().exists()).toBe(true);
    });
  });
});
