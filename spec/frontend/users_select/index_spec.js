import {
  createInputsModelExpectation,
  createUnassignedExpectation,
  createAssignedExpectation,
  UsersSelectTestContext,
  findDropdownItemsModel,
  findDropdownItem,
  findAssigneesInputsModel,
  setAssignees,
  toggleDropdown,
  waitForDropdownItems,
} from './test_helper';

describe('~/users_select/index', () => {
  const context = new UsersSelectTestContext({
    fixturePath: 'merge_requests/merge_request_with_single_assignee_feature.html',
  });

  beforeEach(() => {
    context.setup();
  });

  afterEach(() => {
    context.teardown();
  });

  describe('when opened', () => {
    beforeEach(async () => {
      context.createSubject();

      toggleDropdown();
      await waitForDropdownItems();
    });

    it('shows users', () => {
      expect(findDropdownItemsModel()).toEqual(createUnassignedExpectation());
    });

    describe('when users are selected', () => {
      const selectedUsers = [
        UsersSelectTestContext.AUTOCOMPLETE_USERS[2],
        UsersSelectTestContext.AUTOCOMPLETE_USERS[4],
      ];
      const lastSelected = selectedUsers[selectedUsers.length - 1];
      const expectation = createAssignedExpectation({
        header: 'Assignee',
        assigned: [lastSelected],
      });

      beforeEach(() => {
        selectedUsers.forEach((user) => {
          findDropdownItem(user).click();
        });
      });

      it('shows assignee', () => {
        expect(findDropdownItemsModel()).toEqual(expectation);
      });

      it('shows assignee even after close and open', () => {
        toggleDropdown();
        toggleDropdown();

        expect(findDropdownItemsModel()).toEqual(expectation);
      });

      it('updates field', () => {
        expect(findAssigneesInputsModel()).toEqual(createInputsModelExpectation([lastSelected]));
      });
    });
  });

  describe('with preselected user and opened', () => {
    const expectation = createAssignedExpectation({
      header: 'Assignee',
      assigned: [UsersSelectTestContext.AUTOCOMPLETE_USERS[0]],
    });

    beforeEach(async () => {
      setAssignees(UsersSelectTestContext.AUTOCOMPLETE_USERS[0]);

      context.createSubject();

      toggleDropdown();
      await waitForDropdownItems();
    });

    it('shows users', () => {
      expect(findDropdownItemsModel()).toEqual(expectation);
    });

    // Regression test for https://gitlab.com/gitlab-org/gitlab/-/issues/325991
    describe('when closed and reopened', () => {
      beforeEach(() => {
        toggleDropdown();
        toggleDropdown();
      });

      it('shows users', () => {
        expect(findDropdownItemsModel()).toEqual(expectation);
      });
    });
  });
});
