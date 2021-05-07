import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import IssuableEditActions from '~/issue_show/components/edit_actions.vue';
import eventHub from '~/issue_show/event_hub';

describe('Edit Actions components', () => {
  let wrapper;

  const $apollo = {
    mutate: jest.fn().mockResolvedValue(),
  };

  const createComponent = ({ props, data } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(IssuableEditActions, {
        propsData: {
          formState: {
            issue_type: 'issue',
            title: 'GitLab Issue',
          },
          canDestroy: true,
          issuableType: 'issue',
          ...props,
        },
        data() {
          return {
            ...data,
          };
        },
        mocks: {
          $apollo,
        },
      }),
    );
  };

  const findEditButtons = () => wrapper.findAllComponents(GlButton);
  const findDeleteButton = () => wrapper.findByTestId('issuable-delete-button');
  const findSaveButton = () => wrapper.findByTestId('issuable-save-button');
  const findCancelButton = () => wrapper.findByTestId('issuable-cancel-button');

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders all buttons as enabled', () => {
    const buttons = findEditButtons().wrappers;
    buttons.forEach((button) => {
      expect(button.attributes('disabled')).toBeFalsy();
    });
  });

  it('does not render the delete button if canDestroy is false', () => {
    createComponent({ props: { canDestroy: false } });
    expect(findDeleteButton().exists()).toBe(false);
  });

  it('updates the delete button copy when a different type is selected', () => {
    createComponent({ props: { formState: { title: 'GitLab Incident', issue_type: 'incident' } } });
    expect(findDeleteButton().text()).toBe(`Delete incident`);
  });

  it('disables save button when title is blank', () => {
    createComponent({ props: { formState: { title: '' } } });

    expect(findSaveButton().attributes('disabled')).toBe('true');
  });

  it('does not render the delete button if showDeleteButton is false', () => {
    createComponent({ props: { showDeleteButton: false } });

    expect(findDeleteButton().exists()).toBe(false);
  });

  describe('updateIssuable', () => {
    beforeEach(() => {
      jest.spyOn(eventHub, '$emit').mockImplementation(() => {});
    });

    it('sends update.issauble event when clicking save button', () => {
      findSaveButton().vm.$emit('click', { preventDefault: jest.fn() });

      expect(eventHub.$emit).toHaveBeenCalledWith('update.issuable');
    });
  });
  describe('closeForm', () => {
    beforeEach(() => {
      jest.spyOn(eventHub, '$emit').mockImplementation(() => {});
    });

    it('emits close.form when clicking cancel', () => {
      findCancelButton().vm.$emit('click');

      expect(eventHub.$emit).toHaveBeenCalledWith('close.form');
    });
  });

  describe('deleteIssuable', () => {
    beforeEach(() => {
      jest.spyOn(eventHub, '$emit').mockImplementation(() => {});
    });

    it('sends delete.issuable event when clicking save button', () => {
      jest.spyOn(window, 'confirm').mockReturnValue(true);
      findDeleteButton().vm.$emit('click');

      expect(eventHub.$emit).toHaveBeenCalledWith('delete.issuable', { destroy_confirm: true });
    });

    it('does nothing when confirm is false', () => {
      jest.spyOn(window, 'confirm').mockReturnValue(false);
      findDeleteButton().vm.$emit('click');

      expect(eventHub.$emit).not.toHaveBeenCalledWith('delete.issuable');
    });
  });
});
