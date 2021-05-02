import { GlFormGroup, GlFormSelect } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IssueTypeField, { i18n } from '~/issue_show/components/fields/type.vue';
import { IssuableTypes } from '~/issue_show/constants';

describe('Issue type field component', () => {
  let wrapper;

  const findTypeFromGroup = () => wrapper.findComponent(GlFormGroup);
  const findTypeFromSelect = () => wrapper.findComponent(GlFormSelect);

  beforeEach(() => {
    wrapper = shallowMount(IssueTypeField, {
      propsData: {
        formState: {
          issue_type: IssuableTypes.issue,
        },
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders a form group with the correct label', () => {
    expect(findTypeFromGroup().attributes('label')).toBe(i18n.label);
  });

  it('renders a form select with the `issue_type` value', () => {
    expect(findTypeFromSelect().attributes('value')).toBe(IssuableTypes.issue);
  });

  it('emits an event when the `issue_type` value is changed', () => {
    findTypeFromSelect().vm.$emit('change', IssuableTypes.incident);

    expect(wrapper.emitted('update-store-from-state')).toBeTruthy();
    expect(wrapper.emitted('update-store-from-state')[0][0]).toEqual({
      issue_type: IssuableTypes.incident,
    });
  });
});
