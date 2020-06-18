require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  validate :postal_code_tenant
  validate :residence_tenant
  attr_writer :tenant

  def tenant
    @tenant ||= Tenant.current
  end

  def postal_code_tenant
    errors.add(:postal_code, I18n.t("verification.residence.new.error_not_allowed_postal_code")) unless valid_postal_code?
  end

  def residence_tenant
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_tenant, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def valid_postal_code?
      postal_code =~ /^#{tenant.postal_code}/
    end
end
