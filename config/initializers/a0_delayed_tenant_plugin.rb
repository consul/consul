class A0DelayedTenantPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    # save current tenant before enqueuing the job
    lifecycle.before :enqueue do |job|
      job.tenant = Apartment::Tenant.current
    end
    lifecycle.around :perform do |worker, job, *args, &block|
      # Switch to the saved tenant, ocurrs before deserializing this job
      Apartment::Tenant.switch(job.tenant) do
        # Add aditional context setup HERE, like security context for ex.
        block.call(worker, job, *args)
      end
    end
  end
end
