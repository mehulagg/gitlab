import { GlDropdown } from '@gitlab/ui';
import SecurityPolicyProjectSelector from 'ee/threat_monitoring/components/security_policy_project_selector.vue';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';

describe('SecurityPolicyProjectSelector Component', () => {
  let wrapper;

  const GRAPHQL_FAILED = jest.fn().mockRejectedValue();
  const MUTATE_FAILED = jest
    .fn()
    .mockResolvedValue({ data: { securityPolicyProjectAssign: { errors: ['mutation failed'] } } });
  const MUTATE_SUCCESS = jest
    .fn()
    .mockResolvedValue({ data: { securityPolicyProjectAssign: { clientMutationId: '01' } } });

  const findSaveButton = () => wrapper.findByTestId('save-policy-project');
  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const findErrorAlert = () => wrapper.findByTestId('policy-project-assign-error');
  const findProjectSelector = () => wrapper.findComponent(ProjectSelector);
  const findSuccessAlert = () => wrapper.findByTestId('policy-project-assign-success');

  const selectProject = async () => {
    findProjectSelector().vm.$emit('projectClicked', {
      id: 'gid://gitlab/Project/1',
      name: 'Test 1',
    });
    await wrapper.vm.$nextTick();
    findSaveButton().vm.$emit('click');
    await waitForPromises();
  };

  const createWrapper = ({
    mount = shallowMountExtended,
    mutationResult = MUTATE_SUCCESS,
    propsData = {},
  } = {}) => {
    wrapper = mount(SecurityPolicyProjectSelector, {
      propsData,
      provide: {
        documentationPath: 'test/path/index.md',
        projectPath: 'path/to/project',
      },
      mocks: {
        $apollo: {
          mutate: mutationResult,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('default', () => {
    beforeEach(() => {
      createWrapper();
    });

    it.each`
      findComponent          | state    | title
      ${findDropdown}        | ${true}  | ${'does display the dropdown'}
      ${findProjectSelector} | ${true}  | ${'does display the project selector'}
      ${findErrorAlert}      | ${false} | ${'does not display the error alert'}
      ${findSuccessAlert}    | ${false} | ${'does not display the success alert'}
    `('$title', ({ findComponent, state }) => {
      expect(findComponent().exists()).toBe(state);
    });

    it('renders the "Save Changes" button', () => {
      const button = findSaveButton();
      expect(button.exists()).toBe(true);
      expect(button.attributes('disabled')).toBe('true');
    });
  });

  describe('project selection', () => {
    it('enables the "Save Changes" button if a new project is selected', async () => {
      createWrapper({
        mount: mountExtended,
        propsData: { assignedPolicyProject: { id: 'gid://gitlab/Project/0', name: 'Test 0' } },
      });
      const button = findSaveButton();
      expect(button.attributes('disabled')).toBe('disabled');
      findProjectSelector().vm.$emit('projectClicked', {
        id: 'gid://gitlab/Project/1',
        name: 'Test 1',
      });
      await wrapper.vm.$nextTick();
      expect(button.attributes('disabled')).toBe(undefined);
    });

    it('displays an alert if the security policy project selection succeeds', async () => {
      createWrapper({ mount: mountExtended });
      expect(findErrorAlert().exists()).toBe(false);
      expect(findSuccessAlert().exists()).toBe(false);
      await selectProject();
      expect(findErrorAlert().exists()).toBe(false);
      expect(findSuccessAlert().exists()).toBe(true);
    });

    it('shows an alert if the security policy project selection fails', async () => {
      createWrapper({ mount: mountExtended, mutationResult: MUTATE_FAILED });
      expect(findErrorAlert().exists()).toBe(false);
      expect(findSuccessAlert().exists()).toBe(false);
      await selectProject();
      expect(findErrorAlert().exists()).toBe(true);
      expect(findSuccessAlert().exists()).toBe(false);
    });

    it('shows an alert if GraphQL fails', async () => {
      createWrapper({ mount: mountExtended, mutationResult: GRAPHQL_FAILED });
      expect(findErrorAlert().exists()).toBe(false);
      expect(findSuccessAlert().exists()).toBe(false);
      await selectProject();
      expect(findErrorAlert().exists()).toBe(true);
      expect(findSuccessAlert().exists()).toBe(false);
    });
  });
});
