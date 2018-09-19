class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include Translatable
  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  def index
    @pages = SiteCustomization::Page.order('slug').page(params[:page])
  end

  def create
    if @page.save
      notice = t('admin.site_customization.pages.create.notice')
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t('admin.site_customization.pages.create.error')
      render :new
    end
  end

  def update
    if @page.update(page_params)
      notice = t('admin.site_customization.pages.update.notice')
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t('admin.site_customization.pages.update.error')
      render :edit
    end
  end

  def destroy
    @page.destroy
    notice = t('admin.site_customization.pages.destroy.notice')
    redirect_to admin_site_customization_pages_path, notice: notice
  end
  
  def resource
    SiteCustomization::Page.find(params[:id])
  end

  private

    def page_params
      attributes = [:slug,
        :title,
        :subtitle,
        :content,
        :more_info_flag,
        :print_content_flag,
        :status,
        :locale]
      
      params.require(:site_customization_page).permit(*attributes, 
        *translation_params(SiteCustomization::Page)
      )
    end
end
