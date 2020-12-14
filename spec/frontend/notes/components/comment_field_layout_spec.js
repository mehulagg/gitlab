import { mount, shallowMount } from '@vue/test-utils';
import CommentFieldLayout from '~/notes/components/comment_field_layout.vue';

describe('Comment Field Layout Component', () => {
  let wrapper;

  beforeEach(() => {
    createWrapper({
      noteableData: { ...noteableDataMock },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const noteableDataMock = {
    confidential: false,
    discussion_locked: false,
    locked_discussion_docs_path: '',
    confidential_issues_docs_path: '',
    issue_email_participants: [],
  };

  const createWrapper = (props = {}) => {
    console.log(props);
    wrapper = mount(CommentFieldLayout, {
      propsData: {
        ...props,
      },
    });
  };

  it('does something', () => {
    expect(wrapper.find('.comment-warning-wrapper').exists()).toBe(true);
  });

  it('does something', () => {
    expect(wrapper.find('.error-alert').exists()).toBe(false);
  })

  it('does something', () => {
    createWrapper({
      noteableData: { ...noteableDataMock },
      withAlertContainer: true,
    });

    expect(wrapper.find('.error-alert').exists()).toBe(true);
  })
  
  describe('issue is confidential', () => {
    it('shows information warning', () => {
      createWrapper({
        noteableData: { ...noteableDataMock, confidential: true },
      });

      expect(wrapper.find('.issuable-note-warning').exists()).toBe(true);
    });
  });
});
