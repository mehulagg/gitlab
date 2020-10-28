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
  const enableAuthToggle = () => {
    findAuthToggle().trigger('click');
    return wrapper.vm.$nextTick();
  };

  describe('authentication toggle', () => {
    it('it is disabled per default', () => {
      expect(findAuthToggle().props('value')).toBe(false);
    });

    it('controls the visibility of the authentication-fields form', async () => {
      expect(findByTestId('auth-form').exists()).toBe(false);
      await enableAuthToggle();
      expect(findAuthForm().exists()).toBe(true);
    });
  });

  describe('authentication form', () => {
    beforeEach(async () => {
      await enableAuthToggle();
    });

    const inputFields = ['authenticationUrl', 'password', 'userNameFormField', 'passwordFormField'];

    describe.each(inputFields)('input field "%s"', inputField => {
      it('is rendered', () => {
        expect(findByNameAttribute(inputField).exists()).toBe(true);
      });

      it('makes the component emit an "input" event when its value changes', () => {
        const input = findByNameAttribute(inputField);
        const newValue = 'foo';

        input.setValue(newValue);

        const [[firstCallArgument]] = wrapper.emitted('input');
        expect(firstCallArgument.form.fields[inputField].value).toBe(newValue);
      });
    });
  });
});
