import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "blockIdInput", "summary"]

  select(event) {
    const btn = event.currentTarget
    const blockId = btn.dataset.slotPickerBlockIdParam
    const label = btn.dataset.slotPickerLabelParam

    // Destacar seleccionado
    this.element.querySelectorAll("[data-action='slot-picker#select']").forEach(b => {
      b.classList.remove("border-gray-900", "bg-gray-900", "text-white")
      b.classList.add("border-gray-200", "text-gray-700")
    })
    btn.classList.remove("border-gray-200", "text-gray-700")
    btn.classList.add("border-gray-900", "bg-gray-900", "text-white")

    // Llenar form
    this.blockIdInputTarget.value = blockId
    this.summaryTarget.textContent = label

    this.formTarget.classList.remove("hidden")
  }

  close() {
    this.element.closest("turbo-frame").innerHTML = ""
  }
}
