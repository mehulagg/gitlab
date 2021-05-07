import { shallowMount } from '@vue/test-utils';
import StatusDastProfiles from 'ee/security_configuration/components/status_dast_profiles.vue';

describe('StatusDastProfiles component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(StatusDastProfiles);
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the fixed DAST Profiles status', () => {
    createComponent();

    expect(wrapper.element).toMatchInlineSnapshot(`
      <div>
        Available for on-demand DAST
      </div>
    `);
  });
});
