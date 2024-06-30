import { fromHTML } from './html';

function setFlashError(text) {
  const span = fromHTML(`<span>${text}</span>`);
  const dismiss = fromHTML(
    `<a href="#" onclick="SimpleeFood.clearFlashError()">(dismiss)</a>`
  );

  const flash = document.getElementById('flash');
  flash.appendChild(span);
  flash.appendChild(dismiss);
}

function clearFlashError() {
  document.getElementById('flash').innerHTML = '';
}

export { clearFlashError, setFlashError };
