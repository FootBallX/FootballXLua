var fs = require('fs');

var luaFileName = '../src/GamePlay/SyncedTime.lua';
var cppFileName = '../../Classes/CSyncedTime.h';


function trim(stri) { return stri.replace(/(^\s*)|(\s*$)/g, ""); } 

function getFuncNameFromLua(l){
	var regExp = /\bfunction\b.*:/;
	if (regExp.test(l))
	{
		l = l.replace(regExp, "");
		l = l.replace(/\(.*/, "");
		l = trim(l);
		return l;
	}

	return null
}

function getFuncNameFromCPP(l){
	var regExp = /\s+\w+\(.*\)(\s*$|.*(;|\}))\s*$/;
	l = l.replace(/\/\/.*/, "");
	if (regExp.test(l))
	{
		l = l.replace(/\(.*\).*/, "");
		l = l.replace(/^.*\s/, "");
		l = trim(l);
		return l;
	}

	return null
}


function compareNames(l1, l2){
	var diffL = [];
	var diffR = [];
	for (var i in l1) {
		var found = false;
		for (var j in l2) {
			if (l1[i] == l2[j]){
				found = true;
				break;
			}
		}

		if (!found) {
			diffL.push(l1[i]);
		}
	}

	for (var j in l2) {
		var found = false;
		for (var i in l1) {
			if (l1[i] == l2[j]){
				found = true;
				break;
			}
		}

		if (!found) {
			diffR.push(l2[j]);
		}
	}

	return {left:diffL, right:diffR};
}


fs.readFile(luaFileName, 'utf8', function(err, data) {
	var luaNames = [];
	var cppNames = [];

	var lines = data.split('\n');
	for (i in lines)
	{
		var l = getFuncNameFromLua(lines[i]);
		if (l !== null)
		{
			luaNames.push(l);
		}
	}

	fs.readFile(cppFileName, 'utf8', function(err, data) {
		var lines = data.split('\n');
			for (i in lines)
		{
			var l = getFuncNameFromCPP(lines[i]);
			if (l !== null)
			{
				cppNames.push(l);
			}
		}
		
		var res = compareNames(luaNames, cppNames);
		console.dir(res);
		// console.dir(cppNames);
	})
});