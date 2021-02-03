import { mount } from '@vue/test-utils';
import upgrade from '~/security_configuration/components/upgrade.vue';

let wrapper;
const createComponent = () => {
  wrapper = mount(upgrade, {});
};

const findByID = (id) => wrapper.find(`[data-test-id="${id}"]`);

afterEach(() => {
  wrapper.destroy();
});

describe('upgrade component', () => {
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
    expect(findByID('upgrade').element.querySelector('a').getAttribute('target')).toEqual('_blank');
    expect(findByID('upgrade').element.querySelector('a').getAttribute('rel')).toEqual(
      'noopener noreferrer',
    );
  });
});
