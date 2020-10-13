import MockAdapter from 'axios-mock-adapter';
import Vue from 'vue';

import AssigneeSelect from 'ee/boards/components/assignee_select.vue';
import { boardObj } from 'jest/boards/mock_data';

import axios from '~/lib/utils/axios_utils';
import boardsStore from '~/boards/stores/boards_store';
import IssuableContext from '~/issuable_context';

let vm;

function selectedText() {
  return vm.$el.querySelector('.value').innerText.trim();
}

function activeDropdownItem(index) {
  const items = document.querySelectorAll('.is-active');
  if (!items[index]) return '';
  return items[index].innerText.trim();
}

const assignee = {
  id: 1,
  name: 'first assignee',
};

const assignee2 = {
  id: 2,
  name: 'second assignee',
};

describe('Assignee select component', () => {
  beforeEach(done => {
    setFixtures('<div class="test-container"></div>');
    boardsStore.create();

    // eslint-disable-next-line no-new
    new IssuableContext();

    const Component = Vue.extend(AssigneeSelect);
    vm = new Component({
      propsData: {
        board: boardObj,
        assigneePath: '/test/issue-boards/assignees.json',
        canEdit: true,
        label: 'Assignee',
        selected: {},
        fieldName: 'assignee_id',
        anyUserText: 'Any assignee',
      },
    }).$mount('.test-container');

    setImmediate(done);
  });

  describe('canEdit', () => {
    it('hides Edit button', done => {
      vm.canEdit = false;
      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.edit-link')).toBeFalsy();
        done();
      });
    });

    it('shows Edit button if true', done => {
      vm.canEdit = true;
      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.edit-link')).toBeTruthy();
        done();
      });
    });
  });

  describe('selected value', () => {
    it('defaults to Any Assignee', () => {
      expect(selectedText()).toContain('Any assignee');
    });

    it('shows selected assignee', done => {
      vm.selected = assignee;
      Vue.nextTick(() => {
        expect(selectedText()).toContain('first assignee');
        done();
      });
    });

    describe('clicking dropdown items', () => {
      let mock;

      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onGet('/-/autocomplete/users.json').reply(200, [assignee, assignee2]);
      });

      afterEach(() => {
        mock.restore();
      });

      it('sets assignee', done => {
        vm.$el.querySelector('.edit-link').click();

        jest.runOnlyPendingTimers();

        setImmediate(() => {
          vm.$el.querySelectorAll('li a')[2].click();

          setImmediate(() => {
            expect(activeDropdownItem(0)).toEqual('second assignee');
            expect(vm.board.assignee).toEqual(assignee2);
            done();
          });
        });
      });
    });
  });
});
