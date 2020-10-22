import ListIssue from '~/boards/models/issue';
import IssueProject from '~/boards/models/project';
import boardsStore from '~/boards/stores/boards_store';

class ListIssueEE extends ListIssue {
  constructor(obj) {
    super(obj, {
      IssueProject,
    });

    this.weight = obj.weight;

    if (obj.project) {
      this.project = new IssueProject(obj.project);
    }
  }

  updateEpic(newEpic) {
    boardsStore.updateIssueEpic(this, newEpic);
  }
}

window.ListIssue = ListIssueEE;

export default ListIssueEE;
