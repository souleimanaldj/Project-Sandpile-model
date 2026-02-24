
/* Centered model */


proc iml;
   m = 201;
   sand = j(m, m, 0);
   
   center = ceil(m/2);

   avalanche_Time = {};
   avalanche_Size = {};
   
   do i = 1 to 1000000000;
      sand[center,center] = sand[center,center] + 1;

      time = 0;
      unstable = {};

      do while(max(sand) >= 4);
         affected = loc(sand >= 4);
         
         if ncol(affected) > 0 then do;
         	
         	time = time + 1;
            sand[affected] = sand[affected] - 4;
            unstable = unstable || affected;

			left = affected - 1;
            if mod(left, m) ^= 0 then do;
            	sand[left] = sand[left] + 1;
            end;

			right = affected + 1;
            if mod(right-1, m) ^= 0 then do;
            	sand[right] = sand[right] + 1;
            end;

			up = affected - m;
			if up > 0 then do;
				sand[up] = sand[up] + 1;
			end;
				
			down = affected + m;
			if down<=m*m then do;
				sand[down] = sand[down] + 1;
			end;
      	end;
   end;
   unstable = ncol(unstable);
   avalanche_Time = avalanche_Time // time;              
   avalanche_Size = avalanche_Size // unstable;
end;

call heatmapcont(sand) 
	colorramp= { 'CXF8EDEB' 'CXFEC5BB' 'CXE5989B' 'CXB5838D'}
	displayoutlines=0;
