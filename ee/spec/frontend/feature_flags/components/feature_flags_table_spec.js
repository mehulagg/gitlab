import FeatureFlagsTable from 'ee/feature_flags/components/feature_flags_table.vue';
import { shallowMount } from '@vue/test-utils';
import { GlToggle } from '@gitlab/ui';
import { trimText } from 'helpers/text_helper';
import {
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  DEFAULT_PERCENT_ROLLOUT,
} from 'ee/feature_flags/constants';

const getDefaultProps = () => ({
  featureFlags: [
    {
      id: 1,
      active: true,
      name: 'flag name',
      description: 'flag description',
      destroy_path: 'destroy/path',
      edit_path: 'edit/path',
      scopes: [
        {
          id: 1,
          active: true,
          environmentScope: 'scope',
          canUpdate: true,
          protected: false,
          rolloutStrategy: ROLLOUT_STRATEGY_ALL_USERS,
          rolloutPercentage: DEFAULT_PERCENT_ROLLOUT,
          shouldBeDestroyed: false,
        },
      ],
    },
  ],
  csrfToken: 'fakeToken',
});

describe('Feature flag table', () => {
  let wrapper;
  let props;

  const createWrapper = (propsData, opts = {}) => {
    wrapper = shallowMount(FeatureFlagsTable, {
      propsData,
      sync: false,
      ...opts,
    });
  };

  beforeEach(() => {
    props = getDefaultProps();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('with an active scope and a standard rollout strategy', () => {
    beforeEach(() => {
      props.featureFlags[0].iid = 1;
      createWrapper(props, {
        provide: { glFeatures: { featureFlagIID: true } },
      });
    });

    it('Should render a table', () => {
      expect(wrapper.classes('table-holder')).toBe(true);
    });

    it('Should render rows', () => {
      expect(wrapper.find('.gl-responsive-table-row').exists()).toBe(true);
    });

    it('should render an ID column', () => {
      expect(wrapper.find('.js-feature-flag-id').exists()).toBe(true);
      expect(trimText(wrapper.find('.js-feature-flag-id').text())).toEqual('^1');
    });

    it('Should render a status column', () => {
      expect(wrapper.find('.js-feature-flag-status').exists()).toBe(true);
      expect(trimText(wrapper.find('.js-feature-flag-status').text())).toEqual('Active');
    });

    it('Should render a feature flag column', () => {
      expect(wrapper.find('.js-feature-flag-title').exists()).toBe(true);
      expect(trimText(wrapper.find('.feature-flag-name').text())).toEqual('flag name');

      expect(trimText(wrapper.find('.feature-flag-description').text())).toEqual(
        'flag description',
      );
    });

    it('should render an environments specs column', () => {
      const envColumn = wrapper.find('.js-feature-flag-environments');

      expect(envColumn).toBeDefined();
      expect(trimText(envColumn.text())).toBe('scope');
    });

    it('should render an environments specs badge with active class', () => {
      const envColumn = wrapper.find('.js-feature-flag-environments');

      expect(trimText(envColumn.find('.badge-active').text())).toBe('scope');
    });

    it('should render an actions column', () => {
      expect(wrapper.find('.table-action-buttons').exists()).toBe(true);
      expect(wrapper.find('.js-feature-flag-delete-button').exists()).toBe(true);
      expect(wrapper.find('.js-feature-flag-edit-button').exists()).toBe(true);
      expect(wrapper.find('.js-feature-flag-edit-button').attributes('href')).toEqual('edit/path');
    });
  });

  describe('when active and with an update toggle', () => {
    let toggle;

    beforeEach(() => {
      props.featureFlags[0].update_path = props.featureFlags[0].destroy_path;
      createWrapper(props, { provide: { glFeatures: { featureFlagToggle: true } } });
      toggle = wrapper.find(GlToggle);
    });

    it('should have a toggle', () => {
      expect(toggle.exists()).toBe(true);
      expect(toggle.props('value')).toBe(true);
    });

    it('should trigger a toggle event', () => {
      toggle.vm.$emit('change');
      const flag = { ...props.featureFlags[0], active: !props.featureFlags[0].active };

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('toggle-flag')).toEqual([[flag]]);
      });
    });
  });

  describe('with an active scope and a percentage rollout strategy', () => {
    beforeEach(() => {
      props.featureFlags[0].scopes[0].rolloutStrategy = ROLLOUT_STRATEGY_PERCENT_ROLLOUT;
      props.featureFlags[0].scopes[0].rolloutPercentage = '54';
      createWrapper(props);
    });

    it('should render an environments specs badge with percentage', () => {
      const envColumn = wrapper.find('.js-feature-flag-environments');

      expect(trimText(envColumn.find('.badge').text())).toBe('scope: 54%');
    });
  });

  describe('with an inactive scope', () => {
    beforeEach(() => {
      props.featureFlags[0].scopes[0].active = false;
      createWrapper(props);
    });

    it('should render an environments specs badge with inactive class', () => {
      const envColumn = wrapper.find('.js-feature-flag-environments');

      expect(trimText(envColumn.find('.badge-inactive').text())).toBe('scope');
    });
  });
});
