import { GlFormGroup, GlFormInput } from '@gitlab/ui';
import BranchesSelect from 'ee/status_checks/components/branches_select.vue';
import Form from 'ee/status_checks/components/form.vue';
import {
  EMPTY_STATUS_CHECK,
  NAME_TAKEN_SERVER_ERROR,
  URL_TAKEN_SERVER_ERROR,
} from 'ee/status_checks/constants';
import { stubComponent } from 'helpers/stub_component';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { TEST_PROTECTED_BRANCHES } from '../mock_data';

const projectId = '1';
const statusCheck = {
  protectedBranches: TEST_PROTECTED_BRANCHES,
  branches: TEST_PROTECTED_BRANCHES.map(({ id }) => id),
  name: 'Foo',
  externalUrl: 'https://foo.com',
};

describe('Status checks form', () => {
  let wrapper;

  const createWrapper = (props = {}) => {
    wrapper = shallowMountExtended(Form, {
      propsData: { projectId, statusCheck: EMPTY_STATUS_CHECK, ...props },
      stubs: {
        GlFormGroup: stubComponent(GlFormGroup, {
          props: ['state', 'invalidFeedback'],
        }),
        GlFormInput: stubComponent(GlFormInput, {
          props: ['state', 'disabled', 'value'],
          template: `<input />`,
        }),
      },
    });
  };

  const findNameInput = () => wrapper.findByTestId('name');
  const findNameValidation = () => wrapper.findByTestId('name-group');
  const findBranchesSelect = () => wrapper.findComponent(BranchesSelect);
  const findUrlInput = () => wrapper.findByTestId('url');
  const findUrlValidation = () => wrapper.findByTestId('url-group');
  const findBranchesValidation = () => wrapper.findByTestId('branches-group');

  const findValidations = () => [
    findNameValidation(),
    findUrlValidation(),
    findBranchesValidation(),
  ];
  const inputsAreValid = () => findValidations().every((x) => x.props('state'));

  afterEach(() => {
    wrapper.destroy();
  });

  describe('initialization', () => {
    it('shows empty inputs when no initial data is given', () => {
      createWrapper();

      expect(inputsAreValid()).toBe(true);
      expect(findNameInput().props('value')).toBe('');
      expect(findBranchesSelect().props('selectedBranches')).toStrictEqual([]);
      expect(findUrlInput().props('value')).toBe(undefined);
    });

    it('shows filled inputs when initial data is given', () => {
      createWrapper({ statusCheck });

      expect(inputsAreValid()).toBe(true);
      expect(findNameInput().props('value')).toBe(statusCheck.name);
      expect(findBranchesSelect().props('selectedBranches')).toStrictEqual(statusCheck.branches);
      expect(findUrlInput().props('value')).toBe(statusCheck.externalUrl);
    });
  });

  describe('Validation', () => {
    it('shows the validation messages if showValidation is passed', () => {
      createWrapper({ showValidation: true, branches: ['abc'] });

      expect(inputsAreValid()).toBe(false);
      expect(findNameValidation().props('invalidFeedback')).toBe('Please provide a name.');
      expect(findBranchesValidation().props('invalidFeedback')).toBe(
        'Please select a valid target branch.',
      );
      expect(findUrlValidation().props('invalidFeedback')).toBe('Please provide a valid URL.');
    });

    it('shows the invalid URL error if the URL is unsafe', () => {
      createWrapper({
        showValidation: true,
        statusCheck: { ...statusCheck, externalUrl: 'ftp://foo.com' },
      });

      expect(inputsAreValid()).toBe(false);
      expect(findUrlValidation().props('invalidFeedback')).toBe('Please provide a valid URL.');
    });

    it('shows the serverValidationErrors if given', () => {
      createWrapper({
        showValidation: true,
        serverValidationErrors: [NAME_TAKEN_SERVER_ERROR, URL_TAKEN_SERVER_ERROR],
      });

      expect(inputsAreValid()).toBe(false);
      expect(findNameValidation().props('invalidFeedback')).toBe('Name is already taken.');
      expect(findUrlValidation().props('invalidFeedback')).toBe(
        'External API is already in use by another status check.',
      );
    });

    it('does not show any errors if the values are valid', () => {
      createWrapper({ showValidation: true, statusCheck });

      expect(inputsAreValid()).toBe(true);
    });
  });
});
