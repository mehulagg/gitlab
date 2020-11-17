import initPipelineSecurityDashboard from 'ee/security_dashboard/pipeline_init';
import initPipelineDetails from '~/pipelines/pipeline_details_bundle';
import initPipelines from '~/pages/projects/pipelines/init_pipelines';
import initLicenseReport from './license_report';
import initCodequalityReport from './codequality_report';

initPipelines();
initPipelineDetails();
initPipelineSecurityDashboard();
initLicenseReport();
initCodequalityReport();
