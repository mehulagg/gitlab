import { shallowMount, createLocalVue } from '@vue/test-utils';
import { nextTick } from 'vue';
import Vuex from 'vuex';
import ApproverTypeSelect from 'ee/approvals/components/approver_type_select.vue';
import ApproversList from 'ee/approvals/components/approvers_list.vue';
import ApproversSelect from 'ee/approvals/components/approvers_select.vue';
import BranchesSelect from 'ee/approvals/components/branches_select.vue';
import RuleForm from 'ee/approvals/components/rule_form.vue';
import {
  TYPE_USER,
  TYPE_GROUP,
  TYPE_HIDDEN_GROUPS,
  RULE_TYPE_EXTERNAL_APPROVAL,
} from 'ee/approvals/constants';
import { createStoreOptions } from 'ee/approvals/stores';
import projectSettingsModule from 'ee/approvals/stores/modules/project_settings';
import waitForPromises from 'helpers/wait_for_promises';
import { createExternalRule } from '../mocks';

const TEST_PROJECT_ID = '7';
const TEST_RULE = {
  id: 10,
  name: 'QA',
  approvalsRequired: 2,
  users: [{ id: 1 }, { id: 2 }, { id: 3 }],
  groups: [{ id: 1 }, { id: 2 }],
};
const TEST_PROTECTED_BRANCHES = [{ id: 2 }];
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
const TEST_EXTERNAL_APPROVAL_RULE = {
  ...createExternalRule(),
  protectedBranches: TEST_PROTECTED_BRANCHES,
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
const urlTakenError = {
  response: {
    data: {
      message: ['External url has already been taken'],
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

  const createComponent = (props = {}, options = {}) => {
    wrapper = shallowMount(RuleForm, {
      propsData: props,
      store: new Vuex.Store(store),
      localVue,
      provide: {
        glFeatures: {
          ffComplianceApprovalGates: true,
          scopedApprovalRules: true,
          ...options.provide?.glFeatures,
        },
      },
    });
  };
  const findValidation = (node, hasProps = false) => ({
    feedback: node.element.nextElementSibling.textContent,
    isValid: hasProps ? !node.props('isInvalid') : !node.classes('is-invalid'),
  });

  const findNameInput = () => wrapper.find('input[name=name]');
  const findNameValidation = () => findValidation(findNameInput(), false);
  const findApprovalsRequiredInput = () => wrapper.find('input[name=approvals_required]');
  const findApprovalsRequiredValidation = () => findValidation(findApprovalsRequiredInput(), false);
  const findApproversSelect = () => wrapper.find(ApproversSelect);
  const findApproversValidation = () => findValidation(findApproversSelect(), true);
  const findApproversList = () => wrapper.find(ApproversList);
  const findBranchesSelect = () => wrapper.find(BranchesSelect);
  const findApproverTypeSelect = () => wrapper.findComponent(ApproverTypeSelect);
  const findExternalUrlInput = () => wrapper.find('input[name=approval_gate_url');
  const findExternalUrlValidation = () => findValidation(findExternalUrlInput(), false);
  const findBranchesValidation = () => findValidation(findBranchesSelect(), true);
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

  const findValidationForExternal = () => [
    findNameValidation(),
    findExternalUrlValidation(),
    findBranchesValidation(),
  ];

  beforeEach(() => {
    store = createStoreOptions(projectSettingsModule(), { projectId: TEST_PROJECT_ID });

    ['postRule', 'putRule', 'deleteRule', 'putFallbackRule', 'postExternalApprovalRule'].forEach(
      (actionName) => {
        jest.spyOn(store.modules.approvals.actions, actionName).mockImplementation(() => {});
      },
    );

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
          expect(wrapper.vm.branches).toEqual(TEST_PROTECTED_BRANCHES.map((x) => x.id));
        });
      });

      describe('without initRule', () => {
        beforeEach(() => {
          store.state.settings.protectedBranches = TEST_PROTECTED_BRANCHES;
          createComponent({
            isMrEdit: false,
          });
        });

        it('at first, shows no validation', () => {
          const inputs = findValidationsWithBranch();
          const invalidInputs = inputs.filter((x) => !x.isValid);
          const feedbacks = inputs.map((x) => x.feedback);

          expect(invalidInputs.length).toBe(0);
          expect(feedbacks.every((str) => !str.length)).toBe(true);
        });

        it('on submit, shows branches validation', (done) => {
          wrapper.vm.branches = ['3'];
          wrapper.vm.submit();

          localVue
            .nextTick()
            .then(() => {
              expect(findBranchesValidation()).toEqual({
                isValid: false,
                feedback: 'Please select a valid target branch',
              });
            })
            .then(done)
            .catch(done.fail);
        });

        it('on submit with data, posts rule', () => {
          const users = [1, 2];
          const groups = [2, 3];
          const userRecords = users.map((id) => ({ id, type: TYPE_USER }));
          const groupRecords = groups.map((id) => ({ id, type: TYPE_GROUP }));
          const branches = TEST_PROTECTED_BRANCHES.map((x) => x.id);
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

          findNameInput().setValue(expected.name);
          findApprovalsRequiredInput().setValue(expected.approvalsRequired);
          wrapper.vm.approvers = groupRecords.concat(userRecords);
          wrapper.vm.branches = expected.protectedBranchIds;

          wrapper.vm.submit();

          expect(actions.postRule).toHaveBeenCalledWith(expect.anything(), expected);
        });
      });
    });

    describe('when the rule is an external rule', () => {
      describe('with initial rule', () => {
        beforeEach(() => {
          createComponent({
            isMrEdit: false,
            initRule: TEST_EXTERNAL_APPROVAL_RULE,
          });
        });

        it('does not render the approver type select input', () => {
          expect(findApproverTypeSelect().exists()).toBe(false);
        });

        it('on load, it populates the external URL', () => {
          expect(findExternalUrlInput().element.value).toBe(
            TEST_EXTERNAL_APPROVAL_RULE.externalUrl,
          );
        });
      });

      describe('without an initial rule', () => {
        beforeEach(() => {
          createComponent({
            isMrEdit: false,
          });
          findApproverTypeSelect().vm.$emit('input', RULE_TYPE_EXTERNAL_APPROVAL);
        });

        it('renders the approver type select input', () => {
          expect(findApproverTypeSelect().exists()).toBe(true);
        });

        it('renders the inputs for external rules', () => {
          expect(findNameInput().exists()).toBe(true);
          expect(findExternalUrlInput().exists()).toBe(true);
          expect(findBranchesSelect().exists()).toBe(true);
        });

        it('does not render the user and group input fields', () => {
          expect(findApprovalsRequiredInput().exists()).toBe(false);
          expect(findApproversList().exists()).toBe(false);
          expect(findApproversSelect().exists()).toBe(false);
        });

        it('at first, shows no validation', () => {
          const inputs = findValidationForExternal();
          const invalidInputs = inputs.filter((x) => !x.isValid);
          const feedbacks = inputs.map((x) => x.feedback);

          expect(invalidInputs.length).toBe(0);
          expect(feedbacks.every((str) => !str.length)).toBe(true);
        });

        it('on submit, does not dispatch action', () => {
          wrapper.vm.submit();

          expect(actions.postExternalApprovalRule).not.toHaveBeenCalled();
        });

        it('on submit, shows name validation', async () => {
          findExternalUrlInput().setValue('');

          wrapper.vm.submit();

          await nextTick();

          expect(findExternalUrlValidation()).toEqual({
            isValid: false,
            feedback: 'Please provide a valid URL',
          });
        });

        describe('with valid data', () => {
          const branches = TEST_PROTECTED_BRANCHES.map((x) => x.id);
          const expected = {
            id: null,
            name: 'Lorem',
            externalUrl: 'https://gitlab.com/',
            protectedBranchIds: branches,
          };

          beforeEach(() => {
            findNameInput().setValue(expected.name);
            findExternalUrlInput().setValue(expected.externalUrl);
            wrapper.vm.branches = expected.protectedBranchIds;
          });

          it('on submit, posts external approval rule', () => {
            wrapper.vm.submit();

            expect(actions.postExternalApprovalRule).toHaveBeenCalledWith(
              expect.anything(),
              expected,
            );
          });

          it('when submitted with a duplicate external URL, shows the "url already taken" validation', async () => {
            store.state.settings.prefix = 'project-settings';
            jest.spyOn(wrapper.vm, 'postExternalApprovalRule').mockRejectedValueOnce(urlTakenError);

            wrapper.vm.submit();

            await waitForPromises();

            expect(findExternalUrlValidation()).toEqual({
              isValid: false,
              feedback: 'External url has already been taken',
            });
          });
        });
      });
    });

    describe('without initRule', () => {
      beforeEach(() => {
        createComponent();
      });

      it('at first, shows no validation', () => {
        const inputs = findValidations();
        const invalidInputs = inputs.filter((x) => !x.isValid);
        const feedbacks = inputs.map((x) => x.feedback);

        expect(invalidInputs.length).toBe(0);
        expect(feedbacks.every((str) => !str.length)).toBe(true);
      });

      it('on submit, does not dispatch action', () => {
        wrapper.vm.submit();

        expect(actions.postRule).not.toHaveBeenCalled();
      });

      it('on submit, shows name validation', (done) => {
        findNameInput().setValue('');

        wrapper.vm.submit();

        localVue
          .nextTick()
          .then(() => {
            expect(findNameValidation()).toEqual({
              isValid: false,
              feedback: 'Please provide a name',
            });
          })
          .then(done)
          .catch(done.fail);
      });

      it('on submit, shows approvalsRequired validation', (done) => {
        findApprovalsRequiredInput().setValue(-1);

        wrapper.vm.submit();

        localVue
          .nextTick()
          .then(() => {
            expect(findApprovalsRequiredValidation()).toEqual({
              isValid: false,
              feedback: 'Please enter a non-negative number',
            });
          })
          .then(done)
          .catch(done.fail);
      });

      it('on submit, shows approvers validation', (done) => {
        wrapper.vm.approvers = [];
        wrapper.vm.submit();

        localVue
          .nextTick()
          .then(() => {
            expect(findApproversValidation()).toEqual({
              isValid: false,
              feedback: 'Please select and add a member',
            });
          })
          .then(done)
          .catch(done.fail);
      });

      describe('with valid data', () => {
        const users = [1, 2];
        const groups = [2, 3];
        const userRecords = users.map((id) => ({ id, type: TYPE_USER }));
        const groupRecords = groups.map((id) => ({ id, type: TYPE_GROUP }));
        const branches = TEST_PROTECTED_BRANCHES.map((x) => x.id);
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

        beforeEach(() => {
          findNameInput().setValue(expected.name);
          findApprovalsRequiredInput().setValue(expected.approvalsRequired);
          wrapper.vm.approvers = groupRecords.concat(userRecords);
          wrapper.vm.branches = expected.protectedBranchIds;
        });

        it('on submit, posts rule', () => {
          wrapper.vm.submit();

          expect(actions.postRule).toHaveBeenCalledWith(expect.anything(), expected);
        });

        it('when submitted with a duplicate name, shows the "taken name" validation', async () => {
          store.state.settings.prefix = 'project-settings';
          jest.spyOn(wrapper.vm, 'postRule').mockRejectedValueOnce(nameTakenError);

          wrapper.vm.submit();

          await wrapper.vm.$nextTick();
          // We have to wait for two ticks because the promise needs to resolve
          // AND the result has to update into the UI
          await wrapper.vm.$nextTick();

          expect(findNameValidation()).toEqual({
            isValid: false,
            feedback: 'Rule name is already taken.',
          });
        });
      });

      it('adds selected approvers on selection', () => {
        const orig = [{ id: 7, type: TYPE_GROUP }];
        const selected = [{ id: 2, type: TYPE_USER }];
        const expected = [...orig, ...selected];

        wrapper.setData({ approvers: orig });
        wrapper.vm.$options.watch.approversToAdd.call(wrapper.vm, selected);

        expect(wrapper.vm.approvers).toEqual(expected);
      });
    });

    describe('with initRule', () => {
      beforeEach(() => {
        createComponent({
          initRule: TEST_RULE,
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

        beforeEach(() => {
          findNameInput().setValue(expected.name);
          findApprovalsRequiredInput().setValue(expected.approvalsRequired);
          wrapper.vm.approvers = groupRecords.concat(userRecords);
          wrapper.vm.branches = expected.protectedBranchIds;
        });

        it('on submit, puts rule', () => {
          wrapper.vm.submit();

          expect(actions.putRule).toHaveBeenCalledWith(expect.anything(), expected);
        });

        it('when submitted with a duplicate name, shows the "taken name" validation', async () => {
          store.state.settings.prefix = 'project-settings';
          jest.spyOn(wrapper.vm, 'putRule').mockRejectedValueOnce(nameTakenError);

          wrapper.vm.submit();

          await wrapper.vm.$nextTick();
          // We have to wait for two ticks because the promise needs to resolve
          // AND the result has to update into the UI
          await wrapper.vm.$nextTick();

          expect(findNameValidation()).toEqual({
            isValid: false,
            feedback: 'Rule name is already taken.',
          });
        });
      });
    });

    describe('with init fallback rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: TEST_FALLBACK_RULE,
        });

        wrapper.vm.name = '';
        wrapper.vm.approvers = [];
        wrapper.vm.approvalsRequired = TEST_APPROVALS_REQUIRED;
      });

      describe('with empty name and empty approvers', () => {
        beforeEach((done) => {
          wrapper.vm.submit();
          localVue.nextTick(done);
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
          expect(findValidations().every((x) => x.isValid)).toBe(true);
        });
      });

      describe('with name and empty approvers', () => {
        beforeEach((done) => {
          wrapper.vm.name = 'Lorem';
          wrapper.vm.submit();

          localVue.nextTick(done);
        });

        it('does not put fallback rule', () => {
          expect(actions.putFallbackRule).not.toHaveBeenCalled();
        });

        it('shows approvers validation error', () => {
          expect(findApproversValidation().isValid).toBe(false);
        });
      });

      describe('with empty name and approvers', () => {
        beforeEach((done) => {
          wrapper.vm.approvers = TEST_APPROVERS;
          wrapper.vm.submit();

          localVue.nextTick(done);
        });

        it('does not put fallback rule', () => {
          expect(actions.putFallbackRule).not.toHaveBeenCalled();
        });

        it('shows name validation error', () => {
          expect(findNameValidation().isValid).toBe(false);
        });
      });

      describe('with name and approvers', () => {
        beforeEach((done) => {
          wrapper.vm.approvers = [{ id: 7, type: TYPE_USER }];
          wrapper.vm.name = 'Lorem';
          wrapper.vm.submit();

          localVue.nextTick(done);
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
          wrapper.vm.approvers = wrapper.vm.approvers.filter((x) => x.type !== TYPE_HIDDEN_GROUPS);
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
        defaultRuleName          | expectedDisabledAttribute | approverTypeSelect
        ${'Vulnerability-Check'} | ${'disabled'}             | ${false}
        ${'License-Check'}       | ${'disabled'}             | ${false}
        ${'Foo Bar Baz'}         | ${undefined}              | ${true}
      `(
        'with defaultRuleName set to $defaultRuleName',
        ({ defaultRuleName, expectedDisabledAttribute, approverTypeSelect }) => {
          beforeEach(() => {
            createComponent({
              initRule: null,
              isMrEdit: false,
              defaultRuleName,
            });
          });

          it(`it ${
            expectedDisabledAttribute ? 'disables' : 'does not disable'
          } the name text field`, () => {
            expect(findNameInput().attributes('disabled')).toBe(expectedDisabledAttribute);
          });

          it(`${
            approverTypeSelect ? 'renders' : 'does not render'
          } the approver type select`, () => {
            expect(findApproverTypeSelect().exists()).toBe(approverTypeSelect);
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
        expect(findNameInput().attributes('disabled')).toBe(undefined);
      });
    });

    describe('with new Vulnerability-Check rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: { ...TEST_RULE, id: null, name: 'Vulnerability-Check' },
        });
      });

      it('does not disable the name text field', () => {
        expect(findNameInput().attributes('disabled')).toBe(undefined);
      });
    });

    describe('with editing the License-Check rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: { ...TEST_RULE, name: 'License-Check' },
        });
      });

      it('disables the name text field', () => {
        expect(findNameInput().attributes('disabled')).toBe('disabled');
      });
    });

    describe('with editing the Vulnerability-Check rule', () => {
      beforeEach(() => {
        createComponent({
          initRule: { ...TEST_RULE, name: 'Vulnerability-Check' },
        });
      });

      it('disables the name text field', () => {
        expect(findNameInput().attributes('disabled')).toBe('disabled');
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
        wrapper.vm.approvalsRequired = TEST_APPROVALS_REQUIRED;
      });

      describe('with approvers selected', () => {
        beforeEach(() => {
          wrapper.vm.approvers = TEST_APPROVERS;
          wrapper.vm.submit();

          return localVue.nextTick();
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
          wrapper.vm.submit();

          return localVue.nextTick();
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
        createComponent({
          initRule: TEST_RULE,
        });
        wrapper.vm.approvalsRequired = TEST_APPROVALS_REQUIRED;
      });

      describe('with empty name and empty approvers', () => {
        beforeEach(() => {
          wrapper.vm.name = '';
          wrapper.vm.approvers = [];

          wrapper.vm.submit();

          return localVue.nextTick();
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
        beforeEach((done) => {
          wrapper.vm.name = inputName;
          wrapper.vm.approvers = TEST_APPROVERS;
          wrapper.vm.submit();

          localVue.nextTick(done);
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

  describe('when the approval gates feature is disabled', () => {
    it('does not render the approver type select input', async () => {
      createComponent(
        { isMrEdit: false },
        {
          provide: {
            glFeatures: {
              ffComplianceApprovalGates: false,
            },
          },
        },
      );

      await nextTick();

      expect(findApproverTypeSelect().exists()).toBe(false);
    });
  });
});
