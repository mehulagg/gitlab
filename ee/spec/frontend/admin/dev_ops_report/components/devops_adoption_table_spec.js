import { GlTable, GlButton, GlIcon } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import DevopsAdoptionTable from 'ee/admin/dev_ops_report/components/devops_adoption_table.vue';
import DevopsAdoptionTableCellFlag from 'ee/admin/dev_ops_report/components/devops_adoption_table_cell_flag.vue';
import { DEVOPS_ADOPTION_TABLE_TEST_IDS as TEST_IDS } from 'ee/admin/dev_ops_report/constants';
import { devopsAdoptionSegmentsData, devopsAdoptionTableHeaders } from '../mock_data';

describe('DevopsAdoptionTable', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = mount(DevopsAdoptionTable, {
      propsData: {
        segments: devopsAdoptionSegmentsData.nodes,
      },
      directives: {
        GlTooltip: createMockDirective(),
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findTable = () => wrapper.find(GlTable);

  const findCol = testId => findTable().find(`[data-testid="${testId}"]`);

  const findColRowChild = (col, row, child) =>
    findTable()
      .findAll(`[data-testid="${col}"]`)
      .at(row)
      .find(child);

  const findColSubComponent = (colTestId, childComponent) =>
    findCol(colTestId).find(childComponent);

  it('displays the correct table headers', () => {
    const headers = findTable().findAll(`[data-testid="${TEST_IDS.TABLE_HEADERS}"]`);

    expect(headers).toHaveLength(devopsAdoptionTableHeaders.length);

    devopsAdoptionTableHeaders.forEach((headerText, i) =>
      expect(headers.at(i).text()).toEqual(headerText),
    );
  });

  describe('table fields', () => {
    describe('segment name', () => {
      it('displays the correct segment name', () => {
        expect(findCol(TEST_IDS.SEGMENT).text()).toBe('Segment 1');
      });

      describe('pending state (no snapshot data available)', () => {
        it('grays the text out', () => {
          const name = findColRowChild(TEST_IDS.SEGMENT, 1, 'span');

          expect(name.classes()).toStrictEqual(['gl-text-gray-400']);
        });

        describe('hourglass icon', () => {
          let icon;

          beforeEach(() => {
            icon = findColRowChild(TEST_IDS.SEGMENT, 1, GlIcon);
          });

          it('displays the icon', () => {
            expect(icon.exists()).toBe(true);
            expect(icon.props('name')).toBe('hourglass');
          });

          it('contains a tooltip', () => {
            const tooltip = getBinding(icon.element, 'gl-tooltip');

            expect(tooltip).toBeDefined();
            expect(tooltip.value).toBe('Segment data pending until the start of next month');
          });
        });
      });
    });

    it.each`
      id                    | field          | flag
      ${TEST_IDS.ISSUES}    | ${'issues'}    | ${true}
      ${TEST_IDS.MRS}       | ${'MRs'}       | ${true}
      ${TEST_IDS.APPROVALS} | ${'approvals'} | ${false}
      ${TEST_IDS.RUNNERS}   | ${'runners'}   | ${true}
      ${TEST_IDS.PIPELINES} | ${'pipelines'} | ${false}
      ${TEST_IDS.DEPLOYS}   | ${'deploys'}   | ${false}
      ${TEST_IDS.SCANNING}  | ${'scanning'}  | ${false}
    `('displays the correct $field snapshot value', ({ id, flag }) => {
      const booleanFlag = findColSubComponent(id, DevopsAdoptionTableCellFlag);

      expect(booleanFlag.props('enabled')).toBe(flag);
    });

    it('displays the actions icon', () => {
      const button = findColSubComponent(TEST_IDS.ACTIONS, GlButton);

      expect(button.exists()).toBe(true);
      expect(button.props('icon')).toBe('ellipsis_h');
      expect(button.props('category')).toBe('tertiary');
    });
  });
});
