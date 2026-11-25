import './cookie_banner'
import { initAll } from 'govuk-frontend';

initAll()

document.querySelectorAll("[data-print]").forEach((el) => {
  el.addEventListener("click", (e) => {
    e.preventDefault();
    window.print();
  });
});
