import { mount } from '@vue/test-utils';
import { GlFormCheckbox } from '@gitlab/ui';
import DastSiteAuthSection from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_auth_section.vue';

describe('DastSiteAuthSection', () => {
  let wrapper;

  const createComponent = ({ fields, authEnabled } = {}) => {
    wrapper = mount(DastSiteAuthSection, {
      propsData: {
        fields,
        authEnabled,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findByNameAttribute = name => wrapper.find(`[name="${name}"]`);
  const findByTestId = testId => wrapper.find(`[data-testid=${testId}]`);
  const findAuthForm = () => findByTestId('auth-form');
  const findAuthCheckbox = () => wrapper.find(GlFormCheckbox);

  const setAuthentication = ({ enabled }) => {
    findAuthCheckbox().vm.$emit('input', enabled);
    return wrapper.vm.$nextTick();
  };
  const getLatestInputEventPayload = () => {
    const latestInputEvent = [...wrapper.emitted('input')].pop();
    const [payload] = latestInputEvent;
    return payload;
  };

  describe('authentication toggle', () => {
    it.each(
      [true, false],
      'is set correctly when the "auth-enabled" prop is set to "%s"',
      authEnabled => {
        createComponent({ authEnabled });

        expect(findAuthCheckbox().vm.$attrs.checked).toBe(authEnabled);
      },
    );

    it('controls the visibility of the authentication-fields form', async () => {
      expect(findByTestId('auth-form').exists()).toBe(false);
      await setAuthentication({ enabled: true });
      expect(findAuthForm().exists()).toBe(true);
    });

    it.each([true, false])(
      'makes the component emit an "input" event when changed',
      async enabled => {
        await setAuthentication({ enabled });
        expect(getLatestInputEventPayload().isAuthEnabled).toBe(enabled);
      },
    );
  });

  describe('authentication form', () => {
    beforeEach(async () => {
      await setAuthentication({ enabled: true });
    });

    const inputFieldsWithValues = {
      authenticationUrl: 'http://www.gitlab.com',
      userName: 'foo',
      password: 'foo',
      userNameFormField: 'foo',
      passwordFormField: 'foo',
    };

    const inputFieldNames = Object.keys(inputFieldsWithValues);

    describe.each(inputFieldNames)('input field "%s"', inputFieldName => {
      it('is rendered', () => {
        expect(findByNameAttribute(inputFieldName).exists()).toBe(true);
      });

      it('makes the component emit an "input" event when its value changes', () => {
        const input = findByNameAttribute(inputFieldName);
        const newValue = 'foo';

        input.setValue(newValue);

        expect(getLatestInputEventPayload().form.fields[inputFieldName].value).toBe(newValue);
      });
    });

    describe('validity', () => {
      it('is not valid per default', () => {
        expect(getLatestInputEventPayload().form.state).toBe(false);
      });

      it('is valid when correct values are passed in via the "fields" prop', async () => {
        createComponent({ fields: inputFieldsWithValues });

        await setAuthentication({ enabled: true });

        expect(getLatestInputEventPayload().form.state).toBe(true);
      });

      it('is valid once all fields have been entered correctly', () => {
        Object.entries(inputFieldsWithValues).forEach(([inputFieldName, inputFieldValue]) => {
          const input = findByNameAttribute(inputFieldName);
          input.setValue(inputFieldValue);
          input.trigger('blur');
        });

        expect(getLatestInputEventPayload().form.state).toBe(true);
      });
    });
  });
});
