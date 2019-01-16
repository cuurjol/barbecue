class EventMailer < ApplicationMailer
  def subscription(event, subscription)
    @email = subscription.user_email
    @name = subscription.user_name
    @event = event

    mail(to: event.user.email, subject: "Новая подписка на #{event.title}")
  end

  def comment(event, comment, email)
    @comment = comment
    @event = event

    mail(to: email, subject: "Новый комментарий @ #{event.title}")
  end

  def image(event, photo, email)
    if Rails.env.production?
      attachments.inline['image.jpg'] = File.read(photo.photo)
    else
      attachments.inline['image.jpg'] = File.read("#{Rails.root}/public#{photo.photo}")
    end

    @photo = photo
    @event = event

    mail(to: email, subject: "Новая фотография @ #{event.title}")
  end
end
