class RoomController < ApplicationController
  # GET /room
  def index
    unless cookies[:username]
      redirect_to '/'
    end
  end

  def create
  end

  # POST /room/create
  def make
    name = params[:name]
    if Room.find_by(name: name)
      redirect_to '/'
    else
      @room = Room.create(name: name, number: 10, state: 1, videoId: "https://www.youtube.com/watch?v=-FlxM_0S2lA")
      redirect_to "/room/#{name}"
    end
  end

  # GET /room/join
  def join
    @rooms = Room.all
  end

  def show
    @room = Room.find_by(name: params[:id])
    if @room
      cookies[:room_name] = @room.name
    else
      redirect_to '/room'
    end
  end

  # DELETE /room/1
  def destroy
    # puts params
    @room = Room.find_by(name: params[:id])
    if @room.present?
      @room.destroy
    end
    redirect_to '/room/join'
  end

  def increment
    @room = Room.find_by(name: params[:id])
    @room.increment!(:number)
    ActionCable.server.broadcast "room_channel_#{@room.id}", content: @room.number
  end

  def change
    @room = Room.find(params[:id])
    video_url = params[:room][:videoId]
    @room.update_attribute(:videoId, video_url)
    ActionCable.server.broadcast "room_channel_#{@room.id}", videoId: video_url
  end

  def seek
    @room = Room.find_by(name: params[:id])
    seconds = params[:room][:seconds]
    puts seconds
    @room.update_attribute(:seconds, seconds)
    ActionCable.server.broadcast "room_channel_#{@room.id}", seconds: seconds
  end

  def forward
    puts "forward success"
    @room = Room.find_by(name: params[:id])
    @room.update_attribute(:state, 1)
    ActionCable.server.broadcast "room_channel_#{@room.id}", status: "change"
  end
  helper_method :forward
end
