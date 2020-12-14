import { shallowMount } from '@vue/test-utils';
import { GlModal, GlAlert } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import AddScheduleModal from 'ee/oncall_schedules/components/add_schedule_modal.vue';
import { addScheduleModalId } from 'ee/oncall_schedules/components/oncall_schedules_wrapper';
import { getOncallSchedulesQueryResponse } from './mocks/apollo_mock';
import mockTimezones from './mocks/mockTimezones.json';

describe('AddScheduleModal', () => {
  let wrapper;
  const projectPath = 'group/project';
  const mutate = jest.fn();
  const mockHideModal = jest.fn();
  const formData =
    getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

  const createComponent = ({ data = {}, props = {} } = {}) => {
    wrapper = shallowMount(AddScheduleModal, {
      data() {
        return {
          form: formData,
          ...data,
        };
      },
      propsData: {
        modalId: addScheduleModalId,
        ...props,
      },
      provide: {
        projectPath,
        timezones: mockTimezones,
      },
      mocks: {
        $apollo: {
          mutate,
        },
      },
    });

    wrapper.vm.$refs.createScheduleModal.hide = mockHideModal;
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findModal = () => wrapper.find(GlModal);
  const findAlert = () => wrapper.find(GlAlert);

  it('renders modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Schedule create', () => {
    it('makes a request with form data to create a schedule', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        update: expect.any(Function),
        variables: {
          oncallScheduleCreateInput: {
            projectPath,
            ...formData,
            timezone: formData.timezone.identifier,
          },
        },
      });
    });

    it('hides the modal on successful schedule creation', async () => {
      mutate.mockResolvedValueOnce({ data: { oncallScheduleCreate: { errors: [] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).toHaveBeenCalled();
    });

    it("doesn't hide a modal and shows error alert on fail", async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { oncallScheduleCreate: { errors: [error] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      const alert = findAlert();
      expect(mockHideModal).not.toHaveBeenCalled();
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain(error);
    });
  });
});
