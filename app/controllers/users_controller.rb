class UsersController < ApplicationController
  def index
    @users = User.where(is_active: true).order(:status)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params) && @user.update(status: STAFF_STATUS_LIST[user_params[:status].to_sym])
      redirect_to action: "index"
    else
      redirect_to action: "edit"
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.update(status: STAFF_STATUS_LIST[user_params[:status].to_sym], is_active: true)
      redirect_to action: "index"
    else
      redirect_to action: "new"
    end
  end

  def shuffle
    if params[:group_num].present?
      join_member_ids = params.require(:user_id).select{|k,v| v == "1"}.keys.map(&:to_i)
      join_members = User.where(id: join_member_ids).order(:status)

      full_time = join_members.where(status: STAFF_STATUS_LIST[:full_time])
      japanese = join_members.where(status: STAFF_STATUS_LIST[:japanese])
      foreigners = join_members.where(status: STAFF_STATUS_LIST[:foreigners])

      shuffled_members = full_time.shuffle.concat(japanese.shuffle).concat(foreigners.shuffle)

      group_num = params[:group_num].to_i
      counter = 1
      @shuffled_members_with_group = []

      shuffled_members.each do |member|
        @shuffled_members_with_group << {
          first_name: member.first_name,
          group_num: counter,
          status: STAFF_STATUS_LIST.key(member.status)
        }
        counter == group_num ? counter = 1 : counter += 1
      end

      query_string = {
        attendees: @shuffled_members_with_group.map{|m| m[:first_name]},
        team_list: @shuffled_members_with_group.map{|m| m[:group_num]}
      }.to_query

      @link_for_slack = "/users/share_attendees".concat("?").concat(query_string)
    else
      redirect_to action: "index"
    end
  end

  def share_attendees
    SlackNotification.notify_attendees(params[:attendees], params[:team_list])
    redirect_to action: "index"
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :status, :is_active)
  end
end
