
;(function($){
    var methods = {
        telephone: {
            rule: function(value, element) {
                console.log("telephone check");
                return this.optional(element) || /^\d{10,14}$/.test(value);
            },
            message: "電話番号を正しく入力してください。"
        },
        katakana: {
            rule: function(value,element){
                return this.optional(element) || /^[\u30A1-\u30FC][\u30A1-\u30FC|　| ]+[\u30A1-\u30FC]$/.test(value);
            },
            message: "全角カタカナで入力してください。"
        },
        postalcode: {
            rule: function(value,element){
                return this.optional(element) || /^\d{7}$/.test(value);
            },
            message: "郵便番号を正しく入力してください。"
        },
        checkSelect: {
            rule: function(value, element, origin) {
                return value.indexOf(origin) === -1;
            },
            message: "選択してください。"
        }
    };



    //メソッドの追加
    $.each(methods, function(key) {
        $.validator.addMethod(key, this.rule, this.message);
    });



    $.fn.customvalidate = function(options){
        var initval = {};
        $(this).find('select').each(function(){
            var $this = $(this),name=$this.attr('name'),val=$this.val();
            initval[name] = val;
        });
        options = $.extend({
            errorPlacement: function(err,elem){
                var $elem = $(elem),name=$elem.attr('name');
                if( err.length > 0 ) {
                    var $td = $elem.closest('td,dd'),$myError= $('p.error_'+name,$td);
                    if( $myError.length > 0 ){
                        $myError.text(err[0].innerText);
                        return;
                    }
                    
                    var $pErr= $('<p>').addClass('error error_'+name).text(err[0].innerText),
                        i = $('[name]',$td).index($elem);
                    if( i === 0 ){
                        $td.prepend($pErr);
                    } else {
                        $err = $('p.error',$td);
                        if( $err.length == 0 ){
                            $td.prepend($pErr);
                        } else {
                            $err.after($pErr);
                        }
                    }
                } else {
                    $td.find('p.error_'+name).remove();
                }
            },
            success: function(err,elem){
                var $td = $(elem).closest('td,dd');
                $td.find('p.error').remove();
            },
            onkeyup: function( element, event ) {

                // Avoid revalidate the field when pressing one of the following keys
                // Shift       => 16
                // Ctrl        => 17
                // Alt         => 18
                // Caps lock   => 20
                // End         => 35
                // Home        => 36
                // Left arrow  => 37
                // Up arrow    => 38
                // Right arrow => 39
                // Down arrow  => 40
                // Insert      => 45
                // Num lock    => 144
                // AltGr key   => 225
                var excludedKeys = [
                    16, 17, 18, 20, 35, 36, 37,
                    38, 39, 40, 45, 144, 225
                ];
                console.log("key up execute");
                if ( event.which === 9 && this.elementValue( element ) === "" || $.inArray( event.keyCode, excludedKeys ) !== -1 ) {
                    console.log("keyup no check");
                    return;
                } else   {
                    console.log("keyup exec check");
                    this.element( element );
                }
            },
            onfocusout: function( element ) {
                if ( !this.checkable( element )  ) {
                    this.element( element );
                }
            },
            onchange: function(element) {
                if( $(element).is('select') ){
                    var name = $(element).attr('name'),val = $(element).val();
                    if(name in initval && initval[name] !== val ){
                        this.element( element );
                    }
                    initval[name] = val;
                }
            },
            onclick: function( element ) {

                // Click on selects, radiobuttons and checkboxes
                if ( element.name in this.submitted ) {
                    this.element(element);
                } else if( $(element).is('select') ) {
                    var $elem = $(element),name = $elem.attr('name'),val=$elem.find(':selected').val();
                    if( initval[name] !== val ){
                        this.element(element);
                        initval[name] = val;
                    }
                    // Or option elements, check parent select in that case
                } else if ( element.parentNode.name in this.submitted ) {
                    this.element( element.parentNode );
                }
            }
        },options);

        $(this).validate(options);



    } ;

})(jQuery);
