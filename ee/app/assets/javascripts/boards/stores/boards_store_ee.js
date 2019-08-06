/* eslint-disable class-methods-use-this */
import _ from 'underscore';
import Cookies from 'js-cookie';
import { __, sprintf } from '~/locale';
import sidebarEventHub from '~/sidebar/event_hub';
import createFlash from '~/flash';
import { parseBoolean } from '~/lib/utils/common_utils';
import axios from '~/lib/utils/axios_utils';

class BoardsStoreEE {
  initEESpecific(boardsStore) {
    this.$boardApp = document.getElementById('board-app');
    this.store = boardsStore;
    this.store.addPromotionState = () => {
      this.addPromotion();
    };
    this.store.loadList = (listPath, listType) => this.loadList(listPath, listType);
    this.store.removePromotionState = () => {
      this.removePromotion();
    };

    const superSetCurrentBoard = this.store.setCurrentBoard.bind(this.store);
    this.store.setCurrentBoard = board => {
      superSetCurrentBoard(board);
      this.store.state.assignees = [];
      this.store.state.milestones = [];
    };

    const baseCreate = this.store.create.bind(this.store);
    this.store.create = () => {
      baseCreate();
      if (this.$boardApp) {
        const {
          dataset: {
            boardMilestoneId,
            boardMilestoneTitle,
            boardAssigneeUsername,
            labels,
            boardWeight,
            weightFeatureAvailable,
            scopedLabels,
            scopedLabelsDocumentationLink,
          },
        } = this.$boardApp;
        this.store.boardConfig = {
          milestoneId: parseInt(boardMilestoneId, 10),
          milestoneTitle: boardMilestoneTitle || '',
          assigneeUsername: boardAssigneeUsername,
          labels: JSON.parse(labels || []),
          weight: parseInt(boardWeight, 10),
        };
        this.store.cantEdit = [];
        this.store.weightFeatureAvailable = parseBoolean(weightFeatureAvailable);
        this.store.scopedLabels = {
          enabled: parseBoolean(scopedLabels),
          helpLink: scopedLabelsDocumentationLink,
        };
        this.initBoardFilters();
      }
    };

    this.store.updateFiltersUrl = (replaceState = false) => {
      if (!this.store.filter.path) {
        return;
      }
      if (replaceState) {
        window.history.replaceState(null, null, `?${this.store.filter.path}`);
      } else {
        window.history.pushState(null, null, `?${this.store.filter.path}`);
      }
    };

    sidebarEventHub.$on('updateWeight', this.updateWeight.bind(this));

    Object.assign(this.store, {
      updateWeight(endpoint, weight = null) {
        return axios.put(endpoint, {
          weight,
        });
      },
    });
  }

  initBoardFilters() {
    const updateFilterPath = (key, value) => {
      if (!value) return;
      const querystring = `${key}=${value}`;
      this.store.filter.path = [querystring]
        .concat(
          this.store.filter.path
            .split('&')
            .filter(param => param.match(new RegExp(`^${key}=(.*)$`, 'g')) === null),
        )
        .join('&');
    };

    let { milestoneTitle } = this.store.boardConfig;
    if (this.store.boardConfig.milestoneId === -1) {
      /* eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings */
      milestoneTitle = 'None';
    } else if (this.store.boardConfig.milestoneId === null) {
      /* eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings */
      milestoneTitle = 'Any';
    } else {
      milestoneTitle = encodeURIComponent(milestoneTitle);
    }
    if (milestoneTitle) {
      updateFilterPath('milestone_title', milestoneTitle);
      this.store.cantEdit.push('milestone');
    }

    let { weight } = this.store.boardConfig;
    if (weight !== -1) {
      if (weight === 0) {
        /* eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings */
        weight = 'No+Weight';
      }
      updateFilterPath('weight', weight);
    }
    updateFilterPath('assignee_username', this.store.boardConfig.assigneeUsername);
    if (this.store.boardConfig.assigneeUsername) {
      this.store.cantEdit.push('assignee');
    }

    const filterPath = this.store.filter.path.split('&');
    this.store.boardConfig.labels.forEach(label => {
      const labelTitle = encodeURIComponent(label.title);
      const param = `label_name[]=${labelTitle}`;
      const labelIndex = filterPath.indexOf(param);

      if (labelIndex === -1) {
        filterPath.push(param);
      }

      this.store.cantEdit.push({
        name: 'label',
        value: label.title,
      });
    });

    this.store.filter.path = filterPath.join('&');

    this.store.updateFiltersUrl(true);
  }

  addPromotion() {
    if (
      !this.$boardApp.hasAttribute('data-show-promotion') ||
      this.promotionIsHidden() ||
      this.store.disabled
    ) {
      return;
    }

    this.store.addList({
      id: 'promotion',
      list_type: 'promotion',
      title: __('Improve Issue boards'),
      position: 0,
    });

    this.store.state.lists = _.sortBy(this.store.state.lists, 'position');
  }

  removePromotion() {
    this.store.removeList('promotion', 'promotion');

    Cookies.set('promotion_issue_board_hidden', 'true', {
      expires: 365 * 10,
      path: '',
    });
  }

  promotionIsHidden() {
    return parseBoolean(Cookies.get('promotion_issue_board_hidden'));
  }

  updateWeight(newWeight, id) {
    const { issue } = this.store.detail;
    if (issue.id === id && issue.sidebarInfoEndpoint) {
      issue.setLoadingState('weight', true);
      this.store
        .updateWeight(issue.sidebarInfoEndpoint, newWeight)
        .then(res => res.data)
        .then(data => {
          const lists = issue.getLists();
          const oldWeight = issue.weight;
          const weightDiff = newWeight - oldWeight;

          issue.setLoadingState('weight', false);
          issue.updateData({
            weight: data.weight,
          });
          lists.forEach(list => {
            list.addWeight(weightDiff);
          });
        })
        .catch(() => {
          issue.setLoadingState('weight', false);
          createFlash(__('An error occurred when updating the issue weight'));
        });
    }
  }

  loadList(listPath, listType) {
    if (this.store.state[listType].length) {
      return Promise.resolve();
    }

    return axios
      .get(listPath)
      .then(({ data }) => {
        this.store.state[listType] = data;
      })
      .catch(() => {
        createFlash(
          sprintf(__('Something went wrong while fetching %{listType} list'), {
            listType,
          }),
        );
      });
  }
}

export default new BoardsStoreEE();
