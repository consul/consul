class Verification::ResidenceController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  skip_authorization_check

  def new
    @residence = Verification::Residence.new
  end

  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))
    @residence.tenant = Tenant.current
    if @residence.save
      redirect_to verified_user_path, notice: t("verification.residence.create.flash.success")
    else
      render :new
    end
  end

  private

    def residence_params
      params.require(:residence).permit(:document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service)
    end
end
