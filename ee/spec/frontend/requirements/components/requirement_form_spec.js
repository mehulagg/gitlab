import { shallowMount } from '@vue/test-utils';

import { GlDrawer, GlFormGroup, GlFormTextarea } from '@gitlab/ui';
import RequirementForm from 'ee/requirements/components/requirement_form.vue';
import { MAX_TITLE_LENGTH } from 'ee/requirements/constants';

import { mockRequirementsOpen } from '../mock_data';

const createComponent = ({
  drawerOpen = true,
  requirement = null,
  requirementRequestActive = false,
} = {}) =>
  shallowMount(RequirementForm, {
    propsData: {
      drawerOpen,
      requirement,
      requirementRequestActive,
    },
  });

describe('RequirementForm', () => {
  let wrapper;
  let wrapperWithRequirement;

  beforeEach(() => {
    wrapper = createComponent();
    wrapperWithRequirement = createComponent({
      requirement: mockRequirementsOpen[0],
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapperWithRequirement.destroy();
  });

  describe('computed', () => {
    describe('isCreate', () => {
      it('returns true when `requirement` prop is null', () => {
        expect(wrapper.vm.isCreate).toBe(true);
      });

      it('returns false when `requirement` prop is not null', () => {
        expect(wrapperWithRequirement.vm.isCreate).toBe(false);
      });
    });

    describe('fieldLabel', () => {
      it('returns string "New Requirement" when `requirement` prop is null', () => {
        expect(wrapper.vm.fieldLabel).toBe('New Requirement');
      });

      it('returns string "Edit Requirement" when `requirement` prop is defined', () => {
        expect(wrapperWithRequirement.vm.fieldLabel).toBe('Edit Requirement');
      });
    });

    describe('saveButtonLabel', () => {
      it('returns string "Create requirement" when `requirement` prop is null', () => {
        expect(wrapper.vm.saveButtonLabel).toBe('Create requirement');
      });

      it('returns string "Save changes" when `requirement` prop is defined', () => {
        expect(wrapperWithRequirement.vm.saveButtonLabel).toBe('Save changes');
      });
    });

    describe('titleInvalid', () => {
      it('returns `false` when `title` length is less than max title limit', () => {
        expect(wrapper.vm.titleInvalid).toBe(false);
      });

      it('returns `true` when `title` length is more than max title limit', () => {
        wrapper.setData({
          title: Array(MAX_TITLE_LENGTH + 1)
            .fill()
            .map(() => 'a')
            .join(''),
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.titleInvalid).toBe(true);
        });
      });
    });

    describe('reference', () => {
      it('returns string containing `requirement.iid` prefixed with `REQ-`', () => {
        expect(wrapperWithRequirement.vm.reference).toBe(`REQ-${mockRequirementsOpen[0].iid}`);
      });
    });
  });

  describe('watchers', () => {
    describe('requirement', () => {
      it('sets `title` to the value of `requirement.title` when requirement is not null', async () => {
        wrapper.setProps({
          requirement: mockRequirementsOpen[0],
        });

        await wrapper.vm.$nextTick();

        expect(wrapper.vm.title).toBe(mockRequirementsOpen[0].title);
      });

      it('sets `title` to empty string when requirement is null', async () => {
        wrapperWithRequirement.setProps({
          requirement: null,
        });

        await wrapperWithRequirement.vm.$nextTick();

        expect(wrapperWithRequirement.vm.title).toBe('');
      });
    });

    describe('drawerOpen', () => {
      it('clears `title` value when `drawerOpen` prop is changed to false', async () => {
        wrapper.setData({
          title: 'Foo',
        });

        wrapper.setProps({
          drawerOpen: false,
        });

        await wrapper.vm.$nextTick();

        expect(wrapper.vm.title).toBe('');
      });
    });
  });

  describe('methods', () => {
    describe('handleSave', () => {
      it('emits `save` event on component with `title` as param when form is in create mode', () => {
        wrapper.setData({
          title: 'foo',
        });

        wrapper.vm.handleSave();

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.emitted('save')).toBeTruthy();
          expect(wrapper.emitted('save')[0]).toEqual(['foo']);
        });
      });

      it('emits `save` event on component with object as param containing `iid` & `title` when form is in update mode', () => {
        wrapperWithRequirement.vm.handleSave();

        return wrapperWithRequirement.vm.$nextTick(() => {
          expect(wrapperWithRequirement.emitted('save')).toBeTruthy();
          expect(wrapperWithRequirement.emitted('save')[0]).toEqual([
            {
              iid: mockRequirementsOpen[0].iid,
              title: mockRequirementsOpen[0].title,
            },
          ]);
        });
      });
    });
  });

  describe('template', () => {
    it('renders gl-drawer as component container element', () => {
      expect(wrapper.find(GlDrawer).exists()).toBe(true);
    });

    it('renders element containing requirement reference when form is in edit mode', () => {
      expect(wrapperWithRequirement.find('span').text()).toBe(`REQ-${mockRequirementsOpen[0].iid}`);
    });

    it('renders gl-form-group component', () => {
      const glFormGroup = wrapper.find(GlFormGroup);

      expect(glFormGroup.exists()).toBe(true);
      expect(glFormGroup.attributes('label')).toBe('Title');
      expect(glFormGroup.attributes('label-for')).toBe('requirementTitle');
      expect(glFormGroup.attributes('invalid-feedback')).toBe(
        `Requirement title cannot have more than ${MAX_TITLE_LENGTH} characters.`,
      );
      expect(glFormGroup.attributes('state')).toBe('true');
    });

    it('renders gl-form-textarea component', () => {
      const glFormTextarea = wrapper.find(GlFormTextarea);

      expect(glFormTextarea.exists()).toBe(true);
      expect(glFormTextarea.attributes('id')).toBe('requirementTitle');
      expect(glFormTextarea.attributes('placeholder')).toBe('Describe the requirement here');
      expect(glFormTextarea.attributes('max-rows')).toBe('25');
    });

    it('renders gl-form-textarea component populated with `requirement.title` when `requirement` prop is defined', () => {
      expect(wrapperWithRequirement.find(GlFormTextarea).attributes('value')).toBe(
        mockRequirementsOpen[0].title,
      );
    });

    it('renders save button component', () => {
      const saveButton = wrapper.find('.js-requirement-save');

      expect(saveButton.exists()).toBe(true);
      expect(saveButton.text()).toBe('Create requirement');
    });

    it('renders cancel button component', () => {
      const cancelButton = wrapper.find('.js-requirement-cancel');

      expect(cancelButton.exists()).toBe(true);
      expect(cancelButton.text()).toBe('Cancel');
    });
  });
});
