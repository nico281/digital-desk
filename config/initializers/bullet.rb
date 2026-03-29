return unless Rails.env.development?

Bullet.enable = true
Bullet.alert = true
Bullet.bullet_logger = true
Bullet.console = true
Bullet.rails_logger = true
