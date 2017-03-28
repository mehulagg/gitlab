import Vue from 'vue';
import eventHub from '../eventhub';

import IssueCardMultipleUsers from './issue_card_multiple_users';

(() => {
  const Store = gl.issueBoards.BoardsStore;

  window.gl = window.gl || {};
  window.gl.issueBoards = window.gl.issueBoards || {};

  gl.issueBoards.IssueCardInner = Vue.extend({
    props: {
      issue: {
        type: Object,
        required: true,
      },
      issueLinkBase: {
        type: String,
        required: true,
      },
      list: {
        type: Object,
        required: false,
      },
      rootPath: {
        type: String,
        required: true,
      },
      updateFilters: {
        type: Boolean,
        required: false,
        default: false,
      },
    },
    methods: {
      showLabel(label) {
        if (!this.list) return true;

        return !this.list.label || label.id !== this.list.label.id;
      },
      filterByLabel(label, e) {
        if (!this.updateFilters) return;

        const filterPath = gl.issueBoards.BoardsStore.filter.path.split('&');
        const labelTitle = encodeURIComponent(label.title);
        const param = `label_name[]=${labelTitle}`;
        const labelIndex = filterPath.indexOf(param);
        $(e.currentTarget).tooltip('hide');

        if (labelIndex === -1) {
          filterPath.push(param);
        } else {
          filterPath.splice(labelIndex, 1);
        }

        gl.issueBoards.BoardsStore.filter.path = filterPath.join('&');

        Store.updateFiltersUrl();

        eventHub.$emit('updateTokens');
      },
      labelStyle(label) {
        return {
          backgroundColor: label.color,
          color: label.textColor,
        };
      },
    },
    components: {
      'issue-card-multiple-users': IssueCardMultipleUsers,
    },
    template: `
      <div>
        <h4 class="card-title">
          <i
            class="fa fa-eye-slash confidential-icon"
            v-if="issue.confidential"></i>
          <a
            :href="issueLinkBase + '/' + issue.id"
            :title="issue.title">
            {{ issue.title }}
          </a>
        </h4>
        <div class="card-footer">
          <span
            class="card-number"
            v-if="issue.id">
            #{{ issue.id }}
          </span>
          <issue-card-multiple-users :issue="issue" :rootPath="rootPath" />
          <button
            class="label color-label has-tooltip js-no-trigger"
            v-for="label in issue.labels"
            type="button"
            v-if="showLabel(label)"
            @click="filterByLabel(label, $event)"
            :style="labelStyle(label)"
            :title="label.description"
            data-container="body">
            {{ label.title }}
          </button>
        </div>
      </div>
    `,
  });
})();
