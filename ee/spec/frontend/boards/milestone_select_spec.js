import Vue from 'vue';
import MilestoneSelect from 'ee/boards/components/milestone_select.vue';
import { boardObj } from 'jest/boards/mock_data';
import Api from '~/api';
import IssuableContext from '~/issuable_context';

let vm;

function selectedText() {
  return vm.$el.querySelector('.value').innerText.trim();
}

function activeDropdownItem(index) {
  const items = vm.$el.querySelectorAll('.is-active');
  if (!items[index]) return '';
  return items[index].innerText.trim();
}

const milestone = {
  id: 1,
  title: 'first milestone',
  name: 'first milestone',
  due_date: '2015-05-05',
  expired: true,
};

const milestone2 = {
  id: 2,
  title: 'second milestone',
  name: 'second milestone',
  due_date: null,
  expired: false,
};

describe('Milestone select component', () => {
  beforeEach(done => {
    setFixtures('<div class="test-container"></div>');

    // eslint-disable-next-line no-new
    new IssuableContext();

    const Component = Vue.extend(MilestoneSelect);
    vm = new Component({
      propsData: {
        board: boardObj,
        groupId: 2,
        projectId: 2,
        canEdit: true,
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
    it('defaults to Any milestone', () => {
      expect(selectedText()).toContain('Any milestone');
    });

    it('shows No milestone', done => {
      vm.board.milestone_id = 0;
      Vue.nextTick(() => {
        expect(selectedText()).toContain('No milestone');
        done();
      });
    });

    it('shows selected milestone title', done => {
      vm.board.milestone_id = 20;
      vm.board.milestone = {
        id: 20,
        title: 'Selected milestone',
      };
      Vue.nextTick(() => {
        expect(selectedText()).toContain('Selected milestone');
        done();
      });
    });

    describe('clicking dropdown items', () => {
      beforeEach(() => {
        jest.spyOn(Api, 'projectMilestones').mockResolvedValue({ data: [milestone, milestone2] });
      });

      it('sets Any milestone', async done => {
        vm.board.milestone_id = 0;
        vm.$el.querySelector('.edit-link').click();

        await vm.$nextTick();
        jest.runOnlyPendingTimers();

        setImmediate(() => {
          vm.$el.querySelectorAll('li a')[0].click();
        });

        setImmediate(() => {
          expect(activeDropdownItem(0)).toEqual('Any milestone');
          expect(selectedText()).toEqual('Any milestone');
          done();
        });
      });

      it('sets No milestone', done => {
        vm.$el.querySelector('.edit-link').click();

        jest.runOnlyPendingTimers();

        setImmediate(() => {
          vm.$el.querySelectorAll('li a')[1].click();
        });

        setImmediate(() => {
          expect(activeDropdownItem(0)).toEqual('No milestone');
          expect(selectedText()).toEqual('No milestone');
          done();
        });
      });

      it('sets milestone', done => {
        vm.$el.querySelector('.edit-link').click();

        jest.runOnlyPendingTimers();

        setImmediate(() => {
          vm.$el.querySelectorAll('li a')[4].click();
        });

        setImmediate(() => {
          // "second milestone" is not expired, hence it shows up to the top.
          expect(activeDropdownItem(0)).toBe('second milestone');
          expect(selectedText()).toBe('second milestone');
          expect(vm.board.milestone).toEqual(milestone2);
          done();
        });
      });
    });
  });
});
