import AjaxLoadingSpinner from '~/branches/ajax_loading_spinner';
import BranchSortDropdown from '~/branches/branch_sort_dropdown';
import DeleteModal from '~/branches/branches_delete_modal';
import initDiverganceGraph from '~/branches/divergence_graph';

AjaxLoadingSpinner.init();
new DeleteModal(); // eslint-disable-line no-new
initDiverganceGraph(document.querySelector('.js-branch-list').dataset.divergingCountsEndpoint);
BranchSortDropdown();
