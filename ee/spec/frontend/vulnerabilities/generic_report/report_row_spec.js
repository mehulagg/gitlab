import { shallowMount } from '@vue/test-utils';
import ReportRow from 'ee/vulnerabilities/components/generic_report/report_row.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('EE - GenericReport - ReportRow', () => {
  let wrapper;

  const createWrapper = ({ props, ...options } = {}) =>
    extendedWrapper(
      shallowMount(ReportRow, {
        propsData: {
          label: 'Foo',
          ...props,
        },
        ...options,
      }),
    );

  it.each`
    description                                         | isLastRow
    ${'shows a bottom-border per default'}              | ${false}
    ${'does not show a bottom-border for the last row'} | ${true}
  `('$description', ({ isLastRow }) => {
    wrapper = createWrapper({ props: { isLastRow } });

    expect(wrapper.classes().includes('gl-border-none!')).toBe(isLastRow);
  });

  it('renders the default slot', () => {
    const slotContent = 'foo bar';
    wrapper = createWrapper({ slots: { default: slotContent } });

    expect(wrapper.findByTestId('reportContent').text()).toBe(slotContent);
  });
});
