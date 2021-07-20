import { GlFormCheckbox, GlIcon, GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import ApprovalSettingsCheckbox from 'ee/approvals/components/approval_settings_checkbox.vue';
import { APPROVALS_HELP_PATH } from 'ee/approvals/constants';
import { stubComponent } from 'helpers/stub_component';

describe('ApprovalSettingsCheckbox', () => {
  const label = 'Foo';
  const anchor = 'bar-baz';

  let wrapper;

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(ApprovalSettingsCheckbox, {
      propsData: { label, anchor, ...props },
      stubs: {
        GlFormCheckbox: stubComponent(GlFormCheckbox, {
          props: ['checked'],
        }),
        GlIcon,
        GlLink,
      },
    });
  };

  const findCheckbox = () => wrapper.findComponent(GlFormCheckbox);
  const findIcon = () => wrapper.findComponent(GlIcon);
  const findLink = () => wrapper.findComponent(GlLink);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('rendering', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('shows the label', () => {
      expect(findCheckbox().text()).toBe(label);
    });

    it('sets the correct help link', () => {
      expect(findLink().attributes('href')).toBe(`/help/${APPROVALS_HELP_PATH}#${anchor}`);
    });

    it('shows the icon', () => {
      expect(findIcon().props('name')).toBe('question-o');
    });
  });

  describe('value', () => {
    it('defaults to false when no value is given', () => {
      createWrapper();

      expect(findCheckbox().props('checked')).toBe(false);
    });

    it('sets the checkbox to `true` when a `true` value is given', () => {
      createWrapper({ value: true });

      expect(findCheckbox().props('checked')).toBe(true);
    });

    it('emits an input event when the checkbox is changed', async () => {
      createWrapper();

      await findCheckbox().vm.$emit('input', true);

      expect(wrapper.emitted('input')[0]).toStrictEqual([true]);
    });
  });
});
