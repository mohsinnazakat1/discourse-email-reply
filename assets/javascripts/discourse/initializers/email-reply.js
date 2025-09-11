import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

function initializeEmailReply(api) {
  api.addPostMenuButton("email-reply", (post) => {
    if (!api.getCurrentUser()) return null;

    return {
      action: "emailReply",
      icon: "envelope",
      className: "email-reply-button",
      title: I18n.t("email_reply.button_title"),
      position: "first"
    };
  });

  api.attachWidgetAction("post-menu", "emailReply", function() {
    const post = this.model;

    // Show loading state
    this.state.loading = true;
    this.scheduleRerender();

    ajax(`/email-reply/${post.id}`)
      .then((response) => {
        this.state.loading = false;
        this.scheduleRerender();
        window.location.href = response.mailto_url;
      })
      .catch((error) => {
        this.state.loading = false;
        this.scheduleRerender();
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