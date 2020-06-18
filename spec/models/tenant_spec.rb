require "rails_helper"

describe Tenant do
  let(:tenant) { build(:tenant) }

  it "is valid" do
    expect(tenant).to be_valid
  end

  it "is not valid without a subdomain" do
    tenant.subdomain = nil
    expect(tenant).not_to be_valid
  end

  it "is not valid without a server name" do
    tenant.server_name = nil
    expect(tenant).not_to be_valid
  end

  it "is not valid with duplicated subdomain" do
    expect(create(:tenant, subdomain: "subdomainx")).to be_valid
    expect(build(:tenant, subdomain: "subdomainx")).not_to be_valid
  end
end
