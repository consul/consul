class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!

  skip_authorization_check
  before_action :verify_administrator
  before_action :set_current_tenant
  before_action :load_tenants

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user&.administrator?
    end

    def set_current_tenant
      session[:current_tenant] ||= Tenant.current
    end

    def load_tenants
      @tenants = Tenant.all.order("LOWER(name)")
    end
end
