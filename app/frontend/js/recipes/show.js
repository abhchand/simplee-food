function onRecipeStepClick(event) {
  const el = event.currentTarget;

  if (el.classList.contains('selected')) {
    el.classList.remove('selected');
  } else {
    el.classList.add('selected');
  }
}

export { onRecipeStepClick };
