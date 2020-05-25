import Api from '~/api';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';

import {
  DEFAULT_TARGET_BRANCH,
  SUBMIT_CHANGES_BRANCH_ERROR,
  SUBMIT_CHANGES_COMMIT_ERROR,
  SUBMIT_CHANGES_MERGE_REQUEST_ERROR,
  TRACKING_ACTION_CREATE_COMMIT,
} from '~/static_site_editor/constants';
import generateBranchName from '~/static_site_editor/services/generate_branch_name';
import submitContentChanges from '~/static_site_editor/services/submit_content_changes';

import {
  username,
  projectId,
  commitBranchResponse,
  commitMultipleResponse,
  createMergeRequestResponse,
  sourcePath,
  sourceContent as content,
  trackingCategory,
} from '../mock_data';

jest.mock('~/static_site_editor/services/generate_branch_name');

describe('submitContentChanges', () => {
  const mergeRequestTitle = `Update ${sourcePath} file`;
  const branch = 'branch-name';
  let trackingSpy;
  let origPage;

  beforeEach(() => {
    jest.spyOn(Api, 'createBranch').mockResolvedValue({ data: commitBranchResponse });
    jest.spyOn(Api, 'commitMultiple').mockResolvedValue({ data: commitMultipleResponse });
    jest
      .spyOn(Api, 'createProjectMergeRequest')
      .mockResolvedValue({ data: createMergeRequestResponse });

    generateBranchName.mockReturnValue(branch);

    origPage = document.body.dataset.page;
    document.body.dataset.page = trackingCategory;
    trackingSpy = mockTracking(document.body.dataset.page, undefined, jest.spyOn);
  });

  afterEach(() => {
    document.body.dataset.page = origPage;
    unmockTracking();
  });

  it('creates a branch named after the username and target branch', () => {
    return submitContentChanges({ username, projectId }).then(() => {
      expect(Api.createBranch).toHaveBeenCalledWith(projectId, {
        ref: DEFAULT_TARGET_BRANCH,
        branch,
      });
    });
  });

  it('notifies error when branch could not be created', () => {
    Api.createBranch.mockRejectedValueOnce();

    return expect(submitContentChanges({ username, projectId })).rejects.toThrow(
      SUBMIT_CHANGES_BRANCH_ERROR,
    );
  });

  it('commits the content changes to the branch when creating branch succeeds', () => {
    return submitContentChanges({ username, projectId, sourcePath, content }).then(() => {
      expect(Api.commitMultiple).toHaveBeenCalledWith(projectId, {
        branch,
        commit_message: mergeRequestTitle,
        actions: [
          {
            action: 'update',
            file_path: sourcePath,
            content,
          },
        ],
      });
    });
  });

  it('sends the correct tracking event when committing content changes', () => {
    return submitContentChanges({ username, projectId, sourcePath, content }).then(() => {
      expect(trackingSpy).toHaveBeenCalledWith(
        document.body.dataset.page,
        TRACKING_ACTION_CREATE_COMMIT,
      );
    });
  });

  it('notifies error when content could not be committed', () => {
    Api.commitMultiple.mockRejectedValueOnce();

    return expect(submitContentChanges({ username, projectId })).rejects.toThrow(
      SUBMIT_CHANGES_COMMIT_ERROR,
    );
  });

  it('creates a merge request when commiting changes succeeds', () => {
    return submitContentChanges({ username, projectId, sourcePath, content }).then(() => {
      expect(Api.createProjectMergeRequest).toHaveBeenCalledWith(
        projectId,
        convertObjectPropsToSnakeCase({
          title: mergeRequestTitle,
          targetBranch: DEFAULT_TARGET_BRANCH,
          sourceBranch: branch,
        }),
      );
    });
  });

  it('notifies error when merge request could not be created', () => {
    Api.createProjectMergeRequest.mockRejectedValueOnce();

    return expect(submitContentChanges({ username, projectId })).rejects.toThrow(
      SUBMIT_CHANGES_MERGE_REQUEST_ERROR,
    );
  });

  describe('when changes are submitted successfully', () => {
    let result;

    beforeEach(() => {
      return submitContentChanges({ username, projectId, sourcePath, content }).then(_result => {
        result = _result;
      });
    });

    it('returns the branch name', () => {
      expect(result).toMatchObject({ branch: { label: branch } });
    });

    it('returns commit short id and web url', () => {
      expect(result).toMatchObject({
        commit: {
          label: commitMultipleResponse.short_id,
          url: commitMultipleResponse.web_url,
        },
      });
    });

    it('returns merge request iid and web url', () => {
      expect(result).toMatchObject({
        mergeRequest: {
          label: createMergeRequestResponse.iid,
          url: createMergeRequestResponse.web_url,
        },
      });
    });
  });
});
