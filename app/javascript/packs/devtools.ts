document.addEventListener('DOMContentLoaded', () => {
  const collapse = document.getElementsByClassName('devtools-collapse');
  Array.from(collapse).forEach(item => {
    const title = item.getElementsByClassName('-title')[0];
    title.addEventListener('click', () => {
      const list = item.getElementsByClassName('-list')[0];
      title.classList.toggle('open');
      list.classList.toggle('hide');
    })
  });
});
