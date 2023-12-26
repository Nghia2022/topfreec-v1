//アコーディオン
$('.case-accordion').on('click', function() { //タイトル要素をクリックしたら
    var findElm = $(this).prev(".box"); //直後のアコーディオンを行うエリアを取得し
    $(findElm).slideToggle(); //アコーディオンの上下動作

    if($(this).hasClass('close')){ //タイトル要素にクラス名closeがあれば
        $(this).removeClass('close'); //クラス名を除去し
    }else{//それ以外は
        $(this).addClass('close'); //クラス名closeを付与
    }
});


//ページ内リンク
$('a[href*="#"]').click(function () {//全てのページ内リンクに適用させたい場合はa[href*="#"]のみでもOK
	var elmHash = $(this).attr('href'); //ページ内リンクのHTMLタグhrefから、リンクされているエリアidの値を取得
	var pos = $(elmHash).offset().top-70;//idの上部の距離からHeaderの高さを引いた値を取得
	$('body,html').animate({scrollTop: pos}, 500); //取得した位置にスクロール。500の数値が大きくなるほどゆっくりスクロール
	return false;
});


// 動きのきっかけとなるアニメーションの名前を定義
function fadeAnime(){
    $('.fadeUpTrigger').each(function(){ //fadeInUpTrigger というクラス名が
        var elemPos = $(this).offset().top-50;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('fadeUp');
        }
    });
    $('.fadeDownTrigger').each(function(){ //fadeInDownTrigger というクラス名が
    var elemPos = $(this).offset().top;
    var scroll = $(window).scrollTop();
    var windowHeight = $(window).height();
    if (scroll >= elemPos - windowHeight){
        $(this).addClass('fadeDown');
    }
    });
    $('.fadeInTrigger').each(function(){ //fadeInTrigger というクラス名が
        var elemPos = $(this).offset().top;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('fadeIn');
        }
    });
    $('.fadeLeftTrigger').each(function(){ //fadeLeftTrigger というクラス名が
        var elemPos = $(this).offset().top;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('fadeLeft');
        }
    });
    $('.fadeRightTrigger').each(function(){ //fadeRightTrigger というクラス名が
        var elemPos = $(this).offset().top;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('fadeRight');
        }
    });
    $('.bgextendTrigger').each(function(){ //bgextendTrigger というクラス名が
        var elemPos = $(this).offset().top+120;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('bgextend');
        }
    });
    $('.bgLRextendTrigger').each(function(){ //bgLRextendTrigger というクラス名が
        var elemPos = $(this).offset().top+120;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('bgLRextend');
        }
    });
    $('.bgappearTrigger').each(function(){ //bgappearTrigger というクラス名が
        var elemPos = $(this).offset().top+120;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('bgappear');
        }
    });
    $('.zoomOutTrigger').each(function(){ //zoomOutTrigger というクラス名が
        var elemPos = $(this).offset().top;
        var scroll = $(window).scrollTop();
        var windowHeight = $(window).height();
        if (scroll >= elemPos - windowHeight){
            $(this).addClass('zoomOut');
        }
    });
}
// 画面をスクロールをしたら動かしたい場合の記述
$(window).scroll(function (){
    fadeAnime();/* アニメーション用の関数を呼ぶ*/
});// ここまで画面をスクロールをしたら動かしたい場合の記述
// 画面が読み込まれたらすぐに動かしたい場合の記述
$(window).on('load', function(){
    fadeAnime();/* アニメーション用の関数を呼ぶ*/
});// ここまで画面が読み込まれたらすぐに動かしたい場合の記述


//スクロールした際の動きを関数でまとめる
function setFadeElement(){
	var windowH = $(window).height();	//ウィンドウの高さを取得
	var scroll = $(window).scrollTop(); //スクロール値を取得
    
    //出現範囲の指定
	var contentsTop = Math.round($('#display-area').offset().top+400);	//要素までの高さを四捨五入した値で取得
	var contentsH = $('#display-area').outerHeight(true);	//要素の高さを取得
    
    //2つ目の出現範囲の指定※任意
	//var contentsTop2 = Math.round($('#area-5').offset().top);	//要素までの高さを取得
	//var contentsH2 = $('#area-5').outerHeight(true);//要素の高さを取得

    //スマホ会員登録ボタンが出現範囲内に入ったかどうかをチェック
	if(scroll+windowH >= contentsTop && scroll+windowH  <= contentsTop+contentsH){
        $(".display-block").addClass("UpMove"); //入っていたらUpMoveをクラス追加
        $(".display-block").removeClass("DownMove"); //DownMoveを削除
        $(".hide-btn").removeClass("hide-btn"); //hide-btnを削除 
    }//2つ目の出現範囲に入ったかどうかをチェック※任意
    // else if(scroll+windowH >= contentsTop2 && scroll+windowH <= contentsTop2+contentsH2){       
    //$(".display-block").addClass("UpMove");    //入っていたらUpMoveをクラス追加
    //$(".display-block").removeClass("DownMove");   //DownMoveを削除
	//}//それ以外は
    else{
        if(!$(".hide-btn").length){				//サイト表示時にDownMoveクラスを一瞬付与させないためのクラス付け。hide-btnがなければ下記の動作を行う
            $(".display-block").addClass("DownMove");  //DownMoveをクラス追加
            $(".display-block").removeClass("UpMove"); //UpMoveを削除	
		}
	}
    //ヘッダーが出現範囲内に入ったかどうかをチェック
	if(scroll+windowH >= contentsTop && scroll+windowH  <= contentsTop+contentsH){
        $(".display-block-h").addClass("UpMove2");
        $(".display-block-h").removeClass("DownMove2");
        $(".hide-btn").removeClass("hide-btn");
    }else{
        if(!$(".hide-btn").length){
            $(".display-block-h").addClass("DownMove2");
            $(".display-block-h").removeClass("UpMove2");
		}
	}
    //チャットbotが出現範囲内に入ったかどうかをチェック
	if(scroll+windowH >= contentsTop && scroll+windowH  <= contentsTop+contentsH){
        $(".wc-static-ctn").addClass("UpMove");
        $(".wc-static-ctn").removeClass("DownMove");
        $(".hide-btn").removeClass("hide-btn");
    }else{
        if(!$(".hide-btn").length){
            $(".wc-static-ctn").addClass("DownMove");
            $(".wc-static-ctn").removeClass("UpMove");
		}
	}
    //チャットbot（スマホ）が出現範囲内に入ったかどうかをチェック
	if(scroll+windowH >= contentsTop && scroll+windowH  <= contentsTop+contentsH){
        $(".wc-webchat-ctn").addClass("UpMove");
        $(".wc-webchat-ctn").removeClass("DownMove");
        $(".hide-btn").removeClass("hide-btn");
    }else{
        if(!$(".hide-btn").length){
            $(".wc-webchat-ctn").addClass("DownMove");
            $(".wc-webchat-ctn").removeClass("UpMove");
		}
	}
}
// 画面をスクロールをしたら動かしたい場合の記述
$(window).scroll(function () {
	setFadeElement();/* スクロールした際の動きの関数を呼ぶ*/
});
// ページが読み込まれたらすぐに動かしたい場合の記述
$(window).on('load', function () {
	setFadeElement();/* スクロールした際の動きの関数を呼ぶ*/
});