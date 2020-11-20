import { shallowMount } from '@vue/test-utils';
import { GlModal, GlFormInput, GlFormCheckboxTree, GlSprintf } from '@gitlab/ui';
import { getByText } from '@testing-library/dom';
import { nextTick } from 'vue';
import DevopsAdoptionSegmentModal from 'ee/admin/dev_ops_report/components/devops_adoption_segment_modal.vue';
import { DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from 'ee/admin/dev_ops_report/constants';
import { groupNodes } from '../mock_data';

describe('DevopsAdoptionSegmentModal', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(DevopsAdoptionSegmentModal, {
      propsData: {
        groups: groupNodes,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  const findModal = () => wrapper.find(GlModal);
  const findByTestId = testId => findModal().find(`[data-testid="${testId}"`);

  const assertHelperText = text => expect(getByText(wrapper.element, text)).not.toBeNull();

  beforeEach(() => createComponent());

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('contains the corrrect id', () => {
    const modal = findModal();

    expect(modal.exists()).toBe(true);
    expect(modal.props('modalId')).toBe(DEVOPS_ADOPTION_SEGMENT_MODAL_ID);
  });

  describe('displays the correct content', () => {
    const isCorrectShape = option => {
      const keys = Object.keys(option);
      return keys.includes('label') && keys.includes('value');
    };

    it('displays the name field', () => {
      const name = findByTestId('name');

      expect(name.exists()).toBe(true);
      expect(name.find(GlFormInput).exists()).toBe(true);
    });

    it('contains the checkbox tree component', () => {
      const checkboxes = findByTestId('groups').find(GlFormCheckboxTree);

      expect(checkboxes.exists()).toBe(true);

      const options = checkboxes.props('options');

      expect(options.length).toBe(2);
      expect(options.every(isCorrectShape)).toBe(true);
    });

    describe('selected groups helper text', () => {
      it('displays the plural text when 0 groups are selected', () => {
        assertHelperText('0 groups selected (20 max)');
      });

      it('dispalys the singular text when only 1 group is selected', async () => {
        wrapper.setData({ checkboxValues: [groupNodes[0]] });

        await nextTick();

        assertHelperText('1 group selected (20 max)');
      });

      it('displays the plural text when multiple groups are selected', async () => {
        wrapper.setData({ checkboxValues: groupNodes });

        await nextTick();

        assertHelperText('2 groups selected (20 max)');
      });
    });
  });
});
