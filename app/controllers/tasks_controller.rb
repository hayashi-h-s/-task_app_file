class TasksController < ApplicationController
  before_action :login_required
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page]).per(3)
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def update
    task = Task.find(params[:id])
    if task.update(task_params)
      redirect_to tasks_url,notice: "タスク「#{task.name}」を更新しました。"
    else
      render :edit
    end


  end

  def create

    @task = Task.new(task_params.merge(user_id: current_user.id))

    if params[:back].present?
      #登録確認機能
      render :new
      return
    end

    if @task.save
      TaskMailer.creation_email(@task).deliver_now
      logger.debug "task: #{@task.attributes.inspect}"
      redirect_to root_path,notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_url,notice: "タスク「#{@task.name}」を削除しました。"
  end

  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :description, :image)
    # strong Parmeters
  end

end
