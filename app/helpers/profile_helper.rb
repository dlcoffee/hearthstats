module ProfileHelper
  def profile_owner?
    current_user && params[:id].to_i == current_user.id
  end

  def sig_pic_url
    if @profile.shortened_urls.blank?
      return
    end
    if Rails.env == "development"
    "http://#{request.host}/s/#{@profile.shortened_urls.first.unique_key}"
    else
      "http://hss.io/s/#{@profile.shortened_urls.first.unique_key}"
    end
  end
end
