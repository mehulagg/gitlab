describe('tabs', () => {
  describe('editor tab', () => {
    it('displays editor only after the tab is mounted', async () => {
      createComponent({ mountFn: mount });

      expect(findTabAt(0).find(TextEditor).exists()).toBe(false);

      await nextTick();

      expect(findTabAt(0).find(TextEditor).exists()).toBe(true);
    });
  });

  describe('visualization tab', () => {
    describe('with feature flag on', () => {
      beforeEach(() => {
        createComponent();
      });

      it('display the tab', () => {
        expect(findVisualizationTab().exists()).toBe(true);
      });

      it('displays a loading icon if the lint query is loading', () => {
        createComponent({ lintLoading: true });

        expect(findLoadingIcon().exists()).toBe(true);
        expect(findPipelineGraph().exists()).toBe(false);
      });
    });

    describe('with feature flag off', () => {
      beforeEach(() => {
        createComponent({
          provide: {
            ...mockProvide,
            glFeatures: { ciConfigVisualizationTab: false },
          },
        });
      });

      it('does not display the tab', () => {
        expect(findVisualizationTab().exists()).toBe(false);
      });
    });
  });
});

describe('when data is set', () => {
  beforeEach(async () => {
    createComponent({ mountFn: mount });

    wrapper.setData({
      content: mockCiYml,
      contentModel: mockCiYml,
    });

    await waitForPromises();
  });

  it('displays content after the query loads', () => {
    expect(findLoadingIcon().exists()).toBe(false);

    expect(findEditorLite().attributes('value')).toBe(mockCiYml);
    expect(findEditorLite().attributes('file-name')).toBe(mockCiConfigPath);
  });

  it('configures text editor', () => {
    expect(findTextEditor().props('commitSha')).toBe(mockCommitSha);
  });
});
