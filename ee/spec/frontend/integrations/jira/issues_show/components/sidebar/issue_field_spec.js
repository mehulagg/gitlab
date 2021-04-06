import { GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import IssueField from 'ee/integrations/jira/issues_show/components/sidebar/issue_field.vue';

import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('IssueField', () => {
  let wrapper;

  const defaultProps = {
    icon: 'calendar',
    title: 'Field Title',
  };

  const createComponent = ({ props = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(IssueField, {
        propsData: { ...defaultProps, ...props },
        directives: {
          GlTooltip: createMockDirective(),
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findFieldTitle = () => wrapper.findByTestId('field-title');
  const findFieldValue = () => wrapper.findByTestId('field-value');
  const findFieldCollapsed = () => wrapper.findByTestId('field-collapsed');
  const findFieldCollapsedTooltip = () => getBinding(findFieldCollapsed().element, 'gl-tooltip');
  const findGlIcon = () => wrapper.findComponent(GlIcon);

  it('renders title', () => {
    createComponent();

    expect(findFieldTitle().text()).toBe(defaultProps.title);
  });

  it('renders GlIcon (when collapsed)', () => {
    createComponent();

    expect(findGlIcon().props('name')).toBe(defaultProps.icon);
  });

  describe('without value prop', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders fallback value with "no-value" class', () => {
      expect(findFieldValue().text()).toBe('None');
    });

    it('renders tooltip (when collapsed) with "value" = title', () => {
      const tooltip = findFieldCollapsedTooltip();

      expect(tooltip).toBeDefined();
      expect(tooltip.value.title).toBe(defaultProps.title);
    });
  });

  describe('with value prop', () => {
    const value = 'field value';

    beforeEach(() => {
      createComponent({
        props: { value },
      });
    });

    it('renders value', () => {
      expect(findFieldValue().text()).toBe(value);
    });

    it('renders tooltip (when collapsed) with "value" = value', () => {
      const tooltip = findFieldCollapsedTooltip();

      expect(tooltip).toBeDefined();
      expect(tooltip.value.title).toBe(value);
    });
  });
});
