// ActionScript file


package fink
{
	import com.adobe.serialization.json.JSON;
	import com.clevr.matrixalgebra.RealMatrix;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	


	
	public class MTN
	{
		private const timeStep_Mix:int = 100;
		private const timeStep_Net:int = 2000;
		
		private var time_Mix:Timer = new Timer(timeStep_Mix);
		private var time_Net:Timer = new Timer(timeStep_Net);
		
		private var mix1:SndMixer = new SndMixer();
		
		private var transTimes:Array = new Array(4);
		private var currSnd:int = new int();
		private var nextSnd:int = new int();
		private var timeCount:int = new int();
		
		private var P:RealMatrix = new RealMatrix(4,4,0);
		private var delta:RealMatrix = new RealMatrix(4,4,0);
		private var E:RealMatrix = new RealMatrix(4,4,0);
		private var phi:RealMatrix = new RealMatrix(4,4,0);
		private var A:RealMatrix = new RealMatrix(4,4,0);
		private var tau:RealMatrix = new RealMatrix(4,1,0);
		private var density:Array = new Array(4);
		private var snd_x_locs:Array = new Array(4);
		private var snd_y_locs:Array = new Array(4);
		private var x_loc:Number = new Number;
		private var y_loc:Number = new Number;
		private var zoom:Number = new Number; //Unit Radius of scrub mode
		private var netConnections:RealMatrix = new RealMatrix(4,4,0); 
		
		private var N:int = 4;//new int();
		
		private var allLoaded:Boolean = false;
				
		public function MTN():void
		{
			
			//Initial cursor location
			x_loc = -111.9352984;
			y_loc = 33.4208857875;
			//zoom = 0.5;
			zoom = 0.0004
			
			timeCount = 1000000;
			currSnd = 0;
			nextSnd = 0;
					
			var soundURL:String = "http://soundwalks.org/sounds.json?lat=33.4208857875&lng=-111.9352984&distance=10";
			var request:URLRequest = new URLRequest(soundURL);
			var loader:URLLoader = new URLLoader();
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, loadData);
			
			
			
			
			
			
			
			//for (var i1:int = 0; i1 < 4; i1++)
			//{
				//transTimes[i1] = new Number();
			//}
			//var req1:URLRequest = new URLRequest("http://soundwalks.org/soundwalks/7/sounds/212.mp3");
			//var req2:URLRequest = new URLRequest("http://soundwalks.org/soundwalks/7/sounds/218.mp3");
			//var req3:URLRequest = new URLRequest("http://soundwalks.org/soundwalks/7/sounds/221.mp3");
			//var req4:URLRequest = new URLRequest("http://soundwalks.org/soundwalks/7/sounds/216.mp3");

			//mix1.loadSnd(req1);
			//mix1.loadSnd(req2);
			//mix1.loadSnd(req3);
			//mix1.loadSnd(req4);
			
			//transTimes[0] = 4000;
			//transTimes[1] = 1000;
			//transTimes[2] = 10000;
			//transTimes[3] = 750;

			
			//Network connections from Delaunay Triangulation
			//makeNetConnections();
			

			
			//Set sound GPS Locations
			/**
			snd_x_locs[0] = 0.1;
			snd_x_locs[1] = 0.2;
			snd_x_locs[2] = 0.3;
			snd_x_locs[3] = 0.4;
			snd_y_locs[0] = 0.1;
			snd_y_locs[1] = 0.1;
			snd_y_locs[2] = 0.1;
			snd_y_locs[3] = 0.1;
			 */
			
		}
		
		private function loadData(e:Event):void
		{
			var loader:URLLoader = URLLoader(e.target);
			var req:URLRequest = new URLRequest();
			var JSONsndData:Array = JSON.decode(loader.data);
			var url:String = new String();
			
			//Get N, the number of sounds
			N = JSONsndData.length;
			
			//Resize all matrices and arrays
			P = new RealMatrix(N,N,0);
			delta = new RealMatrix(N,N,0);
			//private var E:RealMatrix = new RealMatrix(4,4,0);
			//private var phi:RealMatrix = new RealMatrix(4,4,0);
			//private var A:RealMatrix = new RealMatrix(4,4,0);
			//private var tau:RealMatrix = new RealMatrix(4,1,0);
			density = new Array(N);
			snd_x_locs = new Array(N);
			snd_y_locs = new Array(N);
			netConnections = new RealMatrix(N,N,0);
			
			JSONsndData.sortOn("id", Array.NUMERIC);
			
			//Load data from JSON
			//for (var i1:int = 0; i1 < N; i1++)
			for (var i1:int = 0; i1 < N; i1++)
			{
				//"http://soundwalks.org/soundwalks/7/sounds/212.mp3"
				url = "http://soundwalks.org/soundwalks/"+ JSONsndData[i1].soundwalk_id +"/sounds/" + JSONsndData[i1].id +".mp3";
				mix1.loadSnd(new URLRequest(url));
				snd_x_locs[i1] = JSONsndData[i1].lng;
				snd_y_locs[i1] = JSONsndData[i1].lat;
				//trace(JSONsndData[i1].id);
			}	
			
			
			//Make Network Connections from Delaunay Triangulation
			makeNetConnections();
			
			allLoaded = true;
			trace ("Sounds loaded.");
		}
		
		private function design_system(starting:Boolean):void
		{
			var rowSum:Number = 0;
			var elem:Number = 0;
			var nearSnd:int;
			
			nearSnd = calc_density();
			if (starting)
			{
				nextSnd = nearSnd;			
			}
			
			//Should do Matrix stuff here, really
			
			//Update Probability Matrix
			for (var i1:int = 0; i1 < N; i1++)
			{
				rowSum = 0;
				for (var j1:int = 0; j1 < N; j1++)
				{
					elem = netConnections.getElement(i1,j1)*density[j1];
					rowSum += elem;
					P.setElement(i1,j1,elem);
				}
				for (var j1:int = 0; j1 < N; j1++)
				{
					P.setElement(i1,j1,(P.getElement(i1,j1)/rowSum));
				}
			}
			
			//update delta matrix
			for (var i1:int = 0; i1 < N; i1++)
			{
				for (var j1:int = 0; j1 < N; j1++)
				{
					delta.setElement(i1,j1,2000); //set all deltas to 2 seconds for now
				}
			}
			
			//var aa1:Array = P.getArray();
			//var aa2:Array = delta.getArray();
			
		}
		
		public function set_location(x:Number, y:Number):void
		{
			x_loc = x;
			y_loc = y;
		}

		public function set_zoom(zm:Number):void
		{
			zoom = zm;
		}
		
		private function calc_density():int
		{
			//calculates densities and returns the ID (array index) of the nearest sound
			var dist:Number;
			var minVal:Number = 99999999;
			var minID:int;
			for (var i1:int = 0; i1 < N; i1++)
			{
				dist = (Math.sqrt( Math.pow((x_loc-snd_x_locs[i1]),2) + Math.pow((y_loc-snd_y_locs[i1]),2) ));
				if (dist < minVal)
				{
					minID = i1;
					minVal = dist;
				}
				density[i1] = goodMath.normPDF(0,zoom,dist);   
			}
			
			return minID;
		}
				
		public function start():void
		{
			if (allLoaded)
			{
				
				design_system(true);
				//maybe start with closest sound?
				time_Mix.addEventListener(TimerEvent.TIMER, actant_tictoc);
				time_Mix.start();
				time_Net.addEventListener(TimerEvent.TIMER, network_tictoc);
				time_Net.start();
				trace("start");
			}	
		}
		
		public function stop():void
		{
			time_Mix.stop();
			time_Net.stop();
			mix1.stopSnd();	
			trace("stop");
		}
		
		private function actant_tictoc(e:Event):void
		{
			timeCount += timeStep_Mix;
			if (timeCount >= delta.getElement(currSnd,nextSnd))
			{
				currSnd = nextSnd;
				mix1.playSnd(currSnd);
				trace(currSnd);
				var rNum:Number = Math.random();
				var pSum:Number = 0;
				nextSnd = -1;
				while(pSum < rNum)
				{
					nextSnd++;
					pSum += P.getElement(currSnd,nextSnd);
				}
				//nextSnd = Math.floor(Math.random()*4);
				timeCount = 0;
			}
					
		}		
		
		private function network_tictoc(e:Event):void
		{
			design_system(false);
			trace("network update");
		}
		
		private function compute_delay_matrix():void
		{
			var vecDelta:RealMatrix = new RealMatrix((N*N),1,0)
			A = E.timesMatrix(phi);
			//vecDelta = A.solve_lowrank(tau);
			vecDelta = A.solve(tau);
			for (var i1:int = 0; i1 < N; i1++)
			{
				for (var j1:int = 0; j1 < N; j1++)
				{
					delta.setElement(i1,j1,vecDelta.getElement((j1*4 + i1),0))
				}
			}
		}
		
		private function compute_E_matrix():void
		{
			var E_row_temp:RealMatrix = new RealMatrix(1,N,0);
			//all functions that take a row index are 1:N (not 0:N-1)
			for (var i1:int = 0; i1 < N; i1++)
			{
				E_row_temp = compute_E_row((i1+1));				
				for (var j1:int = 0; j1 < N; j1++)
				{
					E.setElement(i1,j1,E_row_temp.getElement(0,j1));	
				}
			}
			
		}

		private function compute_phi_matrix():void
		{
			//for testing
			N = 4;
			P = RealMatrix.random(N,N);
			tau = RealMatrix.random(N,1);
			//
			
			var j2:int = new int();
			phi = new RealMatrix(N,(N*N),0);
			for (var i1:int = 0; i1 < N; i1++)
			{
				for (var j1:int = 0; j1 < N; j1++)
				{	
			    	j2 = i1 + N*(j1);  //possible bug?  don't think so
			    	phi.setElement(i1,j2,P.getElement(i1,j1));
    			}
   			}
		}
		
		public function returnPhi():RealMatrix
		{
			compute_phi_matrix();
			compute_E_matrix();
			compute_delay_matrix();
			return delta;
		}

		public function returnP():RealMatrix
		{
			compute_phi_matrix();
			return P;
		}
		
		private function compute_E_row(i:int):RealMatrix
		{
			//Is valid, check if works right
			var E_row:RealMatrix = new RealMatrix(1,N,0);
			var qi:RealMatrix = new RealMatrix(1,N-1,0);
			var QIbar:RealMatrix = new RealMatrix(N-1,N-1,0);
			var ei:RealMatrix = new RealMatrix(1,N,0);
			var EIbar:RealMatrix = new RealMatrix(N-1,N,0);
			var ident:RealMatrix = RealMatrix.identity(N-1,N-1);
			qi = compute_qi(i);
			QIbar = compute_QIbar(i);
			ei = compute_ei(i);
			EIbar = compute_EIbar(i);
			
			E_row = ident.minusEquals(QIbar);
			E_row = E_row.inverse();
			E_row = qi.timesMatrix(E_row);
			E_row = E_row.timesMatrix(EIbar);
			E_row.plusEquals(ei);
						
			return E_row;
			
		}

		private function compute_qi(i:int):RealMatrix
		{
			var qi:RealMatrix = new RealMatrix(1,(N-1),0);
			for (var i1:int = 0; i1 < (i-1); i1++)
			{
				qi.setElement(0,i1,P.getElement(i-1,i1));	
			}
			for (var i1:int = i; i1 < N; i1++)
			{
				qi.setElement(0,i1-1,P.getElement(i-1,i1));	
			}
			return qi;
		}
		
		private function compute_QIbar(i:int):RealMatrix
		{
			var QIbar:RealMatrix = new RealMatrix((N-1),(N-1),0);
			for (var i1:int = 0; i1 < (i-1); i1++)
			{
				//qi.setElement(0,i1,P.getElement(i-1,i1));
				for (var j1:int = 0; j1 < (i-1); j1++)
				{
					QIbar.setElement(i1,j1,P.getElement(i1,j1));
					//qi.setElement(0,i1,P.getElement(i-1,i1));	
				}
				for (var j1:int = i; j1 < N; j1++)
				{
					QIbar.setElement(i1,j1-1,P.getElement(i1,j1));
					//qi.setElement(0,i1-1,P.getElement(i-1,i1));	
				}	
			}
			for (var i1:int = i; i1 < N; i1++)
			{
				//qi.setElement(0,i1-1,P.getElement(i-1,i1));
				for (var j1:int = 0; j1 < (i-1); j1++)
				{
					QIbar.setElement(i1-1,j1,P.getElement(i1,j1));
					//qi.setElement(0,i1,P.getElement(i-1,i1));	
				}
				for (var j1:int = i; j1 < N; j1++)
				{
					QIbar.setElement(i1-1,j1-1,P.getElement(i1,j1));
					//qi.setElement(0,i1-1,P.getElement(i-1,i1));	
				}		
			}
			return QIbar;	
		}

		private function compute_ei(i:int):RealMatrix
		{
			var ei:RealMatrix = new RealMatrix(1,N,0);
			ei.setElement(0,i-1,1);	
			return ei;
		}
		
		private function compute_EIbar(i:int):RealMatrix
		{
			var EIbar:RealMatrix = new RealMatrix(N-1,N,0);
			for (var j1:int = 0; j1 < (i-1); j1++)
			{
				EIbar.setElement(j1,j1,1);
			}
			for (var j1:int = i; j1 < N; j1++)
			{
				EIbar.setElement(j1-1,j1,1);
			} 
			return EIbar;	
		}
		
		private function makeNetConnections():void
		{
			/**
			netConnections.setElement(0,1,1);
			netConnections.setElement(0,2,1);
			netConnections.setElement(1,0,1);
			netConnections.setElement(1,2,1);
			netConnections.setElement(1,3,1);
			netConnections.setElement(2,0,1);
			netConnections.setElement(2,1,1);
			netConnections.setElement(2,3,1);
			netConnections.setElement(3,1,1);
			netConnections.setElement(3,2,1);
			 */
			  netConnections.setElement(0, 0, 1);
 netConnections.setElement(0, 10, 1);
 netConnections.setElement(0, 19, 1);
 netConnections.setElement(0, 36, 1);
 netConnections.setElement(0, 108, 1);
 netConnections.setElement(0, 131, 1);
 netConnections.setElement(1, 1, 1);
 netConnections.setElement(1, 11, 1);
 netConnections.setElement(1, 23, 1);
 netConnections.setElement(1, 25, 1);
 netConnections.setElement(1, 61, 1);
 netConnections.setElement(1, 71, 1);
 netConnections.setElement(1, 150, 1);
 netConnections.setElement(1, 158, 1);
 netConnections.setElement(2, 2, 1);
 netConnections.setElement(2, 7, 1);
 netConnections.setElement(2, 9, 1);
 netConnections.setElement(2, 12, 1);
 netConnections.setElement(2, 18, 1);
 netConnections.setElement(2, 48, 1);
 netConnections.setElement(2, 49, 1);
 netConnections.setElement(3, 3, 1);
 netConnections.setElement(3, 8, 1);
 netConnections.setElement(3, 24, 1);
 netConnections.setElement(3, 25, 1);
 netConnections.setElement(3, 57, 1);
 netConnections.setElement(4, 4, 1);
 netConnections.setElement(4, 30, 1);
 netConnections.setElement(4, 41, 1);
 netConnections.setElement(4, 65, 1);
 netConnections.setElement(4, 69, 1);
 netConnections.setElement(5, 5, 1);
 netConnections.setElement(5, 15, 1);
 netConnections.setElement(5, 17, 1);
 netConnections.setElement(5, 18, 1);
 netConnections.setElement(5, 26, 1);
 netConnections.setElement(5, 105, 1);
 netConnections.setElement(5, 137, 1);
 netConnections.setElement(6, 6, 1);
 netConnections.setElement(6, 47, 1);
 netConnections.setElement(6, 150, 1);
 netConnections.setElement(6, 153, 1);
 netConnections.setElement(6, 156, 1);
 netConnections.setElement(6, 168, 1);
 netConnections.setElement(6, 171, 1);
 netConnections.setElement(7, 2, 1);
 netConnections.setElement(7, 7, 1);
 netConnections.setElement(7, 8, 1);
 netConnections.setElement(7, 9, 1);
 netConnections.setElement(7, 24, 1);
 netConnections.setElement(7, 25, 1);
 netConnections.setElement(7, 48, 1);
 netConnections.setElement(8, 3, 1);
 netConnections.setElement(8, 7, 1);
 netConnections.setElement(8, 8, 1);
 netConnections.setElement(8, 14, 1);
 netConnections.setElement(8, 24, 1);
 netConnections.setElement(8, 48, 1);
 netConnections.setElement(8, 57, 1);
 netConnections.setElement(8, 154, 1);
 netConnections.setElement(8, 176, 1);
 netConnections.setElement(9, 2, 1);
 netConnections.setElement(9, 7, 1);
 netConnections.setElement(9, 9, 1);
 netConnections.setElement(9, 17, 1);
 netConnections.setElement(9, 18, 1);
 netConnections.setElement(9, 25, 1);
 netConnections.setElement(10, 0, 1);
 netConnections.setElement(10, 10, 1);
 netConnections.setElement(10, 11, 1);
 netConnections.setElement(10, 36, 1);
 netConnections.setElement(10, 53, 1);
 netConnections.setElement(10, 78, 1);
 netConnections.setElement(10, 131, 1);
 netConnections.setElement(10, 156, 1);
 netConnections.setElement(11, 1, 1);
 netConnections.setElement(11, 10, 1);
 netConnections.setElement(11, 11, 1);
 netConnections.setElement(11, 36, 1);
 netConnections.setElement(11, 61, 1);
 netConnections.setElement(11, 150, 1);
 netConnections.setElement(11, 156, 1);
 netConnections.setElement(12, 2, 1);
 netConnections.setElement(12, 12, 1);
 netConnections.setElement(12, 18, 1);
 netConnections.setElement(12, 46, 1);
 netConnections.setElement(12, 49, 1);
 netConnections.setElement(12, 109, 1);
 netConnections.setElement(12, 165, 1);
 netConnections.setElement(12, 166, 1);
 netConnections.setElement(13, 13, 1);
 netConnections.setElement(13, 14, 1);
 netConnections.setElement(13, 162, 1);
 netConnections.setElement(13, 164, 1);
 netConnections.setElement(13, 170, 1);
 netConnections.setElement(13, 176, 1);
 netConnections.setElement(14, 8, 1);
 netConnections.setElement(14, 13, 1);
 netConnections.setElement(14, 14, 1);
 netConnections.setElement(14, 57, 1);
 netConnections.setElement(14, 162, 1);
 netConnections.setElement(14, 176, 1);
 netConnections.setElement(15, 5, 1);
 netConnections.setElement(15, 15, 1);
 netConnections.setElement(15, 22, 1);
 netConnections.setElement(15, 26, 1);
 netConnections.setElement(15, 102, 1);
 netConnections.setElement(15, 103, 1);
 netConnections.setElement(15, 137, 1);
 netConnections.setElement(16, 16, 1);
 netConnections.setElement(16, 18, 1);
 netConnections.setElement(16, 105, 1);
 netConnections.setElement(16, 109, 1);
 netConnections.setElement(16, 138, 1);
 netConnections.setElement(17, 5, 1);
 netConnections.setElement(17, 9, 1);
 netConnections.setElement(17, 17, 1);
 netConnections.setElement(17, 18, 1);
 netConnections.setElement(17, 25, 1);
 netConnections.setElement(17, 26, 1);
 netConnections.setElement(17, 112, 1);
 netConnections.setElement(18, 2, 1);
 netConnections.setElement(18, 5, 1);
 netConnections.setElement(18, 9, 1);
 netConnections.setElement(18, 12, 1);
 netConnections.setElement(18, 16, 1);
 netConnections.setElement(18, 17, 1);
 netConnections.setElement(18, 18, 1);
 netConnections.setElement(18, 105, 1);
 netConnections.setElement(18, 109, 1);
 netConnections.setElement(19, 0, 1);
 netConnections.setElement(19, 19, 1);
 netConnections.setElement(19, 40, 1);
 netConnections.setElement(19, 106, 1);
 netConnections.setElement(19, 108, 1);
 netConnections.setElement(19, 121, 1);
 netConnections.setElement(19, 131, 1);
 netConnections.setElement(20, 20, 1);
 netConnections.setElement(20, 26, 1);
 netConnections.setElement(20, 40, 1);
 netConnections.setElement(20, 71, 1);
 netConnections.setElement(20, 102, 1);
 netConnections.setElement(20, 112, 1);
 netConnections.setElement(20, 129, 1);
 netConnections.setElement(21, 21, 1);
 netConnections.setElement(21, 105, 1);
 netConnections.setElement(21, 114, 1);
 netConnections.setElement(21, 137, 1);
 netConnections.setElement(21, 138, 1);
 netConnections.setElement(21, 141, 1);
 netConnections.setElement(21, 146, 1);
 netConnections.setElement(22, 15, 1);
 netConnections.setElement(22, 22, 1);
 netConnections.setElement(22, 102, 1);
 netConnections.setElement(22, 103, 1);
 netConnections.setElement(22, 129, 1);
 netConnections.setElement(22, 142, 1);
 netConnections.setElement(23, 1, 1);
 netConnections.setElement(23, 23, 1);
 netConnections.setElement(23, 59, 1);
 netConnections.setElement(23, 150, 1);
 netConnections.setElement(23, 153, 1);
 netConnections.setElement(23, 157, 1);
 netConnections.setElement(23, 158, 1);
 netConnections.setElement(23, 168, 1);
 netConnections.setElement(24, 3, 1);
 netConnections.setElement(24, 7, 1);
 netConnections.setElement(24, 8, 1);
 netConnections.setElement(24, 24, 1);
 netConnections.setElement(24, 25, 1);
 netConnections.setElement(25, 1, 1);
 netConnections.setElement(25, 3, 1);
 netConnections.setElement(25, 7, 1);
 netConnections.setElement(25, 9, 1);
 netConnections.setElement(25, 17, 1);
 netConnections.setElement(25, 24, 1);
 netConnections.setElement(25, 25, 1);
 netConnections.setElement(25, 57, 1);
 netConnections.setElement(25, 71, 1);
 netConnections.setElement(25, 112, 1);
 netConnections.setElement(25, 158, 1);
 netConnections.setElement(26, 5, 1);
 netConnections.setElement(26, 15, 1);
 netConnections.setElement(26, 17, 1);
 netConnections.setElement(26, 20, 1);
 netConnections.setElement(26, 26, 1);
 netConnections.setElement(26, 102, 1);
 netConnections.setElement(26, 112, 1);
 netConnections.setElement(27, 27, 1);
 netConnections.setElement(27, 29, 1);
 netConnections.setElement(27, 33, 1);
 netConnections.setElement(27, 162, 1);
 netConnections.setElement(27, 169, 1);
 netConnections.setElement(27, 170, 1);
 netConnections.setElement(28, 28, 1);
 netConnections.setElement(28, 50, 1);
 netConnections.setElement(28, 51, 1);
 netConnections.setElement(28, 163, 1);
 netConnections.setElement(28, 172, 1);
 netConnections.setElement(29, 27, 1);
 netConnections.setElement(29, 29, 1);
 netConnections.setElement(29, 43, 1);
 netConnections.setElement(29, 169, 1);
 netConnections.setElement(29, 170, 1);
 netConnections.setElement(30, 4, 1);
 netConnections.setElement(30, 30, 1);
 netConnections.setElement(30, 31, 1);
 netConnections.setElement(30, 41, 1);
 netConnections.setElement(30, 69, 1);
 netConnections.setElement(30, 159, 1);
 netConnections.setElement(30, 170, 1);
 netConnections.setElement(31, 30, 1);
 netConnections.setElement(31, 31, 1);
 netConnections.setElement(31, 32, 1);
 netConnections.setElement(31, 37, 1);
 netConnections.setElement(31, 60, 1);
 netConnections.setElement(31, 69, 1);
 netConnections.setElement(31, 107, 1);
 netConnections.setElement(31, 148, 1);
 netConnections.setElement(31, 159, 1);
 netConnections.setElement(32, 31, 1);
 netConnections.setElement(32, 32, 1);
 netConnections.setElement(32, 56, 1);
 netConnections.setElement(32, 60, 1);
 netConnections.setElement(32, 148, 1);
 netConnections.setElement(33, 27, 1);
 netConnections.setElement(33, 33, 1);
 netConnections.setElement(33, 47, 1);
 netConnections.setElement(33, 53, 1);
 netConnections.setElement(33, 153, 1);
 netConnections.setElement(33, 162, 1);
 netConnections.setElement(33, 169, 1);
 netConnections.setElement(34, 34, 1);
 netConnections.setElement(34, 38, 1);
 netConnections.setElement(34, 42, 1);
 netConnections.setElement(34, 63, 1);
 netConnections.setElement(34, 149, 1);
 netConnections.setElement(34, 167, 1);
 netConnections.setElement(34, 173, 1);
 netConnections.setElement(35, 35, 1);
 netConnections.setElement(35, 44, 1);
 netConnections.setElement(35, 77, 1);
 netConnections.setElement(35, 79, 1);
 netConnections.setElement(35, 86, 1);
 netConnections.setElement(35, 93, 1);
 netConnections.setElement(35, 95, 1);
 netConnections.setElement(35, 101, 1);
 netConnections.setElement(36, 0, 1);
 netConnections.setElement(36, 10, 1);
 netConnections.setElement(36, 11, 1);
 netConnections.setElement(36, 36, 1);
 netConnections.setElement(36, 40, 1);
 netConnections.setElement(36, 61, 1);
 netConnections.setElement(36, 108, 1);
 netConnections.setElement(37, 31, 1);
 netConnections.setElement(37, 37, 1);
 netConnections.setElement(37, 58, 1);
 netConnections.setElement(37, 66, 1);
 netConnections.setElement(37, 107, 1);
 netConnections.setElement(37, 159, 1);
 netConnections.setElement(37, 164, 1);
 netConnections.setElement(38, 34, 1);
 netConnections.setElement(38, 38, 1);
 netConnections.setElement(38, 50, 1);
 netConnections.setElement(38, 149, 1);
 netConnections.setElement(38, 163, 1);
 netConnections.setElement(38, 173, 1);
 netConnections.setElement(38, 174, 1);
 netConnections.setElement(39, 39, 1);
 netConnections.setElement(39, 45, 1);
 netConnections.setElement(39, 49, 1);
 netConnections.setElement(39, 107, 1);
 netConnections.setElement(39, 166, 1);
 netConnections.setElement(39, 173, 1);
 netConnections.setElement(40, 19, 1);
 netConnections.setElement(40, 20, 1);
 netConnections.setElement(40, 36, 1);
 netConnections.setElement(40, 40, 1);
 netConnections.setElement(40, 61, 1);
 netConnections.setElement(40, 71, 1);
 netConnections.setElement(40, 106, 1);
 netConnections.setElement(40, 108, 1);
 netConnections.setElement(40, 129, 1);
 netConnections.setElement(41, 4, 1);
 netConnections.setElement(41, 30, 1);
 netConnections.setElement(41, 41, 1);
 netConnections.setElement(41, 43, 1);
 netConnections.setElement(41, 62, 1);
 netConnections.setElement(41, 65, 1);
 netConnections.setElement(41, 170, 1);
 netConnections.setElement(41, 177, 1);
 netConnections.setElement(42, 34, 1);
 netConnections.setElement(42, 42, 1);
 netConnections.setElement(42, 46, 1);
 netConnections.setElement(42, 63, 1);
 netConnections.setElement(42, 167, 1);
 netConnections.setElement(43, 29, 1);
 netConnections.setElement(43, 41, 1);
 netConnections.setElement(43, 43, 1);
 netConnections.setElement(43, 70, 1);
 netConnections.setElement(43, 104, 1);
 netConnections.setElement(43, 118, 1);
 netConnections.setElement(43, 169, 1);
 netConnections.setElement(43, 170, 1);
 netConnections.setElement(43, 177, 1);
 netConnections.setElement(44, 35, 1);
 netConnections.setElement(44, 44, 1);
 netConnections.setElement(44, 77, 1);
 netConnections.setElement(44, 100, 1);
 netConnections.setElement(44, 101, 1);
 netConnections.setElement(44, 122, 1);
 netConnections.setElement(45, 39, 1);
 netConnections.setElement(45, 45, 1);
 netConnections.setElement(45, 49, 1);
 netConnections.setElement(45, 58, 1);
 netConnections.setElement(45, 107, 1);
 netConnections.setElement(45, 154, 1);
 netConnections.setElement(46, 12, 1);
 netConnections.setElement(46, 42, 1);
 netConnections.setElement(46, 46, 1);
 netConnections.setElement(46, 63, 1);
 netConnections.setElement(46, 165, 1);
 netConnections.setElement(46, 167, 1);
 netConnections.setElement(47, 6, 1);
 netConnections.setElement(47, 33, 1);
 netConnections.setElement(47, 47, 1);
 netConnections.setElement(47, 53, 1);
 netConnections.setElement(47, 153, 1);
 netConnections.setElement(47, 156, 1);
 netConnections.setElement(48, 2, 1);
 netConnections.setElement(48, 7, 1);
 netConnections.setElement(48, 8, 1);
 netConnections.setElement(48, 48, 1);
 netConnections.setElement(48, 49, 1);
 netConnections.setElement(48, 154, 1);
 netConnections.setElement(49, 2, 1);
 netConnections.setElement(49, 12, 1);
 netConnections.setElement(49, 39, 1);
 netConnections.setElement(49, 45, 1);
 netConnections.setElement(49, 48, 1);
 netConnections.setElement(49, 49, 1);
 netConnections.setElement(49, 154, 1);
 netConnections.setElement(49, 166, 1);
 netConnections.setElement(50, 28, 1);
 netConnections.setElement(50, 38, 1);
 netConnections.setElement(50, 50, 1);
 netConnections.setElement(50, 163, 1);
 netConnections.setElement(50, 172, 1);
 netConnections.setElement(50, 174, 1);
 netConnections.setElement(51, 28, 1);
 netConnections.setElement(51, 51, 1);
 netConnections.setElement(51, 56, 1);
 netConnections.setElement(51, 60, 1);
 netConnections.setElement(51, 67, 1);
 netConnections.setElement(51, 163, 1);
 netConnections.setElement(51, 172, 1);
 netConnections.setElement(52, 52, 1);
 netConnections.setElement(52, 64, 1);
 netConnections.setElement(52, 73, 1);
 netConnections.setElement(52, 75, 1);
 netConnections.setElement(52, 110, 1);
 netConnections.setElement(52, 155, 1);
 netConnections.setElement(52, 160, 1);
 netConnections.setElement(53, 10, 1);
 netConnections.setElement(53, 33, 1);
 netConnections.setElement(53, 47, 1);
 netConnections.setElement(53, 53, 1);
 netConnections.setElement(53, 70, 1);
 netConnections.setElement(53, 78, 1);
 netConnections.setElement(53, 156, 1);
 netConnections.setElement(53, 169, 1);
 netConnections.setElement(54, 54, 1);
 netConnections.setElement(54, 68, 1);
 netConnections.setElement(54, 149, 1);
 netConnections.setElement(54, 161, 1);
 netConnections.setElement(54, 167, 1);
 netConnections.setElement(54, 174, 1);
 netConnections.setElement(55, 55, 1);
 netConnections.setElement(55, 64, 1);
 netConnections.setElement(55, 73, 1);
 netConnections.setElement(55, 77, 1);
 netConnections.setElement(55, 81, 1);
 netConnections.setElement(55, 122, 1);
 netConnections.setElement(55, 126, 1);
 netConnections.setElement(56, 32, 1);
 netConnections.setElement(56, 51, 1);
 netConnections.setElement(56, 56, 1);
 netConnections.setElement(56, 60, 1);
 netConnections.setElement(56, 148, 1);
 netConnections.setElement(56, 163, 1);
 netConnections.setElement(56, 173, 1);
 netConnections.setElement(57, 3, 1);
 netConnections.setElement(57, 8, 1);
 netConnections.setElement(57, 14, 1);
 netConnections.setElement(57, 25, 1);
 netConnections.setElement(57, 57, 1);
 netConnections.setElement(57, 157, 1);
 netConnections.setElement(57, 158, 1);
 netConnections.setElement(57, 162, 1);
 netConnections.setElement(58, 37, 1);
 netConnections.setElement(58, 45, 1);
 netConnections.setElement(58, 58, 1);
 netConnections.setElement(58, 66, 1);
 netConnections.setElement(58, 107, 1);
 netConnections.setElement(58, 154, 1);
 netConnections.setElement(59, 23, 1);
 netConnections.setElement(59, 59, 1);
 netConnections.setElement(59, 157, 1);
 netConnections.setElement(59, 158, 1);
 netConnections.setElement(60, 31, 1);
 netConnections.setElement(60, 32, 1);
 netConnections.setElement(60, 51, 1);
 netConnections.setElement(60, 56, 1);
 netConnections.setElement(60, 60, 1);
 netConnections.setElement(60, 67, 1);
 netConnections.setElement(60, 69, 1);
 netConnections.setElement(61, 1, 1);
 netConnections.setElement(61, 11, 1);
 netConnections.setElement(61, 36, 1);
 netConnections.setElement(61, 40, 1);
 netConnections.setElement(61, 61, 1);
 netConnections.setElement(61, 71, 1);
 netConnections.setElement(62, 41, 1);
 netConnections.setElement(62, 62, 1);
 netConnections.setElement(62, 65, 1);
 netConnections.setElement(62, 177, 1);
 netConnections.setElement(63, 34, 1);
 netConnections.setElement(63, 42, 1);
 netConnections.setElement(63, 46, 1);
 netConnections.setElement(63, 63, 1);
 netConnections.setElement(63, 135, 1);
 netConnections.setElement(63, 165, 1);
 netConnections.setElement(63, 173, 1);
 netConnections.setElement(64, 52, 1);
 netConnections.setElement(64, 55, 1);
 netConnections.setElement(64, 64, 1);
 netConnections.setElement(64, 73, 1);
 netConnections.setElement(64, 81, 1);
 netConnections.setElement(64, 117, 1);
 netConnections.setElement(64, 155, 1);
 netConnections.setElement(65, 4, 1);
 netConnections.setElement(65, 41, 1);
 netConnections.setElement(65, 62, 1);
 netConnections.setElement(65, 65, 1);
 netConnections.setElement(65, 67, 1);
 netConnections.setElement(65, 69, 1);
 netConnections.setElement(65, 177, 1);
 netConnections.setElement(66, 37, 1);
 netConnections.setElement(66, 58, 1);
 netConnections.setElement(66, 66, 1);
 netConnections.setElement(66, 154, 1);
 netConnections.setElement(66, 164, 1);
 netConnections.setElement(66, 176, 1);
 netConnections.setElement(67, 51, 1);
 netConnections.setElement(67, 60, 1);
 netConnections.setElement(67, 65, 1);
 netConnections.setElement(67, 67, 1);
 netConnections.setElement(67, 68, 1);
 netConnections.setElement(67, 69, 1);
 netConnections.setElement(67, 172, 1);
 netConnections.setElement(67, 177, 1);
 netConnections.setElement(68, 54, 1);
 netConnections.setElement(68, 67, 1);
 netConnections.setElement(68, 68, 1);
 netConnections.setElement(68, 118, 1);
 netConnections.setElement(68, 130, 1);
 netConnections.setElement(68, 161, 1);
 netConnections.setElement(68, 172, 1);
 netConnections.setElement(68, 174, 1);
 netConnections.setElement(68, 177, 1);
 netConnections.setElement(69, 4, 1);
 netConnections.setElement(69, 30, 1);
 netConnections.setElement(69, 31, 1);
 netConnections.setElement(69, 60, 1);
 netConnections.setElement(69, 65, 1);
 netConnections.setElement(69, 67, 1);
 netConnections.setElement(69, 69, 1);
 netConnections.setElement(70, 43, 1);
 netConnections.setElement(70, 53, 1);
 netConnections.setElement(70, 70, 1);
 netConnections.setElement(70, 78, 1);
 netConnections.setElement(70, 104, 1);
 netConnections.setElement(70, 169, 1);
 netConnections.setElement(71, 1, 1);
 netConnections.setElement(71, 20, 1);
 netConnections.setElement(71, 25, 1);
 netConnections.setElement(71, 40, 1);
 netConnections.setElement(71, 61, 1);
 netConnections.setElement(71, 71, 1);
 netConnections.setElement(71, 112, 1);
 netConnections.setElement(72, 72, 1);
 netConnections.setElement(72, 80, 1);
 netConnections.setElement(72, 83, 1);
 netConnections.setElement(72, 85, 1);
 netConnections.setElement(72, 91, 1);
 netConnections.setElement(72, 115, 1);
 netConnections.setElement(73, 52, 1);
 netConnections.setElement(73, 55, 1);
 netConnections.setElement(73, 64, 1);
 netConnections.setElement(73, 73, 1);
 netConnections.setElement(73, 75, 1);
 netConnections.setElement(73, 120, 1);
 netConnections.setElement(73, 126, 1);
 netConnections.setElement(74, 74, 1);
 netConnections.setElement(74, 82, 1);
 netConnections.setElement(74, 86, 1);
 netConnections.setElement(74, 88, 1);
 netConnections.setElement(74, 93, 1);
 netConnections.setElement(74, 106, 1);
 netConnections.setElement(74, 121, 1);
 netConnections.setElement(75, 52, 1);
 netConnections.setElement(75, 73, 1);
 netConnections.setElement(75, 75, 1);
 netConnections.setElement(75, 76, 1);
 netConnections.setElement(75, 110, 1);
 netConnections.setElement(75, 118, 1);
 netConnections.setElement(75, 120, 1);
 netConnections.setElement(75, 130, 1);
 netConnections.setElement(75, 152, 1);
 netConnections.setElement(76, 75, 1);
 netConnections.setElement(76, 76, 1);
 netConnections.setElement(76, 85, 1);
 netConnections.setElement(76, 91, 1);
 netConnections.setElement(76, 94, 1);
 netConnections.setElement(76, 120, 1);
 netConnections.setElement(76, 127, 1);
 netConnections.setElement(76, 130, 1);
 netConnections.setElement(77, 35, 1);
 netConnections.setElement(77, 44, 1);
 netConnections.setElement(77, 55, 1);
 netConnections.setElement(77, 77, 1);
 netConnections.setElement(77, 79, 1);
 netConnections.setElement(77, 81, 1);
 netConnections.setElement(77, 117, 1);
 netConnections.setElement(77, 122, 1);
 netConnections.setElement(78, 10, 1);
 netConnections.setElement(78, 53, 1);
 netConnections.setElement(78, 70, 1);
 netConnections.setElement(78, 78, 1);
 netConnections.setElement(78, 104, 1);
 netConnections.setElement(78, 131, 1);
 netConnections.setElement(78, 151, 1);
 netConnections.setElement(78, 175, 1);
 netConnections.setElement(79, 35, 1);
 netConnections.setElement(79, 77, 1);
 netConnections.setElement(79, 79, 1);
 netConnections.setElement(79, 86, 1);
 netConnections.setElement(79, 117, 1);
 netConnections.setElement(79, 121, 1);
 netConnections.setElement(80, 72, 1);
 netConnections.setElement(80, 80, 1);
 netConnections.setElement(80, 83, 1);
 netConnections.setElement(80, 92, 1);
 netConnections.setElement(80, 115, 1);
 netConnections.setElement(80, 123, 1);
 netConnections.setElement(80, 124, 1);
 netConnections.setElement(81, 55, 1);
 netConnections.setElement(81, 64, 1);
 netConnections.setElement(81, 77, 1);
 netConnections.setElement(81, 81, 1);
 netConnections.setElement(81, 117, 1);
 netConnections.setElement(82, 74, 1);
 netConnections.setElement(82, 82, 1);
 netConnections.setElement(82, 88, 1);
 netConnections.setElement(82, 90, 1);
 netConnections.setElement(82, 106, 1);
 netConnections.setElement(82, 132, 1);
 netConnections.setElement(82, 139, 1);
 netConnections.setElement(83, 72, 1);
 netConnections.setElement(83, 80, 1);
 netConnections.setElement(83, 83, 1);
 netConnections.setElement(83, 91, 1);
 netConnections.setElement(83, 123, 1);
 netConnections.setElement(83, 126, 1);
 netConnections.setElement(84, 84, 1);
 netConnections.setElement(84, 85, 1);
 netConnections.setElement(84, 111, 1);
 netConnections.setElement(84, 115, 1);
 netConnections.setElement(84, 125, 1);
 netConnections.setElement(84, 127, 1);
 netConnections.setElement(85, 72, 1);
 netConnections.setElement(85, 76, 1);
 netConnections.setElement(85, 84, 1);
 netConnections.setElement(85, 85, 1);
 netConnections.setElement(85, 91, 1);
 netConnections.setElement(85, 115, 1);
 netConnections.setElement(85, 127, 1);
 netConnections.setElement(86, 35, 1);
 netConnections.setElement(86, 74, 1);
 netConnections.setElement(86, 79, 1);
 netConnections.setElement(86, 86, 1);
 netConnections.setElement(86, 93, 1);
 netConnections.setElement(86, 121, 1);
 netConnections.setElement(87, 87, 1);
 netConnections.setElement(87, 89, 1);
 netConnections.setElement(87, 92, 1);
 netConnections.setElement(87, 96, 1);
 netConnections.setElement(87, 115, 1);
 netConnections.setElement(87, 124, 1);
 netConnections.setElement(88, 74, 1);
 netConnections.setElement(88, 82, 1);
 netConnections.setElement(88, 88, 1);
 netConnections.setElement(88, 90, 1);
 netConnections.setElement(88, 93, 1);
 netConnections.setElement(88, 95, 1);
 netConnections.setElement(88, 96, 1);
 netConnections.setElement(88, 119, 1);
 netConnections.setElement(89, 87, 1);
 netConnections.setElement(89, 89, 1);
 netConnections.setElement(89, 96, 1);
 netConnections.setElement(89, 99, 1);
 netConnections.setElement(89, 115, 1);
 netConnections.setElement(89, 125, 1);
 netConnections.setElement(90, 82, 1);
 netConnections.setElement(90, 88, 1);
 netConnections.setElement(90, 90, 1);
 netConnections.setElement(90, 116, 1);
 netConnections.setElement(90, 119, 1);
 netConnections.setElement(90, 128, 1);
 netConnections.setElement(90, 139, 1);
 netConnections.setElement(91, 72, 1);
 netConnections.setElement(91, 76, 1);
 netConnections.setElement(91, 83, 1);
 netConnections.setElement(91, 85, 1);
 netConnections.setElement(91, 91, 1);
 netConnections.setElement(91, 120, 1);
 netConnections.setElement(91, 126, 1);
 netConnections.setElement(92, 80, 1);
 netConnections.setElement(92, 87, 1);
 netConnections.setElement(92, 92, 1);
 netConnections.setElement(92, 115, 1);
 netConnections.setElement(92, 124, 1);
 netConnections.setElement(93, 35, 1);
 netConnections.setElement(93, 74, 1);
 netConnections.setElement(93, 86, 1);
 netConnections.setElement(93, 88, 1);
 netConnections.setElement(93, 93, 1);
 netConnections.setElement(93, 95, 1);
 netConnections.setElement(94, 76, 1);
 netConnections.setElement(94, 94, 1);
 netConnections.setElement(94, 127, 1);
 netConnections.setElement(94, 130, 1);
 netConnections.setElement(94, 161, 1);
 netConnections.setElement(94, 167, 1);
 netConnections.setElement(95, 35, 1);
 netConnections.setElement(95, 88, 1);
 netConnections.setElement(95, 93, 1);
 netConnections.setElement(95, 95, 1);
 netConnections.setElement(95, 96, 1);
 netConnections.setElement(95, 101, 1);
 netConnections.setElement(96, 87, 1);
 netConnections.setElement(96, 88, 1);
 netConnections.setElement(96, 89, 1);
 netConnections.setElement(96, 95, 1);
 netConnections.setElement(96, 96, 1);
 netConnections.setElement(96, 99, 1);
 netConnections.setElement(96, 101, 1);
 netConnections.setElement(96, 119, 1);
 netConnections.setElement(96, 124, 1);
 netConnections.setElement(97, 97, 1);
 netConnections.setElement(97, 98, 1);
 netConnections.setElement(97, 111, 1);
 netConnections.setElement(97, 128, 1);
 netConnections.setElement(97, 139, 1);
 netConnections.setElement(97, 141, 1);
 netConnections.setElement(98, 97, 1);
 netConnections.setElement(98, 98, 1);
 netConnections.setElement(98, 111, 1);
 netConnections.setElement(98, 116, 1);
 netConnections.setElement(98, 128, 1);
 netConnections.setElement(99, 89, 1);
 netConnections.setElement(99, 96, 1);
 netConnections.setElement(99, 99, 1);
 netConnections.setElement(99, 116, 1);
 netConnections.setElement(99, 119, 1);
 netConnections.setElement(99, 125, 1);
 netConnections.setElement(100, 44, 1);
 netConnections.setElement(100, 100, 1);
 netConnections.setElement(100, 101, 1);
 netConnections.setElement(100, 122, 1);
 netConnections.setElement(100, 123, 1);
 netConnections.setElement(100, 124, 1);
 netConnections.setElement(101, 35, 1);
 netConnections.setElement(101, 44, 1);
 netConnections.setElement(101, 95, 1);
 netConnections.setElement(101, 96, 1);
 netConnections.setElement(101, 100, 1);
 netConnections.setElement(101, 101, 1);
 netConnections.setElement(101, 124, 1);
 netConnections.setElement(102, 15, 1);
 netConnections.setElement(102, 20, 1);
 netConnections.setElement(102, 22, 1);
 netConnections.setElement(102, 26, 1);
 netConnections.setElement(102, 102, 1);
 netConnections.setElement(102, 129, 1);
 netConnections.setElement(103, 15, 1);
 netConnections.setElement(103, 22, 1);
 netConnections.setElement(103, 103, 1);
 netConnections.setElement(103, 137, 1);
 netConnections.setElement(103, 142, 1);
 netConnections.setElement(104, 43, 1);
 netConnections.setElement(104, 70, 1);
 netConnections.setElement(104, 78, 1);
 netConnections.setElement(104, 104, 1);
 netConnections.setElement(104, 118, 1);
 netConnections.setElement(104, 151, 1);
 netConnections.setElement(105, 5, 1);
 netConnections.setElement(105, 16, 1);
 netConnections.setElement(105, 18, 1);
 netConnections.setElement(105, 21, 1);
 netConnections.setElement(105, 105, 1);
 netConnections.setElement(105, 137, 1);
 netConnections.setElement(105, 138, 1);
 netConnections.setElement(106, 19, 1);
 netConnections.setElement(106, 40, 1);
 netConnections.setElement(106, 74, 1);
 netConnections.setElement(106, 82, 1);
 netConnections.setElement(106, 106, 1);
 netConnections.setElement(106, 121, 1);
 netConnections.setElement(106, 129, 1);
 netConnections.setElement(106, 132, 1);
 netConnections.setElement(106, 134, 1);
 netConnections.setElement(106, 143, 1);
 netConnections.setElement(106, 145, 1);
 netConnections.setElement(107, 31, 1);
 netConnections.setElement(107, 37, 1);
 netConnections.setElement(107, 39, 1);
 netConnections.setElement(107, 45, 1);
 netConnections.setElement(107, 58, 1);
 netConnections.setElement(107, 107, 1);
 netConnections.setElement(107, 148, 1);
 netConnections.setElement(107, 173, 1);
 netConnections.setElement(108, 0, 1);
 netConnections.setElement(108, 19, 1);
 netConnections.setElement(108, 36, 1);
 netConnections.setElement(108, 40, 1);
 netConnections.setElement(108, 108, 1);
 netConnections.setElement(109, 12, 1);
 netConnections.setElement(109, 16, 1);
 netConnections.setElement(109, 18, 1);
 netConnections.setElement(109, 109, 1);
 netConnections.setElement(109, 138, 1);
 netConnections.setElement(110, 52, 1);
 netConnections.setElement(110, 75, 1);
 netConnections.setElement(110, 110, 1);
 netConnections.setElement(110, 151, 1);
 netConnections.setElement(110, 152, 1);
 netConnections.setElement(110, 160, 1);
 netConnections.setElement(110, 175, 1);
 netConnections.setElement(111, 84, 1);
 netConnections.setElement(111, 97, 1);
 netConnections.setElement(111, 98, 1);
 netConnections.setElement(111, 111, 1);
 netConnections.setElement(111, 116, 1);
 netConnections.setElement(111, 125, 1);
 netConnections.setElement(112, 17, 1);
 netConnections.setElement(112, 20, 1);
 netConnections.setElement(112, 25, 1);
 netConnections.setElement(112, 26, 1);
 netConnections.setElement(112, 71, 1);
 netConnections.setElement(112, 112, 1);
 netConnections.setElement(113, 113, 1);
 netConnections.setElement(113, 134, 1);
 netConnections.setElement(113, 142, 1);
 netConnections.setElement(113, 143, 1);
 netConnections.setElement(113, 145, 1);
 netConnections.setElement(113, 146, 1);
 netConnections.setElement(114, 21, 1);
 netConnections.setElement(114, 114, 1);
 netConnections.setElement(114, 136, 1);
 netConnections.setElement(114, 141, 1);
 netConnections.setElement(114, 146, 1);
 netConnections.setElement(114, 147, 1);
 netConnections.setElement(115, 72, 1);
 netConnections.setElement(115, 80, 1);
 netConnections.setElement(115, 84, 1);
 netConnections.setElement(115, 85, 1);
 netConnections.setElement(115, 87, 1);
 netConnections.setElement(115, 89, 1);
 netConnections.setElement(115, 92, 1);
 netConnections.setElement(115, 115, 1);
 netConnections.setElement(115, 125, 1);
 netConnections.setElement(116, 90, 1);
 netConnections.setElement(116, 98, 1);
 netConnections.setElement(116, 99, 1);
 netConnections.setElement(116, 111, 1);
 netConnections.setElement(116, 116, 1);
 netConnections.setElement(116, 119, 1);
 netConnections.setElement(116, 125, 1);
 netConnections.setElement(116, 128, 1);
 netConnections.setElement(117, 64, 1);
 netConnections.setElement(117, 77, 1);
 netConnections.setElement(117, 79, 1);
 netConnections.setElement(117, 81, 1);
 netConnections.setElement(117, 117, 1);
 netConnections.setElement(117, 121, 1);
 netConnections.setElement(117, 131, 1);
 netConnections.setElement(117, 155, 1);
 netConnections.setElement(118, 43, 1);
 netConnections.setElement(118, 68, 1);
 netConnections.setElement(118, 75, 1);
 netConnections.setElement(118, 104, 1);
 netConnections.setElement(118, 118, 1);
 netConnections.setElement(118, 130, 1);
 netConnections.setElement(118, 151, 1);
 netConnections.setElement(118, 152, 1);
 netConnections.setElement(118, 177, 1);
 netConnections.setElement(119, 88, 1);
 netConnections.setElement(119, 90, 1);
 netConnections.setElement(119, 96, 1);
 netConnections.setElement(119, 99, 1);
 netConnections.setElement(119, 116, 1);
 netConnections.setElement(119, 119, 1);
 netConnections.setElement(120, 73, 1);
 netConnections.setElement(120, 75, 1);
 netConnections.setElement(120, 76, 1);
 netConnections.setElement(120, 91, 1);
 netConnections.setElement(120, 120, 1);
 netConnections.setElement(120, 126, 1);
 netConnections.setElement(121, 19, 1);
 netConnections.setElement(121, 74, 1);
 netConnections.setElement(121, 79, 1);
 netConnections.setElement(121, 86, 1);
 netConnections.setElement(121, 106, 1);
 netConnections.setElement(121, 117, 1);
 netConnections.setElement(121, 121, 1);
 netConnections.setElement(121, 131, 1);
 netConnections.setElement(122, 44, 1);
 netConnections.setElement(122, 55, 1);
 netConnections.setElement(122, 77, 1);
 netConnections.setElement(122, 100, 1);
 netConnections.setElement(122, 122, 1);
 netConnections.setElement(122, 123, 1);
 netConnections.setElement(122, 126, 1);
 netConnections.setElement(123, 80, 1);
 netConnections.setElement(123, 83, 1);
 netConnections.setElement(123, 100, 1);
 netConnections.setElement(123, 122, 1);
 netConnections.setElement(123, 123, 1);
 netConnections.setElement(123, 124, 1);
 netConnections.setElement(123, 126, 1);
 netConnections.setElement(124, 80, 1);
 netConnections.setElement(124, 87, 1);
 netConnections.setElement(124, 92, 1);
 netConnections.setElement(124, 96, 1);
 netConnections.setElement(124, 100, 1);
 netConnections.setElement(124, 101, 1);
 netConnections.setElement(124, 123, 1);
 netConnections.setElement(124, 124, 1);
 netConnections.setElement(125, 84, 1);
 netConnections.setElement(125, 89, 1);
 netConnections.setElement(125, 99, 1);
 netConnections.setElement(125, 111, 1);
 netConnections.setElement(125, 115, 1);
 netConnections.setElement(125, 116, 1);
 netConnections.setElement(125, 125, 1);
 netConnections.setElement(126, 55, 1);
 netConnections.setElement(126, 73, 1);
 netConnections.setElement(126, 83, 1);
 netConnections.setElement(126, 91, 1);
 netConnections.setElement(126, 120, 1);
 netConnections.setElement(126, 122, 1);
 netConnections.setElement(126, 123, 1);
 netConnections.setElement(126, 126, 1);
 netConnections.setElement(127, 76, 1);
 netConnections.setElement(127, 84, 1);
 netConnections.setElement(127, 85, 1);
 netConnections.setElement(127, 94, 1);
 netConnections.setElement(127, 127, 1);
 netConnections.setElement(127, 167, 1);
 netConnections.setElement(128, 90, 1);
 netConnections.setElement(128, 97, 1);
 netConnections.setElement(128, 98, 1);
 netConnections.setElement(128, 116, 1);
 netConnections.setElement(128, 128, 1);
 netConnections.setElement(128, 139, 1);
 netConnections.setElement(129, 20, 1);
 netConnections.setElement(129, 22, 1);
 netConnections.setElement(129, 40, 1);
 netConnections.setElement(129, 102, 1);
 netConnections.setElement(129, 106, 1);
 netConnections.setElement(129, 129, 1);
 netConnections.setElement(129, 134, 1);
 netConnections.setElement(129, 142, 1);
 netConnections.setElement(130, 68, 1);
 netConnections.setElement(130, 75, 1);
 netConnections.setElement(130, 76, 1);
 netConnections.setElement(130, 94, 1);
 netConnections.setElement(130, 118, 1);
 netConnections.setElement(130, 130, 1);
 netConnections.setElement(130, 161, 1);
 netConnections.setElement(131, 0, 1);
 netConnections.setElement(131, 10, 1);
 netConnections.setElement(131, 19, 1);
 netConnections.setElement(131, 78, 1);
 netConnections.setElement(131, 117, 1);
 netConnections.setElement(131, 121, 1);
 netConnections.setElement(131, 131, 1);
 netConnections.setElement(131, 155, 1);
 netConnections.setElement(131, 160, 1);
 netConnections.setElement(131, 175, 1);
 netConnections.setElement(132, 82, 1);
 netConnections.setElement(132, 106, 1);
 netConnections.setElement(132, 132, 1);
 netConnections.setElement(132, 133, 1);
 netConnections.setElement(132, 136, 1);
 netConnections.setElement(132, 139, 1);
 netConnections.setElement(132, 140, 1);
 netConnections.setElement(132, 145, 1);
 netConnections.setElement(133, 132, 1);
 netConnections.setElement(133, 133, 1);
 netConnections.setElement(133, 139, 1);
 netConnections.setElement(133, 140, 1);
 netConnections.setElement(133, 144, 1);
 netConnections.setElement(134, 106, 1);
 netConnections.setElement(134, 113, 1);
 netConnections.setElement(134, 129, 1);
 netConnections.setElement(134, 134, 1);
 netConnections.setElement(134, 142, 1);
 netConnections.setElement(134, 143, 1);
 netConnections.setElement(135, 63, 1);
 netConnections.setElement(135, 135, 1);
 netConnections.setElement(135, 165, 1);
 netConnections.setElement(135, 166, 1);
 netConnections.setElement(135, 173, 1);
 netConnections.setElement(136, 114, 1);
 netConnections.setElement(136, 132, 1);
 netConnections.setElement(136, 136, 1);
 netConnections.setElement(136, 140, 1);
 netConnections.setElement(136, 144, 1);
 netConnections.setElement(136, 145, 1);
 netConnections.setElement(136, 146, 1);
 netConnections.setElement(136, 147, 1);
 netConnections.setElement(137, 5, 1);
 netConnections.setElement(137, 15, 1);
 netConnections.setElement(137, 21, 1);
 netConnections.setElement(137, 103, 1);
 netConnections.setElement(137, 105, 1);
 netConnections.setElement(137, 137, 1);
 netConnections.setElement(137, 142, 1);
 netConnections.setElement(137, 146, 1);
 netConnections.setElement(138, 16, 1);
 netConnections.setElement(138, 21, 1);
 netConnections.setElement(138, 105, 1);
 netConnections.setElement(138, 109, 1);
 netConnections.setElement(138, 138, 1);
 netConnections.setElement(138, 141, 1);
 netConnections.setElement(139, 82, 1);
 netConnections.setElement(139, 90, 1);
 netConnections.setElement(139, 97, 1);
 netConnections.setElement(139, 128, 1);
 netConnections.setElement(139, 132, 1);
 netConnections.setElement(139, 133, 1);
 netConnections.setElement(139, 139, 1);
 netConnections.setElement(139, 141, 1);
 netConnections.setElement(139, 144, 1);
 netConnections.setElement(140, 132, 1);
 netConnections.setElement(140, 133, 1);
 netConnections.setElement(140, 136, 1);
 netConnections.setElement(140, 140, 1);
 netConnections.setElement(140, 144, 1);
 netConnections.setElement(141, 21, 1);
 netConnections.setElement(141, 97, 1);
 netConnections.setElement(141, 114, 1);
 netConnections.setElement(141, 138, 1);
 netConnections.setElement(141, 139, 1);
 netConnections.setElement(141, 141, 1);
 netConnections.setElement(141, 144, 1);
 netConnections.setElement(141, 147, 1);
 netConnections.setElement(142, 22, 1);
 netConnections.setElement(142, 103, 1);
 netConnections.setElement(142, 113, 1);
 netConnections.setElement(142, 129, 1);
 netConnections.setElement(142, 134, 1);
 netConnections.setElement(142, 137, 1);
 netConnections.setElement(142, 142, 1);
 netConnections.setElement(142, 146, 1);
 netConnections.setElement(143, 106, 1);
 netConnections.setElement(143, 113, 1);
 netConnections.setElement(143, 134, 1);
 netConnections.setElement(143, 143, 1);
 netConnections.setElement(143, 145, 1);
 netConnections.setElement(144, 133, 1);
 netConnections.setElement(144, 136, 1);
 netConnections.setElement(144, 139, 1);
 netConnections.setElement(144, 140, 1);
 netConnections.setElement(144, 141, 1);
 netConnections.setElement(144, 144, 1);
 netConnections.setElement(144, 147, 1);
 netConnections.setElement(145, 106, 1);
 netConnections.setElement(145, 113, 1);
 netConnections.setElement(145, 132, 1);
 netConnections.setElement(145, 136, 1);
 netConnections.setElement(145, 143, 1);
 netConnections.setElement(145, 145, 1);
 netConnections.setElement(145, 146, 1);
 netConnections.setElement(146, 21, 1);
 netConnections.setElement(146, 113, 1);
 netConnections.setElement(146, 114, 1);
 netConnections.setElement(146, 136, 1);
 netConnections.setElement(146, 137, 1);
 netConnections.setElement(146, 142, 1);
 netConnections.setElement(146, 145, 1);
 netConnections.setElement(146, 146, 1);
 netConnections.setElement(147, 114, 1);
 netConnections.setElement(147, 136, 1);
 netConnections.setElement(147, 141, 1);
 netConnections.setElement(147, 144, 1);
 netConnections.setElement(147, 147, 1);
 netConnections.setElement(148, 31, 1);
 netConnections.setElement(148, 32, 1);
 netConnections.setElement(148, 56, 1);
 netConnections.setElement(148, 107, 1);
 netConnections.setElement(148, 148, 1);
 netConnections.setElement(148, 173, 1);
 netConnections.setElement(149, 34, 1);
 netConnections.setElement(149, 38, 1);
 netConnections.setElement(149, 54, 1);
 netConnections.setElement(149, 149, 1);
 netConnections.setElement(149, 167, 1);
 netConnections.setElement(149, 174, 1);
 netConnections.setElement(150, 1, 1);
 netConnections.setElement(150, 6, 1);
 netConnections.setElement(150, 11, 1);
 netConnections.setElement(150, 23, 1);
 netConnections.setElement(150, 150, 1);
 netConnections.setElement(150, 156, 1);
 netConnections.setElement(150, 168, 1);
 netConnections.setElement(151, 78, 1);
 netConnections.setElement(151, 104, 1);
 netConnections.setElement(151, 110, 1);
 netConnections.setElement(151, 118, 1);
 netConnections.setElement(151, 151, 1);
 netConnections.setElement(151, 152, 1);
 netConnections.setElement(151, 175, 1);
 netConnections.setElement(152, 75, 1);
 netConnections.setElement(152, 110, 1);
 netConnections.setElement(152, 118, 1);
 netConnections.setElement(152, 151, 1);
 netConnections.setElement(152, 152, 1);
 netConnections.setElement(153, 6, 1);
 netConnections.setElement(153, 23, 1);
 netConnections.setElement(153, 33, 1);
 netConnections.setElement(153, 47, 1);
 netConnections.setElement(153, 153, 1);
 netConnections.setElement(153, 157, 1);
 netConnections.setElement(153, 162, 1);
 netConnections.setElement(153, 168, 1);
 netConnections.setElement(153, 171, 1);
 netConnections.setElement(154, 8, 1);
 netConnections.setElement(154, 45, 1);
 netConnections.setElement(154, 48, 1);
 netConnections.setElement(154, 49, 1);
 netConnections.setElement(154, 58, 1);
 netConnections.setElement(154, 66, 1);
 netConnections.setElement(154, 154, 1);
 netConnections.setElement(154, 176, 1);
 netConnections.setElement(155, 52, 1);
 netConnections.setElement(155, 64, 1);
 netConnections.setElement(155, 117, 1);
 netConnections.setElement(155, 131, 1);
 netConnections.setElement(155, 155, 1);
 netConnections.setElement(155, 160, 1);
 netConnections.setElement(156, 6, 1);
 netConnections.setElement(156, 10, 1);
 netConnections.setElement(156, 11, 1);
 netConnections.setElement(156, 47, 1);
 netConnections.setElement(156, 53, 1);
 netConnections.setElement(156, 150, 1);
 netConnections.setElement(156, 156, 1);
 netConnections.setElement(157, 23, 1);
 netConnections.setElement(157, 57, 1);
 netConnections.setElement(157, 59, 1);
 netConnections.setElement(157, 153, 1);
 netConnections.setElement(157, 157, 1);
 netConnections.setElement(157, 158, 1);
 netConnections.setElement(157, 162, 1);
 netConnections.setElement(158, 1, 1);
 netConnections.setElement(158, 23, 1);
 netConnections.setElement(158, 25, 1);
 netConnections.setElement(158, 57, 1);
 netConnections.setElement(158, 59, 1);
 netConnections.setElement(158, 157, 1);
 netConnections.setElement(158, 158, 1);
 netConnections.setElement(159, 30, 1);
 netConnections.setElement(159, 31, 1);
 netConnections.setElement(159, 37, 1);
 netConnections.setElement(159, 159, 1);
 netConnections.setElement(159, 164, 1);
 netConnections.setElement(159, 170, 1);
 netConnections.setElement(160, 52, 1);
 netConnections.setElement(160, 110, 1);
 netConnections.setElement(160, 131, 1);
 netConnections.setElement(160, 155, 1);
 netConnections.setElement(160, 160, 1);
 netConnections.setElement(160, 175, 1);
 netConnections.setElement(161, 54, 1);
 netConnections.setElement(161, 68, 1);
 netConnections.setElement(161, 94, 1);
 netConnections.setElement(161, 130, 1);
 netConnections.setElement(161, 161, 1);
 netConnections.setElement(161, 167, 1);
 netConnections.setElement(162, 13, 1);
 netConnections.setElement(162, 14, 1);
 netConnections.setElement(162, 27, 1);
 netConnections.setElement(162, 33, 1);
 netConnections.setElement(162, 57, 1);
 netConnections.setElement(162, 153, 1);
 netConnections.setElement(162, 157, 1);
 netConnections.setElement(162, 162, 1);
 netConnections.setElement(162, 170, 1);
 netConnections.setElement(163, 28, 1);
 netConnections.setElement(163, 38, 1);
 netConnections.setElement(163, 50, 1);
 netConnections.setElement(163, 51, 1);
 netConnections.setElement(163, 56, 1);
 netConnections.setElement(163, 163, 1);
 netConnections.setElement(163, 173, 1);
 netConnections.setElement(164, 13, 1);
 netConnections.setElement(164, 37, 1);
 netConnections.setElement(164, 66, 1);
 netConnections.setElement(164, 159, 1);
 netConnections.setElement(164, 164, 1);
 netConnections.setElement(164, 170, 1);
 netConnections.setElement(164, 176, 1);
 netConnections.setElement(165, 12, 1);
 netConnections.setElement(165, 46, 1);
 netConnections.setElement(165, 63, 1);
 netConnections.setElement(165, 135, 1);
 netConnections.setElement(165, 165, 1);
 netConnections.setElement(165, 166, 1);
 netConnections.setElement(166, 12, 1);
 netConnections.setElement(166, 39, 1);
 netConnections.setElement(166, 49, 1);
 netConnections.setElement(166, 135, 1);
 netConnections.setElement(166, 165, 1);
 netConnections.setElement(166, 166, 1);
 netConnections.setElement(166, 173, 1);
 netConnections.setElement(167, 34, 1);
 netConnections.setElement(167, 42, 1);
 netConnections.setElement(167, 46, 1);
 netConnections.setElement(167, 54, 1);
 netConnections.setElement(167, 94, 1);
 netConnections.setElement(167, 127, 1);
 netConnections.setElement(167, 149, 1);
 netConnections.setElement(167, 161, 1);
 netConnections.setElement(167, 167, 1);
 netConnections.setElement(168, 6, 1);
 netConnections.setElement(168, 23, 1);
 netConnections.setElement(168, 150, 1);
 netConnections.setElement(168, 153, 1);
 netConnections.setElement(168, 168, 1);
 netConnections.setElement(168, 171, 1);
 netConnections.setElement(169, 27, 1);
 netConnections.setElement(169, 29, 1);
 netConnections.setElement(169, 33, 1);
 netConnections.setElement(169, 43, 1);
 netConnections.setElement(169, 53, 1);
 netConnections.setElement(169, 70, 1);
 netConnections.setElement(169, 169, 1);
 netConnections.setElement(170, 13, 1);
 netConnections.setElement(170, 27, 1);
 netConnections.setElement(170, 29, 1);
 netConnections.setElement(170, 30, 1);
 netConnections.setElement(170, 41, 1);
 netConnections.setElement(170, 43, 1);
 netConnections.setElement(170, 159, 1);
 netConnections.setElement(170, 162, 1);
 netConnections.setElement(170, 164, 1);
 netConnections.setElement(170, 170, 1);
 netConnections.setElement(171, 6, 1);
 netConnections.setElement(171, 153, 1);
 netConnections.setElement(171, 168, 1);
 netConnections.setElement(171, 171, 1);
 netConnections.setElement(172, 28, 1);
 netConnections.setElement(172, 50, 1);
 netConnections.setElement(172, 51, 1);
 netConnections.setElement(172, 67, 1);
 netConnections.setElement(172, 68, 1);
 netConnections.setElement(172, 172, 1);
 netConnections.setElement(172, 174, 1);
 netConnections.setElement(173, 34, 1);
 netConnections.setElement(173, 38, 1);
 netConnections.setElement(173, 39, 1);
 netConnections.setElement(173, 56, 1);
 netConnections.setElement(173, 63, 1);
 netConnections.setElement(173, 107, 1);
 netConnections.setElement(173, 135, 1);
 netConnections.setElement(173, 148, 1);
 netConnections.setElement(173, 163, 1);
 netConnections.setElement(173, 166, 1);
 netConnections.setElement(173, 173, 1);
 netConnections.setElement(174, 38, 1);
 netConnections.setElement(174, 50, 1);
 netConnections.setElement(174, 54, 1);
 netConnections.setElement(174, 68, 1);
 netConnections.setElement(174, 149, 1);
 netConnections.setElement(174, 172, 1);
 netConnections.setElement(174, 174, 1);
 netConnections.setElement(175, 78, 1);
 netConnections.setElement(175, 110, 1);
 netConnections.setElement(175, 131, 1);
 netConnections.setElement(175, 151, 1);
 netConnections.setElement(175, 160, 1);
 netConnections.setElement(175, 175, 1);
 netConnections.setElement(176, 8, 1);
 netConnections.setElement(176, 13, 1);
 netConnections.setElement(176, 14, 1);
 netConnections.setElement(176, 66, 1);
 netConnections.setElement(176, 154, 1);
 netConnections.setElement(176, 164, 1);
 netConnections.setElement(176, 176, 1);
 netConnections.setElement(177, 41, 1);
 netConnections.setElement(177, 43, 1);
 netConnections.setElement(177, 62, 1);
 netConnections.setElement(177, 65, 1);
 netConnections.setElement(177, 67, 1);
 netConnections.setElement(177, 68, 1);
 netConnections.setElement(177, 118, 1);
 netConnections.setElement(177, 177, 1);
			
			//remove self-connections
			for (var i1:int = 0; i1 < 178; i1++)
			{
				netConnections.setElement(i1,i1,0);
			}
		}
	}
}