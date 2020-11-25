import { GlFormSelect, GlButton } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import SelectionSummary from 'ee/security_dashboard/components/selection_summary.vue';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';
import toast from '~/vue_shared/plugins/global_toast';

jest.mock('~/flash');
jest.mock('~/vue_shared/plugins/global_toast');

describe('Selection Summary component', () => {
  let wrapper;
  let spyMutate;

  const defaultData = {
    dismissalReason: null,
  };

  const defaultMocks = {
    $apollo: {
      mutate: jest.fn().mockResolvedValue(),
    },
  };

  const dismissButton = () => wrapper.find(GlButton);
  const dismissMessage = () => wrapper.find('[data-testid="dismiss-message"]');
  const formSelect = () => wrapper.find(GlFormSelect);
  const createComponent = ({ props = {}, data = defaultData, mocks = defaultMocks } = {}) => {
    spyMutate = mocks.$apollo.mutate;
    wrapper = mount(SelectionSummary, {
      mocks: {
        ...defaultMocks,
        ...mocks,
      },
      propsData: {
        selectedVulnerabilities: [],
        ...props,
      },
      data: () => data,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('with 1 vulnerability selected', () => {
    beforeEach(() => {
      createComponent({ props: { selectedVulnerabilities: [{ id: 'id_0' }] } });
    });

    it('renders correctly', () => {
      expect(dismissMessage().text()).toBe('Dismiss 1 selected vulnerability as');
    });

    describe('dismiss button', () => {
      it('should have the button disabled if an option is not selected', () => {
        expect(dismissButton().attributes('disabled')).toBe('disabled');
      });

      it('should have the button enabled if a vulnerability is selected and an option is selected', async () => {
        expect(wrapper.vm.dismissalReason).toBe(null);
        expect(wrapper.findAll('option')).toHaveLength(4);

        const option = formSelect()
          .findAll('option')
          .at(1);
        option.setSelected();
        formSelect().trigger('change');

        await wrapper.vm.$nextTick();
        expect(wrapper.vm.dismissalReason).toEqual(option.attributes('value'));
        expect(dismissButton().attributes('disabled')).toBe(undefined);
      });
    });
  });

  describe('with multiple vulnerabilities selected', () => {
    beforeEach(() => {
      createComponent({ props: { selectedVulnerabilities: [{ id: 'id_0' }, { id: 'id_1' }] } });
    });

    it('renders correctly', () => {
      expect(dismissMessage().text()).toBe('Dismiss 2 selected vulnerabilities as');
    });
  });

  describe('clicking the dismiss vulnerability button', () => {
    let mutateMock;

    beforeEach(() => {
      mutateMock = jest.fn(data =>
        data.variables.id % 2 === 0 ? Promise.resolve() : Promise.reject(),
      );

      createComponent({
        props: { selectedVulnerabilities: [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }] },
        data: { dismissalReason: 'Will Not Fix' },
        mocks: { $apollo: { mutate: mutateMock } },
      });
    });

    it('should make an API request for each vulnerability', () => {
      dismissButton().trigger('submit');
      expect(spyMutate).toHaveBeenCalledTimes(5);
    });

    it('should show toast with the right message for the successful calls', async () => {
      dismissButton().trigger('submit');
      await waitForPromises();

      expect(toast).toHaveBeenCalledWith('2 vulnerabilities dismissed');
    });

    it('should show flash with the right message for the failed calls', async () => {
      dismissButton().trigger('submit');
      await waitForPromises();

      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error dismissing 3 vulnerabilities. Please try again later.',
      });
    });
  });

  describe('when vulnerabilities are not selected', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should have the button disabled', () => {
      expect(dismissButton().attributes('disabled')).toBe('disabled');
    });
  });
});
