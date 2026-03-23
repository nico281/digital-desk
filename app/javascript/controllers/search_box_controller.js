import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  submit(event) {
    if (event.key === "Enter") {
      event.target.closest("form").requestSubmit();
    }
  }
}
