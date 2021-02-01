import { mount } from '@vue/test-utils';
import ConfigurationTable from '~/security_configuration/components/configuration_table.vue';


describe('configuration Table', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = mount(ConfigurationTable, {});
  };
  // const findTableRow = () => wrapper.findAll('[data-test-class="configuration-table-entry"]');

  afterEach(() => {
    wrapper.destroy();
  });

  // TODO rename description
  describe('on initial load', () => {

    // this needs to be removed
    it('foo bar', () => {
      createComponent();
      console.log(wrapper.html());
        expect(true).toBe(true);
      });
  });

  // TODO
  // texte testen
  // error handling testen!




  // TODO test error message
  // find row
  // find component in managecolumn
  // emit error message from that component
  // check that alert is rendered with correct message




  // TODO check for the specifi strings in the table
  // shallowMount
});
