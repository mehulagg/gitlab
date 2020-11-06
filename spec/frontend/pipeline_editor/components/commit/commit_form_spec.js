import { shallowMount } from '@vue/test-utils';
import { GlForm, GlFormTextarea, GlFormInput, GlFormCheckbox } from '@gitlab/ui';

import CommitForm from '~/pipeline_editor/components/commit/commit_form.vue';

import { mockCommitMessage, mockDefaultBranch } from '../../mock_data';

describe('~/pipeline_editor/pipeline_editor_app.vue', () => {
  let wrapper;

  const createComponent = ({ props = {} } = {}, mountFn = shallowMount) => {
    wrapper = mountFn(CommitForm, {
      propsData: {
        defaultMessage: mockCommitMessage,
        defaultBranch: mockDefaultBranch,
        ...props,
      },
    });
  };

  const findForm = () => wrapper.find(GlForm);
  const findCommitTextarea = () => wrapper.find(GlFormTextarea);
  const findBranchInput = () => wrapper.find(GlFormInput);
  const findMrCheckbox = () => wrapper.find(GlFormCheckbox);
  const findSubmitBtn = () => wrapper.find('[type="submit"]');
  const findCancelBtn = () => wrapper.find('[type="reset"]');

  beforeEach(() => {
    createComponent();
  });

  it('shows a default commit message', () => {
    expect(findCommitTextarea().attributes('value')).toBe(mockCommitMessage);
  });

  it('shows a default branch', () => {
    expect(findBranchInput().attributes('value')).toBe(mockDefaultBranch);
  });

  it('shows buttons', () => {
    expect(findSubmitBtn().exists()).toBe(true);
    expect(findCancelBtn().exists()).toBe(true);
  });

  it('does not show a new MR checkbox', () => {
    expect(findMrCheckbox().exists()).toBe(false);
  });

  describe('events', () => {
    it('emits an event when the form submits', () => {
      findForm().vm.$emit('submit', new Event('submit'));

      expect(wrapper.emitted('submit')[0]).toEqual([
        {
          message: mockCommitMessage,
          branch: mockDefaultBranch,
          openMergeRequest: false,
        },
      ]);
    });

    it('emits an event when the form resets', () => {
      findForm().vm.$emit('reset', new Event('reset'));

      expect(wrapper.emitted('cancel')).toHaveLength(1);
    });
  });

  describe('when values change', () => {
    const anotherMessage = 'Another commit message';
    const anotherBranch = 'my-branch';

    beforeEach(() => {
      findCommitTextarea().vm.$emit('input', anotherMessage);
      findBranchInput().vm.$emit('input', anotherBranch);
    });

    it('shows a new MR checkbox', () => {
      expect(findMrCheckbox().exists()).toBe(true);
    });

    it('emits an event with other values', () => {
      findMrCheckbox().vm.$emit('input', true);

      findForm().vm.$emit('submit', new Event('submit'));

      expect(wrapper.emitted('submit')[0]).toEqual([
        {
          message: anotherMessage,
          branch: anotherBranch,
          openMergeRequest: true,
        },
      ]);
    });

    describe('when values are removed', () => {
      beforeEach(() => {
        findBranchInput().vm.$emit('input', anotherBranch);
      });

      it('shows a disables the form', () => {
        findCommitTextarea().vm.$emit('input', '');
        expect(findMrCheckbox().exists()).toBe(true);
      });

      it('emits an event with other values', () => {
        findMrCheckbox().vm.$emit('input', true);

        findForm().vm.$emit('submit', new Event('submit'));

        expect(wrapper.emitted('submit')[0]).toEqual([
          {
            message: anotherMessage,
            branch: anotherBranch,
            openMergeRequest: true,
          },
        ]);
      });
    });
  });
});
