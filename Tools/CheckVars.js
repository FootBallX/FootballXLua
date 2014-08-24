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

function getVarNameFromLua(l){
	l = trim(l);
	var regExp = /^self\.(\w+)\s*=\s*.*$/;
	var ret = l.match(regExp);
	if (ret !== null)
	{
		return ret[1];
	}

	return null;
}

function getVarNameFromCPP(l){
	l = l.replace(/\/\/.*/, "");
	l = trim(l);

	var regExp = /\b(m_\w+).*;$/;
	var ret = l.match(regExp);
	if (ret !== null)
	{
		return ret[1];
	}

	return null;
}


function convert(data) {
	data = data.replace(/nullptr/g, 'nil');
	data = data.replace(/->/g, ':');
	data = data.replace(/\bauto\b/g, 'local');
	data = data.replace(/local&/g, 'local');
	data = data.replace(/\bint\b/g, 'local');
	data = data.replace(/float/g, 'local');
	data = data.replace(/::/g, '.');
	data = data.replace(/FBDefs/g, 'matchDefs');
	data = data.replace(/m_/g, 'self.m_');
	data = data.replace(/FBMATCH/g, 'g_matchManager');
	data = data.replace(/!=/g, '~=');
	data = data.replace(/&&/g, 'and');
	data = data.replace(/\|\|/g, 'or');
	data = data.replace(/this:/g, '');
	data = data.replace(/\/\//g, '--');
	data = data.replace(/\{/g, '');
	data = data.replace(/\}/g, 'end');
	data = data.replace(/\bFLT_MAX\b/g, 'constVar.Sys.numberMax');

	return data;
}


function makeLuaVar(data) {
	var lua = data.right;
	var refer = data.refer;
	
	for (var i in lua) {
		var s = 'self.' + lua[i];
		var r = refer[i];
		var res = r.match(/\bvector<.*>.*;/);
		if (res !== null)
		{
			s += ' = {}; HDVector.extend(self.' + lua[i] + ');';
		}
		else
		{
			res = r.match(/.*=\s*(.*)\s*;/);
			if (res !== null)
			{
				var t = res[1];
				t = convert(t);
				s += ' = ' + t + ';';
			}
		}

		s += ' -- ' + refer[i];

		lua[i] = s;
	}

	data.right = lua;
	data.refer = null;
}


function compareNames(l1, l2, l3){
	var diffL = [];
	var diffR = [];
	var refer = [];
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
			refer.push(l3[j]);
		}
	}

	return {left:diffL, right:diffR, refer:refer};
}

function main() {
	for (var i in FileList) {
		var luaNames = [];
		var cppNames = [];
		var cppLines = [];
		var files = FileList[i];

		for (var j in files.lua) {
			var data = fs.readFileSync(files.lua[j], 'utf8');
			var ret = data.match(/ctor\(.*\).*?([\r\n|\n].*?)+?end[\r\n|\n]/m);
			var lines;
			if (ret !== null) {
				lines = ret[0].split(/\r\n|\n/);
			}

			for (var k in lines)
			{
				var l = getVarNameFromLua(lines[k]);
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
				var l = getVarNameFromCPP(lines[k]);
				if (l !== null)
				{
					cppNames.push(l);
					cppLines.push(lines[k]);
				}
			}
		}


		var res = compareNames(luaNames, cppNames, cppLines);
		makeLuaVar(res);
		console.log('------------------');
		console.log(files.lua);
		console.dir(res);
	}
}

main();









