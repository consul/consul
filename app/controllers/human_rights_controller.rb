class HumanRightsController < ApplicationController
  skip_authorization_check

  include CommentableActions

  before_action :set_random_seed,             only: :index
  before_action :parse_search_terms,          only: :index
  before_action :parse_advanced_search_terms, only: :index
  before_action :set_search_order,            only: :index

  has_orders %w{random confidence_score},     only: :index
  has_orders %w{most_voted newest oldest},    only: :show

  def index
    load_human_right_proposals
    filter_by_search
    filter_by_subproceeding

    load_votes
    load_tags
    load_subproceedings

    paginate_results
    order_results
    render "proposals/index"
  end

  def show
    @proposal = Proposal.find(params[:id])
    set_resource_votes(@proposal)

    @notifications = []

    @commentable = @proposal
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)

    set_comment_flags(@comment_tree.comments)
    render "proposals/show"
  end

  private

  def load_human_right_proposals
    @proposals = @human_right_proposals = Proposal.where(proceeding: "Derechos Humanos")
  end

  def filter_by_search
    @proposals = @search_terms.present? ? @proposals.search(@search_terms) : @proposals
    @proposals = @advanced_search_terms.present? ? @proposals.filter(@advanced_search_terms) : @proposals
  end

  def filter_by_subproceeding
    @proposals = @proposals.where("sub_proceeding = ?", params[:sub_proceeding]) if params[:sub_proceeding].present?
  end

  def load_votes
    set_resource_votes(@proposals)
  end

  def load_tags
    @tag_cloud = tag_cloud
  end

  def load_subproceedings
    @subproceedings = @human_right_proposals.distinct.pluck(:sub_proceeding)
  end

  def paginate_results
    @proposals = @proposals.page(params[:page])
  end

  def order_results
    @proposals = @proposals.send("sort_by_#{@current_order}")
  end

  def set_random_seed
    if params[:order] == 'random' || params[:order].blank?
      session[:random_seed] ||= rand(99)/100.0
      Proposal.connection.execute "select setseed(#{session[:random_seed]})"
    else
      session[:random_seed] = nil
    end
  end

  def resource_name
    "proposal"
  end

  def resource_model
    Proposal
  end

end