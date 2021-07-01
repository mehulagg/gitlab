import { GlLabel } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import DropdownValue from '~/vue_shared/components/sidebar/labels_select_widget/dropdown_value.vue';

import { mockRegularLabel, mockScopedLabel } from './mock_data';

describe('DropdownValue', () => {
  let wrapper;

  const findRegularLabel = () => wrapper.findAllComponents(GlLabel).at(0);
  const findScopedLabel = () => wrapper.findAllComponents(GlLabel).at(1);
  const findWrapper = () => wrapper.find('.js-value');

  const createComponent = (props = {}, slots = {}) => {
    wrapper = shallowMount(DropdownValue, {
      slots,
      propsData: {
        selectedLabels: [mockRegularLabel, mockScopedLabel],
        allowLabelRemove: true,
        allowScopedLabels: true,
        labelsFilterBasePath: '/gitlab-org/my-project/issues',
        labelsFilterParam: 'label_name',
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when there are no labels', () => {
    beforeEach(() => {
      createComponent(
        {
          selectedLabels: [],
        },
        {
          default: 'None',
        },
      );
    });

    it('does not apply `has-labels` class to the wrapping container', () => {
      expect(findWrapper().classes()).not.toContain('has-labels');
    });
  });

  describe('when there are labels', () => {
    beforeEach(() => {
      createComponent();
    });

    it('applies `has-labels` class to the wrapping container', () => {
      expect(findWrapper().classes()).toContain('has-labels');
    });
  });

  describe('methods', () => {
    describe('labelFilterUrl', () => {
      it('returns a label filter URL based on provided label param', () => {
        createComponent();

        expect(findRegularLabel().props('target')).toBe(
          '/gitlab-org/my-project/issues?label_name[]=Foo%20Label',
        );
      });
    });

    describe('scopedLabel', () => {
      beforeEach(() => {
        createComponent();
      });

      it('returns `true` when provided label param is a scoped label', () => {
        expect(wrapper.vm.scopedLabel(mockScopedLabel)).toBe(true);
      });

      it('returns `false` when provided label param is a regular label', () => {
        expect(wrapper.vm.scopedLabel(mockRegularLabel)).toBe(false);
      });
    });
  });

  describe('template', () => {
    it('renders class `has-labels` on component container element when `selectedLabels` is not empty', () => {
      createComponent();

      expect(wrapper.attributes('class')).toContain('has-labels');
    });

    it('renders element containing `None` when `selectedLabels` is empty', () => {
      createComponent(
        {
          selectedLabels: [],
        },
        {
          default: 'None',
        },
      );
      const noneEl = wrapper.find('span.text-secondary');

      expect(noneEl.exists()).toBe(true);
      expect(noneEl.text()).toBe('None');
    });

    it('renders labels when `selectedLabels` is not empty', () => {
      createComponent();

      expect(wrapper.findAll(GlLabel).length).toBe(2);
    });
  });
});
