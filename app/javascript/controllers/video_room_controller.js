import { Controller } from "@hotwired/stimulus"
import { Room, RoomEvent, Track } from "livekit-client"

export default class extends Controller {
  static targets = [
    "localVideo", "remoteVideo", "status",
    "remotePlaceholder", "placeholderText", "micBtn", "camBtn", "leaveBtn"
  ]
  static values = { tokenUrl: String, bookingUrl: String }

  async connect() {
    this.room = null
    this.connected = false
    this.hasCamera = false
    this.hasMic = false

    // Request permissions + detect devices
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: true })
      this.hasMic = true
      this.hasCamera = true
      stream.getTracks().forEach(t => t.stop())
    } catch {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
        this.hasMic = true
        stream.getTracks().forEach(t => t.stop())
      } catch { /* no mic */ }

      try {
        const devices = await navigator.mediaDevices.enumerateDevices()
        this.hasCamera = devices.some(d => d.kind === "videoinput" && d.deviceId)
      } catch { /* ignore */ }
    }

    this.renderControls()

    // Auto-connect
    await this.join()
  }

  disconnect() {
    if (this.room) this.room.disconnect()
  }

  async join() {
    this.updateStatus("Conectando...")

    try {
      const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
      const response = await fetch(this.tokenUrlValue, {
        method: "POST",
        headers: { "Accept": "application/json", "X-CSRF-Token": csrfToken }
      })

      if (!response.ok) {
        this.updateStatus("Error al obtener token")
        return
      }

      const data = await response.json()

      this.room = new Room({
        adaptiveStream: true,
        dynacast: true,
        videoCaptureDefaults: { resolution: { width: 640, height: 480 } }
      })

      this.room.on(RoomEvent.TrackSubscribed, this.handleTrackSubscribed.bind(this))
      this.room.on(RoomEvent.TrackUnsubscribed, this.handleTrackUnsubscribed.bind(this))
      this.room.on(RoomEvent.ParticipantDisconnected, this.handleParticipantDisconnected.bind(this))
      this.room.on(RoomEvent.Disconnected, this.handleDisconnected.bind(this))

      console.log("[LiveKit] Connecting to", data.url, "room:", this.room)
      await this.room.connect(data.url, data.token)
      console.log("[LiveKit] Connected. Remote participants:", this.room.remoteParticipants.size)

      // Publish tracks
      if (this.hasMic) await this.room.localParticipant.setMicrophoneEnabled(true)
      if (this.hasCamera) {
        await this.room.localParticipant.setCameraEnabled(true)
        const camPub = this.room.localParticipant.getTrackPublication(Track.Source.Camera)
        if (camPub?.track) camPub.track.attach(this.localVideoTarget)
      }

      this.connected = true
      this.renderControls()

      // Process participants already in the room
      this.room.remoteParticipants.forEach(participant => {
        participant.trackPublications.forEach(pub => {
          if (pub.track && pub.isSubscribed) {
            this.handleTrackSubscribed(pub.track, pub, participant)
          }
        })
      })

      if (this.room.remoteParticipants.size === 0) {
        this.updateStatus("Conectado — esperando al otro participante")
      }
    } catch (error) {
      console.error("Error connecting:", error)
      this.updateStatus("Error al conectar")
    }
  }

  leave() {
    if (this.room) this.room.disconnect()
    // Navigate handled by the link href
  }

  async toggleAudio() {
    if (!this.room || !this.hasMic) return
    const enabled = this.room.localParticipant.isMicrophoneEnabled
    await this.room.localParticipant.setMicrophoneEnabled(!enabled)
    this.renderControls()
  }

  async toggleVideo() {
    if (!this.room || !this.hasCamera) return
    const enabled = this.room.localParticipant.isCameraEnabled
    await this.room.localParticipant.setCameraEnabled(!enabled)

    if (!enabled) {
      const camPub = this.room.localParticipant.getTrackPublication(Track.Source.Camera)
      if (camPub?.track) camPub.track.attach(this.localVideoTarget)
    } else {
      this.localVideoTarget.srcObject = null
    }

    this.renderControls()
  }

  // -- Remote track handlers --

  handleTrackSubscribed(track, _publication, participant) {
    console.log("[LiveKit] Track subscribed:", track.kind, "from", participant.identity)
    if (track.kind === Track.Kind.Video) {
      track.attach(this.remoteVideoTarget)
      this.remoteVideoTarget.classList.remove("hidden")
      if (this.hasRemotePlaceholderTarget) {
        this.remotePlaceholderTarget.classList.add("hidden")
      }
    } else if (track.kind === Track.Kind.Audio) {
      const audioEl = document.createElement("audio")
      audioEl.id = `audio-${participant.identity}`
      this.element.appendChild(audioEl)
      track.attach(audioEl)
      // Update placeholder to show connected (no video)
      if (this.hasPlaceholderTextTarget) {
        this.placeholderTextTarget.textContent = "Conectado (sin cámara)"
      }
    }
    this.updateStatus("En llamada")
  }

  handleTrackUnsubscribed(track) {
    track.detach().forEach(el => {
      if (el.tagName === "AUDIO") el.remove()
    })
  }

  handleParticipantDisconnected(participant) {
    participant.trackPublications.forEach(pub => {
      if (pub.track) pub.track.detach().forEach(el => {
        if (el.tagName === "AUDIO") el.remove()
      })
    })
    this.remoteVideoTarget.classList.add("hidden")
    this.remoteVideoTarget.srcObject = null
    if (this.hasRemotePlaceholderTarget) {
      this.remotePlaceholderTarget.classList.remove("hidden")
    }
    this.updateStatus("El otro participante se desconectó")
  }

  handleDisconnected() {
    this.connected = false
    this.localVideoTarget.srcObject = null
    this.remoteVideoTarget.srcObject = null
    this.remoteVideoTarget.classList.add("hidden")
    if (this.hasRemotePlaceholderTarget) {
      this.remotePlaceholderTarget.classList.remove("hidden")
    }
    this.updateStatus("Desconectado")
    this.renderControls()
  }

  // -- UI --

  updateStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  renderControls() {
    // Mic
    if (this.hasMicBtnTarget) {
      const btn = this.micBtnTarget
      if (!this.hasMic) {
        btn.disabled = true
        btn.classList.add("opacity-30", "cursor-not-allowed")
        btn.classList.remove("cursor-pointer")
        btn.title = "Sin micrófono disponible"
      } else if (this.connected && !this.room.localParticipant.isMicrophoneEnabled) {
        this.setButtonMuted(btn, true)
        btn.title = "Activar micrófono"
      } else {
        this.setButtonMuted(btn, false)
        btn.title = "Silenciar micrófono"
      }
    }

    // Camera
    if (this.hasCamBtnTarget) {
      const btn = this.camBtnTarget
      if (!this.hasCamera) {
        btn.disabled = true
        btn.classList.add("opacity-30", "cursor-not-allowed")
        btn.classList.remove("cursor-pointer")
        btn.title = "Sin cámara disponible"
      } else if (this.connected && !this.room.localParticipant.isCameraEnabled) {
        this.setButtonMuted(btn, true)
        btn.title = "Encender cámara"
      } else {
        this.setButtonMuted(btn, false)
        btn.title = "Apagar cámara"
      }
    }
  }

  setButtonMuted(btn, muted) {
    if (muted) {
      btn.classList.add("bg-red-500/80")
      btn.classList.remove("bg-white/10", "hover:bg-white/20")
    } else {
      btn.classList.remove("bg-red-500/80")
      btn.classList.add("bg-white/10", "hover:bg-white/20")
    }
  }
}
