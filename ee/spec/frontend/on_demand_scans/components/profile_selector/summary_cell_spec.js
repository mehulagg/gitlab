import { mount } from '@vue/test-utils';
import OnDemandScansProfileSummaryCell from 'ee/on_demand_scans/components/profile_selector/summary_cell.vue';

describe('OnDemandScansProfileSummaryCell', () => {
  let wrapper;

  const createFullComponent = () => {
    wrapper = mount(OnDemandScansProfileSummaryCell, {
      propsData: {
        label: 'Row Label',
        value: 'Row Value',
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders properly', () => {
    createFullComponent();

    expect(wrapper.html()).toMatchSnapshot();
  });
});
