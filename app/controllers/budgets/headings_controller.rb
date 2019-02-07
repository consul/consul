module Budgets
  class HeadingsController < ApplicationController

    skip_authorization_check :json_data

    def json_data
      heading =  Budget::Heading.find(params[:id])
      data = {
        heading_id: heading.id,
        heading_name: heading.name,
        budget_id: heading.budget.id
      }.to_json

      respond_to do |format|
        format.json { render json: data }
      end
    end

  end
end
