import { GlAlert, GlLink } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import ConfigurationTable from 'ee/security_configuration/components/configuration_table.vue';
import FeatureStatus from 'ee/security_configuration/components/feature_status.vue';
import ManageFeature from 'ee/security_configuration/components/manage_feature.vue';
import stubChildren from 'helpers/stub_children';
import { generateFeatures } from './helpers';

const propsData = {
  features: [],
  autoDevopsEnabled: false,
  gitlabCiPresent: false,
  gitlabCiHistoryPath: '/ci/history',
};

describe('ConfigurationTable component', () => {
  let wrapper;
  const mockFeatures = [
    ...generateFeatures(1, {
      name: 'foo',
      description: 'Foo description',
      helpPath: '/help/foo',
    }),
    ...generateFeatures(1, {
      name: 'bar',
      description: 'Bar description',
      helpPath: '/help/bar',
    }),
  ];

  const createComponent = (props) => {
    wrapper = mount(ConfigurationTable, {
      stubs: {
        ...stubChildren(ConfigurationTable),
        GlTable: false,
      },
      propsData: {
        ...propsData,
        ...props,
      },
    });
  };

  const getTable = () => wrapper.find('table');
  const getRows = () => wrapper.findAll('tbody tr');
  const getRowCells = (row) => {
    const [description, status, manage] = row.findAll('td').wrappers;
    return { description, status, manage };
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it.each(mockFeatures)('renders the feature %p correctly', (feature) => {
    createComponent({ features: [feature] });
    expect(getTable().classes('b-table-stacked-md')).toBe(true);
    const rows = getRows();
    expect(rows).toHaveLength(1);

    const { description, status, manage } = getRowCells(rows.at(0));
    expect(description.text()).toMatch(feature.name);
    expect(description.text()).toMatch(feature.description);
    expect(status.find(FeatureStatus).props()).toEqual({
      feature,
      gitlabCiPresent: propsData.gitlabCiPresent,
      gitlabCiHistoryPath: propsData.gitlabCiHistoryPath,
      autoDevopsEnabled: propsData.autoDevopsEnabled,
    });
    expect(manage.find(ManageFeature).props()).toMatchObject({ feature });
    expect(description.find(GlLink).attributes('href')).toBe(feature.helpPath);
  });

  it('catches errors and displays them in an alert', async () => {
    const error = 'error message';
    createComponent({ features: mockFeatures });

    const firstRow = getRows().at(0);
    await firstRow.findComponent(ManageFeature).vm.$emit('error', error);

    const alert = wrapper.findComponent(GlAlert);
    expect(alert.exists()).toBe(true);
    expect(alert.text()).toBe(error);
  });
});
