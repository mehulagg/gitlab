import { mount } from '@vue/test-utils';
import CommentFieldLayout from '~/notes/components/comment_field_layout.vue';

describe('Comment Field Layout Component', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const LOCKED_DISCUSSION_DOCS_PATH = 'docs/locked/path';
  const CONFIDENTIAL_ISSUES_DOCS_PATH = 'docs/confidential/path';

  const noteableDataMock = {
    confidential: false,
    discussion_locked: false,
    locked_discussion_docs_path: LOCKED_DISCUSSION_DOCS_PATH,
    confidential_issues_docs_path: CONFIDENTIAL_ISSUES_DOCS_PATH,
  };

  const findIssuableNoteWarning = () => wrapper.find('[data-testid="confidential-warning"]');
  const findEmailParticipantsWarning = () => wrapper.find('[data-testid="email-participants-warning"]');

  const createWrapper = (propOVerrides = { }) => {
    const props = propOVerrides;

    if (props.noteableData == null) 
      props.noteableData = noteableDataMock;

    wrapper = mount(CommentFieldLayout, {
      propsData: {
        ...props,
      },
    });
  };

  describe('.error-alert', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('does not exist by default', () => {
      createWrapper();

      expect(wrapper.find('.error-alert').exists()).toBe(false);
    })
  
    it('exists when withAlertContainer is true', () => {
      createWrapper({ withAlertContainer: true });
  
      expect(wrapper.find('.error-alert').exists()).toBe(true);
    })
  });

  describe('issue is not confidential and not locked', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('does not show IssuableNoteWarning', () => {
      expect(findIssuableNoteWarning().exists()).toBe(false);
    });
  });

  describe('issue is confidential', () => {
    beforeEach(() => {
      createWrapper({
        noteableData: { ...noteableDataMock, confidential: true },
      });
    });

    it('shows IssuableNoteWarning', () => {
      expect(findIssuableNoteWarning().exists()).toBe(true);
    });

    it('sets IssuableNoteWarning props', () => {
      expect(findIssuableNoteWarning().vm.isLocked).toBe(false);
      expect(findIssuableNoteWarning().vm.isConfidential).toBe(true);
      expect(findIssuableNoteWarning().vm.lockedNoteableDocsPath).toEqual(LOCKED_DISCUSSION_DOCS_PATH);
      expect(findIssuableNoteWarning().vm.confidentialNoteableDocsPath).toEqual(CONFIDENTIAL_ISSUES_DOCS_PATH);
    });
  });

  describe('issue is locked', () => {
    beforeEach(() => {
      createWrapper({
        noteableData: { ...noteableDataMock, discussion_locked: true },
      });
    });

    it('shows IssuableNoteWarning', () => {
      expect(findIssuableNoteWarning().exists()).toBe(true);
    });

    it('sets IssuableNoteWarning props', () => {
      expect(findIssuableNoteWarning().vm.isConfidential).toBe(false);
      expect(findIssuableNoteWarning().vm.isLocked).toBe(true);
      expect(findIssuableNoteWarning().vm.lockedNoteableDocsPath).toEqual(LOCKED_DISCUSSION_DOCS_PATH);
      expect(findIssuableNoteWarning().vm.confidentialNoteableDocsPath).toEqual(CONFIDENTIAL_ISSUES_DOCS_PATH);
    });
  });

  describe('issue has no email participants', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('does not show EmailParticipantsWarning', () => {
      expect(findEmailParticipantsWarning().exists()).toBe(false);
    });
  });

  describe('issue has email participants', () => {
    beforeEach(() => {
      createWrapper({
        noteableData: { ...noteableDataMock, issue_email_participants: ['someone@gitlab.com', 'another@gitlab.com'] },
      });
    });

    it('shows EmailParticipantsWarning', () => {
      expect(findEmailParticipantsWarning().exists()).toBe(true);
    });

    it('sets EmailParticipantsWarning props', () => {
      expect(findEmailParticipantsWarning().vm.emails).toEqual(['someone@gitlab.com', 'another@gitlab.com']);
    });
  });
});
