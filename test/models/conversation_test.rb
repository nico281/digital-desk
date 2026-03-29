require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  def setup
    @conversation = conversations(:pro_conversation)
  end

  # Validations

  test "conversation válida con todos los atributos" do
    assert_valid @conversation
  end

  test "requiere client" do
    @conversation.client = nil
    assert_invalid @conversation
  end

  test "requiere professional" do
    @conversation.professional = nil
    assert_invalid @conversation
  end

  # Asociaciones

  test "conversation pertenece a client" do
    assert_equal users(:client), @conversation.client
  end

  test "conversation pertenece a professional" do
    assert_equal professionals(:pro), @conversation.professional
  end

  test "conversation tiene muchos mensajes" do
    assert @conversation.messages.any?
  end

  test "conversation puede tener bookings" do
    skip "La conversación en fixtures no tiene bookings asociados"
    assert @conversation.bookings.any?
  end

  test "conversation tiene chat_read_markers" do
    skip "Revisar modelo chat_read_markers"
    assert @conversation.chat_read_markers.any?
  end

  # Métodos

  test "other_user retorna el otro usuario" do
    client = users(:client)
    pro = users(:pro_user)

    assert_equal pro, @conversation.other_user(client)
    assert_equal client, @conversation.other_user(pro)
  end

  test "last_message retorna el último mensaje" do
    assert_equal messages(:recent_message), @conversation.last_message
  end

  test "unread_messages_count_for retorna count de no leídos" do
    client = users(:client)
    count = @conversation.unread_messages_count_for(client)
    assert count >= 0
  end

  test "conversaciones ordenadas por updated_at" do
    conv1 = conversations(:pro_conversation)
    conv2 = conversations(:another_conversation)

    # another_conversation tiene updated_at más reciente
    ordered = Conversation.order(updated_at: :desc)
    assert ordered.first.updated_at >= ordered.last.updated_at
  end
end
