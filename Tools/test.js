 var s =  '#endif /* defined(__FootBallX__CFBPitch__) */';

 var s1  = ' void setGridDrawNode(int index, DrawNode* node)  //adasf';

var regExp = /\s+\w+\(.*\)(\s*$|.*(;|\}))\s*$/;

s1 = s1.replace(/\/\/.*/, "");

 console.dir(regExp.exec(s1));