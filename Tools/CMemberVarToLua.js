
var fs = require('fs');

function trim(stri) { return stri.replace(/(^\s*)|(\s*$)/g, ""); } 

fs.readFile('CMemberVarToLua.txt', 'utf8', function(err, data) {
	if (err) {
		console.error(err);
	} else {
		var lines = data.split('\n');
		for (i in lines)
		{
			var l = trim(lines[i]);
			var pos = l.search('m_');
			if (pos >= 0)
			{
				var orign = l;
				var str = l.substr(0, pos);
				str = l.replace(str, 'self.');
				
				str = '--' + orign + '\n' + str;
				data = data.replace(orign, str);
			}
		}
		
		data = data.replace(/nullptr/g, 'nil')
		console.log(data);
	}
});
