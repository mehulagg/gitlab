import { GlFormGroup, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IssueTypeField, { i18n } from '~/issue_show/components/fields/type.vue';
import { IssuableTypes } from '~/issue_show/constants';
import updateIssueStateMutation from '~/issue_show/queries/update_issue_state.mutation.graphql';

describe('Issue type field component', () => {
  let wrapper;

  const $apollo = {
    mutate: jest.fn().mockResolvedValue(),
  };

  const findTypeFromGroup = () => wrapper.findComponent(GlFormGroup);
  const findTypeFromDropDown = () => wrapper.findComponent(GlDropdown);
  const findTypeFromDropDownItems = () => wrapper.findAllComponents(GlDropdownItem);

  const createComponent = ({ data } = {}) => {
    wrapper = shallowMount(IssueTypeField, {
      propsData: {
        formState: {
          issue_type: IssuableTypes.issue,
        },
      },
      data() {
        return {
          issueState: {},
          ...data,
        };
      },
      mocks: {
        $apollo,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders a form group with the correct label', () => {
    expect(findTypeFromGroup().attributes('label')).toBe(i18n.label);
  });

  it('renders a form select with the `issue_type` value', () => {
    expect(findTypeFromDropDown().attributes('value')).toBe(IssuableTypes.issue);
  });

  it('updates the form value when a different type is selected', () => {
    createComponent({ data: { issueState: IssuableTypes.incident } });
    expect(findTypeFromDropDown().attributes('value')).toBe(IssuableTypes.incident);
  });

  it('emits an event when the `issue_type` value is changed', () => {
    expect($apollo.mutate).toHaveBeenCalledTimes(0);
    findTypeFromDropDownItems().at(1).vm.$emit('click', IssuableTypes.incident);

    const expected = {
      mutation: updateIssueStateMutation,
      variables: {
        issue_type: 'incident',
      },
    };

    expect($apollo.mutate).toHaveBeenCalledWith(expected);
    expect($apollo.mutate).toHaveBeenCalledTimes(1);
  });
});
