import { shallowMount } from '@vue/test-utils';
import AlertWidgetForm from 'ee/monitoring/components/alert_widget_form.vue';
import { GlModal } from '@gitlab/ui';

describe('AlertWidgetForm', () => {
  let wrapper;

  const metricId = '8';
  const alertPath = 'alert';
  const relevantQueries = [{ metricId, alert_path: alertPath, label: 'alert-label' }];

  const defaultProps = {
    disabled: false,
    relevantQueries,
    modalId: 'alert-modal-1',
  };

  const propsWithAlertData = {
    ...defaultProps,
    alertsToManage: {
      alert: { alert_path: alertPath, operator: '<', threshold: 5, metricId },
    },
  };

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = shallowMount(AlertWidgetForm, {
      sync: false,
      propsData,
    });
  }

  const modal = () => wrapper.find(GlModal);
  const modalTitle = () => modal().attributes('title');
  const submitText = () => modal().attributes('ok-title');
  const e = {
    preventDefault: jest.fn(),
  };

  beforeEach(() => {
    e.preventDefault.mockReset();
  });

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('disables the form when disabled prop is set', () => {
    createComponent({ disabled: true });

    expect(modal().attributes('ok-disabled')).toBe('true');
  });

  it('disables the form if no query is selected', () => {
    createComponent();

    expect(modal().attributes('ok-disabled')).toBe('true');
  });

  it('shows correct title and button text', () => {
    expect(modalTitle()).toBe('Add alert');
    expect(submitText()).toBe('Add');
  });

  it('emits a "create" event when form submitted without existing alert', () => {
    createComponent();

    wrapper.vm.selectQuery('9');
    wrapper.vm.threshold = 900;

    wrapper.vm.handleSubmit(e);

    expect(wrapper.emitted().create[0]).toEqual([
      {
        alert: undefined,
        operator: '>',
        threshold: 900,
        prometheus_metric_id: '9',
      },
    ]);
    expect(e.preventDefault).toHaveBeenCalledTimes(1);
  });

  it('resets form when modal is dismissed (hidden)', () => {
    createComponent();

    wrapper.vm.selectQuery('9');
    wrapper.vm.selectQuery('>');
    wrapper.vm.threshold = 800;

    wrapper.find(GlModal).vm.$emit('hidden');

    expect(wrapper.vm.selectedAlert).toEqual({});
    expect(wrapper.vm.operator).toBe(null);
    expect(wrapper.vm.threshold).toBe(null);
    expect(wrapper.vm.prometheusMetricId).toBe(null);
  });

  describe('with existing alert', () => {
    beforeEach(() => {
      createComponent(propsWithAlertData);

      wrapper.vm.selectQuery(metricId);
    });

    it('updates button text', () => {
      expect(modalTitle()).toBe('Edit alert');
      expect(submitText()).toBe('Delete');
    });

    it('emits "delete" event when form values unchanged', () => {
      wrapper.vm.handleSubmit(e);

      expect(wrapper.emitted().delete[0]).toEqual([
        {
          alert: 'alert',
          operator: '<',
          threshold: 5,
          prometheus_metric_id: '8',
        },
      ]);
      expect(e.preventDefault).toHaveBeenCalledTimes(1);
    });

    it('emits "update" event when form changed', () => {
      wrapper.vm.threshold = 11;

      wrapper.vm.handleSubmit(e);

      expect(wrapper.emitted().update[0]).toEqual([
        {
          alert: 'alert',
          operator: '<',
          threshold: 11,
          prometheus_metric_id: '8',
        },
      ]);
      expect(e.preventDefault).toHaveBeenCalledTimes(1);
    });
  });
});
