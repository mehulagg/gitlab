import { mount } from '@vue/test-utils';
import Upgrade from '~/security_configuration/components/upgrade.vue';
import { UPGRADE_CTA, PRICING_HREF, DISCOVER_SECURITY_HREF } from '~/security_configuration/components/features_constants';

let wrapper;
const createComponent = () => {
  wrapper = mount(Upgrade, {});
};

afterEach(() => {
  wrapper.destroy();
});

describe('Upgrade component', () => {
  beforeEach(() => {
    createComponent();
  });

  it('renders correct text in link', () => {
    expect(wrapper.text()).toMatchInterpolatedText(UPGRADE_CTA);
  });


  it('renders link with correct attributes', () => {
    expect(wrapper.find('a').attributes()).toMatchObject({
      href: PRICING_HREF,
      target: '_blank',
    });
  });
});

describe('Upgrade component when Discover Security page is available', () => {
  beforeEach(() => {
    window.gon.dot_com = true;
    createComponent();
  });

  it('renders link with correct attributes', () => {
    expect(wrapper.find('a').attributes()).toMatchObject({
      href: DISCOVER_SECURITY_HREF,
      target: '_blank',
    });
  });
});
