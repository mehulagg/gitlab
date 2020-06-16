/* eslint-disable no-underscore-dangle, class-methods-use-this */

import ListIssue from 'ee_else_ce/boards/models/issue';
import { __ } from '~/locale';
import ListLabel from './label';
import ListAssignee from './assignee';
import flash from '~/flash';
import boardsStore from '../stores/boards_store';
import ListMilestone from './milestone';

const TYPES = {
  backlog: {
    isPreset: true,
    isExpandable: true,
    isBlank: false,
  },
  closed: {
    isPreset: true,
    isExpandable: true,
    isBlank: false,
  },
  blank: {
    isPreset: true,
    isExpandable: false,
    isBlank: true,
  },
  default: {
    // includes label, assignee, and milestone lists
    isPreset: false,
    isExpandable: true,
    isBlank: false,
  },
};

class List {
  constructor(obj) {
    this.id = obj.id;
    this._uid = this.guid();
    this.position = obj.position;
    this.title = (obj.list_type || obj.listType) === 'backlog' ? __('Open') : obj.title;
    this.type = obj.list_type || obj.listType;

    const typeInfo = this.getTypeInfo(this.type);
    this.preset = Boolean(typeInfo.isPreset);
    this.isExpandable = Boolean(typeInfo.isExpandable);
    this.isExpanded = !obj.collapsed;
    this.page = 1;
    this.loading = true;
    this.loadingMore = false;
    this.issues = obj.issues || [];
    this.issuesSize = obj.issuesSize ? obj.issuesSize : 0;
    this.maxIssueCount = obj.maxIssueCount || obj.max_issue_count || 0;

    if (obj.label) {
      this.label = new ListLabel(obj.label);
    } else if (obj.user || obj.assignee) {
      this.assignee = new ListAssignee(obj.user || obj.assignee);
      this.title = this.assignee.name;
    } else if (IS_EE && obj.milestone) {
      this.milestone = new ListMilestone(obj.milestone);
      this.title = this.milestone.title;
    }

    if (!typeInfo.isBlank && this.id) {
      this.getIssues().catch(() => {
        // TODO: handle request error
      });
    }
  }

  guid() {
    const s4 = () =>
      Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
    return `${s4()}${s4()}-${s4()}-${s4()}-${s4()}-${s4()}${s4()}${s4()}`;
  }

  save() {
    return boardsStore.saveList(this);
  }

  destroy() {
    boardsStore.destroy(this);
  }

  update() {
    return boardsStore.updateListFunc(this);
  }

  nextPage() {
    return boardsStore.goToNextPage(this);
  }

  getIssues(emptyIssues = true) {
    return boardsStore.getListIssues(this, emptyIssues);
  }

  newIssue(issue) {
    return boardsStore.newListIssue(this, issue);
  }

  createIssues(data) {
    data.forEach(issueObj => {
      this.addIssue(new ListIssue(issueObj));
    });
  }

  addMultipleIssues(issues, listFrom, newIndex) {
    boardsStore.addMultipleListIssues(this, issues, listFrom, newIndex);
  }

  addIssue(issue, listFrom, newIndex) {
    boardsStore.addListIssue(this, issue, listFrom, newIndex);
  }

  moveIssue(issue, oldIndex, newIndex, moveBeforeId, moveAfterId) {
    boardsStore.moveListIssues(this, issue, oldIndex, newIndex, moveBeforeId, moveAfterId);
  }

  moveMultipleIssues({ issues, oldIndicies, newIndex, moveBeforeId, moveAfterId }) {
    oldIndicies.reverse().forEach(index => {
      this.issues.splice(index, 1);
    });
    this.issues.splice(newIndex, 0, ...issues);

    boardsStore
      .moveMultipleIssues({
        ids: issues.map(issue => issue.id),
        fromListId: null,
        toListId: null,
        moveBeforeId,
        moveAfterId,
      })
      .catch(() => flash(__('Something went wrong while moving issues.')));
  }

  updateIssueLabel(issue, listFrom, moveBeforeId, moveAfterId) {
    boardsStore.moveIssue(issue.id, listFrom.id, this.id, moveBeforeId, moveAfterId).catch(() => {
      // TODO: handle request error
    });
  }

  updateMultipleIssues(issues, listFrom, moveBeforeId, moveAfterId) {
    boardsStore
      .moveMultipleIssues({
        ids: issues.map(issue => issue.id),
        fromListId: listFrom.id,
        toListId: this.id,
        moveBeforeId,
        moveAfterId,
      })
      .catch(() => flash(__('Something went wrong while moving issues.')));
  }

  findIssue(id) {
    return boardsStore.findListIssue(this, id);
  }

  removeMultipleIssues(removeIssues) {
    return boardsStore.removeListMultipleIssues(this, removeIssues);
  }

  removeIssue(removeIssue) {
    return boardsStore.removeListIssues(this, removeIssue);
  }

  getTypeInfo(type) {
    return TYPES[type] || TYPES.default;
  }

  onNewIssueResponse(issue, data) {
    issue.refreshData(data);

    if (this.issuesSize > 1) {
      const moveBeforeId = this.issues[1].id;
      boardsStore.moveIssue(issue.id, null, null, null, moveBeforeId);
    }
  }
}

window.List = List;

export default List;
