import createComponent from 'jest/boards/board_list_helper';

describe('BoardList Component', () => {
  let mock;
  let component;

  beforeEach(done => {
    const listIssueProps = {
      project: {
        path: '/test',
      },
      real_path: '',
      webUrl: '',
    };

    const componentProps = {
      groupId: undefined,
    };

    ({ mock, component } = createComponent({
      done,
      componentProps,
      listIssueProps,
    }));
  });

  afterEach(() => {
    mock.restore();
  });

  it('renders link properly in issue', () => {
    expect(
      component.$el.querySelector('.board-card .board-card-title a').getAttribute('href'),
    ).not.toContain(':project_path');
  });
});
