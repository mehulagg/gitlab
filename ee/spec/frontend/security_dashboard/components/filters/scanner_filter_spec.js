import { GlDropdownItem } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { sampleSize, cloneDeep } from 'lodash';
import FilterItem from 'ee/security_dashboard/components/filters/filter_item.vue';
import ScannerFilter from 'ee/security_dashboard/components/filters/scanner_filter.vue';
import { DEFAULT_SCANNER } from 'ee/security_dashboard/constants';
import { scannerFilter } from 'ee/security_dashboard/helpers';

const filter = cloneDeep(scannerFilter);
filter.options = filter.options.map((option) => ({
  ...option,
  id: `GitLab.${option.id}`,
}));

const createScannerConfig = (vendor, reportType, externalId) => ({
  vendor,
  report_type: reportType,
  external_id: externalId,
});

const scanners = [
  createScannerConfig(DEFAULT_SCANNER, 'DEPENDENCY_SCANNING', 'bundler_audit'),
  createScannerConfig(DEFAULT_SCANNER, 'SAST', 'eslint'),
  createScannerConfig(DEFAULT_SCANNER, 'SAST', 'find_sec_bugs'),
  createScannerConfig(DEFAULT_SCANNER, 'DEPENDENCY_SCANNING', 'gemnasium'),
  createScannerConfig(DEFAULT_SCANNER, 'SECRET_DETECTION', 'gitleaks'),
  createScannerConfig(DEFAULT_SCANNER, 'CONTAINER_SCANNING', 'klar'),
  createScannerConfig(DEFAULT_SCANNER, 'COVERAGE_FUZZING', 'libfuzzer'),
  createScannerConfig(DEFAULT_SCANNER, 'SAST', 'pmd-apex'),
  createScannerConfig(DEFAULT_SCANNER, 'SAST', 'sobelow'),
  createScannerConfig(DEFAULT_SCANNER, 'SAST', 'tslint'),
  createScannerConfig(DEFAULT_SCANNER, 'DAST', 'zaproxy'),
  createScannerConfig('Custom', 'SAST', 'custom1'),
  createScannerConfig('Custom', 'SAST', 'custom2'),
  createScannerConfig('Custom', 'DAST', 'custom3'),
];

describe('Scanner Filter component', () => {
  let wrapper;

  const createWrapper = () => {
    wrapper = shallowMount(ScannerFilter, {
      propsData: { filter },
      provide: { scanners },
    });
  };

  beforeEach(() => {
    gon.features = { customSecurityScanners: true };
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows the correct dropdown items', () => {
    const getTestIds = (selector) =>
      wrapper.findAll(selector).wrappers.map((x) => x.attributes('data-testid'));

    const options = getTestIds(FilterItem);
    const expectedOptions = [
      'all',
      ...filter.options.map((x) => x.id),
      'Custom.SAST',
      'Custom.DAST',
    ];

    const headers = getTestIds(GlDropdownItem);
    const expectedHeaders = ['GitLabHeader', 'CustomHeader'];

    expect(options).toEqual(expectedOptions);
    expect(headers).toEqual(expectedHeaders);
  });

  it('toggles selection of all items in a group when the group header is clicked', async () => {
    const expectSelectedItems = (items) => {
      const checkedItems = wrapper
        .findAll(FilterItem)
        .wrappers.filter((x) => x.props('isChecked'))
        .map((x) => x.attributes('data-testid'));
      const expectedItems = items.map((x) => x.id);

      expect(checkedItems.sort()).toEqual(expectedItems.sort());
    };

    const clickAndCheck = async (expectedOptions) => {
      await wrapper.find('[data-testid="GitLabHeader"]').trigger('click');

      expectSelectedItems(expectedOptions);
    };

    const selectedOptions = sampleSize(filter.options, 3); // Randomly select some options.
    await wrapper.setData({ selectedOptions });

    expectSelectedItems(selectedOptions);

    await clickAndCheck(filter.options); // First click selects all.
    await clickAndCheck([filter.allOption]); // Second check unselects all.
    await clickAndCheck(filter.options); // Third click selects all again.
  });

  it('emits filter-changed event with expected data when selected options is changed', async () => {
    const selectedIds = ['GitLab.SAST', 'Custom.SAST'];
    const selectedOptions = wrapper.vm.options.filter((x) => selectedIds.includes(x.id));
    await wrapper.setData({ selectedOptions });

    expect(wrapper.emitted('filter-changed')[1][0]).toEqual({
      reportType: ['SAST'],
      scanner: scanners.filter((x) => x.report_type === 'SAST').map((x) => x.external_id),
    });
  });
});
