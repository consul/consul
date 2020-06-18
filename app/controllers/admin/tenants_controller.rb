class Admin::TenantsController < Admin::BaseController
  load_and_authorize_resource
  helper_method :main_tenant?

  def index
  end

  def new
  end

  def edit
  end

  def create
    @tenant = Tenant.new(tenant_params)

    if @tenant.save
      redirect_to admin_tenants_path, notice: t("admin.tenants.create.success")
    else
      render :new
    end
  end

  def update
    if @tenant.update(tenant_params)
      redirect_to admin_tenants_path, notice: t("admin.tenants.update.success")
    else
      render :edit
    end
  end

  def destroy
    @tenant.destroy!
    redirect_to admin_tenants_path, notice: t("admin.tenants.delete.success")
  end

  def switch
    session[:current_tenant] = Tenant.find_by(subdomain: params[:subdomain])
  end

  private

    def main_tenant?(tenant)
      tenant.subdomain == "public"
    end

    def tenant_params
      params.require(:tenant).permit(:name, :title, :subdomain, :postal_code,
        :endpoint_census, :institution_code_census, :portal_name_census, :user_code_census,
        :server_name, :twitter_key, :twitter_secret, :facebook_key, :facebook_secret)
    end
end
