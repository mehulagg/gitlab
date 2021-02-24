import { GlFormCheckbox } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import JiraTriggerFields from '~/integrations/edit/components/jira_trigger_fields.vue';

describe('JiraTriggerFields', () => {
  let wrapper;

  const defaultProps = {
    initialTriggerCommit: false,
    initialTriggerMergeRequest: false,
    initialEnableComments: false,
    initialJiraIssueTransitionEnabled: false,
  };

  const createComponent = (props, isInheriting = false) => {
    wrapper = mount(JiraTriggerFields, {
      propsData: { ...defaultProps, ...props },
      computed: {
        isInheriting: () => isInheriting,
      },
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findCommentSettings = () => wrapper.find('[data-testid="comment-settings"]');
  const findCommentDetail = () => wrapper.find('[data-testid="comment-detail"]');
  const findCommentSettingsCheckbox = () => findCommentSettings().find(GlFormCheckbox);
  const findIssueTransitionToggle = () => wrapper.find('[data-testid="issue-transition-toggle"]');
  const findIssueTransitionToggleCheckbox = () =>
    findIssueTransitionToggle().find('input[type="checkbox"]');
  const findIssueTransitionMode = () => wrapper.find('[data-testid="issue-transition-mode"]');
  const findIssueTransitionModeRadios = () =>
    findIssueTransitionMode().findAll('input[type="radio"]');
  const findIssueTransitionIdsField = () =>
    wrapper.find('input[type="text"][name="service[jira_issue_transition_id]"]');

  describe('template', () => {
    describe('initialTriggerCommit and initialTriggerMergeRequest are false', () => {
      it('does not show trigger settings', () => {
        createComponent();

        expect(findCommentSettings().isVisible()).toBe(false);
        expect(findCommentDetail().isVisible()).toBe(false);
        expect(findIssueTransitionToggle().isVisible()).toBe(false);
        expect(findIssueTransitionMode().isVisible()).toBe(false);
      });
    });

    describe('initialTriggerCommit is true', () => {
      beforeEach(() => {
        createComponent({
          initialTriggerCommit: true,
        });
      });

      it('shows trigger settings', () => {
        expect(findCommentSettings().isVisible()).toBe(true);
        expect(findCommentDetail().isVisible()).toBe(false);
        expect(findIssueTransitionToggle().isVisible()).toBe(true);
        expect(findIssueTransitionMode().isVisible()).toBe(false);
      });

      // As per https://vuejs.org/v2/guide/forms.html#Checkbox-1,
      // browsers don't include unchecked boxes in form submissions.
      it('includes comment settings as false even if unchecked', () => {
        expect(
          findCommentSettings().find('input[name="service[comment_on_event_enabled]"]').exists(),
        ).toBe(true);
      });

      describe('on enable comments', () => {
        it('shows comment detail', () => {
          findCommentSettingsCheckbox().vm.$emit('input', true);

          return wrapper.vm.$nextTick().then(() => {
            expect(findCommentDetail().isVisible()).toBe(true);
          });
        });
      });
    });

    describe('initialTriggerMergeRequest is true', () => {
      it('shows trigger settings', () => {
        createComponent({
          initialTriggerMergeRequest: true,
        });

        expect(findCommentSettings().isVisible()).toBe(true);
        expect(findCommentDetail().isVisible()).toBe(false);
        expect(findIssueTransitionToggle().isVisible()).toBe(true);
        expect(findIssueTransitionMode().isVisible()).toBe(false);
        expect(findIssueTransitionToggleCheckbox().element.checked).toBe(false);
      });
    });

    describe('initialTriggerCommit is true, initialEnableComments is true', () => {
      it('shows comment settings and comment detail', () => {
        createComponent({
          initialTriggerCommit: true,
          initialEnableComments: true,
        });

        expect(findCommentSettings().isVisible()).toBe(true);
        expect(findCommentDetail().isVisible()).toBe(true);
      });
    });

    describe('initialTriggerCommit is true, initialJiraIssueTransitionEnabled is true', () => {
      it('shows transition settings', () => {
        createComponent({
          initialTriggerCommit: true,
          initialJiraIssueTransitionEnabled: true,
        });

        expect(findIssueTransitionToggle().isVisible()).toBe(true);
        expect(findIssueTransitionMode().isVisible()).toBe(true);
      });
    });

    describe('initialJiraIssueTransitionEnabled is true, initialJiraIssueTransitionId is blank', () => {
      it('uses automatic transitions', () => {
        createComponent({
          initialTriggerCommit: true,
          initialJiraIssueTransitionEnabled: true,
        });

        expect(findIssueTransitionToggleCheckbox().element.checked).toBe(true);

        const [radio1, radio2] = findIssueTransitionModeRadios().wrappers;
        expect(radio1.element.checked).toBe(true);
        expect(radio2.element.checked).toBe(false);

        expect(findIssueTransitionIdsField().exists()).toBe(false);
      });
    });

    describe('initialJiraIssueTransitionEnabled is true, initialJiraIssueTransitionId is set', () => {
      it('uses custom transitions', () => {
        createComponent({
          initialTriggerCommit: true,
          initialJiraIssueTransitionEnabled: true,
          initialJiraIssueTransitionId: '1, 2, 3',
        });

        expect(findIssueTransitionToggleCheckbox().element.checked).toBe(true);

        const [radio1, radio2] = findIssueTransitionModeRadios().wrappers;
        expect(radio1.element.checked).toBe(false);
        expect(radio2.element.checked).toBe(true);

        const field = findIssueTransitionIdsField();
        expect(field.isVisible()).toBe(true);
        expect(field.element).toMatchObject({
          type: 'text',
          value: '1, 2, 3',
        });
      });
    });

    it('disables input fields if inheriting', () => {
      createComponent(
        {
          initialTriggerCommit: true,
          initialEnableComments: true,
          initialJiraIssueTransitionEnabled: true,
        },
        true,
      );

      wrapper.findAll('[type=text], [type=checkbox], [type=radio]').wrappers.forEach((input) => {
        expect(input.attributes('disabled')).toBe('disabled');
      });
    });
  });
});
