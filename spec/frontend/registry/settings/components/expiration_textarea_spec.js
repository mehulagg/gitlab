import { shallowMount } from '@vue/test-utils';
import { GlSprintf, GlFormTextarea, GlLink } from '@gitlab/ui';
import { GlFormGroup } from 'jest/registry/shared/stubs';
import component from '~/registry/settings/components/expiration_textarea.vue';
import { NAME_REGEX_LENGTH } from '~/registry/shared/constants';

describe('ExpirationTextarea', () => {
  let wrapper;

  const defaultProps = {
    name: 'foo',
    label: 'label-bar',
    placeholder: 'placeholder-baz',
    description: '%{linkStart}description-foo%{linkEnd}',
  };

  const findTextArea = () => wrapper.find(GlFormTextarea);
  const findFormGroup = () => wrapper.find(GlFormGroup);
  const findLabel = () => wrapper.find('[data-testid="label"]');
  const findDescription = () => wrapper.find('[data-testid="description"]');
  const findDescriptionLink = () => wrapper.find(GlLink);

  const mountComponent = props => {
    wrapper = shallowMount(component, {
      stubs: {
        GlSprintf,
        GlFormGroup,
      },
      provide: {
        tagsRegexHelpPagePath: 'foo',
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
    it('has a label', () => {
      mountComponent();

      expect(findLabel().text()).toBe(defaultProps.label);
    });

    it('has a textarea component', () => {
      mountComponent();

      expect(findTextArea().exists()).toBe(true);
    });

    it('has a description', () => {
      mountComponent();

      expect(findDescription().text()).toMatchInterpolatedText(defaultProps.description);
    });

    it('has a description link', () => {
      mountComponent();

      const link = findDescriptionLink();
      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe('foo');
    });
  });

  describe('model', () => {
    it('assigns the right props to the textarea component', () => {
      mountComponent({ value: 'foobar', disabled: true });

      expect(findTextArea().attributes()).toMatchObject({
        id: defaultProps.name,
        value: 'foobar',
        placeholder: defaultProps.placeholder,
        disabled: 'true',
        trim: '',
      });
    });

    it('emits input event when textarea emits input', () => {
      mountComponent();

      findTextArea().vm.$emit('input', 'barfoo');
      expect(wrapper.emitted('input')).toEqual([['barfoo']]);
    });
  });

  describe('regex textarea validation', () => {
    const invalidString = new Array(NAME_REGEX_LENGTH + 2).join(',');

    describe('when error contains an error message', () => {
      const errorMessage = 'something went wrong';

      it('shows the error message on the relevant field', () => {
        mountComponent({ error: errorMessage });

        expect(findFormGroup().attributes('invalid-feedback')).toBe(errorMessage);
      });

      it('gives precedence to API errors compared to local ones', () => {
        mountComponent({
          error: errorMessage,
          value: invalidString,
        });

        expect(findFormGroup().attributes('invalid-feedback')).toBe(errorMessage);
      });
    });

    describe('when error is empty', () => {
      it('if the user did not type validation is not emitted and the state is true', () => {
        mountComponent();

        expect(findFormGroup().props('state')).toBe(true);
        expect(wrapper.emitted('validation')).toBeUndefined();
      });

      it(`if the user typed and is less than ${NAME_REGEX_LENGTH} state is true`, () => {
        mountComponent();

        findTextArea().vm.$emit('input', 'foo');

        expect(findFormGroup().props('state')).toBe(true);
        expect(findTextArea().attributes('state')).toBe('true');
        expect(wrapper.emitted('validation')).toEqual([[true]]);
      });

      describe(`when name regex is longer than ${NAME_REGEX_LENGTH}`, () => {
        beforeEach(() => {
          // since the component has no state we both emit the event and set the prop
          mountComponent({ value: invalidString });

          findTextArea().vm.$emit('input', invalidString);
        });

        it('textAreaValidation state is false', () => {
          expect(findFormGroup().props('state')).toBe(false);
          expect(findTextArea().attributes('state')).toBeUndefined();
        });

        it('emits the @validation event with false payload', () => {
          expect(wrapper.emitted('validation')).toEqual([[false]]);
        });
      });
    });
  });
});
