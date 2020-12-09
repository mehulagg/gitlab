import { GlDrawer, GlFormTextarea, GlFormCheckbox } from '@gitlab/ui';
import { getByText } from '@testing-library/dom';
import { shallowMount } from '@vue/test-utils';
import $ from 'jquery';

import RequirementForm from 'ee/requirements/components/requirement_form.vue';
import RequirementStatusBadge from 'ee/requirements/components/requirement_status_badge.vue';

import { TestReportStatus, MAX_TITLE_LENGTH } from 'ee/requirements/constants';

import MarkdownField from '~/vue_shared/components/markdown/field.vue';
import ZenMode from '~/zen_mode';

import { mockRequirementsOpen, mockTestReport } from '../mock_data';

const createComponent = ({
  drawerOpen = true,
  requirement = null,
  requirementRequestActive = false,
} = {}) =>
  shallowMount(RequirementForm, {
    provide: {
      descriptionPreviewPath: '/gitlab-org/gitlab-test/preview_markdown',
      descriptionHelpPath: '/help/user/markdown',
    },
    propsData: {
      drawerOpen,
      requirement,
      requirementRequestActive,
    },
    stubs: {
      GlDrawer,
      MarkdownField,
    },
  });

describe('RequirementForm', () => {
  let renderGFMSpy;
  let documentEventSpyOn;
  let wrapper;
  let wrapperWithRequirement;

  beforeEach(() => {
    renderGFMSpy = jest.spyOn($.fn, 'renderGFM');
    documentEventSpyOn = jest.spyOn($.prototype, 'on');
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
  });

  describe('watchers', () => {
    describe('requirement', () => {
      describe('when requirement is not null', () => {
        it('renders the value of `requirement.title` as title and `requirement.description` as description', async () => {
          wrapper.setProps({
            requirement: mockRequirementsOpen[0],
            enableRequirementEdit: true,
          });

          await wrapper.vm.$nextTick();

          expect(
            wrapper
              .find('[data-testid="title"]')
              .find(GlFormTextarea)
              .attributes('value'),
          ).toBe(mockRequirementsOpen[0].title);

          expect(wrapper.find('[data-testid="description"] textarea').element.value).toBe(
            mockRequirementsOpen[0].description,
          );
        });

        it.each`
          requirement                | satisfied
          ${mockRequirementsOpen[0]} | ${true}
          ${mockRequirementsOpen[1]} | ${false}
        `(
          `renders the satisfied checkbox according to the value of \`requirement.satisfied\`=$satisfied`,
          async ({ requirement, satisfied }) => {
            wrapper = createComponent();
            wrapper.setProps({ requirement, enableRequirementEdit: true });

            await wrapper.vm.$nextTick();

            expect(wrapper.find(GlFormCheckbox).vm.$attrs.checked).toBe(satisfied);
          },
        );
      });

      describe('when requirement is null', () => {
        beforeEach(() => {
          wrapper.setProps({
            requirement: null,
            enableRequirementEdit: true,
          });
        });

        it('renders empty string as title and description', async () => {
          await wrapper.vm.$nextTick();

          expect(
            wrapper
              .find('[data-testid="title"]')
              .find(GlFormTextarea)
              .attributes('value'),
          ).toBe('');
          expect(wrapper.find('[data-testid="description"] textarea').element.value).toBe('');
          expect(wrapper.find(GlFormCheckbox).exists()).toBe(false);
        });
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
        expect(wrapper.vm.description).toBe('');
        expect(wrapper.vm.satisfied).toBe(false);
      });
    });
  });

  describe('mounted', () => {
    it('initializes `zenMode` prop on component', () => {
      expect(wrapper.vm.zenMode instanceof ZenMode).toBe(true);
    });

    it('calls `renderGFM` on `$refs.gfmContainer`', () => {
      expect(renderGFMSpy).toHaveBeenCalled();
    });

    it('binds events `zen_mode:enter` & `zen_mode:leave` events on document', () => {
      expect(documentEventSpyOn).toHaveBeenCalledWith('zen_mode:enter', expect.any(Function));
      expect(documentEventSpyOn).toHaveBeenCalledWith('zen_mode:leave', expect.any(Function));
    });
  });

  describe('beforeDestroy', () => {
    let documentEventSpyOff;

    it('unbinds events `zen_mode:enter` & `zen_mode:leave` events on document', () => {
      const wrapperTemp = createComponent();
      documentEventSpyOff = jest.spyOn($.prototype, 'off');

      wrapperTemp.destroy();

      expect(documentEventSpyOff).toHaveBeenCalledWith('zen_mode:enter');
      expect(documentEventSpyOff).toHaveBeenCalledWith('zen_mode:leave');
    });
  });

  describe('methods', () => {
    describe.each`
      lastTestReportState        | requirement                | newLastTestReportState
      ${TestReportStatus.Passed} | ${mockRequirementsOpen[0]} | ${TestReportStatus.Failed}
      ${TestReportStatus.Failed} | ${mockRequirementsOpen[1]} | ${TestReportStatus.Passed}
      ${'null'}                  | ${mockRequirementsOpen[2]} | ${TestReportStatus.Passed}
    `('newLastTestReportState', ({ lastTestReportState, requirement, newLastTestReportState }) => {
      describe(`when \`lastTestReportState\` is ${lastTestReportState}`, () => {
        beforeEach(() => {
          wrapperWithRequirement = createComponent({ requirement });
        });

        it("returns null when `satisfied` hasn't changed", () => {
          expect(wrapperWithRequirement.vm.newLastTestReportState()).toBe(null);
        });

        it(`returns ${newLastTestReportState} when \`satisfied\` has changed from ${
          requirement.satisfied
        } to ${!requirement.satisfied}`, () => {
          wrapperWithRequirement.setData({
            satisfied: !requirement.satisfied,
          });

          expect(wrapperWithRequirement.vm.newLastTestReportState()).toBe(newLastTestReportState);
        });
      });
    });

    describe('handleSave', () => {
      it('emits `save` event on component with object as param containing `title` & `description` when form is in create mode', () => {
        const title = 'foo';
        const description = '_bar_';
        wrapper.setData({
          title,
          description,
        });

        wrapper.vm.handleSave();

        expect(wrapper.emitted('save')).toBeTruthy();
        expect(wrapper.emitted('save')[0]).toEqual([
          {
            title,
            description,
          },
        ]);
      });

      it('emits `save` event on component with object as param containing `iid`, `title`, `description` & `lastTestReportState` when form is in update mode', () => {
        const { iid, title, description } = mockRequirementsOpen[0];
        wrapperWithRequirement.vm.handleSave();

        expect(wrapperWithRequirement.emitted('save')).toBeTruthy();
        expect(wrapperWithRequirement.emitted('save')[0]).toEqual([
          {
            iid,
            title,
            description,
            lastTestReportState: wrapperWithRequirement.vm.newLastTestReportState(),
          },
        ]);
      });
    });

    describe('handleCancel', () => {
      it('emits `drawer-close` event when form create mode', () => {
        wrapper.vm.handleCancel();

        expect(wrapper.emitted('drawer-close')).toBeTruthy();
      });

      it('emits `disable-edit` event when form edit mode', () => {
        wrapperWithRequirement.vm.handleCancel();

        expect(wrapperWithRequirement.emitted('disable-edit')).toBeTruthy();
      });
    });
  });

  describe('template', () => {
    it('renders gl-drawer as component container element', () => {
      expect(wrapper.find(GlDrawer).exists()).toBe(true);
    });

    describe('create requirement', () => {
      it('renders drawer header with string "New Requirement"', () => {
        expect(getByText(wrapper.element, 'New Requirement')).not.toBeNull();
      });

      it('renders title and description input fields', () => {
        expect(wrapper.find('[data-testid="title"]').exists()).toBe(true);
        expect(wrapper.find('[data-testid="description"]').exists()).toBe(true);
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

    describe('view requirement', () => {
      it('renders drawer header with `requirement.reference` and test report badge', () => {
        expect(
          getByText(wrapperWithRequirement.element, `REQ-${mockRequirementsOpen[0].iid}`),
        ).not.toBeNull();
        expect(wrapperWithRequirement.find(RequirementStatusBadge).exists()).toBe(true);
        expect(wrapperWithRequirement.find(RequirementStatusBadge).props('testReport')).toBe(
          mockTestReport,
        );
      });

      it('renders requirement title', () => {
        expect(
          getByText(wrapperWithRequirement.element, mockRequirementsOpen[0].titleHtml),
        ).not.toBeNull();
      });

      it('renders edit button', () => {
        const editButtonEl = wrapperWithRequirement.find('[data-testid="edit"]');

        expect(editButtonEl.exists()).toBe(true);
        expect(editButtonEl.props('icon')).toBe('pencil');
        expect(editButtonEl.attributes('title')).toBe('Edit title and description');
      });

      it('renders requirement description', () => {
        const descriptionEl = wrapperWithRequirement.find('[data-testid="descriptionContainer"]');

        expect(descriptionEl.exists()).toBe(true);
        expect(descriptionEl.text()).toBe('fortitudinis fomentis dolor mitigari solet.');
      });

      describe('edit', () => {
        beforeEach(async () => {
          wrapperWithRequirement.setProps({
            enableRequirementEdit: true,
          });

          await wrapperWithRequirement.vm.$nextTick();
        });

        it('renders flash error container', () => {
          expect(wrapperWithRequirement.find('[data-testid="form-error-container"]').exists()).toBe(
            true,
          );
        });

        it('renders title input field', () => {
          const titleInputEl = wrapperWithRequirement.find('[data-testid="title"]');
          const titleTextarea = titleInputEl.find(GlFormTextarea);

          expect(titleInputEl.exists()).toBe(true);
          expect(titleInputEl.attributes()).toMatchObject({
            label: 'Title',
            state: 'true',
            'label-for': 'requirementTitle',
            'invalid-feedback': `Requirement title cannot have more than ${MAX_TITLE_LENGTH} characters.`,
          });

          expect(titleTextarea.exists()).toBe(true);
          expect(titleTextarea.attributes()).toMatchObject({
            id: 'requirementTitle',
            placeholder: 'Requirement title',
            value: mockRequirementsOpen[0].title,
            'max-rows': '25',
          });
        });

        it('renders description input field', () => {
          const descriptionInputEl = wrapperWithRequirement.find('[data-testid="description"]');
          const markdownEl = descriptionInputEl.find(MarkdownField);
          const descriptionTextarea = markdownEl.find('textarea');

          expect(descriptionInputEl.exists()).toBe(true);
          expect(descriptionInputEl.find('label').text()).toBe('Description');

          expect(markdownEl.exists()).toBe(true);
          expect(markdownEl.props()).toMatchObject({
            markdownPreviewPath: '/gitlab-org/gitlab-test/preview_markdown',
            markdownDocsPath: '/help/user/markdown',
            enableAutocomplete: false,
            textareaValue: mockRequirementsOpen[0].description,
          });

          expect(descriptionTextarea.exists()).toBe(true);
          expect(descriptionTextarea.attributes()).toMatchObject({
            id: 'requirementDescription',
            placeholder: 'Describe the requirement here',
            'aria-label': 'Description',
          });
        });

        it('renders satisfied checkbox field', () => {
          expect(wrapperWithRequirement.find(GlFormCheckbox).exists()).toBe(true);
          expect(wrapperWithRequirement.find(GlFormCheckbox).text()).toBe('Satisfied');
        });
      });
    });
  });
});
