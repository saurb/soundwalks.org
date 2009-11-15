package fink
{
	public class goodMath
	{
		public function goodMath()
		{
		}
		
		public static function normPDF(mean:Number, stdDev:Number, ip:Number):Number 
		{
			//overload for multi-variate?
			var op:Number;
			op = Math.exp(-Math.pow((ip-mean),2)/(2*stdDev*stdDev))/(Math.sqrt(2*Math.PI*stdDev*stdDev));
			return op;
		}
		

	}
}