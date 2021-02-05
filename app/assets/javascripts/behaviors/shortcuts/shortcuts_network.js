import Mousetrap from 'mousetrap';
import ShortcutsNavigation from './shortcuts_navigation';
import {
  keysFor,
  REPO_GRAPH_SCROLL_BOTTOM,
  REPO_GRAPH_SCROLL_DOWN,
  REPO_GRAPH_SCROLL_LEFT,
  REPO_GRAPH_SCROLL_RIGHT,
  REPO_GRAPH_SCROLL_TOP,
  REPO_GRAPH_SCROLL_UP,
} from './keybindings';

export default class ShortcutsNetwork extends ShortcutsNavigation {
  constructor(graph) {
    super();

    Mousetrap.bind(keysFor(REPO_GRAPH_SCROLL_LEFT), graph.scrollLeft);
    Mousetrap.bind(keysFor(REPO_GRAPH_SCROLL_RIGHT), graph.scrollRight);
    Mousetrap.bind(keysFor(REPO_GRAPH_SCROLL_UP), graph.scrollUp);
    Mousetrap.bind(keysFor(REPO_GRAPH_SCROLL_DOWN), graph.scrollDown);
    Mousetrap.bind(keysFor(REPO_GRAPH_SCROLL_TOP), graph.scrollTop);
    Mousetrap.bind(keysFor(REPO_GRAPH_SCROLL_BOTTOM), graph.scrollBottom);
  }
}
