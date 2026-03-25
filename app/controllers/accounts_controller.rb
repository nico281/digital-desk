class AccountsController < ApplicationController
  layout "dashboard"
  before_action :require_authentication!

  def show
  end

  def update
    if current_user.update(account_params)
      redirect_to account_path, notice: "Perfil actualizado"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:name, :avatar)
  end
end
