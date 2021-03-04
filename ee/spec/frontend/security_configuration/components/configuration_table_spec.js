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

  it('passes the expected data to the GlTable', () => {
    const features = [
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

    createComponent({ features });

    expect(wrapper.classes('b-table-stacked-md')).toBeTruthy();
    const rows = getRows();
    expect(rows).toHaveLength(features.length);

    for (let i = 0; i < features.length; i += 1) {
      const { description, status, manage } = getRowCells(rows.at(i));
      expect(description.text()).toMatch(features[i].name);
      expect(description.text()).toMatch(features[i].description);
      expect(status.find(FeatureStatus).props()).toEqual({
        feature: features[i],
        gitlabCiPresent: propsData.gitlabCiPresent,
        gitlabCiHistoryPath: propsData.gitlabCiHistoryPath,
      });
      expect(manage.find(ManageFeature).props()).toEqual({
        feature: features[i],
        autoDevopsEnabled: propsData.autoDevopsEnabled,
      });
      expect(description.find(GlLink).attributes('href')).toBe(features[i].helpPath);
    }
  });
});
