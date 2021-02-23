import { GlAlert, GlModal } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import AddEditRotationForm from 'ee/oncall_schedules/components/rotations/components/add_edit_rotation_form.vue';
import AddEditRotationModal, {
  i18n,
} from 'ee/oncall_schedules/components/rotations/components/add_edit_rotation_modal.vue';
import { addRotationModalId } from 'ee/oncall_schedules/constants';
import createOncallScheduleRotationMutation from 'ee/oncall_schedules/graphql/mutations/create_oncall_schedule_rotation.mutation.graphql';
import getOncallSchedulesWithRotationsQuery from 'ee/oncall_schedules/graphql/queries/get_oncall_schedules.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash, { FLASH_TYPES } from '~/flash';
import usersSearchQuery from '~/graphql_shared/queries/users_search.query.graphql';
import {
  participants,
  getOncallSchedulesQueryResponse,
  createRotationResponse,
  createRotationResponseWithErrors,
} from '../../mocks/apollo_mock';
import mockRotation from '../../mocks/mock_rotation.json';

jest.mock('~/flash');

const schedule =
  getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];
const localVue = createLocalVue();
const projectPath = 'group/project';
const mutate = jest.fn();
const mockHideModal = jest.fn();

describe('AddEditRotationModal', () => {
  let wrapper;
  let fakeApollo;
  let userSearchQueryHandler;
  let createRotationHandler;

  async function awaitApolloDomMock() {
    await wrapper.vm.$nextTick(); // kick off the DOM update
    await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
    await wrapper.vm.$nextTick(); // kick off the DOM update for flash
  }

  async function createRotation(localWrapper) {
    localWrapper.find(GlModal).vm.$emit('primary', { preventDefault: jest.fn() });
  }

  const createComponent = ({ data = {}, props = {}, loading = false } = {}) => {
    wrapper = shallowMount(AddEditRotationModal, {
      data() {
        return {
          ...data,
        };
      },
      propsData: {
        modalId: addRotationModalId,
        schedule,
        ...props,
      },
      provide: {
        projectPath,
      },
      mocks: {
        $apollo: {
          queries: {
            participants: {
              loading,
            },
          },
          mutate,
        },
      },
    });
    wrapper.vm.$refs.addEditScheduleRotationModal.hide = mockHideModal;
  };

  const createComponentWithApollo = ({
    search = '',
    createHandler = jest.fn().mockResolvedValue(createRotationResponse),
  } = {}) => {
    createRotationHandler = createHandler;
    localVue.use(VueApollo);

    fakeApollo = createMockApollo([
      [
        getOncallSchedulesWithRotationsQuery,
        jest.fn().mockResolvedValue(getOncallSchedulesQueryResponse),
      ],
      [usersSearchQuery, userSearchQueryHandler],
      [createOncallScheduleRotationMutation, createRotationHandler],
    ]);

    fakeApollo.clients.defaultClient.cache.writeQuery({
      query: getOncallSchedulesWithRotationsQuery,
      variables: {
        projectPath: 'group/project',
      },
      data: getOncallSchedulesQueryResponse.data,
    });

    wrapper = shallowMount(AddEditRotationModal, {
      localVue,
      propsData: {
        modalId: addRotationModalId,
        schedule,
        rotation: mockRotation[0],
      },
      apolloProvider: fakeApollo,
      data() {
        return {
          ptSearchTerm: search,
          form: {
            participants,
          },
          participants,
        };
      },
      provide: {
        projectPath,
      },
    });

    wrapper.vm.$refs.addEditScheduleRotationModal.hide = mockHideModal;
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
  const findForm = () => wrapper.find(AddEditRotationForm);

  it('renders rotation modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Rotation create', () => {
    it('makes a request with `oncallRotationCreate` to create a schedule rotation', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        variables: { input: expect.objectContaining({ projectPath }) },
      });
    });

    it('does not hide the rotation modal and shows error alert on fail', async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { oncallRotationCreate: { errors: [error] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).not.toHaveBeenCalled();
      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toContain(error);
    });
  });

  describe('with mocked Apollo client', () => {
    it('it calls searchUsers query with the search parameter', async () => {
      userSearchQueryHandler = jest.fn().mockResolvedValue({
        data: {
          users: {
            nodes: participants,
          },
        },
      });
      createComponentWithApollo({ search: 'root' });
      await awaitApolloDomMock();
      expect(userSearchQueryHandler).toHaveBeenCalledWith({ search: 'root' });
    });

    it('calls a mutation with correct parameters and creates a rotation', async () => {
      createComponentWithApollo();
      expect(wrapper.emitted('fetchRotationShifts')).toBeUndefined();

      await createRotation(wrapper);
      await awaitApolloDomMock();

      expect(mockHideModal).toHaveBeenCalled();
      expect(createRotationHandler).toHaveBeenCalled();
      expect(createFlash).toHaveBeenCalledWith({
        message: i18n.rotationCreated,
        type: FLASH_TYPES.SUCCESS,
      });
      expect(wrapper.emitted('fetchRotationShifts')).toHaveLength(1);
    });

    it('displays alert if mutation had a recoverable error', async () => {
      createComponentWithApollo({
        createHandler: jest.fn().mockResolvedValue(createRotationResponseWithErrors),
      });

      await createRotation(wrapper);
      await awaitApolloDomMock();

      const alert = findAlert();
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain('Houston, we have a problem');
    });
  });

  describe('loading data', () => {
    it('should load rotation restriction data successfully', async () => {
      await createComponentWithApollo();
      await awaitApolloDomMock();

      findModal().vm.$emit('show');

      expect(findForm().props('form')).toMatchObject({
        isRestrictedToTime: true,
        restrictedTo: { startTime: 2, endTime: 10 },
      });
    });
  });
});
