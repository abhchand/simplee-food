import { fromHTML } from './html';

function setFlashError(text, autoscroll = false) {
  const span = fromHTML(`<span>${text}</span>`);
  const dismiss = fromHTML(
    `(<a href="#" onclick="SimpleeFood.clearFlash()">dismiss</a>)`
  );

  const flash = document.getElementById('flash');
  flash.classList.add('flash--error');
  flash.appendChild(span);
  flash.appendChild(dismiss);

  if (autoscroll) {
    flash.scrollIntoView(true, { behavior: 'smooth' });
  }
}

function clearFlash() {
  const flash = document.getElementById('flash');

  flash.innerHTML = '';
  flash.classList.remove('flash--error');
}

export { clearFlash, setFlashError };
