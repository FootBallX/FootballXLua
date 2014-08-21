var fs = require('fs');


var FileList = [
	{lua:['../src/GamePlay/FBMatch.lua'], cpp:['../../Classes/CFBMatch.h']},
	{lua:['../src/GamePlay/FBPitch.lua'], cpp:['../../Classes/CFBPitch.h']},
	{lua:['../src/GamePlay/FBPitchGrid.lua'], cpp:['../../Classes/CFBPitchGrid.h']},
	{lua:['../src/GamePlay/FBPlayer.lua'], cpp:['../../Classes/CFBPlayer.h']},
	{lua:['../src/GamePlay/FBPlayerAI.lua'], cpp:['../../Classes/CFBPlayerAI.h', '../../Classes/CFBGoalkeeperAI.h', '../../Classes/CFBBackAI.h', '../../Classes/CFBHalfBackAI.h', '../../Classes/CFBForwardAI.h']},
	{lua:['../src/GamePlay/FBTeam.lua'], cpp:['../../Classes/CFBTeam.h']},
	{lua:['../src/GamePlay/NetProxy.lua'], cpp:['../../Classes/CFBMatchProxy.h', '../../Classes/CFBMatchProxyNet.h']},
	{lua:['../src/GamePlay/SyncedTime.lua'], cpp:['../../Classes/CSyncedTime.h']}
];



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

function main() {
	for (var i in FileList) {
		var luaNames = [];
		var cppNames = [];
		var files = FileList[i];

		for (var j in files.lua) {
			var data = fs.readFileSync(files.lua[j], 'utf8');
			var lines = data.split('\n');
			for (var k in lines)
			{
				var l = getFuncNameFromLua(lines[k]);
				if (l !== null)
				{
					luaNames.push(l);
				}
			}
		}

		for (var j in files.cpp) {
			var data = fs.readFileSync(files.cpp[j], 'utf8');
			var lines = data.split('\n');
			for (var k in lines)
			{
				var l = getFuncNameFromCPP(lines[k]);
				if (l !== null)
				{
					cppNames.push(l);
				}
			}
		}

		var res = compareNames(luaNames, cppNames);
		console.log('------------------');
		console.log(files.lua);
		console.dir(res);
	}
}

function test()
{
	var data = fs.readFileSync(FileList[0].lua[0], 'utf8');

	var ret = data.match(/ctor\(\)(([\r|\n|\r\n].*){1,}|end[\r|\n|\r\n])/);
	console.dir(ret);
}

test();
// main();









