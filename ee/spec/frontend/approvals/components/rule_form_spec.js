import { createLocalVue, shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import Vuex from 'vuex';
import ApproversList from 'ee/approvals/components/approvers_list.vue';
import ApproversSelect from 'ee/approvals/components/approvers_select.vue';
import BranchesSelect from 'ee/approvals/components/branches_select.vue';
import RuleForm from 'ee/approvals/components/rule_form.vue';
import { TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS } from 'ee/approvals/constants';
import { createStoreOptions } from 'ee/approvals/stores';
import projectSettingsModule from 'ee/approvals/stores/modules/project_settings';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';

const TEST_PROJECT_ID = '7';
const TEST_RULE = {
  id: 10,
  name: 'QA',
  approvalsRequired: 2,
  users: [{ id: 1 }, { id: 2 }, { id: 3 }],
  groups: [{ id: 1 }, { id: 2 }],
};
const TEST_PROTECTED_BRANCHES = [{ id: 2 }, { id: 3 }, { id: 4 }];
const TEST_RULE_WITH_PROTECTED_BRANCHES = {
  ...TEST_RULE,
  protectedBranches: TEST_PROTECTED_BRANCHES,
};
const TEST_APPROVERS = [{ id: 7, type: TYPE_USER }];
const TEST_APPROVALS_REQUIRED = 3;
const TEST_FALLBACK_RULE = {
  approvalsRequired: 1,
  isFallback: true,
};
const TEST_LOCKED_RULE_NAME = 'LOCKED_RULE';
const nameTakenError = {
  response: {
    data: {
      message: {
        name: ['has already been taken'],
      },
    },
  },
};

const localVue = createLocalVue();
localVue.use(Vuex);

const addType = (type) => (x) => Object.assign(x, { type });

describe('EE Approvals RuleForm', () => {
  let wrapper;
  let store;
  let actions;

  const createComponent = (props = {}, mountFn = shallowMount) => {
    wrapper = extendedWrapper(
      mountFn(RuleForm, {
        propsData: props,
        store: new Vuex.Store(store),
        localVue,
        provide: {
          glFeatures: { scopedApprovalRules: true },
        },
        stubs: {
          GlFormGroup: {
            name: 'gl-form-group-stub',
            props: ['state', 'invalidFeedback'],
            template: `
            <div>
              <slot name="label"></slot>
              <slot></slot>
              <slot name="description"></slot>
            </div>`,
          },
          GlFormInput: {
            name: 'gl-form-input-stub',
            props: ['state', 'disabled', 'value'],
            template: `<input />`,
          },
        },
      }),
    );
  };

  const findNameInput = () => wrapper.findByTestId('name');
  const findNameValidation = () => wrapper.findByTestId('name-group');
  const findApprovalsRequiredInput = () => wrapper.findByTestId('approvals-required');
  const findApprovalsRequiredValidation = () => wrapper.findByTestId('approvals-required-group');
  const findApproversSelect = () => wrapper.findComponent(ApproversSelect);
  const findApproversValidation = () => wrapper.findByTestId('approvers-group');
  const findApproversList = () => wrapper.findComponent(ApproversList);
  const findBranchesSelect = () => wrapper.findComponent(BranchesSelect);
  const findBranchesValidation = () => wrapper.findByTestId('branches-group');
  const findValidations = () => [
    findNameValidation(),
    findApprovalsRequiredValidation(),
    findApproversValidation(),
  ];

  const findValidationsWithBranch = () => [
    findNameValidation(),
    findApprovalsRequiredValidation(),
    findApproversValidation(),
    findBranchesValidation(),
  ];

  beforeEach(() => {
    store = createStoreOptions(projectSettingsModule(), { projectId: TEST_PROJECT_ID });

    ['postRule', 'putRule', 'deleteRule', 'putFallbackRule'].forEach((actionName) => {
      jest.spyOn(store.modules.approvals.actions, actionName).mockImplementation(() => {});
    });

    ({ actions } = store.modules.approvals);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when allow multiple rules', () => {
    beforeEach(() => {
      store.state.settings.allowMultiRule = true;
    });

    describe('when has protected branch feature', () => {
      describe('with initial rule', () => {
        beforeEach(() => {
          createComponent({
            isMrEdit: false,
            initRule: TEST_RULE_WITH_PROTECTED_BRANCHES,
          });
        });

        it('on load, it populates initial protected branch ids', () => {
          expect(findBranchesSelect().props('initRule').protectedBranches).toEqual(
            TEST_PROTECTED_BRANCHES,
          );
        });
      });

      describe('without initRule', () => {
        beforeEach(() => {
          store.state.settings.protectedBranches = TEST_PROTECTED_BRANCHES;
        });

        it('at first, shows no validation', () => {
          createComponent({
            isMrEdit: false,
          });

          const inputs = findValidationsWithBranch();
          const invalidInputs = inputs.filter((x) => !x.props('state'));

          expect(invalidInputs).toHaveLength(0);
        });

        it('on submit, shows branches validation', async () => {
          createComponent({
            isMrEdit: false,
          });

          await findBranchesSelect().vm.$emit('input', '3');
          wrapper.vm.submit();

          await nextTick();

          const branchesGroup = findBranchesValidation();
          expect(branchesGroup.props('state')).toBe(false);
          expect(branchesGroup.props('invalidFeedback')).toBe(
            'Please select a valid target branch',
          );
        });

        it('on submit with data, posts rule', async () => {
          createComponent({
            isMrEdit: false,
          });

          const users = [1, 2];
          const groups = [2, 3];
          const userRecords = users.map((id) => ({ id, type: TYPE_USER }));
          const groupRecords = groups.map((id) => ({ id, type: TYPE_GROUP }));
          const branches = [TEST_PROTECTED_BRANCHES[0].id];
          const expected = {
            id: null,
            name: 'Lorem',
            approvalsRequired: 2,
            users,
            groups,
            userRecords,
            groupRecords,
            removeHiddenGroups: false,
            protectedBranchIds: branches,
          };

          await findNameInput().vm.$emit('input', expected.name);
          await findApprovalsRequiredInput().vm.$emit('input', expected.approvalsRequired);
          await findApproversList().vm.$emit('input', [...groupRecords, ...userRecords]);
          await findBranchesSelect().vm.$emit('input', branches[0]);

          wrapper.vm.submit();

          expect(actions.postRule).toHaveBeenCalledWith(expect.anything(), expected);
        });
      });
    });

    describe('without initRule', () => {
      beforeEach(() => {
        createComponent({ isMrEdit: false });
      });

      it('at first, shows no validation', () => {
        const inputs = findValidationsWithBranch();
        const invalidInputs = inputs.filter((x) => !x.props('state'));

        expect(invalidInputs).toHaveLength(0);
      });

      it('on submit, does not dispatch action', () => {
        wrapper.vm.submit();

        expect(actions.postRule).not.toHaveBeenCalled();
      });

      it('on submit, shows name validation', async () => {
        findNameInput().setValue('');

        wrapper.vm.submit();

        await nextTick();

        const nameGroup = findNameValidation();
        expect(nameGroup.props('state')).toBe(false);
        expect(nameGroup.props('invalidFeedback')).toBe('Please provide a name');
      });

      it('on submit, shows approvalsRequired validation', async () => {
        await findApprovalsRequiredInput().vm.$emit('input', -1);

        wrapper.vm.submit();

        await nextTick();

        const approvalsRequiredGroup = findApprovalsRequiredValidation();
        expect(approvalsRequiredGroup.props('state')).toBe(false);
        expect(approvalsRequiredGroup.props('invalidFeedback')).toBe(
          'Please enter a non-negative number',
        );
      });

      it('on submit, shows approvers validation', async () => {
        wrapper.vm.approvers = [];
        wrapper.vm.submit();

        await nextTick();

        const approversGroup = findApproversValidation();
        expect(approversGroup.props('state')).toBe(false);
        expect(approversGroup.props('invalidFeedback')).toBe('Please select and add a member');
      });

      describe('with valid data', () => {
        const users = [1, 2];
        const groups = [2, 3];
        const userRecords = users.map((id) => ({ id, type: TYPE_USER }));
        const groupRecords = groups.map((id) => ({ id, type: TYPE_GROUP }));
        const branches = [TEST_PROTECTED_BRANCHES[0].id];
        const expected = {
          id: null,
          name: 'Lorem',
          approvalsRequired: 2,
          users,
          groups,
          userRecords,
          groupRecords,
          removeHiddenGroups: false,
          protectedBranchIds: branches,
        };

        beforeEach(async () => {
          await findNameInput().vm.$emit('input', expected.name);
          await findApprovalsRequiredInput().vm.$emit('input', expected.approvalsRequired);
          await findApproversList().vm.$emit('input', [...groupRecords, ...userRecords]);
          await findBranchesSelect().vm.$emit('input', branches[0]);
        });

        it('on submit, posts rule', () => {
          wrapper.vm.submit();

          expect(actions.postRule).toHaveBeenCalledWith(expect.anything(), expected);
        });

        it('when submitted with a duplicate name, shows the "taken name" validation', async () => {
          store.state.settings.prefix = 'project-settings';
          jest.spyOn(wrapper.vm, 'postRule').mockRejectedValueOnce(nameTakenError);

          wrapper.vm.submit();

          await nextTick();
          // We have to wait for two ticks because the promise needs to resolve
          // AND the result has to update into the UI
          await nextTick();

          const nameGroup = findNameValidation();
          expect(nameGroup.props('state')).toBe(false);
          expect(nameGroup.props('invalidFeedback')).toBe('Rule name is already taken.');
        });
      });

      it('adds selected approvers on selection', async () => {
        const orig = [{ id: 7, type: TYPE_GROUP }];
        const selected = [{ id: 2, type: TYPE_USER }];
        const expected = [...orig, ...selected];

        await findApproversSelect().vm.$emit('input', orig);
        await findApproversSelect().vm.$emit('input', selected);

        expect(findApproversList().props('value')).toEqual(expected);
      });
    });

    describe('with initRule', () => {
      beforeEach(() => {
        createComponent({
          initRule: TEST_RULE,
          isMrEdit: false,
        });
      });

      it('does not disable the name text field', () => {
        expect(findNameInput().attributes('disabled')).toBe(undefined);
      });

      it('shows approvers', () => {
        const list = findApproversList();

        expect(list.props('value')).toEqual([
          ...TEST_RULE.groups.map(addType(TYPE_GROUP)),
          ...TEST_RULE.users.map(addType(TYPE_USER)),
        ]);
      });

      describe('with valid data', () => {
        const userRecords = TEST_RULE.users.map((x) => ({ ...x, type: TYPE_USER }));
        const groupRecords = TEST_RULE.groups.map((x) => ({ ...x, type: TYPE_GROUP }));
        const users = userRecords.map((x) => x.id);
        const groups = groupRecords.map((x) => x.id);

        const expected = {
          ...TEST_RULE,
          users,
          groups,
          userRecords,
          groupRecords,
          removeHiddenGroups: false,
          protectedBranchIds: [],
        };

        it('on submit, puts rule', () => {
          wrapper.vm.submit();

          expect(actions.putRule).toHaveBeenCalledWith(expect.anything(), expected);
        });

        it('when submitted with a duplicate name, shows the "taken name" validation', async () => {
          store.state.settings.prefix = 'project-settings';
          jest.spyOn(wrapper.vm, 'putRule').mockRejectedValueOnce(nameTakenError);

          wrapper.vm.submit();

          await waitForPromises();

          const nameGroup = findNameValidation();
          expect(nameGroup.props('state')).toBe(false);
          expect(nameGroup.props('invalidFeedback')).toBe('Rule name is already taken.');
        });
      });
    });

    describe('with init fallback rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: TEST_FALLBACK_RULE,
        });

        findNameInput().vm.$emit('input', '');
        findApprovalsRequiredInput().vm.$emit('input', TEST_APPROVALS_REQUIRED);
        findApproversList().vm.$emit('input', []);
      });

      describe('with empty name and empty approvers', () => {
        beforeEach(() => {
          return wrapper.vm.submit();
        });

        it('does not post rule', () => {
          expect(actions.postRule).not.toHaveBeenCalled();
        });

        it('puts fallback rule', () => {
          expect(actions.putFallbackRule).toHaveBeenCalledWith(expect.anything(), {
            approvalsRequired: TEST_APPROVALS_REQUIRED,
          });
        });

        it('does not show any validation errors', () => {
          expect(findValidations().filter((x) => !x.props('state'))).toHaveLength(0);
        });
      });

      describe('with name and empty approvers', () => {
        beforeEach(() => {
          findNameInput().vm.$emit('input', 'Lorem');

          return wrapper.vm.submit();
        });

        it('does not put fallback rule', () => {
          expect(actions.putFallbackRule).not.toHaveBeenCalled();
        });

        it('shows approvers validation error', () => {
          expect(findApproversValidation().props('state')).toBe(false);
        });
      });

      describe('with empty name and approvers', () => {
        beforeEach(() => {
          findApproversList().vm.$emit('input', TEST_APPROVERS);

          return wrapper.vm.submit();
        });

        it('does not put fallback rule', () => {
          expect(actions.putFallbackRule).not.toHaveBeenCalled();
        });

        it('shows name validation error', () => {
          expect(findNameValidation().props('state')).toBe(false);
        });
      });

      describe('with name and approvers', () => {
        beforeEach(() => {
          findApproversList().vm.$emit('input', [{ id: 7, type: TYPE_USER }]);
          findNameInput().vm.$emit('input', 'Lorem');

          return wrapper.vm.submit();
        });

        it('does not put fallback rule', () => {
          expect(actions.putFallbackRule).not.toHaveBeenCalled();
        });

        it('posts new rule', () => {
          expect(actions.postRule).toHaveBeenCalled();
        });
      });
    });

    describe('with hidden groups rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: {
            ...TEST_RULE,
            containsHiddenGroups: true,
          },
        });
      });

      it('shows approvers and hidden group', () => {
        const list = findApproversList();

        expect(list.props('value')).toEqual([
          ...TEST_RULE.groups.map(addType(TYPE_GROUP)),
          ...TEST_RULE.users.map(addType(TYPE_USER)),
          { type: TYPE_HIDDEN_GROUPS },
        ]);
      });

      it('on submit, does not remove hidden groups', () => {
        wrapper.vm.submit();

        expect(actions.putRule).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            removeHiddenGroups: false,
          }),
        );
      });

      describe('and hidden groups removed', () => {
        beforeEach(() => {
          findApproversList().vm.$emit(
            'input',
            findApproversList()
              .props('value')
              .filter((x) => x.type !== TYPE_HIDDEN_GROUPS),
          );
        });

        it('on submit, removes hidden groups', () => {
          wrapper.vm.submit();

          expect(actions.putRule).toHaveBeenCalledWith(
            expect.anything(),
            expect.objectContaining({
              removeHiddenGroups: true,
            }),
          );
        });
      });
    });

    describe('with removed hidden groups rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: {
            ...TEST_RULE,
            containsHiddenGroups: true,
            removeHiddenGroups: true,
          },
        });
      });

      it('does not add hidden groups in approvers', () => {
        expect(
          findApproversList()
            .props('value')
            .every((x) => x.type !== TYPE_HIDDEN_GROUPS),
        ).toBe(true);
      });
    });

    describe('with approval suggestions', () => {
      describe.each`
        defaultRuleName          | expectedDisabledAttribute
        ${'Vulnerability-Check'} | ${true}
        ${'License-Check'}       | ${true}
        ${'Foo Bar Baz'}         | ${false}
      `(
        'with defaultRuleName set to $defaultRuleName',
        ({ defaultRuleName, expectedDisabledAttribute }) => {
          beforeEach(() => {
            createComponent({
              initRule: null,
              defaultRuleName,
            });
          });

          it(`it ${
            expectedDisabledAttribute ? 'disables' : 'does not disable'
          } the name text field`, () => {
            expect(findNameInput().props('disabled')).toBe(expectedDisabledAttribute);
          });
        },
      );
    });

    describe('with new License-Check rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: { ...TEST_RULE, id: null, name: 'License-Check' },
        });
      });

      it('does not disable the name text field', () => {
        expect(findNameInput().props('disabled')).toBe(false);
      });
    });

    describe('with new Vulnerability-Check rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: { ...TEST_RULE, id: null, name: 'Vulnerability-Check' },
        });
      });

      it('does not disable the name text field', () => {
        expect(findNameInput().props('disabled')).toBe(false);
      });
    });

    describe('with editing the License-Check rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: { ...TEST_RULE, name: 'License-Check' },
        });
      });

      it('disables the name text field', () => {
        expect(findNameInput().props('disabled')).toBe(true);
      });
    });

    describe('with editing the Vulnerability-Check rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: { ...TEST_RULE, name: 'Vulnerability-Check' },
        });
      });

      it('disables the name text field', () => {
        expect(findNameInput().props('disabled')).toBe(true);
      });
    });
  });

  describe('when allow only single rule', () => {
    beforeEach(() => {
      store.state.settings.allowMultiRule = false;
    });

    describe('with locked rule name', () => {
      beforeEach(() => {
        store.state.settings.lockedApprovalsRuleName = TEST_LOCKED_RULE_NAME;
        createComponent();
      });

      it('does not render the approval-rule name input', () => {
        expect(findNameInput().exists()).toBe(false);
      });
    });

    describe.each`
      lockedRuleName           | expectedNameSubmitted
      ${TEST_LOCKED_RULE_NAME} | ${TEST_LOCKED_RULE_NAME}
      ${null}                  | ${'Default'}
    `('with no init rule', ({ lockedRuleName, expectedNameSubmitted }) => {
      beforeEach(() => {
        store.state.settings.lockedApprovalsRuleName = lockedRuleName;
        createComponent();
        findApprovalsRequiredInput().vm.$emit('input', TEST_APPROVALS_REQUIRED);
      });

      describe('with approvers selected', () => {
        beforeEach(() => {
          findApproversList().vm.$emit('input', TEST_APPROVERS);

          return wrapper.vm.submit();
        });

        it('posts new rule', () => {
          expect(actions.postRule).toHaveBeenCalledWith(
            expect.anything(),
            expect.objectContaining({
              name: expectedNameSubmitted,
              approvalsRequired: TEST_APPROVALS_REQUIRED,
              users: TEST_APPROVERS.map((x) => x.id),
            }),
          );
        });
      });

      describe('without approvers', () => {
        beforeEach(() => {
          return wrapper.vm.submit();
        });

        it('puts fallback rule', () => {
          expect(actions.putFallbackRule).toHaveBeenCalledWith(expect.anything(), {
            approvalsRequired: TEST_APPROVALS_REQUIRED,
          });
        });
      });
    });

    describe.each`
      lockedRuleName           | inputName | expectedNameSubmitted
      ${TEST_LOCKED_RULE_NAME} | ${'Foo'}  | ${TEST_LOCKED_RULE_NAME}
      ${null}                  | ${'Foo'}  | ${'Foo'}
    `('with init rule', ({ lockedRuleName, inputName, expectedNameSubmitted }) => {
      beforeEach(() => {
        store.state.settings.lockedApprovalsRuleName = lockedRuleName;
      });

      describe('with empty name and empty approvers', () => {
        beforeEach(() => {
          createComponent({
            initRule: { ...TEST_RULE, name: '' },
          });
          findApprovalsRequiredInput().vm.$emit('input', TEST_APPROVALS_REQUIRED);
          findApproversList().vm.$emit('input', []);

          return wrapper.vm.submit();
        });

        it('deletes rule', () => {
          expect(actions.deleteRule).toHaveBeenCalledWith(expect.anything(), TEST_RULE.id);
        });

        it('puts fallback rule', () => {
          expect(actions.putFallbackRule).toHaveBeenCalledWith(expect.anything(), {
            approvalsRequired: TEST_APPROVALS_REQUIRED,
          });
        });
      });

      describe('with name and approvers', () => {
        beforeEach(() => {
          createComponent({
            initRule: { ...TEST_RULE, name: inputName },
          });
          findApprovalsRequiredInput().vm.$emit('input', TEST_APPROVALS_REQUIRED);
          findApproversList().vm.$emit('input', TEST_APPROVERS);

          return wrapper.vm.submit();
        });

        it('puts rule', () => {
          expect(actions.putRule).toHaveBeenCalledWith(
            expect.anything(),
            expect.objectContaining({
              id: TEST_RULE.id,
              name: expectedNameSubmitted,
              approvalsRequired: TEST_APPROVALS_REQUIRED,
              users: TEST_APPROVERS.map((x) => x.id),
            }),
          );
        });
      });
    });
  });
});
