module TenantsHelper
  def change_subdomain?(tenant)
    tenant.subdomain != "public"
  end
end
