import { GlEmptyState, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import OnDemandScansEmptyState from 'ee/on_demand_scans/components/on_demand_scans_empty_state.vue';
import { TEST_HOST } from 'helpers/test_constants';

const helpPagePath = `${TEST_HOST}/application_security/dast/index#on-demand-scans`;
const emptyStateSvgPath = `${TEST_HOST}/assets/illustrations/alert-management-empty-state.svg`;

const GlEmptyStateStub = {
  props: GlEmptyState.props,
  template: `
    <div>
      <slot name="description" />
      <slot name="actions" />
    </div>
  `,
};

describe('OnDemandScansEmptyState', () => {
  let wrapper;

  const findEmptyState = () => wrapper.find(GlEmptyStateStub);
  const findRunScanButton = () => wrapper.find('[data-testid="run-scan-button"]');

  const createComponent = (props = {}) => {
    wrapper = shallowMount(OnDemandScansEmptyState, {
      propsData: {
        helpPagePath,
        emptyStateSvgPath,
        ...props,
      },
      stubs: {
        GlEmptyState: GlEmptyStateStub,
        GlSprintf,
        GlButton: { template: '<button><slot /></button>' },
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

  it('renders empty state', () => {
    expect(wrapper.find(GlEmptyStateStub).exists()).toBe(true);
  });

  it('passes correct props to GlEmptyState', () => {
    expect(findEmptyState().props()).toMatchObject({
      svgPath: emptyStateSvgPath,
      title: 'On-demand Scans',
    });
  });

  it('renders the description', () => {
    expect(wrapper.text()).toContain(
      'Schedule or run scans immediately against target sites. Currently available on-demand scan type: DAST.',
    );
    expect(wrapper.text()).toContain('More information');
  });

  it('renders the run scan button', () => {
    const button = findRunScanButton();

    expect(button.exists()).toBe(true);
    expect(button.text()).toBe('Create new DAST scan');
  });

  it('clicking on the run scan button emits createNewScan event', () => {
    findRunScanButton().vm.$emit('click');

    expect(wrapper.emitted().createNewScan).toBeTruthy();
  });
});
