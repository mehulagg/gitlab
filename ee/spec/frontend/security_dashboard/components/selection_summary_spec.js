import { mount } from '@vue/test-utils';
import SelectionSummary from 'ee/security_dashboard/components/selection_summary.vue';
import { GlFormSelect, GlButton } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import { deprecatedCreateFlash as createFlash } from '~/flash';
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
  const dismissMessage = () => wrapper.find({ ref: 'dismiss-message' });
  const formSelect = () => wrapper.find(GlFormSelect);
  const createComponent = ({ props = {}, data = defaultData, mocks = defaultMocks }) => {
    if (wrapper) {
      throw new Error('Please avoid recreating components in the same spec');
    }

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

      it('should have the button enabled if a vulnerability is selected and an option is selected', () => {
        expect(wrapper.vm.dismissalReason).toBe(null);
        expect(wrapper.findAll('option')).toHaveLength(4);
        formSelect()
          .findAll('option')
          .at(1)
          .setSelected();
        formSelect().trigger('change');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.vm.dismissalReason).toEqual(expect.any(String));
          expect(dismissButton().attributes('disabled')).toBe(undefined);
        });
      });
    });
  });

  describe('with 1 vulnerabilities selected', () => {
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
      mutateMock = jest.fn().mockResolvedValue();

      createComponent({
        props: { selectedVulnerabilities: [{ id: 'id_0' }, { id: 'id_1' }] },
        data: { dismissalReason: 'Will Not Fix' },
        mocks: { $apollo: { mutate: mutateMock } },
      });
    });

    it('should make an API request for each vulnerability', () => {
      dismissButton().trigger('submit');
      expect(spyMutate).toHaveBeenCalledTimes(2);
    });

    it('should show toast with the right message if all calls were successful', () => {
      dismissButton().trigger('submit');
      return waitForPromises().then(() => {
        expect(toast).toHaveBeenCalledWith('2 vulnerabilities dismissed');
      });
    });

    it('should show flash with the right message if some calls failed', () => {
      mutateMock.mockRejectedValue();
      dismissButton().trigger('submit');
      return waitForPromises().then(() => {
        expect(createFlash).toHaveBeenCalledWith(
          'There was an error dismissing the vulnerabilities.',
          'alert',
        );
      });
    });
  });

  describe('when vulnerabilities are not selected', () => {
    beforeEach(() => {
      createComponent({});
    });

    it('should have the button disabled', () => {
      expect(dismissButton().attributes('disabled')).toBe('disabled');
    });
  });
});
