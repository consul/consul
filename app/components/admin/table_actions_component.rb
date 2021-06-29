class Admin::TableActionsComponent < ApplicationComponent
  include TableActionLink
  include Admin::Namespace
  attr_reader :record, :options

  def initialize(record = nil, **options)
    @record = record
    @options = options
  end

  private

    def actions
      options[:actions] || [:edit, :destroy]
    end

    def edit_text
      options[:edit_text] || t("admin.actions.edit")
    end

    def edit_path
      options[:edit_path] || namespaced_polymorphic_path(namespace, record, action: :edit)
    end

    def edit_options
      { class: "edit-link" }.merge(options[:edit_options] || {})
    end

    def destroy_text
      options[:destroy_text] || t("admin.actions.delete")
    end

    def destroy_path
      options[:destroy_path] || namespaced_polymorphic_path(namespace, record)
    end

    def destroy_options
      {
        method: :delete,
        class: "destroy-link",
        data: { confirm: destroy_confirmation }
      }.merge(options[:destroy_options] || {})
    end

    def destroy_confirmation
      options[:destroy_confirmation] || t("admin.actions.confirm_action", action: destroy_text)
    end
end
