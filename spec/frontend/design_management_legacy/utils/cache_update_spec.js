import { InMemoryCache } from 'apollo-cache-inmemory';
import {
  updateStoreAfterDesignsDelete,
  updateStoreAfterAddDiscussionComment,
  updateStoreAfterAddImageDiffNote,
  updateStoreAfterUploadDesign,
  updateStoreAfterUpdateImageDiffNote,
} from '~/design_management_legacy/utils/cache_update';
import {
  designDeletionError,
  ADD_DISCUSSION_COMMENT_ERROR,
  ADD_IMAGE_DIFF_NOTE_ERROR,
  UPDATE_IMAGE_DIFF_NOTE_ERROR,
} from '~/design_management_legacy/utils/error_messages';
import design from '../mock_data/design';
import { deprecatedCreateFlash as createFlash } from '~/flash';

jest.mock('~/flash.js');

describe('Design Management cache update', () => {
  const mockErrors = ['code red!'];

  let mockStore;

  beforeEach(() => {
    mockStore = new InMemoryCache();
  });

  describe('error handling', () => {
    it.each`
      fnName                                    | subject                                 | errorMessage                               | extraArgs
      ${'updateStoreAfterDesignsDelete'}        | ${updateStoreAfterDesignsDelete}        | ${designDeletionError({ singular: true })} | ${[[design]]}
      ${'updateStoreAfterAddDiscussionComment'} | ${updateStoreAfterAddDiscussionComment} | ${ADD_DISCUSSION_COMMENT_ERROR}            | ${[]}
      ${'updateStoreAfterAddImageDiffNote'}     | ${updateStoreAfterAddImageDiffNote}     | ${ADD_IMAGE_DIFF_NOTE_ERROR}               | ${[]}
      ${'updateStoreAfterUploadDesign'}         | ${updateStoreAfterUploadDesign}         | ${mockErrors[0]}                           | ${[]}
      ${'updateStoreAfterUpdateImageDiffNote'}  | ${updateStoreAfterUpdateImageDiffNote}  | ${UPDATE_IMAGE_DIFF_NOTE_ERROR}            | ${[]}
    `('$fnName handles errors in response', ({ subject, extraArgs, errorMessage }) => {
      expect(createFlash).not.toHaveBeenCalled();
      expect(() => subject(mockStore, { errors: mockErrors }, {}, ...extraArgs)).toThrow();
      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith(errorMessage);
    });
  });
});
