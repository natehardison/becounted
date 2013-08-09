/**
 * @author "Nate Hardison<hardison@stanford.edu>"
 */
var _myGetElementById = document.getElementById;

document.getElementById = function(id) {
	var elem;
	if (typeof id == "string") {
		elem = _myGetElementById(id);
	} else {
		elem = id;
	} 
	if(!elem) {
		var title = "document.getElementById() error!";
		var message = "Can't find element with ID = " + id;
		new Dialog().showMessage(title, message);
	}
	return elem;
}
