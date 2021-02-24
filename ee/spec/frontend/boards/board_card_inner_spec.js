import { GlLabel } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IssueCardWeight from 'ee/boards/components/issue_card_weight.vue';
import BoardCardInner from '~/boards/components/board_card_inner.vue';
import defaultStore from '~/boards/stores';

describe('Board card component', () => {
  let wrapper;
  let issue;
  let list;

  const createComponent = (props = {}, store = defaultStore) => {
    wrapper = shallowMount(BoardCardInner, {
      store,
      propsData: {
        list,
        item: issue,
        ...props,
      },
      provide: {
        groupId: null,
        rootPath: '/',
        scopedLabelsAvailable: false,
      },
    });
  };

  beforeEach(() => {
    list = {
      id: 300,
      position: 0,
      title: 'Test',
      listType: 'label',
      label: {
        id: 5000,
        title: 'Testing',
        color: '#ff0000',
        description: 'testing;',
        textColor: 'white',
      },
    };

    issue = {
      title: 'Testing',
      id: 1,
      iid: 1,
      confidential: false,
      labels: [list.label],
      assignees: [],
      referencePath: '#1',
      webUrl: '/test/1',
      weight: 1,
      blocked: true,
      blockedByCount: 2,
    };
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('labels', () => {
    beforeEach(() => {
      const label1 = {
        id: 3,
        title: 'testing 123',
        color: '#000cff',
        textColor: 'white',
        description: 'test',
      };

      issue.labels = [...issue.labels, label1];
    });

    it.each`
      type              | title              | desc
      ${'GroupLabel'}   | ${'Group label'}   | ${'shows group labels on group boards'}
      ${'ProjectLabel'} | ${'Project label'} | ${'shows project labels on group boards'}
    `('$desc', ({ type, title }) => {
      issue.labels = [
        ...issue.labels,
        {
          id: 9001,
          type,
          title,
          color: '#000000',
        },
      ];

      createComponent({ groupId: 1 });

      expect(wrapper.findAll(GlLabel)).toHaveLength(3);
      expect(wrapper.find(GlLabel).props('title')).toContain(title);
    });

    it('shows no labels when the isShowingLabels state is false', () => {
      const store = {
        ...defaultStore,
        state: {
          ...defaultStore.state,
          isShowingLabels: false,
        },
      };
      createComponent({}, store);

      expect(wrapper.findAll('.board-card-labels')).toHaveLength(0);
    });
  });

  describe('blocked', () => {
    const findBlockedIcon = () => wrapper.find('[data-testid="issue-blocked-icon"');

    it('shows blocked icon if issue is blocked, when blocked by multiple issues', () => {
      createComponent();
      const blockedIcon = findBlockedIcon();

      expect(blockedIcon.exists()).toBe(true);
      expect(blockedIcon.attributes('title')).toBe('Blocked by 2 issues');
    });

    it('shows blocked icon if issue is blocked, when blocked by one issue', () => {
      issue.blockedByCount = 1;
      createComponent();
      const blockedIcon = findBlockedIcon();

      expect(blockedIcon.exists()).toBe(true);
      expect(blockedIcon.attributes('title')).toBe('Blocked by 1 issue');
    });

    it('does not show blocked icon if issue is not blocked', () => {
      issue.blocked = false;
      issue.blockedByCount = 0;
      createComponent();

      expect(findBlockedIcon().exists()).toBe(false);
    });
  });

  describe('weight', () => {
    it('shows weight component', () => {
      createComponent();

      expect(wrapper.find(IssueCardWeight).exists()).toBe(true);
    });
  });
});
