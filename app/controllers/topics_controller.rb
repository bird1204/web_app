class TopicsController < ApplicationController
  def show
    @topic = Topic.new(id: params[:id])
    @gamaitems, @meta = @topic.gamaitems
  end
end
