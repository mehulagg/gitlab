import { shallowMount } from '@vue/test-utils';

import { mockCurrentUserTodo } from 'jest/issuable_list/mock_data';

import TestCaseShowRoot from 'ee/test_case_show/components/test_case_show_root.vue';
import updateTestCase from 'ee/test_case_show/queries/update_test_case.mutation.graphql';
import markTestCaseTodoDone from 'ee/test_case_show/queries/mark_test_case_todo_done.mutation.graphql';

import createFlash from '~/flash';
import Api from '~/api';

import { mockProvide, mockTestCase } from '../mock_data';

jest.mock('~/flash');

const createComponent = ({ testCase, testCaseQueryLoading = false } = {}) =>
  shallowMount(TestCaseShowRoot, {
    provide: {
      ...mockProvide,
    },
    mocks: {
      $apollo: {
        queries: {
          testCase: {
            loading: testCaseQueryLoading,
            refetch: jest.fn(),
          },
        },
        mutate: jest.fn(),
      },
    },
    data() {
      return {
        testCaseLoading: testCaseQueryLoading,
        testCase: testCaseQueryLoading
          ? {}
          : {
              ...mockTestCase,
              ...testCase,
            },
      };
    },
  });

describe('TestCaseGraphQL Mixin', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('updateTestCase', () => {
    it('calls `$apollo.mutate` with updateTestCase mutation and updateTestCaseInput variables', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({
        data: {
          updateIssue: {
            errors: [],
            issue: mockTestCase,
          },
        },
      });

      wrapper.vm.updateTestCase({
        variables: {
          title: 'Foo',
        },
        errorMessage: 'Something went wrong',
      });

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateTestCase,
        variables: {
          updateTestCaseInput: {
            projectPath: mockProvide.projectFullPath,
            iid: mockProvide.testCaseId,
            title: 'Foo',
          },
        },
      });
    });

    it('calls `createFlash` with errorMessage on promise reject', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue({});

      return wrapper.vm
        .updateTestCase({
          variables: {
            title: 'Foo',
          },
          errorMessage: 'Something went wrong',
        })
        .then(() => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'Something went wrong',
            captureError: true,
            error: expect.any(Object),
          });
        });
    });
  });

  describe('addTestCaseAsTodo', () => {
    it('sets `testCaseTodoUpdateInProgress` to true', () => {
      jest.spyOn(Api, 'addProjectIssueAsTodo').mockResolvedValue({});

      wrapper.vm.addTestCaseAsTodo();

      expect(wrapper.vm.testCaseTodoUpdateInProgress).toBe(true);
    });

    it('calls `Api.addProjectIssueAsTodo` method with params `projectFullPath` and `testCaseId`', () => {
      jest.spyOn(Api, 'addProjectIssueAsTodo').mockResolvedValue({});

      wrapper.vm.addTestCaseAsTodo();

      expect(Api.addProjectIssueAsTodo).toHaveBeenCalledWith(
        mockProvide.projectFullPath,
        mockProvide.testCaseId,
      );
    });

    it('calls `$apollo.queries.testCase.refetch` method on request promise resolve', () => {
      jest.spyOn(Api, 'addProjectIssueAsTodo').mockResolvedValue({});
      jest.spyOn(wrapper.vm.$apollo.queries.testCase, 'refetch');

      return wrapper.vm.addTestCaseAsTodo().then(() => {
        expect(wrapper.vm.$apollo.queries.testCase.refetch).toHaveBeenCalled();
      });
    });

    it('calls `createFlash` method on request promise reject', () => {
      jest.spyOn(Api, 'addProjectIssueAsTodo').mockRejectedValue({});

      return wrapper.vm.addTestCaseAsTodo().then(() => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Something went wrong while adding test case to Todo.',
          captureError: true,
          error: expect.any(Object),
        });
      });
    });

    it('sets `testCaseTodoUpdateInProgress` to false on request promise resolve or reject', () => {
      jest.spyOn(Api, 'addProjectIssueAsTodo').mockRejectedValue({});

      return wrapper.vm.addTestCaseAsTodo().finally(() => {
        expect(wrapper.vm.testCaseTodoUpdateInProgress).toBe(false);
      });
    });
  });

  describe('markTestCaseTodoDone', () => {
    const todoResolvedMutation = {
      data: {
        todoMarkDone: {
          errors: [],
        },
      },
    };

    it('sets `testCaseTodoUpdateInProgress` to true', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(todoResolvedMutation);

      wrapper.vm.markTestCaseTodoDone();

      expect(wrapper.vm.testCaseTodoUpdateInProgress).toBe(true);
    });

    it('calls `$apollo.mutate` with markTestCaseTodoDone mutation and todoMarkDoneInput variables', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(todoResolvedMutation);

      wrapper.vm.markTestCaseTodoDone();

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: markTestCaseTodoDone,
        variables: {
          todoMarkDoneInput: {
            id: mockCurrentUserTodo.id,
          },
        },
      });
    });

    it('calls `$apollo.queries.testCase.refetch` on mutation promise resolve', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(todoResolvedMutation);
      jest.spyOn(wrapper.vm.$apollo.queries.testCase, 'refetch');

      return wrapper.vm.markTestCaseTodoDone().then(() => {
        expect(wrapper.vm.$apollo.queries.testCase.refetch).toHaveBeenCalled();
      });
    });

    it('calls `createFlash` with errorMessage on mutation promise reject', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue({});

      return wrapper.vm.markTestCaseTodoDone().then(() => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Something went wrong while marking test case todo as done.',
          captureError: true,
          error: expect.any(Object),
        });
      });
    });

    it('sets `testCaseTodoUpdateInProgress` to false on mutation promise resolve or reject', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(todoResolvedMutation);

      return wrapper.vm.markTestCaseTodoDone().finally(() => {
        expect(wrapper.vm.testCaseTodoUpdateInProgress).toBe(false);
      });
    });
  });
});
