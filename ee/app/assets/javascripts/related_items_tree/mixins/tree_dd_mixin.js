import Draggable from 'vuedraggable';

import defaultSortableConfig from '~/sortable/sortable_config';
import { idProp, relativePositions } from '../constants';

export default {
  computed: {
    treeRootWrapper() {
      return this.userSignedIn ? Draggable : 'ul';
    },
    treeRootOptions() {
      const options = {
        ...defaultSortableConfig,
        fallbackOnBody: false,
        group: this.parentItem.reference,
        tag: 'ul',
        'ghost-class': 'tree-item-drag-active',
        'data-parent-reference': this.parentItem.reference,
        value: this.children,
      };

      return this.userSignedIn ? options : {};
    },
  },
  methods: {
    /**
     * This method returns ID property's value for a given
     * item by accessing it using correct property name.
     *
     * Here's the name of id property for item types;
     *    Type `Epic` ->  `id`
     *    Type `Issue` ->  `epicIssueId`
     *
     * @param {object} item
     */
    getItemId(item) {
      return item[idProp[item.type]];
    },
    /**
     * This method returns an object containing
     *
     *  - `id` Global ID of target item.
     *  - `adjacentReferenceId` Global ID of adjacent item that's
     *                          either above or below new position of target item.
     *  - `relativePosition` String representation of adjacent item with respect to
     *                       target item, which can be either `before` or `after`.
     *
     * @param {number} object.newIndex new position of target item
     * @param {object} object.targetItem target item object
     */
    getTreeReorderMutation({ newIndex, targetItem }) {
      let relativePosition;

      // adjacentReference is always the item that's at the position
      // where target was moved.
      const adjacentReferenceId = this.getItemId(this.children[newIndex]);

      if (newIndex === 0) {
        // If newIndex is `0`, item was moved to the top.
        // Adjacent reference will be the one which is currently at the top,
        // and it's relative position with respect to target's new position is `after`.
        relativePosition = relativePositions.After;
      } else if (newIndex === this.children.length - 1) {
        // If newIndex is last position in list, item was moved to the bottom.
        // Adjacent reference will be the one which is currently at the bottom,
        // and it's relative position with respect to target's new position is `before`.
        relativePosition = relativePositions.Before;
      } else {
        // If newIndex is neither top nor bottom, it was moved somewhere in the middle.
        // Adjacent reference will be the one which currently at that position,
        // and it's relative postion with respect to target's new position is `after`.
        relativePosition = relativePositions.After;
      }

      return {
        id: this.getItemId(targetItem),
        adjacentReferenceId,
        relativePosition,
      };
    },
    /**
     * This event handler is triggered the moment dragging
     * of item is started, and it sets `is-dragging` class
     * to page body.
     */
    handleDragOnStart() {
      document.body.classList.add('is-dragging');
    },
    /**
     * This event handler is fired when user releases the dragging
     * item.
     *
     * This method actually fires Vuex action `reorderItem`
     * that performs GraphQL mutation to update item order
     * within tree.
     *
     * @param {object} event Object representing drag end event.
     */
    handleDragOnEnd({ oldIndex, newIndex }) {
      document.body.classList.remove('is-dragging');

      // If both old and new index of target are same,
      // nothing was moved, we do an early return.
      if (oldIndex === newIndex) return;

      const targetItem = this.children[oldIndex];

      this.reorderItem({
        treeReorderMutation: this.getTreeReorderMutation({ newIndex, targetItem }),
        parentItem: this.parentItem,
        targetItem,
        oldIndex,
        newIndex,
      });
    },
  },
};
