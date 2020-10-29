import { mount } from '@vue/test-utils';
import DastSiteAuthSection from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_auth_section.vue';

describe('DastSiteAuthSection', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = mount(DastSiteAuthSection);
  };

  beforeEach(() => {
    createComponent();
  });

  const findByNameAttribute = name => wrapper.find(`[name="${name}"]`);
  const findByTestId = testId => wrapper.find(`[data-testid=${testId}]`);
  const findAuthToggle = () => findByTestId('auth-toggle');
  const findAuthForm = () => findByTestId('auth-form');

  const setAuthToggle = ({ enabled }) => {
    findAuthToggle().vm.$emit('change', enabled);
    return wrapper.vm.$nextTick();
  };
  const getLatestInputEventPayload = () => {
    const latestInputEvent = [...wrapper.emitted('input')].pop();
    const [payload] = latestInputEvent;
    return payload;
  };

  describe('authentication toggle', () => {
    it('it is disabled per default', () => {
      expect(findAuthToggle().props('value')).toBe(false);
    });

    it('controls the visibility of the authentication-fields form', async () => {
      expect(findByTestId('auth-form').exists()).toBe(false);
      await setAuthToggle({ enabled: true });
      expect(findAuthForm().exists()).toBe(true);
    });

    it.each([true, false])(
      'makes the component emit an "input" event when changed',
      async enabled => {
        await setAuthToggle({ enabled });
        expect(getLatestInputEventPayload().isAuthEnabled).toBe(enabled);
      },
    );
  });

  describe('authentication form', () => {
    beforeEach(async () => {
      await setAuthToggle({ enabled: true });
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
