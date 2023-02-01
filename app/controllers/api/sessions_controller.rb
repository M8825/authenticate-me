class Api::SessionsController < ApplicationController
  def show
    if current_user
      @user = current_user
      render "api/users/show"
    else
      render :inter
    end
  end

  def create
    credential = params.require(:credential)
    password = params.require(:password)

    # debugger
    @user = User.find_by_credentials(credential, password)

    if @user
      login!(@user)
      render "api/users/show"
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def destroy
    if current_user
      logout!
      render json: { message: "success!" }
    else
      render json: { message: "failure!" }
    end
  end

  private

  # def user_params
  #   debugger
  #   # params.require(:user).permit(:credential, :password)
  # end
end
