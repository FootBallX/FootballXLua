

var fs = require('fs');

function trim(stri) { return stri.replace(/(^\s*)|(\s*$)/g, ""); } 

fs.readFile('CEnumToLua.txt', 'utf8', function(err, data) {
	if (err) {
		console.error(err);
	} else {
		var lines = data.split('\n');
		for (i in lines)
		{
			var l = lines[i];
			if (l.search(',') >= 0 && l.search('},') == -1)
			{
				var pos = l.search('--');
				if (pos >= 0)
				{
					l = l.substr(0, pos);
				}
				
				l = trim(l);
				var orign = l;
				l = "\"" + l;
				pos = l.search("=");
				if (pos >= 0)
				{
					l = l.substr(0, pos);
					l = trim(l);
					l = l + ",";
				}
				l = l.replace(',', "\",");
				data = data.replace(orign, l);
			}
		}
		
		console.log(data);
	}
});
