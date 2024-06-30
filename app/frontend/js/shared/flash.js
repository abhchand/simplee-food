import { fromHTML } from './html';

function setFlashError(text, autoscroll = false) {
  const span = fromHTML(`<span>${text}</span>`);
  const dismiss = fromHTML(
    `<a href="#" onclick="SimpleeFood.clearFlashError()">(dismiss)</a>`
  );

  const flash = document.getElementById('flash');
  flash.appendChild(span);
  flash.appendChild(dismiss);

  if (autoscroll) {
    flash.scrollIntoView(true, { behavior: 'smooth' });
  }
}

function clearFlashError() {
  document.getElementById('flash').innerHTML = '';
}

export { clearFlashError, setFlashError };
