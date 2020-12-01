import { shallowMount } from '@vue/test-utils';
import DevopsAdoptionTableCellFlag from 'ee/admin/dev_ops_report/components/devops_adoption_table_cell_flag.vue';

describe('DevopsAdoptionTableCellFlag', () => {
  let wrapper;

  const createComponent = props => {
    wrapper = shallowMount(DevopsAdoptionTableCellFlag, {
      propsData: {
        enabled: true,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('contains the circle-enabled class when enabled', () => {
    createComponent();

    expect(wrapper.classes()).toContain('circle');
    expect(wrapper.classes()).toContain('circle-enabled');
  });

  it('does not contain the circle-enabled class when disabled', () => {
    createComponent({ enabled: false });

    expect(wrapper.classes()).toContain('circle');
    expect(wrapper.classes()).not.toContain('circle-enabled');
  });
});
