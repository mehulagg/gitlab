import { merge } from 'lodash';
import { shallowMount } from '@vue/test-utils';
import { TEST_HOST } from 'helpers/test_constants';
import OnDemandScansApp from 'ee/on_demand_scans/components/on_demand_scans_app.vue';
import OnDemandScansForm from 'ee/on_demand_scans/components/on_demand_scans_form.vue';
import OnDemandScansEmptyState from 'ee/on_demand_scans/components/on_demand_scans_empty_state.vue';

const helpPagePath = `${TEST_HOST}/application_security/dast/index#on-demand-scans`;
const projectPath = 'group/project';
const defaultBranch = 'master';
const emptyStateSvgPath = `${TEST_HOST}/assets/illustrations/alert-management-empty-state.svg`;
const profilesLibraryPath = `${TEST_HOST}/${projectPath}/-/on_demand_scans/profiles`;
const newSiteProfilePath = `${TEST_HOST}/${projectPath}/-/on_demand_scans/profiles`;

describe('OnDemandScansApp', () => {
  let wrapper;

  const findOnDemandScansEmptyState = () => wrapper.find(OnDemandScansEmptyState);
  const findOnDemandScansForm = () => wrapper.find(OnDemandScansForm);

  const expectEmptyState = () => {
    expect(wrapper.contains(OnDemandScansForm)).toBe(false);
    expect(wrapper.contains(OnDemandScansEmptyState)).toBe(true);
  };

  const expectForm = () => {
    expect(wrapper.contains(OnDemandScansForm)).toBe(true);
    expect(wrapper.contains(OnDemandScansEmptyState)).toBe(false);
  };

  const createComponent = options => {
    wrapper = shallowMount(
      OnDemandScansApp,
      merge(
        {},
        {
          propsData: {
            helpPagePath,
            projectPath,
            defaultBranch,
            emptyStateSvgPath,
            profilesLibraryPath,
            newSiteProfilePath,
          },
        },
        options,
      ),
    );
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('empty state', () => {
    it('renders an empty state by default', () => {
      expectEmptyState();
    });

    it('passes correct props to GlEmptyState', () => {
      expect(findOnDemandScansEmptyState().props()).toMatchObject({
        emptyStateSvgPath,
        helpPagePath,
      });
    });
  });

  describe('form', () => {
    beforeEach(async () => {
      findOnDemandScansEmptyState().vm.$emit('createNewScan');
      await wrapper.vm.$nextTick();
    });

    it('renders the form when clicking on the primary button', () => {
      expectForm();
    });

    it('passes correct props to OnDemandScansForm', () => {
      expect(findOnDemandScansForm().props()).toMatchObject({
        helpPagePath,
        projectPath,
        defaultBranch,
        profilesLibraryPath,
        newSiteProfilePath,
      });
    });

    it('shows the empty state on cancel', async () => {
      findOnDemandScansForm().vm.$emit('cancel');
      await wrapper.vm.$nextTick();

      expectEmptyState();
    });
  });
});
