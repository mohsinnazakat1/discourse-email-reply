import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

function initializeEmailReply(api) {
  api.includePostAttributes("can_reply_via_email");
  
  api.addPostMenuButton("email-reply", (attrs) => {
    return {
      action: "emailReply",
      icon: "envelope",
      className: "email-reply-button",
      title: "reply_via_email",
      position: "first"
    };
  });
  
  api.attachWidgetAction("post-menu", "emailReply", function() {
    const post = this.findAncestorModel();
    
    // Show loading state
    const button = document.querySelector(`[data-post-id="${post.id}"] .email-reply-button`);
    if (button) {
      button.classList.add("loading");
    }
    
    ajax(`/email-reply/${post.id}`)
      .then((response) => {
        if (button) {
          button.classList.remove("loading");
        }
        window.location.href = response.mailto_url;
      })
      .catch((error) => {
        if (button) {
          button.classList.remove("loading");
        }
        popupAjaxError(error);
      });
  });
}

export default {
  name: "email-reply",
  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    
    if (!siteSettings.email_reply_enabled) {
      return;
    }
    
    withPluginApi("0.8.31", initializeEmailReply);
  }
};