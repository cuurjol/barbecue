class PhotosController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :set_photo, only: [:destroy]

  # POST /photos
  def create
    @new_photo = @event.photos.build(photo_params)

    @new_photo.user = current_user

    if @new_photo.save
      notify_subscribers(@event, @new_photo)
      redirect_to(@event, notice: I18n.t('controllers.photos.created'))
    else
      # https://goo.gl/ake5rB - stackoverflow, last comment
      # https://goo.gl/Yjpy1Z - Adding flash message capability to your render calls in Rails
      render('events/show', alert: I18n.t('controllers.photos.error'))
    end
  end

  # DELETE /photos/1
  def destroy
    message = { notice: I18n.t('controllers.photos.destroyed') }

    if current_user_can_edit?(@photo)
      @photo.destroy
    else
      message = { alert: I18n.t('controllers.photos.error') }
    end

    redirect_to(@event, message)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_photo
    @photo = @event.photos.find(params[:id])
  end

  def photo_params
    params.fetch(:photo, {}).permit(:photo)
  end

  def notify_subscribers(event, photo)
    all_emails = (event.subscriptions.map(&:user_email) + [event.user.email] - [photo.user.email]).uniq

    all_emails.each do |mail|
      EventMailer.image(event, photo, mail).deliver_now
    end
  end
end
