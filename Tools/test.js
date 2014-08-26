
var r = [
	'int ballSide  = 1; // 123',
	'void increaseGridScore(int index, int s) {m_grids[index].m_score += s; }',
	'int a ;'
	];

// var regExp = /\b(m_\w+).*;$/;

var regExp = /^(?!.*\(.*\)).*\s(\w+)\s*(?:=\s*.+;|;)/;


for (var i in r)
{
	var res = r[i].match(regExp);

	console.dir(res);
}
