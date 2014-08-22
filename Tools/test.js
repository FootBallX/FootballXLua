
var regExp = /\s+(\w+)\(.*\)(\s*$|.*(;|\}))\s*$/;

var s = 'virtual CFBInstructionResult& getInstructionResult() {return 0;}';

var ret = s.match(regExp);

console.dir(ret);