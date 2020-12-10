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

  const findColSubComponent = (colTestId, childComponent) =>
    findCol(colTestId).find(childComponent);

  describe('table headings', () => {
    let headers;

    beforeEach(() => {
      headers = findTable().findAll(`[data-testid="${TEST_IDS.TABLE_HEADERS}"]`);
    });

    it('displays the correct number of headings', () => {
      expect(headers).toHaveLength(devopsAdoptionTableHeaders.length);
    });

    describe.each(devopsAdoptionTableHeaders)(
      'header fields',
      ({ label, tooltip: tooltipText, index }) => {
        let headerWrapper;

        beforeEach(() => {
          headerWrapper = headers.at(index);
        });

        it(`displays the correct table heading text for "${label}"`, () => {
          expect(headerWrapper.text()).toBe(label);
        });

        describe(`helper information for "${label}"`, () => {
          const expected = Boolean(tooltipText);

          it(`${expected ? 'displays' : "doesn't display"} an information icon`, () => {
            expect(headerWrapper.find(GlIcon).exists()).toBe(expected);
          });

          if (expected) {
            it('includes a tooltip', () => {
              const icon = headerWrapper.find(GlIcon);
              const tooltip = getBinding(icon.element, 'gl-tooltip');

              expect(tooltip).toBeDefined();
              expect(tooltip.value).toBe(tooltipText);
            });
          }
        });
      },
    );
  });

  describe('table fields', () => {
    it('displays the correct segment name', () => {
      expect(findCol(TEST_IDS.SEGMENT).text()).toBe('Segment 1');
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
