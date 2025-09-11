import { createWidget } from "discourse/widgets/widget";
import { h } from "virtual-dom";
import { iconNode } from "discourse-common/lib/icon-library";

export default createWidget("email-reply-button", {
  tagName: "button.btn.btn-default.email-reply-button",
  
  buildClasses(attrs) {
    const classes = ["email-reply"];
    if (attrs.loading) {
      classes.push("loading");
    }
    return classes;
  },
  
  html(attrs) {
    const contents = [iconNode("envelope")];
    
    if (attrs.loading) {
      contents.push(" ");
      contents.push(iconNode("spinner", { class: "fa-spin" }));
    }
    
    return contents;
  },
  
  click() {
    this.sendWidgetAction("emailReply");
  }
});