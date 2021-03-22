import { GlLink } from '@gitlab/ui';
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

    expect(wrapper.classes('b-table-stacked-md')).toBeTruthy();
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
    expect(manage.find(ManageFeature).props()).toEqual({
      feature,
      autoDevopsEnabled: propsData.autoDevopsEnabled,
    });
    expect(description.find(GlLink).attributes('href')).toBe(feature.helpPath);
  });
});
