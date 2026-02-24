
/* Random model */

proc iml;
   m = 21;
   sand = j(m, m, 0);
   
   avalanche_Time = {};
   avalanche_Size = {};
   
   do i = 1 to 10000;
      xaxis = ceil(m*randfun(1, "Uniform"));
   	  yaxis = ceil(m*randfun(1,"Uniform"));
      sand[xaxis,yaxis] = sand[xaxis,yaxis] + 1;
      
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
	
create avalanche_Size from avalanche_Size[colname={"size_of_an_avalanche"}];
append from avalanche_Size;
close avalanche_Size;

create avalanche_Time from avalanche_Time[colname={"duration_of_an_avalanche"}];
append from avalanche_Time;
close avalanche_Time;
quit;

data avalanche_Size;
	set avalanche_Size;
	where size_of_an_avalanche > 0;
	observations = _N_;
run;

proc freq data=avalanche_size noprint;
	table size_of_an_avalanche / out = frequence_of_avalanches_size;
run;

data frequence_of_avalanches_size;
	set frequence_of_avalanches_size;
	log_size_of_an_avalanche = log(size_of_an_avalanche);
	Percent = log(Percent);
	drop Count;
run;

proc reg data=frequence_of_avalanches_size
         outest=parametres_regression noprint;                           
    model Percent = log_size_of_an_avalanche size_of_an_avalanche / stb; 
    output out=predictions_regression
           p=yhat; 
run;

data parametres;
	set parametres_regression(
		keep=Intercept log_size_of_an_avalanche size_of_an_avalanche
		rename=(
			Intercept = constante
			log_size_of_an_avalanche = beta1
			size_of_an_avalanche = beta2
			)
	);
run;	

data regression;
	set predictions_regression(
		keep=log_size_of_an_avalanche Percent yhat
		rename=(
			log_size_of_an_avalanche = x
			Percent = y
			yhat = yhat
		)
	);
run;

proc print data=parametres;
run;

proc sgplot data=avalanche_Size;
    histogram size_of_an_avalanche / nbins=100 scale=count transparency=0.2 fillattrs=(color=CXF8EDEB);
    density size_of_an_avalanche / type=kernel lineattrs=(color=black thickness=2);
    xaxis label="avalanche size";
    yaxis label="frequency";
    title "avalanche size frequency";
run;

proc sgplot data=regression;
    scatter x=x y=y / markerattrs=(symbol=circle color=black)
    			legendlabel="avalanche";
    series x=x y=yhat / lineattrs=(color=CXFEC5BB thickness=2)
            legendlabel="OLS";
    xaxis label="avalanche size (log)";
    yaxis label="frequency (log %)";
    title "avalanche size frequency and OLS";
run;
