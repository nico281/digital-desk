import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["priceLabel"];

  updatePrice(event) {
    const value = event.target.value;
    const label = this.element.querySelector('label');
    label.textContent = `Precio máximo: $${parseInt(value).toLocaleString()}`;
  }
}
