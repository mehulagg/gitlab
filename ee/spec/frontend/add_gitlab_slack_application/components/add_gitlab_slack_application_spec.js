import Vue from 'vue';
import addGitlabSlackApplication from 'ee/add_gitlab_slack_application/components/add_gitlab_slack_application.vue';
import GitlabSlackService from 'ee/add_gitlab_slack_application/services/gitlab_slack_service';
import mountComponent from 'helpers/vue_mount_component_helper';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility');

describe('AddGitlabSlackApplication', () => {
  const redirectLink = '//redirectLink';
  const gitlabForSlackGifPath = '//gitlabForSlackGifPath';
  const signInPath = '//signInPath';
  const slackLinkPath = '//slackLinkPath';
  const docsPath = '//docsPath';
  const gitlabLogoPath = '//gitlabLogoPath';
  const slackLogoPath = '//slackLogoPath';
  const projects = [
    {
      id: 4,
      name: 'test',
    },
    {
      id: 6,
      name: 'nope',
    },
  ];
  const DEFAULT_PROPS = {
    projects,
    gitlabForSlackGifPath,
    signInPath,
    slackLinkPath,
    docsPath,
    gitlabLogoPath,
    slackLogoPath,
    isSignedIn: false,
  };

  const AddGitlabSlackApplication = Vue.extend(addGitlabSlackApplication);

  it('opens popup when button is clicked', () => {
    const vm = mountComponent(AddGitlabSlackApplication, DEFAULT_PROPS);

    vm.$el.querySelector('.js-popup-button').click();

    return vm.$nextTick().then(() => {
      expect(vm.$el.querySelector('.js-popup')).toBeDefined();
    });
  });

  it('hides popup when button is clicked', () => {
    const vm = mountComponent(AddGitlabSlackApplication, DEFAULT_PROPS);

    vm.popupOpen = true;

    return vm
      .$nextTick()
      .then(() => vm.$el.querySelector('.js-popup-button').click())
      .then(vm.$nextTick)
      .then(() => {
        expect(vm.$el.querySelector('.js-popup')).toBeNull();
      });
  });

  it('popup has a project select when signed in', () => {
    const vm = mountComponent(AddGitlabSlackApplication, {
      ...DEFAULT_PROPS,
      isSignedIn: true,
    });

    vm.popupOpen = true;

    return vm.$nextTick().then(() => {
      expect(vm.$el.querySelector('.js-project-select')).toBeDefined();
    });
  });

  it('popup has a message when there is no projects', () => {
    const vm = mountComponent(AddGitlabSlackApplication, {
      ...DEFAULT_PROPS,
      projects: [],
      isSignedIn: true,
    });

    vm.popupOpen = true;

    return vm.$nextTick().then(() => {
      expect(vm.$el.querySelector('.js-no-projects').textContent).toMatch(
        "You don't have any projects available.",
      );
    });
  });

  it('popup has a sign in link when logged out', () => {
    const vm = mountComponent(AddGitlabSlackApplication, {
      ...DEFAULT_PROPS,
    });

    vm.popupOpen = true;
    vm.selectedProjectId = 4;

    return vm.$nextTick().then(() => {
      expect(vm.$el.querySelector('.js-gitlab-slack-sign-in-link').href).toMatch(
        new RegExp(signInPath, 'i'),
      );
    });
  });

  it('redirects user to external link when submitted', () => {
    const vm = mountComponent(AddGitlabSlackApplication, {
      ...DEFAULT_PROPS,
      isSignedIn: true,
    });
    const addToSlackPromise = Promise.resolve({ data: { add_to_slack_link: redirectLink } });

    jest.spyOn(GitlabSlackService, 'addToSlack').mockReturnValue(addToSlackPromise);

    vm.popupOpen = true;

    return vm
      .$nextTick()
      .then(() => vm.$el.querySelector('.js-add-button').click())
      .then(vm.$nextTick)
      .then(addToSlackPromise)
      .then(() => {
        expect(redirectTo).toHaveBeenCalledWith(redirectLink);
      });
  });
});
