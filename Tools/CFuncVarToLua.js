
var fs = require('fs');

function trim(stri) { return stri.replace(/(^\s*)|(\s*$)/g, ""); } 

fs.readFile('CFuncVarToLua.txt', 'utf8', function(err, data) {
	if (err) {
		console.error(err);
	} else {
		data = data.replace(/nullptr/g, 'nil');
		data = data.replace(/->/g, ':');
		data = data.replace(/auto/g, 'local');
		data = data.replace(/local&/g, 'local');
		data = data.replace(/int/g, 'local');
		data = data.replace(/float/g, 'local');
		data = data.replace(/::/g, '.');
		data = data.replace(/FBDefs/g, 'matchDefs');
		data = data.replace(/m_/g, 'self.m_');
		data = data.replace(/FBMATCH/g, 'g_matchManager');
		data = data.replace(/!=/g, '~=');
		data = data.replace(/&&/g, 'and');
		data = data.replace(/\|\|/g, 'or');
		data = data.replace(/this:/g, '');
		console.log(data);
	}
});
