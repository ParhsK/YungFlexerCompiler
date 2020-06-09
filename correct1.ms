// File: testing.ms
var limit, num, counter, n, E : number;
var listOfNums[10] : number;
const pi = 3.14 : number;

function testing(n : number) : boolean 
{
   var i : number;
   var result, testVar : boolean;
   if (n < 0)
      result = testing(-n);
   else if (listOfNums[5] < 2)
   {
      i = 1;
      i = i**5;
      result = false;
      E = 2 * pi * i;
   }
   else if (listOfNums[5] < 2)
   {
      i = 4;
      result = false;
      E = 2 * pi * i;
   }
   else
   {
      i = 3;
      testVar = true;
      while (testVar and (i < n / 2))
      {
         testVar = n % i != 0;
         i = i + 2;
      };
      result = testVar;
   }
   return result;
};

function start() : void
{
   var i = 1, r : number;
   var testVar, result : boolean;
   counter = readNumber();
   counter = 0;
   counter = 12 + listOfNums[2];
   while (counter <= limit)
   {
      if (testing(num))
      {
         counter = counter + 1;
         writeNumber(num);
         writeString("hi");
      }
   };
   num = num + 1;
   writeString("\n");
   writeNumber(counter);
   for (i = 7; i < listOfNums[2]; i = i + 1)
   {
      if (n < 0)
         result = testing(-n);
      else if (listOfNums[5] < 2)
      {
         r = 3;
         result = false;
         E = 2 * pi * r;
      }
      else
      {
         i = 3;
         testVar = true;
         while (testVar and (i < n / 2))
         {
            testVar = n % i != 0;
            i = i + 2;
         };
      }
   }
   while (result) {
      printf("ok");
   };
}