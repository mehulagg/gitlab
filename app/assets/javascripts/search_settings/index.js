import { debounce, uniq, isFunction, first } from 'lodash';
import { __ } from '~/locale';

const TYPING_DELAY = 500;
const TYPING_EVENT = 'keydown';
const HIDE_CLASS = 'gl-display-none';
const HIGHLIGHT_CLASS = 'gl-outline-dotted-2-gray-800';
const EXCLUDED_NODES = ['OPTION'];

const includeNode = node =>
  node.textContent.trim().length && !EXCLUDED_NODES.includes(node.parentElement.nodeName);

const buildIndex = root => {
  const textIndex = [];
  const nodes = [];
  const iterator = document.createNodeIterator(root, NodeFilter.SHOW_TEXT, {
    acceptNode(node) {
      return includeNode(node) ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT;
    },
  });
  let currentNode = iterator.nextNode();

  while (currentNode) {
    nodes.push(currentNode);
    textIndex.push(currentNode.textContent);

    currentNode = iterator.nextNode();
  }

  return { textIndex, nodes };
};

const search = (textIndex, nodes, term) => {
  const matches = textIndex.reduce((accum, item, index) => {
    return item.toLowerCase().includes(term.toLowerCase()) ? accum.concat([index]) : accum;
  }, []);

  return matches.map(match => nodes[match]);
};

const findSettingsSection = (sectionSelector, node) => {
  return node.parentElement.closest(sectionSelector);
};

const resetSections = ({ sectionSelector, expandSection, collapseSection }) => {
  document.querySelectorAll(sectionSelector).forEach((section, index) => {
    section.classList.remove(HIDE_CLASS);

    if (index === 0) {
      expandSection(section);
    } else {
      collapseSection(section);
    }
  });
};

const resetElements = () => {
  document
    .querySelectorAll(`.${HIGHLIGHT_CLASS}`)
    .forEach(element => element.classList.remove(HIGHLIGHT_CLASS));
};

const hideSectionsExcept = (sectionSelector, visibleSections) => {
  Array.from(document.querySelectorAll(sectionSelector))
    .filter(section => !visibleSections.includes(section))
    .forEach(section => {
      section.classList.add(HIDE_CLASS);
    });
};

const highlightElements = (elements = []) => {
  elements.forEach(element => element.classList.add(HIGHLIGHT_CLASS));
};

const displayResults = ({ sectionSelector, expandSection, collapseSection }, matches) => {
  const elements = matches.map(match => match.parentElement);
  const sections = uniq(elements.map(element => findSettingsSection(sectionSelector, element)));

  hideSectionsExcept(sectionSelector, sections);
  sections.forEach(expandSection);
  highlightElements(elements);
};

const resetState = params => {
  resetSections(params);
  resetElements();
};

const createSearchBoxEventListener = ({
  textIndex,
  nodes,
  searchBox,
  sectionSelector,
  expandSection,
  collapseSection,
}) => {
  return debounce(() => {
    const displayOptions = { sectionSelector, expandSection, collapseSection };

    resetState(displayOptions);

    if (searchBox.value.length) {
      displayResults(displayOptions, search(textIndex, nodes, searchBox.value));
    }
  }, TYPING_DELAY);
};

const initSearch = ({
  rootSelector,
  searchBoxSelector,
  sectionSelector,
  expandSection,
  collapseSection,
}) => {
  const rootNode = document.querySelector(rootSelector);
  const searchBox = document.querySelector(searchBoxSelector);

  if (!rootNode) {
    throw new Error(__('Could not find root node'));
  }

  if (!searchBox) {
    throw new Error(__('Could not find search box input'));
  }

  if (!isFunction(expandSection)) {
    throw new Error(__('Provide an expand section function'));
  }

  if (!isFunction(collapseSection)) {
    throw new Error(__('Provide a collapse section function'));
  }

  const { textIndex, nodes } = buildIndex(rootNode);

  searchBox.addEventListener(
    TYPING_EVENT,
    createSearchBoxEventListener({
      textIndex,
      nodes,
      searchBox,
      sectionSelector,
      expandSection,
      collapseSection,
    }),
  );
};

export default initSearch;
