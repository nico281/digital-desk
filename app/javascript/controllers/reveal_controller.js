import { Controller } from "@hotwired/stimulus"

// Track Turbo navigations — on Turbo visits the view transition
// already animates the page, so we skip reveal and show immediately.
let isTurboNavigation = false
document.addEventListener("turbo:visit", () => { isTurboNavigation = true })

// Before Turbo caches, finalize all reveals so cached preview shows visible content
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll('[data-reveal-target="item"]').forEach((el) => {
    el.classList.remove("reveal-animating")
    el.classList.add("reveal-done")
  })
})

export default class extends Controller {
  static targets = ["item"]

  connect() {
    if (isTurboNavigation) {
      // Turbo visit — show everything immediately, view transition handles animation
      this.itemTargets.forEach((el) => el.classList.add("reveal-done"))
      return
    }

    // Initial page load — animate reveals on scroll/viewport
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const el = entry.target
            const delay = parseInt(el.dataset.revealDelay || 0, 10)
            setTimeout(() => {
              el.classList.add("reveal-animating")
              el.addEventListener("transitionend", () => {
                el.classList.remove("reveal-animating")
                el.classList.add("reveal-done")
              }, { once: true })
            }, delay)
            this.observer.unobserve(el)
          }
        })
      },
      { threshold: 0.1, rootMargin: "0px 0px -40px 0px" }
    )

    this.itemTargets.forEach((el) => {
      if (!el.classList.contains("reveal-done")) {
        this.observer.observe(el)
      }
    })
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
