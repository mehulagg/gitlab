import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import CommentForm from '~/notes/components/comment_form.vue';
import createStore from '~/notes/stores';
import {
  notesDataMock,
  userDataMock,
  noteableDataMock,
} from '../../../../../spec/frontend/notes/mock_data';

jest.mock('autosize');
jest.mock('~/commons/nav/user_merge_requests');
jest.mock('~/gl_form');

describe('issue_comment_form component', () => {
  let store;
  let wrapper;
  let axiosMock;

  const setupStore = (userData, noteableData) => {
    store.dispatch('setUserData', userData);
    store.dispatch('setNoteableData', noteableData);
    store.dispatch('setNotesData', notesDataMock);
  };

  const mountComponent = (noteableType = 'issue') => {
    wrapper = mount(CommentForm, {
      propsData: {
        noteableType,
      },
      store,
    });
  };

  const findCloseBtn = () => wrapper.find('.btn-comment-and-close');

  beforeEach(() => {
    axiosMock = new MockAdapter(axios);
    store = createStore();

    // This is necessary as we query Close issue button at the top of issue page when clicking bottom button
    setFixtures(
      '<div class="detail-page-header-actions"><button class="btn-close btn-grouped"></button></div>',
    );
  });

  afterEach(() => {
    axiosMock.restore();
    wrapper.destroy();
  });

  describe('when issue is not blocked by other issues', () => {
    beforeEach(() => {
      setupStore(userDataMock, noteableDataMock);

      mountComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('should close the issue when clicking close issue button', done => {
      jest.spyOn(wrapper.vm, 'closeIssue').mockResolvedValue();
      findCloseBtn().trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(wrapper.vm.closeIssue).toHaveBeenCalled();

        done();
      });
    });
  });

  describe('when issue is blocked by other issues', () => {
    let noteableDataMockBlocked;
    beforeEach(() => {
      noteableDataMockBlocked = Object.assign(noteableDataMock, {
        blocked_by_issues: [
          {
            iid: 1,
            web_url: 'path/to/issue',
          },
        ],
      });
      setupStore(userDataMock, noteableDataMockBlocked);

      mountComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('should display alert warning when attempting to close issue, close button is hidden', done => {
      findCloseBtn().trigger('click');

      wrapper.vm.$nextTick(() => {
        const warning = wrapper.find('.gl-alert-warning');
        expect(warning.exists()).toBe(true);
        expect(warning.text()).toContain('Are you sure you want to close this blocked issue?');

        const linkToBlockingIssue = warning.find('.gl-link');
        expect(linkToBlockingIssue.text()).toContain(
          noteableDataMockBlocked.blocked_by_issues[0].iid,
        );
        done();
      });
    });

    it('should close the issue when clicking close issue button in alert', done => {
      jest.spyOn(wrapper.vm, 'closeIssue').mockResolvedValue();
      findCloseBtn().trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(findCloseBtn().exists()).toBe(false);
        const warning = wrapper.find('.gl-alert-warning');
        const primaryButton = warning.find('.gl-alert-actions .gl-button');
        expect(primaryButton.text()).toEqual('Yes, close issue');
        primaryButton.trigger('click');

        wrapper.vm.$nextTick(() => {
          expect(warning.exists()).toBe(false);

          done();
        });

        setTimeout(() => {
          expect(wrapper.vm.closeIssue).toHaveBeenCalled();

          done();
        }, 1000);
        done();
      });
    });

    it('should dismiss alert warning when clicking cancel button in alert', done => {
      findCloseBtn().trigger('click');

      wrapper.vm.$nextTick(() => {
        const warning = wrapper.find('.gl-alert-warning');
        const secondaryButton = warning.find('.gl-alert-actions .btn-default');
        expect(secondaryButton.text()).toEqual('Cancel');
        secondaryButton.trigger('click');
        wrapper.vm.$nextTick(() => {
          expect(warning.exists()).toBe(false);

          done();
        });
      });
    });
  });
});
