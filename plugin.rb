# name: discourse-email-reply
# about: Lightweight email reply mechanism for Discourse posts
# version: 1.0.0
# authors: Your Name
# url: https://github.com/yourusername/discourse-email-reply
require 'yaml'


after_initialize do
  # Load additional files
  load File.expand_path("../app/controllers/email_reply_controller.rb", __FILE__)
  
  # Add email reply functionality to posts
  class ::Post
    def email_reply_data
      topic = self.topic
      user = self.user
      site = Discourse.current_hostname
      
      # Generate Message-ID format for threading
      message_id = "discourse-#{topic.id}-#{self.post_number}@#{site}"
      
      # For replies, reference the original post
      references = if self.post_number == 1
        message_id
      else
        first_post_id = "discourse-#{topic.id}-1@#{site}"
        [first_post_id, message_id].join(" ")
      end
      
      # Extract plain text content (simplified)
      quote_length = SiteSetting.email_reply_quoted_text_length rescue 1000
      body_text = PrettyText.excerpt(self.cooked, quote_length, strip_links: true)
      include_quotes = SiteSetting.email_reply_include_quoted_text rescue true
      quoted_body = include_quotes ? body_text.split("\n").map { |line| "> #{line}" }.join("\n") : ""
      
      {
        to: topic.category&.email_in || (SiteSetting.email_reply_address rescue '') || SiteSetting.reply_by_email_address&.gsub('%{reply_key}', 'noreply'),
        cc: [], # Will be populated with original CCs if available
        subject: "#{SiteSetting.email_reply_subject_prefix rescue 'Re: '}#{topic.title}",
        body: "\n\n#{quoted_body}\n\n",
        in_reply_to: message_id,
        references: references,
        thread_index: generate_thread_index(topic.id, self.post_number),
        thread_topic: topic.title
      }
    end
    
    private
    
    def generate_thread_index(topic_id, post_number)
      # Generate a simple thread index for Outlook threading
      base = topic_id.to_s(16).upcase.rjust(8, '0')
      post_hex = post_number.to_s(16).upcase.rjust(4, '0')
      "#{base}#{post_hex}"
    end
  end
  
  # Add route for generating mailto links
  Discourse::Application.routes.append do
    get "/email-reply/:post_id" => "email_reply#generate_mailto", constraints: { post_id: /\d+/ }
  end
end
