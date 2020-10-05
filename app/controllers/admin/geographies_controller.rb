class Admin::GeographiesController < Admin::BaseController
  before_action :set_geography, only: [:show, :edit, :update, :destroy]
  before_action :set_headings, only: [:new, :edit, :update, :create]

  def index
    @geographies = Geography.all
  end

  def new
    @geography = Geography.new
  end

  def edit
  end

  def create
    @geography = Geography.new(geography_params)

    if @geography.save
      redirect_to admin_geographies_path, notice: t("admin.geographies.create.notice")
    else
      render :new
    end
  end

  def update
    if @geography.update(geography_params)
      redirect_to admin_geographies_path, notice: t("admin.geographies.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @geography.destroy!
    redirect_to admin_geographies_path, notice: t("admin.geographies.delete.notice")
  end

  private

    def set_geography
      @geography = Geography.find(params[:id])
    end

    def set_headings
      @headings = Budget::Heading.all
    end

    def geography_params
      params.require(:geography).permit(:name, :color, :geojson, heading_ids: [])
    end
end
