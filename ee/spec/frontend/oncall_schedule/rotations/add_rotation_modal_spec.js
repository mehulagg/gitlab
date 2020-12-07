import { shallowMount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import VueApollo from 'vue-apollo';
import waitForPromises from 'helpers/wait_for_promises';
import { GlDropdownItem, GlModal, GlAlert, GlTokenSelector } from '@gitlab/ui';
import AddRotationModal from 'ee/oncall_schedules/components/rotations/add_rotation_modal.vue';
// import createOncallScheduleRotationMutation from 'ee/oncall_schedules/graphql/create_oncall_schedule_rotation.mutation.graphql';
import usersSearchQuery from '~/graphql_shared/queries/users_search.query.graphql';
import { participants } from '../mocks/apollo_mock';

const localVue = createLocalVue();
const projectPath = 'group/project';
const mutate = jest.fn();
const mockHideModal = jest.fn();

localVue.use(VueApollo);

describe('AddRotationModal', () => {
  let wrapper;
  let fakeApollo;
  let userSearchQueryHandler;

  async function awaitApolloDomMock() {
    await wrapper.vm.$nextTick(); // kick off the DOM update
    await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
    await wrapper.vm.$nextTick(); // kick off the DOM update for flash
  }

  const createComponent = ({ data = {}, props = {}, loading = false } = {}) => {
    wrapper = shallowMount(AddRotationModal, {
      data() {
        return {
          ...data,
        };
      },
      propsData: {
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
    wrapper.vm.$refs.createScheduleRotationModal.hide = mockHideModal;
  };

  const createComponentWithApollo = ({ search = '' } = {}) => {
    fakeApollo = createMockApollo([[usersSearchQuery, userSearchQueryHandler]]);

    wrapper = shallowMount(AddRotationModal, {
      localVue,
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
  const findRotationLength = () => wrapper.find('[id = "rotation-length"]');
  const findRotationStartsOn = () => wrapper.find('[id = "rotation-time"]');
  const findUserSelector = () => wrapper.find(GlTokenSelector);
  const findDropdownOptions = () => wrapper.findAll(GlDropdownItem);
  const findAlert = () => wrapper.find(GlAlert);

  it('renders rotation modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Rotation length and start time', () => {
    it('renders the rotation length value', async () => {
      const rotationLength = findRotationLength();
      expect(rotationLength.exists()).toBe(true);
      expect(rotationLength.attributes('value')).toBe('1');
    });

    it('renders the rotation starts on datepicker', async () => {
      const startsOn = findRotationStartsOn();
      expect(startsOn.exists()).toBe(true);
      expect(startsOn.attributes('text')).toBe('00:00');
      expect(startsOn.attributes('headertext')).toBe('');
    });

    it('should add a check for a rotation length type selected', async () => {
      const selectedLengthType1 = findDropdownOptions().at(0);
      const selectedLengthType2 = findDropdownOptions().at(1);
      selectedLengthType1.vm.$emit('click');
      await wrapper.vm.$nextTick();
      expect(selectedLengthType1.props('isChecked')).toBe(true);
      expect(selectedLengthType2.props('isChecked')).toBe(false);
    });
  });

  describe('filter participants', () => {
    beforeEach(() => {
      createComponent({ data: { participants } });
    });

    it('has user options that are populated via apollo', () => {
      expect(findUserSelector().props('dropdownItems').length).toBe(participants.length);
    });

    it('calls the API and sets dropdown items as request result', async () => {
      const tokenSelector = findUserSelector();

      tokenSelector.vm.$emit('focus');
      tokenSelector.vm.$emit('blur');
      tokenSelector.vm.$emit('focus');

      await waitForPromises();

      expect(tokenSelector.props('dropdownItems')).toMatchObject(participants);
      expect(tokenSelector.props('hideDropdownWithNoItems')).toBe(false);
    });

    it('emits `input` event with selected users', () => {
      findUserSelector().vm.$emit('input', participants);

      expect(findUserSelector().emitted().input[0][0]).toEqual(participants);
    });

    it('when text input is blurred the text input clears', async () => {
      const tokenSelector = findUserSelector();
      tokenSelector.vm.$emit('blur');

      await wrapper.vm.$nextTick();

      expect(tokenSelector.props('hideDropdownWithNoItems')).toBe(false);
    });
  });

  describe('Rotation create', () => {
    it('makes a request with `oncallScheduleRotationCreate` to create a schedule rotation', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        variables: { oncallScheduleRotationCreate: expect.objectContaining({ projectPath }) },
      });
    });

    it('does not hide the rotation modal and shows error alert on fail', async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { oncallScheduleRotationCreate: { errors: [error] } } });
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

    // TODO: Once the BE is complete for the mutation add specs here for that via a creationHandler
  });
});
