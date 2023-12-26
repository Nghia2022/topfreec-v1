;(function($) {
    $(function() {
        $.fn.aiPageTop = function(options){
            options = $.extend({
                speed: 1000,
                easing: 'swing',
                fadeSpeed: 'normal',
                fadeEasing: 'swing',
                fadePosition: 100,  // スクロールボタンの表示する開始位置
                noscroll: '.no-scroll, .meanmenu-close',
                scrollMarginTop: function(){
                    return 0;
                },
                onScrollEnd: function(){}
            },options);
            var $this = $(this),buttonShow = null,
                fadeButton = function(){
                    if( $(window).scrollTop() > options.fadePosition ){
                        if( buttonShow !== true ){
                            fadeinButton();
                        }
                    } else if(buttonShow !== false ){
                            fadeoutButton();
                    }
                }
                fadeinButton = function(){
                    $this.fadeIn(options.speed, options.fadeEasing);
                    buttonShow = true;
                },
                fadeoutButton = function(){
                    $this.fadeOut(options.speed, options.fadeEasing);
                    buttonShow = false;
                }
                ,scrollY = function(hash){
                    var $target = $(hash === "#" || hash === "" || hash === "#top" || hash === undefined ? 'html' : hash);
                    if( $target.length === 0 ){
                        return true;
                    }
                    var pos = $target.offset().top - options.scrollMarginTop();
                    pos = pos > 0 ? pos : 0;
                    $('body,html').animate({scrollTop: pos}, options.speed, options.easing,function(){
                        if( options.onScrollEnd ){
                            options.onScrollEnd();
                        }
                    });
                    return false;
                };
            $(window).on('load',function(){
                var hash = location.hash;
                if( hash !== "" ) {
                    scrollY(hash);
                }
                fadeButton();
            });
            var fadeIn = undefined
            $(window).on('scroll',function(){
                fadeButton();
            });
            $('body').on('click','a[href^="#"]:not('+options.noscroll+'),area[href^="#"]:not('+options.noscroll+')',function(){
                return scrollY($(this).attr('href'));
            });
        }
        $('#back-top').aiPageTop({
            'speed': 1000,
            'fadeSpeed': 300,
            scrollMarginTop: function(){
                if( window.matchMedia("(min-width: 770px)").matches){
                    return $('header').outerHeight();
                } else {
                    return 0;
                }
//                return  window.matchMedia("min-width: 770px").matches ? $('header').height : 0;
            }
        });
    });
})(jQuery);