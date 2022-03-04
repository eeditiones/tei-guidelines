window.addEventListener('WebComponentsReady', function() {
    const pbView = document.getElementById('reference');
    pbEvents.subscribe('pb-autocomplete-selected', 'ident', function(ev) {
        const page = document.querySelector('pb-page');
        if (pbView && !pbView.hasAttribute('static')) {
            pbEvents.emit('pb-refresh', 'transcription', {
                xpath: `//(elementSpec|classSpec|macroSpec|attSpec|dataSpec)[@ident='${ev.detail.value}']`
            });
            const url = new URL(window.location.href);
            url.pathname = `${page.appRoot}/ref/${ev.detail.value}`;
            history.pushState('guidelines-ref', null, url.toString());
        } else {
            window.location = `${page.appRoot}/ref/${ev.detail.value}`;
        }
    });
});