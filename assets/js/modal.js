export const showModal = contents => {
  const modal = document.querySelector(".modal");

  modal.querySelector('.modal-content').innerHTML = contents;
  modal.classList.add('show');
}

document.addEventListener('DOMContentLoaded', () => {
  const modal = document.querySelector(".modal");
  const closeButton = document.querySelector(".modal .close");

  closeButton.addEventListener('click', () => {
    modal.classList.remove('show');
  });
});
