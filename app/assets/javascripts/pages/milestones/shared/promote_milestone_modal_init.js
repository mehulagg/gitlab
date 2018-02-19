import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import PromoteMilestoneModal from './components/promote_milestone_modal.vue';
import eventHub from './event_hub';

Vue.use(Translate);

const onRequestFinished = ({ milestoneUrl, successful }) => {
  const button = document.querySelector(`.js-promote-project-milestone[data-url="${milestoneUrl}"]`);

  if (!successful) {
    button.removeAttribute('disabled');
  }
};

const onRequestStarted = (milestoneUrl) => {
  const button = document.querySelector(`.js-promote-project-milestone[data-url="${milestoneUrl}"]`);
  button.setAttribute('disabled', '');
  eventHub.$once('promoteMilestoneModal.requestFinished', onRequestFinished);
};

const onDeleteButtonClick = (event) => {
  const button = event.currentTarget;
  const modalProps = {
    milestoneTitle: button.dataset.milestoneTitle,
    milestoneGroup: button.dataset.milestoneGroup,
    url: button.dataset.url,
  };
  eventHub.$once('promoteMilestoneModal.requestStarted', onRequestStarted);
  eventHub.$emit('promoteMilestoneModal.props', modalProps);
};

const promoteMilestoneButtons = document.querySelectorAll('.js-promote-project-milestone');
promoteMilestoneButtons.forEach((button) => {
  button.addEventListener('click', onDeleteButtonClick);
});

eventHub.$once('promoteMilestoneModal.mounted', () => {
  promoteMilestoneButtons.forEach((button) => {
    button.removeAttribute('disabled');
  });
});

export default () => {
  const promoteMilestoneComponent = new Vue({
    el: '#promote-milestone-modal',
    components: {
      PromoteMilestoneModal,
    },
    data() {
      return {
        modalProps: {
          milestoneTitle: '',
          milestoneGroup: '',
          url: '',
        },
      };
    },
    mounted() {
      eventHub.$on('promoteMilestoneModal.props', this.setModalProps);
      eventHub.$emit('promoteMilestoneModal.mounted');
    },
    beforeDestroy() {
      eventHub.$off('promoteMilestoneModal.props', this.setModalProps);
    },
    methods: {
      setModalProps(modalProps) {
        this.modalProps = modalProps;
      },
    },
    render(createElement) {
      return createElement('promote-milestone-modal', {
        props: this.modalProps,
      });
    },
  });

  const promoteMilestoneModal = document.getElementById('promote-milestone-modal');
  let withMilestone;
  if (promoteMilestoneModal != null) {
    withMilestone = promoteMilestoneComponent;
  }
  return withMilestone;
};
