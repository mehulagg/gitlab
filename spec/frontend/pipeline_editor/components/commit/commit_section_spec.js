describe('commit form', () => {
  const mockVariables = {
    content: mockCiYml,
    filePath: mockCiConfigPath,
    lastCommitId: mockCommitSha,
    message: mockCommitMessage,
    projectPath: mockProjectFullPath,
    startBranch: mockDefaultBranch,
  };

  const findInForm = (selector) => findCommitForm().find(selector);

  const submitCommit = async ({
    message = mockCommitMessage,
    branch = mockDefaultBranch,
    openMergeRequest = false,
  } = {}) => {
    await findInForm(GlFormTextarea).setValue(message);
    await findInForm(GlFormInput).setValue(branch);
    if (openMergeRequest) {
      await findInForm('[data-testid="new-mr-checkbox"]').setChecked(openMergeRequest);
    }
    await findInForm('[type="submit"]').trigger('click');
  };

  const cancelCommitForm = async () => {
    const findCancelBtn = () => wrapper.find('[type="reset"]');
    await findCancelBtn().trigger('click');
  };

  describe('when the user commits changes to the current branch', () => {
    beforeEach(async () => {
      await submitCommit();
    });

    it('calls the mutation with the default branch', () => {
      expect(mockMutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        variables: {
          ...mockVariables,
          branch: mockDefaultBranch,
        },
      });
    });

    it('displays an alert to indicate success', () => {
      expect(findAlert().text()).toMatchInterpolatedText(
        'Your changes have been successfully committed.',
      );
    });

    it('shows no saving state', () => {
      expect(findCommitBtnLoadingIcon().exists()).toBe(false);
    });

    it('a second commit submits the latest sha, keeping the form updated', async () => {
      await submitCommit();

      expect(mockMutate).toHaveBeenCalledTimes(2);
      expect(mockMutate).toHaveBeenLastCalledWith({
        mutation: expect.any(Object),
        variables: {
          ...mockVariables,
          lastCommitId: mockCommitNextSha,
          branch: mockDefaultBranch,
        },
      });
    });
  });

  describe('when the user commits changes to a new branch', () => {
    const newBranch = 'new-branch';

    beforeEach(async () => {
      await submitCommit({
        branch: newBranch,
      });
    });

    it('calls the mutation with the new branch', () => {
      expect(mockMutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        variables: {
          ...mockVariables,
          branch: newBranch,
        },
      });
    });
  });

  describe('when the user commits changes to open a new merge request', () => {
    const newBranch = 'new-branch';

    beforeEach(async () => {
      await submitCommit({
        branch: newBranch,
        openMergeRequest: true,
      });
    });

    it('redirects to the merge request page with source and target branches', () => {
      const branchesQuery = objectToQuery({
        'merge_request[source_branch]': newBranch,
        'merge_request[target_branch]': mockDefaultBranch,
      });

      expect(redirectTo).toHaveBeenCalledWith(`${mockNewMergeRequestPath}?${branchesQuery}`);
    });
  });

  describe('when the commit is ocurring', () => {
    it('shows a saving state', async () => {
      await mockMutate.mockImplementationOnce(() => {
        expect(findCommitBtnLoadingIcon().exists()).toBe(true);
        return Promise.resolve();
      });

      await submitCommit({
        message: mockCommitMessage,
        branch: mockDefaultBranch,
        openMergeRequest: false,
      });
    });
  });

  describe('when the commit fails', () => {
    it('shows an error message', async () => {
      mockMutate.mockRejectedValueOnce(new Error('commit failed'));

      await submitCommit();

      await waitForPromises();

      expect(findAlert().text()).toMatchInterpolatedText(
        'The GitLab CI configuration could not be updated. commit failed',
      );
    });

    it('shows an unkown error', async () => {
      mockMutate.mockRejectedValueOnce();

      await submitCommit();

      await waitForPromises();

      expect(findAlert().text()).toMatchInterpolatedText(
        'The GitLab CI configuration could not be updated.',
      );
    });
  });

  describe('when the commit form is cancelled', () => {
    const otherContent = 'other content';

    beforeEach(async () => {
      findTextEditor().vm.$emit('input', otherContent);
      await nextTick();
    });

    it('content is restored after cancel is called', async () => {
      await cancelCommitForm();

      expect(findEditorLite().attributes('value')).toBe(mockCiYml);
    });
  });
});
