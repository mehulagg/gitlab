import { shallowMount } from '@vue/test-utils';
import { GlFormGroup, GlFormSelect } from 'jest/registry/shared/stubs';
import component from '~/registry/settings/components/expiration_dropdown.vue';

describe('ExpirationDropdown', () => {
  let wrapper;

  const defaultProps = {
    name: 'foo',
    label: 'label-bar',
    formOptions: [{ key: 'foo', label: 'bar' }, { key: 'baz', label: 'zab' }],
  };

  const findFormSelect = () => wrapper.find(GlFormSelect);
  const findFormGroup = () => wrapper.find(GlFormGroup);
  const findOptions = () => wrapper.findAll('[data-testid="options"]');

  const mountComponent = props => {
    wrapper = shallowMount(component, {
      stubs: {
        GlFormGroup,
        GlFormSelect,
      },
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('structure', () => {
    it('has a form-select component', () => {
      mountComponent();
      expect(findFormSelect().exists()).toBe(true);
    });

    it('has the correct options', () => {
      mountComponent();

      expect(findOptions()).toHaveLength(defaultProps.formOptions.length);
    });
  });

  describe('model', () => {
    it('assign the right props to the form-select component', () => {
      mountComponent({ value: 'foobar', disabled: true });

      expect(findFormSelect().props()).toMatchObject({
        value: 'foobar',
        disabled: true,
      });
      expect(findFormSelect().attributes('id')).toBe(defaultProps.name);
    });

    it('assign the right props to the form-group component', () => {
      mountComponent();

      expect(findFormGroup().attributes()).toMatchObject({
        id: `${defaultProps.name}-form-group`,
        'label-for': defaultProps.name,
        label: defaultProps.label,
      });
    });

    it('emits input event when form-select emits input', () => {
      mountComponent();

      findFormSelect().vm.$emit('input', 'barfoo');

      expect(wrapper.emitted('input')).toEqual([['barfoo']]);
    });
  });
});
