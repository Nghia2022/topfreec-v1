;(function($){
    $.fadePage = function(options){
        options = $.extend({
            coverWindowID: "fade-window",
            zindex: 999999999,
            wcolor: '#fff',
            speed: 800,
            easing: 'swing',
            pageLoadTrigger: 'PageLoadComplete',
            pageOutTrigger: 'PageOutComplete',
            pageBeforeLoadTrigger: 'PageLoadStart',
            onFadeInComplete: function(){},
            onFadeOutComplete: function(){}
        },options);
        var $window = $('#' + options.coverWindowID),
            fadein = function(done){
                $window.animate({
                    'opacity': 0
                }, options.speed,options.easing,  function () {
                    if (options.onFadeInComplete) {
                        options.onFadeInComplete();
                    }
                    $(window).trigger(options.pageLoadTrigger);
                });
                $(window).trigger(options.pageBeforeLoadTrigger);
            }, fadeout = function() {
                $window.animate({
                    'opacity': 1
                },options.speed,options.easing,function(){
                    if( options.onFadeOutComplete ) {
                        options.onFadeOutComplete();
                    }
                    $(window).trigger(options.pageOutTrigger);
                });
            }, init = function(){
                if( $window.length === 0 ){
                    $window = $('<div id="'+ options.coverWindowID +'" />');
                    $('body').prepend($window);
                }
                $window.css({
                    content: '',
                    position: 'fixed',
                    'top': 0,
                    left: 0,
                    width: '100%',
                    height: '100%',
                    'background-color': options.wcolor,
                    'z-index': options.zindex,
                    'pointer-events': 'none',
                    'opacity': 100
                });
            };
        init();
        $(window).on('beforeunload',function(){
            fadeout();
        });
        $(window).on('pageshow',function(event){
            if (event.persisted) {
                location.reload();
            } else {
                fadein();
            }
        });
    }

    $(function(){
        $.fadePage({
            speed: 1200
        });
    });
})(jQuery)