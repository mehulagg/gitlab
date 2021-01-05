import { shallowMount } from '@vue/test-utils';
import waitForPromises from 'helpers/wait_for_promises';
import { GlDropdownItem, GlTokenSelector } from '@gitlab/ui';
import AddEditRotationForm from 'ee/oncall_schedules/components/rotations/components/add_edit_rotation_form.vue';
import { LENGTH_ENUM } from 'ee/oncall_schedules/constants';
import { participants, getOncallSchedulesQueryResponse } from '../../mocks/apollo_mock';

const projectPath = 'group/project';
const schedule =
  getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

describe('AddEditRotationForm', () => {
  let wrapper;

  const createComponent = ({ data = {}, props = {} } = {}) => {
    wrapper = shallowMount(AddEditRotationForm, {
      data() {
        return {
          ...data,
        };
      },
      propsData: {
        ...props,
        schedule,
        isLoading: false,
        rotationNameIsValid: true,
        rotationParticipantsAreValid: true,
        rotationStartsAtIsValid: true,
        participants,
        form: {
          name: '',
          participants: [],
          rotationLength: {
            length: 1,
            unit: LENGTH_ENUM.hours,
          },
          startsAt: {
            date: null,
            time: 0,
          },
        },
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
  });

  const findRotationLength = () => wrapper.find('[id = "rotation-length"]');
  const findRotationStartsOn = () => wrapper.find('[id = "rotation-time"]');
  const findUserSelector = () => wrapper.find(GlTokenSelector);
  const findDropdownOptions = () => wrapper.findAll(GlDropdownItem);

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
      createComponent();
    });

    it('has user options that are populated via apollo', () => {
      expect(findUserSelector().props('dropdownItems')).toHaveLength(participants.length);
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
});
