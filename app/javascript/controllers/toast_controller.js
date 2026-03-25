import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 4000 } }

  connect() {
    requestAnimationFrame(() => this.element.classList.add("toast-visible"))
    this.timeout = setTimeout(() => this.dismiss(), this.durationValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.remove("toast-visible")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }
}
