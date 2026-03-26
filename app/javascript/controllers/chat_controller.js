import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "fileInput", "filePreview", "form", "submit", "empty"]
  static values = { url: String }

  connect() {
    this.scrollToBottom()
    this.markAsRead()
    this.observeNewMessages()
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  observeNewMessages() {
    if (!this.hasMessagesTarget) return
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
      this.markAsRead()
      // Hide empty state when messages arrive
      if (this.hasEmptyTarget) this.emptyTarget.remove()
    })
    this.observer.observe(this.messagesTarget, { childList: true })
  }

  scrollToBottom() {
    if (!this.hasMessagesTarget) return
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  handleKeydown(e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      this.formTarget.requestSubmit()
    }
  }

  autoResize(e) {
    const el = e.target
    el.style.height = "auto"
    el.style.height = Math.min(el.scrollHeight, 120) + "px"
  }

  resetForm() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.style.height = "auto"
    }
    if (this.hasFileInputTarget) this.fileInputTarget.value = ""
    if (this.hasFilePreviewTarget) {
      this.filePreviewTarget.innerHTML = ""
      this.filePreviewTarget.classList.add("hidden")
    }
  }

  showFiles() {
    if (!this.hasFilePreviewTarget || !this.hasFileInputTarget) return
    const files = this.fileInputTarget.files
    if (files.length === 0) {
      this.filePreviewTarget.classList.add("hidden")
      return
    }

    this.filePreviewTarget.innerHTML = ""
    this.filePreviewTarget.classList.remove("hidden")

    Array.from(files).forEach(file => {
      const tag = document.createElement("div")
      tag.className = "flex items-center gap-2 text-xs text-gray-500 bg-gray-100 rounded-lg px-3 py-1.5 inline-flex mr-1"
      tag.innerHTML = `
        <svg class="w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"/>
        </svg>
        ${file.name}
      `
      this.filePreviewTarget.appendChild(tag)
    })
  }

  markAsRead() {
    if (!this.urlValue) return
    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
        "Accept": "application/json"
      }
    })
  }
}
