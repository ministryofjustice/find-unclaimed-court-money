import { initAll } from "govuk-frontend";
import "./cookie_banner"

initAll();

document.querySelectorAll("[data-print]").forEach((el) => {
  el.addEventListener("click", (e) => {
    e.preventDefault();
    window.print();
  });
});
