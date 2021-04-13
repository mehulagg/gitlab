import { shallowMount } from '@vue/test-utils';
import StorageRow from 'ee/other_storage_counter/components/storage_row.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';

let wrapper;
const data = {
  name: 'LFS Package',
  value: 1293346,
};

function factory({ name, value }) {
  wrapper = shallowMount(StorageRow, {
    propsData: {
      name,
      value,
    },
  });
}

describe('Storage Counter row component', () => {
  beforeEach(() => {
    factory(data);
  });

  it('renders provided name', () => {
    expect(wrapper.text()).toContain(data.name);
  });

  it('renders formatted value', () => {
    expect(wrapper.text()).toContain(numberToHumanSize(data.value));
  });
});
