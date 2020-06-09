// File: testing.ms
var limit, num, counter, E: number;
var listOfNums[10] : number;
const pi = 3.14: number;

function testing(n: number): boolean {
   var i: number; 
   var result, testVar: boolean;
    if (1 < 2)
        result = 1;
   if (n < 0){
      result = testing(-n);
   }
   else { 
      i = 3;
      testVar = true;
      while (testVar and (i < n / 2) ) { 
         testVar = n % i != 0;
         i = i + 2;
      };
      result = testVar;
   }
   if (5 < 2){
       i = 3;
   }
   return result;
};

function start() : void
{
   var a = readNumber() : number;
   return testing(a);
}