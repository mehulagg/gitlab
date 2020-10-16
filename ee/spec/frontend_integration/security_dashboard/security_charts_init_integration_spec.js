import { TEST_HOST } from 'jest/helpers/test_constants';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import initSecurityCharts from 'ee/security_dashboard/security_charts_init';

const TEST_DATASET = {
  link: '/test/link',
  svgPath: '/test/no_changes_state.svg',
  dashboardDocumentation: '/test/dashboard_page',
  emptyStateSvgPath: '/test/empty_state.svg',
};

describe('Security Charts', () => {
  let vm;
  let root;

  beforeEach(() => {
    root = document.createElement('div');
    document.body.appendChild(root);

    global.jsdom.reconfigure({
      url: `${TEST_HOST}/-/security/dashboard`,
    });
  });

  afterEach(() => {
    vm.$destroy();
    vm = null;
    root.remove();
  });

  const createComponent = ({ type, CUSTOM_DATA }) => {
    const el = document.createElement('div');
    Object.assign(el.dataset, { ...TEST_DATASET, ...CUSTOM_DATA });
    root.appendChild(el);
    vm = initSecurityCharts(el, type);
  };

  it('runs for the group-level', () => {
    createComponent({ type: DASHBOARD_TYPES.GROUP, CUSTOM_DATA: { groupFullPath: '/test/' } });

    expect(root).toMatchSnapshot();
  });

  it('runs for the instance-level', () => {
    createComponent({
      type: DASHBOARD_TYPES.INSTANCE,
      CUSTOM_DATA: { instanceDashboardSettingsPath: '/instance/settings_page' },
    });

    expect(root).toMatchSnapshot();
  });
});
