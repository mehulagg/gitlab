import { mount } from '@vue/test-utils';
import upgrade from '~/security_configuration/components/upgrade.vue';

describe('upgrade', () => {
  let wrapper;

  // TODO UPDATE THIS EXPLANATION!
  // could not shallow mount this, this would stub the gl-sprint-f component
  // making it .... what? useless?
  const createComponent = () => {
    console.log('upgrade', upgrade);
    wrapper = mount(upgrade, {});
  };

  const findByID = (id) => wrapper.find(`[data-test-id="${id}"]`);

  afterEach(() => {
    wrapper.destroy();
  });

  // TODO rename description
  describe('on initial load', () => {
    it('renders correct text in link', () => {
      createComponent();
      expect(findByID('upgrade').element.innerText.replace(/\s\s+/g, ' ').trim()).toEqual(
        'Available with upgrade or free trial',
      );
    });

    it('renders link with correct attributes', () => {
      createComponent();
      expect(findByID('upgrade').element.querySelector('a').getAttribute('href')).toEqual(
        'http://www.TOBEDEFINED',
      );
      expect(findByID('upgrade').element.querySelector('a').getAttribute('target')).toEqual(
        '_blank',
      );
      expect(findByID('upgrade').element.querySelector('a').getAttribute('rel')).toEqual(
        'noopener noreferrer',
      );
    });
  });
});
