import { shallowMount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import AlertWidget from 'ee/monitoring/components/alert_widget.vue';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';

const mockReadAlert = jest.fn();
const mockCreateAlert = jest.fn();
const mockUpdateAlert = jest.fn();
const mockDeleteAlert = jest.fn();

jest.mock('~/flash');
jest.mock(
  'ee/monitoring/services/alerts_service',
  () =>
    function AlertsServiceMock() {
      return {
        readAlert: mockReadAlert,
        createAlert: mockCreateAlert,
        updateAlert: mockUpdateAlert,
        deleteAlert: mockDeleteAlert,
      };
    },
);

describe('AlertWidget', () => {
  let wrapper;

  const metricId = '5';
  const alertPath = 'my/alert.json';
  const relevantQueries = [{ metricId, label: 'alert-label', alert_path: alertPath }];

  const defaultProps = {
    alertsEndpoint: '',
    relevantQueries,
    alertsToManage: {},
    modalId: 'alert-modal-1',
  };

  const propsWithAlert = {
    relevantQueries,
  };

  const propsWithAlertData = {
    relevantQueries,
    alertsToManage: {
      [alertPath]: { operator: '>', threshold: 42, alert_path: alertPath, metricId },
    },
  };

  const createComponent = propsData => {
    wrapper = shallowMount(AlertWidget, {
      propsData: {
        ...defaultProps,
        ...propsData,
      },
      sync: false,
    });
  };
  const findWidgetForm = () => wrapper.find({ ref: 'widgetForm' });
  const findAlertErrorMessage = () => wrapper.find('.alert-error-message');
  const findCurrentSettings = () => wrapper.find('.alert-current-setting');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('displays a loading spinner and disables form when fetching alerts', () => {
    let resolveReadAlert;
    mockReadAlert.mockReturnValue(
      new Promise(resolve => {
        resolveReadAlert = resolve;
      }),
    );
    createComponent(defaultProps);
    return wrapper.vm
      .$nextTick()
      .then(() => {
        expect(wrapper.find(GlLoadingIcon).isVisible()).toBe(true);
        expect(findWidgetForm().props('disabled')).toBe(true);

        resolveReadAlert({ operator: '==', threshold: 42 });
      })
      .then(() => waitForPromises())
      .then(() => {
        expect(wrapper.find(GlLoadingIcon).isVisible()).toBe(false);
        expect(findWidgetForm().props('disabled')).toBe(false);
      });
  });

  it('displays an error message when fetch fails', () => {
    mockReadAlert.mockRejectedValue();
    createComponent(propsWithAlert);

    expect(wrapper.find(GlLoadingIcon).isVisible()).toBe(true);

    return waitForPromises().then(() => {
      expect(createFlash).toHaveBeenCalled();
      expect(wrapper.find(GlLoadingIcon).isVisible()).toBe(false);
    });
  });

  it('displays an alert summary when there is a single alert', () => {
    mockReadAlert.mockResolvedValue({ operator: '>', threshold: 42 });
    createComponent(propsWithAlertData);

    expect(wrapper.text()).toContain('alert-label > 42');
  });

  it('displays a combined alert summary when there are multiple alerts', () => {
    mockReadAlert.mockResolvedValue({ operator: '>', threshold: 42 });
    const propsWithManyAlerts = {
      relevantQueries: relevantQueries.concat([
        { metricId: '6', alert_path: 'my/alert2.json', label: 'alert-label2' },
      ]),
      alertsToManage: {
        'my/alert.json': {
          operator: '>',
          threshold: 42,
          alert_path: alertPath,
          metricId,
        },
        'my/alert2.json': {
          operator: '==',
          threshold: 900,
          alert_path: 'my/alert2.json',
          metricId: '6',
        },
      },
    };
    createComponent(propsWithManyAlerts);

    expect(findCurrentSettings().text()).toEqual('2 alerts applied');
  });

  it('creates an alert with an appropriate handler', () => {
    const alertParams = {
      operator: '<',
      threshold: 4,
      prometheus_metric_id: '5',
    };
    mockReadAlert.mockResolvedValue({ operator: '>', threshold: 42 });
    const fakeAlertPath = 'foo/bar';
    mockCreateAlert.mockResolvedValue({ alert_path: fakeAlertPath, ...alertParams });
    createComponent({
      alertsToManage: {
        [fakeAlertPath]: {
          alert_path: fakeAlertPath,
          operator: '<',
          threshold: 4,
          prometheus_metric_id: '5',
          metricId: '5',
        },
      },
    });

    findWidgetForm().vm.$emit('create', alertParams);

    expect(mockCreateAlert).toHaveBeenCalledWith(alertParams);
  });

  it('updates an alert with an appropriate handler', () => {
    const alertParams = { operator: '<', threshold: 4, alert_path: alertPath };
    const newAlertParams = { operator: '==', threshold: 12 };
    mockReadAlert.mockResolvedValue(alertParams);
    mockUpdateAlert.mockResolvedValue({ ...alertParams, ...newAlertParams });
    createComponent({
      ...propsWithAlertData,
      alertsToManage: {
        [alertPath]: {
          alert_path: alertPath,
          operator: '==',
          threshold: 12,
          metricId: '5',
        },
      },
    });

    findWidgetForm().vm.$emit('update', {
      alert: alertPath,
      ...newAlertParams,
      prometheus_metric_id: '5',
    });

    expect(mockUpdateAlert).toHaveBeenCalledWith(alertPath, newAlertParams);
  });

  it('deletes an alert with an appropriate handler', () => {
    const alertParams = { alert_path: alertPath, operator: '>', threshold: 42 };
    mockReadAlert.mockResolvedValue(alertParams);
    mockDeleteAlert.mockResolvedValue({});
    createComponent({
      ...propsWithAlert,
      alertsToManage: {
        [alertPath]: {
          alert_path: alertPath,
          operator: '>',
          threshold: 42,
          metricId: '5',
        },
      },
    });

    findWidgetForm().vm.$emit('delete', { alert: alertPath });

    return wrapper.vm.$nextTick().then(() => {
      expect(mockDeleteAlert).toHaveBeenCalledWith(alertPath);
      expect(findAlertErrorMessage().exists()).toBe(false);
    });
  });

  describe('when delete fails', () => {
    beforeEach(() => {
      const alertParams = { alert_path: alertPath, operator: '>', threshold: 42 };
      mockReadAlert.mockResolvedValue(alertParams);
      mockDeleteAlert.mockRejectedValue();

      createComponent({
        ...propsWithAlert,
        alertsToManage: {
          [alertPath]: {
            alert_path: alertPath,
            operator: '>',
            threshold: 42,
            metricId: '5',
          },
        },
      });

      findWidgetForm().vm.$emit('delete', { alert: alertPath });
      return wrapper.vm.$nextTick();
    });

    it('shows error message', () => {
      expect(findAlertErrorMessage().text()).toEqual('Error deleting alert');
    });

    it('dismisses error message on cancel', () => {
      findWidgetForm().vm.$emit('cancel');

      return wrapper.vm.$nextTick().then(() => {
        expect(findAlertErrorMessage().exists()).toBe(false);
      });
    });
  });
});
