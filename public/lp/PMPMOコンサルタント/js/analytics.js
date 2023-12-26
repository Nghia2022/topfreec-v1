var UA = 'UA-XXXXXXXXX-X';
document.write('<script async src="https://www.googletagmanager.com/gtag/js?id="+UA></script>');
window.dataLayer = window.dataLayer || [];
function gtag(){
  dataLayer.push(arguments);
}
gtag('js', new Date());gtag('config', UA);
