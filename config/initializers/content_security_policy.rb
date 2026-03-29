# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, "https://*.gravatar.com", "https://*.cloudinary.com"
    policy.object_src  :none
    # unsafe_inline para Hotwire/Turbo (se mejorará con nonces en el futuro)
    policy.script_src  :self, :https, :unsafe_inline, :unsafe_eval
    # unsafe_inline para Tailwind (styles generados dinámicamente)
    policy.style_src   :self, :https, :unsafe_inline
    policy.connect_src :self, :https, "wss://*.livekit.cloud"
    policy.frame_src   :self
    policy.base_uri    :none
    policy.form_action :self
    policy.frame_ancestors :none
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Report violations without enforcing the policy.
  # Cambiar a false para enforce en producción
  config.content_security_policy_report_only = Rails.env.development?
end
