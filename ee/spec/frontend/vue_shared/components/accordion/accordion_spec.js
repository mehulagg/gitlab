import { shallowMount } from '@vue/test-utils';
import { Accordion } from 'ee/vue_shared/components/accordion';

jest.mock('lodash/uniqueId', () => () => 'foo');

describe('Accordion component', () => {
  let wrapper;
  const factory = ({ defaultSlot = '' } = {}) => {
    wrapper = shallowMount(Accordion, {
      scopedSlots: {
        default: defaultSlot,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('contains a default slot', () => {
    const defaultSlot = `<span class="content"></span>`;

    factory({ defaultSlot });

    expect(wrapper.find('.content').exists()).toBe(true);
  });

  it('passes a unique "accordionId" to the default slot', () => {
    const mockUniqueIdValue = 'foo';

    const defaultSlot = '<span>{{ props.accordionId }}</span>';

    factory({ defaultSlot });

    expect(wrapper.text()).toContain(mockUniqueIdValue);
  });
});
