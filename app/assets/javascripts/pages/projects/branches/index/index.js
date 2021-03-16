import AjaxLoadingSpinner from '~/branches/ajax_loading_spinner';
import initDeleteBranchButton from '~/branches/init_delete_branch_button';
import initDeleteBranchModal from '~/branches/init_delete_branch_modal';
import initDiverganceGraph from '~/branches/divergence_graph';

AjaxLoadingSpinner.init();
initDeleteBranchButton();
initDeleteBranchModal();
initDiverganceGraph(document.querySelector('.js-branch-list').dataset.divergingCountsEndpoint);
