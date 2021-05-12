import { shallowMount } from '@vue/test-utils';
import EnvironmentPicker from 'ee/threat_monitoring/components/environment_picker.vue';
import ThreatMonitoringFilters from 'ee/threat_monitoring/components/threat_monitoring_filters.vue';
import createStore from 'ee/threat_monitoring/store';
import DateTimePicker from '~/vue_shared/components/date_time_picker/date_time_picker.vue';
import { timeRanges, defaultTimeRange } from '~/vue_shared/constants';
import { mockEnvironmentsResponse } from '../mocks/mock_data';

const mockEnvironments = mockEnvironmentsResponse.environments;

describe('ThreatMonitoringFilters component', () => {
  let store;
  let wrapper;

  const factory = (state) => {
    store = createStore();
    Object.assign(store.state.threatMonitoring, state);

    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(ThreatMonitoringFilters, {
      store,
    });
  };

  const findEnvironmentsPicker = () => wrapper.find(EnvironmentPicker);
  const findShowLastDropdown = () => wrapper.find(DateTimePicker);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('the environments picker', () => {
    beforeEach(() => {
      factory();
    });

    it('renders EnvironmentPicker', () => {
      expect(findEnvironmentsPicker().exists()).toBe(true);
    });
  });

  describe('the "show last" dropdown', () => {
    beforeEach(() => {
      factory({
        environments: mockEnvironments,
      });
    });

    it('is not disabled', () => {
      expect(findShowLastDropdown().attributes().disabled).toBe(undefined);
    });

    it('has text set to the current time window name', () => {
      expect(findShowLastDropdown().vm.value.label).toBe(defaultTimeRange.label);
    });

    it('has dropdown items for each time window', () => {
      const dropdownOptions = findShowLastDropdown().props('options');
      Object.entries(timeRanges).forEach(([index, timeWindow]) => {
        const dropdownOption = dropdownOptions[index];
        expect(dropdownOption.interval).toBe(timeWindow.interval);
        expect(dropdownOption.duration.seconds).toBe(timeWindow.duration.seconds);
      });
    });
  });

  describe.each`
    context                            | isLoadingEnvironments | isLoadingNetworkPolicyStatistics | environments
    ${'environments are loading'}      | ${true}               | ${false}                         | ${mockEnvironments}
    ${'NetPol statistics are loading'} | ${false}              | ${true}                          | ${mockEnvironments}
    ${'there are no environments'}     | ${false}              | ${false}                         | ${[]}
  `(
    'given $context',
    ({ isLoadingEnvironments, isLoadingNetworkPolicyStatistics, environments }) => {
      beforeEach(() => {
        factory({
          environments,
          isLoadingEnvironments,
          isLoadingNetworkPolicyStatistics,
        });

        return wrapper.vm.$nextTick();
      });

      it('disables the "show last" dropdown', () => {
        expect(findShowLastDropdown().attributes('disabled')).toBe('true');
      });
    },
  );
});
