/* eslint-disable @gitlab/require-i18n-strings */

import createFlash from '~/flash';
import { extractCurrentDiscussion, extractDesign } from './design_management_utils';
import {
  ADD_IMAGE_DIFF_NOTE_ERROR,
  UPDATE_IMAGE_DIFF_NOTE_ERROR,
  ADD_DISCUSSION_COMMENT_ERROR,
  designDeletionError,
} from './error_messages';

const deleteDesignsFromStore = (store, query, selectedDesigns) => {
  const data = store.readQuery(query);

  const changedDesigns = data.project.issue.designCollection.designs.nodes.filter(
    node => !selectedDesigns.includes(node.filename),
  );
  data.project.issue.designCollection.designs.nodes = [...changedDesigns];

  store.writeQuery({
    ...query,
    data,
  });
};

/**
 * Adds a new version of designs to store
 *
 * @param {Object} store
 * @param {Object} query
 * @param {Object} version
 */
const addNewVersionToStore = (store, query, version) => {
  if (!version) return;

  const data = store.readQuery(query);

  data.project.issue.designCollection.versions.nodes = [
    version,
    ...data.project.issue.designCollection.versions.nodes,
  ];

  store.writeQuery({
    ...query,
    data,
  });
};

const addDiscussionCommentToStore = (store, createNote, query, queryVariables, discussionId) => {
  const data = store.readQuery({
    query,
    variables: queryVariables,
  });

  const design = extractDesign(data);
  const currentDiscussion = extractCurrentDiscussion(design.discussions, discussionId);
  currentDiscussion.notes.nodes = [...currentDiscussion.notes.nodes, createNote.note];

  design.notesCount += 1;
  if (
    !design.issue.participants.nodes.some(
      participant => participant.username === createNote.note.author.username,
    )
  ) {
    design.issue.participants.nodes = [
      ...design.issue.participants.nodes,
      {
        __typename: 'User',
        ...createNote.note.author,
      },
    ];
  }
  store.writeQuery({
    query,
    variables: queryVariables,
    data: {
      ...data,
      design: {
        ...design,
      },
    },
  });
};

const addImageDiffNoteToStore = (store, createImageDiffNote, query, variables) => {
  const data = store.readQuery({
    query,
    variables,
  });
  const newDiscussion = {
    __typename: 'Discussion',
    id: createImageDiffNote.note.discussion.id,
    replyId: createImageDiffNote.note.discussion.replyId,
    resolvable: true,
    resolved: false,
    resolvedAt: null,
    resolvedBy: null,
    notes: {
      __typename: 'NoteConnection',
      nodes: [createImageDiffNote.note],
    },
  };
  const design = extractDesign(data);
  const notesCount = design.notesCount + 1;
  design.discussions.nodes = [...design.discussions.nodes, newDiscussion];
  if (
    !design.issue.participants.nodes.some(
      participant => participant.username === createImageDiffNote.note.author.username,
    )
  ) {
    design.issue.participants.nodes = [
      ...design.issue.participants.nodes,
      {
        __typename: 'User',
        ...createImageDiffNote.note.author,
      },
    ];
  }
  store.writeQuery({
    query,
    variables,
    data: {
      ...data,
      design: {
        ...design,
        notesCount,
      },
    },
  });
};

const updateImageDiffNoteInStore = (store, updateImageDiffNote, query, variables) => {
  const data = store.readQuery({
    query,
    variables,
  });

  const design = extractDesign(data);
  const discussion = extractCurrentDiscussion(
    design.discussions,
    updateImageDiffNote.note.discussion.id,
  );

  discussion.notes = {
    ...discussion.notes,
    nodes: [updateImageDiffNote.note, ...discussion.notes.nodes.slice(1)],
  };

  store.writeQuery({
    query,
    variables,
    data: {
      ...data,
      design,
    },
  });
};

const addNewDesignToStore = (store, designManagementUpload, query) => {
  const data = store.readQuery(query);

  const newDesigns = data.project.issue.designCollection.designs.nodes.reduce((acc, design) => {
    if (!acc.find(d => d.filename === design.filename)) {
      acc.push(design);
    }

    return acc;
  }, designManagementUpload.designs);

  let newVersionNode;
  const findNewVersions = designManagementUpload.designs.find(design => design.versions);

  if (findNewVersions) {
    const findNewVersionsNodes = findNewVersions.versions.nodes;

    if (findNewVersionsNodes && findNewVersionsNodes.length) {
      newVersionNode = [findNewVersionsNodes[0]];
    }
  }

  const newVersions = [
    ...(newVersionNode || []),
    ...data.project.issue.designCollection.versions.nodes,
  ];

  const updatedDesigns = {
    __typename: 'DesignCollection',
    designs: {
      __typename: 'DesignConnection',
      nodes: newDesigns,
    },
    versions: {
      __typename: 'DesignVersionConnection',
      nodes: newVersions,
    },
  };

  data.project.issue.designCollection = updatedDesigns;

  store.writeQuery({
    ...query,
    data,
  });
};

const moveDesignInStore = (store, designManagementMove, query) => {
  const data = store.readQuery(query);
  data.project.issue.designCollection.designs = designManagementMove.designCollection.designs;
  store.writeQuery({
    ...query,
    data,
  });
};

const onError = (data, message) => {
  createFlash(message);
  throw new Error(data.errors);
};

export const hasErrors = ({ errors = [] }) => errors?.length;

/**
 * Updates a store after design deletion
 *
 * @param {Object} store
 * @param {Object} data
 * @param {Object} query
 * @param {Array} designs
 */
export const updateStoreAfterDesignsDelete = (store, data, query, designs) => {
  if (hasErrors(data)) {
    onError(data, designDeletionError({ singular: designs.length === 1 }));
  } else {
    deleteDesignsFromStore(store, query, designs);
    addNewVersionToStore(store, query, data.version);
  }
};

export const updateStoreAfterAddDiscussionComment = (
  store,
  data,
  query,
  queryVariables,
  discussionId,
) => {
  if (hasErrors(data)) {
    onError(data, ADD_DISCUSSION_COMMENT_ERROR);
  } else {
    addDiscussionCommentToStore(store, data, query, queryVariables, discussionId);
  }
};

export const updateStoreAfterAddImageDiffNote = (store, data, query, queryVariables) => {
  if (hasErrors(data)) {
    onError(data, ADD_IMAGE_DIFF_NOTE_ERROR);
  } else {
    addImageDiffNoteToStore(store, data, query, queryVariables);
  }
};

export const updateStoreAfterUpdateImageDiffNote = (store, data, query, queryVariables) => {
  if (hasErrors(data)) {
    onError(data, UPDATE_IMAGE_DIFF_NOTE_ERROR);
  } else {
    updateImageDiffNoteInStore(store, data, query, queryVariables);
  }
};

export const updateStoreAfterUploadDesign = (store, data, query) => {
  if (hasErrors(data)) {
    onError(data, data.errors[0]);
  } else {
    addNewDesignToStore(store, data, query);
  }
};

export const updateDesignsOnStoreAfterReorder = (store, data, query) => {
  if (hasErrors(data)) {
    createFlash(data.errors[0]);
  } else {
    moveDesignInStore(store, data, query);
  }
};
