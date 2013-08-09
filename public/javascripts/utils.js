/**
 * @author "Nate Hardison<hardison@stanford.edu>"
 * 
 * A lot of these functions are very similar to the ones
 * provided in facebooker.js.  However, we needed to roll
 * our own JS rather than use theirs since theirs is not
 * totally developed yet.
 */
// Change me if I get moved to a new location!
var baseURL = "http://fjqqqyaa.joyent.us:3000/"; // Trunk
//var baseURL = "http://fjqqqyaa.joyent.us:3001/";  // Nate's branch
//var baseURL = "http://fjqqqyaa.joyent.us:3002/";  // Mike's branch

function $(elem) {
	if(typeof elem == "string") {
		var elem = document.getElementById(elem);
	}
	if(elem) {
		extend(elem, Element);
		if(elem.getId().search("content_") == 0) {
			extend(elem, Content);
		} else if(elem.getId().search("link_") == 0) {
			extend(elem, Link);
		}
	}
	return elem;
}

function extend(instance, hash){
    for (var name in hash) {
        instance[name] = hash[name]
    }
}

Ajax.Request = function(action, options) {
    var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = options["ondone"];
    if (options["onerror"]) {
        ajax.onerror = options["onerror"];
    }
	var params = {};
    for (var param in options["params"]) {
        params[param] = options["params"][param];
    }
	// Can't use this if partials contain FBML
	//ajax.useLocalProxy = options.useLocalProxy;
    ajax.requireLogin = true;
    ajax.post(baseURL + action, params);
}

var Content = {
    getLink: function(){
        return $("link_" + this.getStatus());
    },
    getStatus: function(){
        return parseInt(this.getId().replace("content_", ""));
    },
    hide: function(){
        Animation(this).to("height", "0px").blind().hide().go();
		// HACK HACK HACK remove current class name from parent elem
		this.getParentNode().removeClassName("current");
    },
    next: function(){
        var nextStatus = this.getStatus() + 1;
        return $("content_" + nextStatus);
    },
    show: function(innerFBML){
        this.setInnerFBML(innerFBML);
		// HACK HACK HACK add current class name to parent elem
		this.getParentNode().addClassName("current");
        Animation(this).to("height", "auto").from("0px").blind().show().go();
    }
};

var Link = {
    getContent: function(){
        return $("content_" + this.getStatus());
    },
    getStatus: function(){
        return parseInt(this.getId().replace("link_", ""));
    }
};

var Element = {
	hide: function(){
        this.setStyle("display", "none");
    },
    show: function(/* optional */ innerFBML){
		if(innerFBML) {
			this.setInnerFBML(innerFBML);
		}
		this.setStyle("display", "block");
    },
	visible: function() {
		return (this.getStyle("display") != "none");
	}
}
