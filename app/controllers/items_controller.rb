class ItemsController < ApplicationController
  skip_before_action :require_login, only: [:show, :index]
  respond_to :html, :js

  def index
    if params[:search]
      @items = Item.search(params[:search]).order("created_at DESC")
    else
      @items = Item.all.order("created_at DESC").includes(:user)
    end
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.new
  end

  def create
   @item = Item.new(item_params)
   @item.user_id = current_user.id

    if @item.save
      redirect_to profile_path(current_user.id)
    else
      render 'new'
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    @reservation = Reservation.find_by(item_id: @item.id)
    @renter = User.find_by(id: @reservation.renter_id)

    if @item.approved
      @item.update(approved: false)
      up_tokens = @item.user.tokens += 1
      @item.user.update(tokens: up_tokens)
      down_tokens = @renter.tokens -= 1
      @renter.update(tokens: down_tokens)

      @reservation.destroy
      redirect_to profile_path(current_user.id)
    else
      @item.update(approved: true)
      redirect_to profile_path(current_user.id)
    end
  end

  def destroy
    @item = Item.find(params[:id])
    if @item.reservations.destroy_all && @item.destroy
      redirect_to profile_path(current_user.id)
    else
      redirect_to profile_path(current_user.id)
    end
  end

  private
  def item_params
    params.require(:item).permit(:name, :description, :image)
  end

end
