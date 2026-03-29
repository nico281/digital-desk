class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Indexes para evitar N+1 queries y mejorar performance

    # Professionals
    add_index :professionals, :rating_avg unless index_exists?(:professionals, :rating_avg)
    add_index :professionals, :created_at unless index_exists?(:professionals, :created_at)
    add_index :professionals, :verified unless index_exists?(:professionals, :verified)

    # Services
    add_index :services, :active unless index_exists?(:services, :active)
    add_index :services, :price unless index_exists?(:services, :price)
    add_index :services, :duration_minutes unless index_exists?(:services, :duration_minutes)

    # Bookings
    add_index :bookings, :status unless index_exists?(:bookings, :status)
    add_index :bookings, :created_at unless index_exists?(:bookings, :created_at)
    add_index :bookings, [ :client_id, :status ] unless index_exists?(:bookings, [ :client_id, :status ])
    add_index :bookings, [ :professional_id, :status ] unless index_exists?(:bookings, [ :professional_id, :status ])

    # Availability blocks
    add_index :availability_blocks, :status unless index_exists?(:availability_blocks, :status)
    add_index :availability_blocks, :date unless index_exists?(:availability_blocks, :date)
    add_index :availability_blocks, [ :status, :date ] unless index_exists?(:availability_blocks, [ :status, :date ])

    # Messages
    add_index :messages, :conversation_id unless index_exists?(:messages, :conversation_id)
    add_index :messages, :created_at unless index_exists?(:messages, :created_at)

    # Conversations
    add_index :conversations, :updated_at unless index_exists?(:conversations, :updated_at)
    add_index :conversations, :client_id unless index_exists?(:conversations, :client_id)

    # Reviews
    add_index :reviews, :created_at unless index_exists?(:reviews, :created_at)
    add_index :reviews, :rating unless index_exists?(:reviews, :rating)
    add_index :reviews, :professional_id unless index_exists?(:reviews, :professional_id)

    # Categories
    add_index :categories, :parent_id unless index_exists?(:categories, :parent_id)
    add_index :categories, :slug unless index_exists?(:categories, :slug)
  end
end
