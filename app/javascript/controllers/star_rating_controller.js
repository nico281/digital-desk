import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stars", "input"]

  rate(event) {
    const value = parseInt(event.params.value)
    this.inputTarget.value = value

    const buttons = this.starsTarget.querySelectorAll("button")
    buttons.forEach((btn, i) => {
      btn.classList.toggle("text-yellow-400", i < value)
      btn.classList.toggle("text-gray-300", i >= value)
    })
  }
}
