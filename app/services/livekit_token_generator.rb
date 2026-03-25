require "livekit"

class LivekitTokenGenerator
  def self.generate(room_name:, participant_name:, participant_identity:)
    token = LiveKit::AccessToken.new(
      api_key: ENV.fetch("LIVEKIT_API_KEY"),
      api_secret: ENV.fetch("LIVEKIT_API_SECRET"),
      identity: participant_identity,
      name: participant_name
    )
    token.video_grant = LiveKit::VideoGrant.new(
      roomJoin: true,
      room: room_name,
      canPublish: true,
      canSubscribe: true
    )
    token.to_jwt
  end
end
