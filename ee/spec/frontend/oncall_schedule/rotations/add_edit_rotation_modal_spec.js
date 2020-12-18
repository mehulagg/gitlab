import { shallowMount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import VueApollo from 'vue-apollo';
import waitForPromises from 'helpers/wait_for_promises';
import { GlModal, GlAlert } from '@gitlab/ui';
import { addRotationModalId } from 'ee/oncall_schedules/constants';
import AddEditRotationModal from 'ee/oncall_schedules/components/rotations/add_edit_rotation_modal.vue';
import getOncallSchedulesQuery from 'ee/oncall_schedules/graphql/queries/get_oncall_schedules.query.graphql';
import createOncallScheduleRotationMutation from 'ee/oncall_schedules/graphql/mutations/create_oncall_schedule_rotation.mutation.graphql';
import usersSearchQuery from '~/graphql_shared/queries/users_search.query.graphql';
import {
  participants,
  getOncallSchedulesQueryResponse,
  createRotationResponse,
  createRotationResponseWithErrors,
} from '../mocks/apollo_mock';

const localVue = createLocalVue();
const projectPath = 'group/project';
const mutate = jest.fn();
const mockHideModal = jest.fn();
const schedule =
  getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

localVue.use(VueApollo);

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
    await jest.runOnlyPendingTimers();
    await localWrapper.vm.$nextTick();

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
        ...props,
        schedule,
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

    fakeApollo = createMockApollo([
      [getOncallSchedulesQuery, jest.fn().mockResolvedValue(getOncallSchedulesQueryResponse)],
      [usersSearchQuery, userSearchQueryHandler],
      [createOncallScheduleRotationMutation, createRotationHandler],
    ]);

    fakeApollo.clients.defaultClient.cache.writeQuery({
      query: getOncallSchedulesQuery,
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

  it('renders rotation modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Rotation create', () => {
    it('makes a request with `oncallRotationCreate` to create a schedule rotation', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        update: expect.anything(),
        variables: { OncallRotationCreateInput: expect.objectContaining({ projectPath }) },
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
    it('it calls searchUsers query with the search paramter', async () => {
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

      await createRotation(wrapper);

      expect(createRotationHandler).toHaveBeenCalled();
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
});
