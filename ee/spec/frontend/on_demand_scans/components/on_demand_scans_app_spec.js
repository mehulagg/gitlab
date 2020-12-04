import { shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import OnDemandScansApp from 'ee/on_demand_scans/components/on_demand_scans_app.vue';
import OnDemandScansForm from 'ee/on_demand_scans/components/on_demand_scans_form.vue';
import { TEST_HOST } from 'helpers/test_constants';

const helpPagePath = `${TEST_HOST}/application_security/dast/index#on-demand-scans`;
const projectPath = 'group/project';
const defaultBranch = 'master';
const emptyStateSvgPath = `${TEST_HOST}/assets/illustrations/alert-management-empty-state.svg`;
const newSiteProfilePath = `${TEST_HOST}/${projectPath}/-/security/configuration/dast_profiles`;

describe('OnDemandScansApp', () => {
  let wrapper;

  const findOnDemandScansForm = () => wrapper.find(OnDemandScansForm);

  const expectForm = () => {
    expect(wrapper.find(OnDemandScansForm).exists()).toBe(true);
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

  describe('form', () => {
    it('renders the form', () => {
      expectForm();
    });

    it('passes correct props to OnDemandScansForm', () => {
      expect(findOnDemandScansForm().props()).toMatchObject({
        helpPagePath,
        projectPath,
        defaultBranch,
      });
    });
  });
});
