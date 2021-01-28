const el = document.querySelector('#js-security-configuration');

if (el) {
    import('ee/security_configuration').then(({initSecurityConfiguration})=> 
        initSecurityConfiguration(el)
    ).catch(() => {});
} else {
    import('~/pages/projects/security/configuration')
    .catch(() => {});
}