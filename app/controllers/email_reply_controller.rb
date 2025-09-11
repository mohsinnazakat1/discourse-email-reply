class ::EmailReplyController < ::ApplicationController
  requires_login

  def generate_mailto
    post = Post.find(params[:post_id])
    guardian.ensure_can_see!(post)
    
    reply_data = post.email_reply_data
    
    # URL encode all components
    mailto_params = []
    
    if reply_data[:cc].any?
      mailto_params << "cc=#{CGI.escape(reply_data[:cc].join(','))}"
    end
    
    mailto_params << "subject=#{CGI.escape(reply_data[:subject])}"
    mailto_params << "body=#{CGI.escape(reply_data[:body])}"
    
    # Add email headers for threading
    mailto_params << "In-Reply-To=#{CGI.escape(reply_data[:in_reply_to])}"
    mailto_params << "References=#{CGI.escape(reply_data[:references])}"
    mailto_params << "Thread-Index=#{CGI.escape(reply_data[:thread_index])}"
    mailto_params << "Thread-Topic=#{CGI.escape(reply_data[:thread_topic])}"
    
    mailto_url = "mailto:#{reply_data[:to]}?#{mailto_params.join('&')}"
    
    render json: { mailto_url: mailto_url }
  end
end