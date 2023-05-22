*Importing The Data;
title "Data1";
data Data1;
infile "/home/u63295601/CW2/Melbourne_housing_2000data_WilsonWU.csv" firstobs=2 delimiter=',';
input Price Distance Bedroom Bathroom CarSpace Landsize BuildingArea YearBuilt Regionname$ Date$;
ln_Price=log(Price); 
ln_Landsize =log(Landsize); 
ln_BuildingArea =log(BuildingArea); 
ln_Distance = log(Distance); 
run;

*Prediction to be inputted;
title "Input Results To Be Predicted";
data new;
  input 
  Distance Bedroom Bathroom CarSpace Landsize BuildingArea YearBuilt;
  datalines;
  16 3 2 2 770 200 2001
;
run;

*Classifying Houses By Price;
Data Data2;
	Set Data1;
	IF Price < 750000 THEN Price_Cat = "Cheap";
	ELSE IF 750000 <= Price <= 1750000 THEN Price_Cat = "Moderate";
	ELSE IF 1750000 < Price THEN Price_Cat = "Expensive";
run; 


*Frequency Of House Prices By Region;
proc SGPLOT data = Data2;
	vbar Regionname/group=Price_Cat ;
	 title 'Frequency Of Different House Prices In Each Region';
run;

*Average House Price For Each Region;
proc sgplot data=Data1;
    title"Mean House Cost In Each Region";
    vbar Regionname / response=Price stat=mean colorstat=mean colorresponse=Price COLORMODEL=(Green Yellow Red);
run;

*EDA Of Price Varaible;
title"Price EDA & Histogram"; 
proc univariate;
	var Price; 
	histogram/normal;
run;

*Showing Why We Apply Logarithmic Function To Data;
title "Landsize V ln_Landsize";
proc univariate;
	var Landsize;
	histogram/normal;
	
proc univariate;
	var ln_Landsize;
	histogram/normal;
run;

*Finding PMCC Of Data Varibles;
title "Product Moment Correlation Coeffiecnt (PMCC)";
proc corr data=Data1;
	var Price Distance Bedroom Bathroom Carspace Landsize BuildingArea YearBuilt
	ln_Price ln_Landsize ln_BuildingArea ln_Distance;
run;

*Showing Correlation Between ln_Price & Building Area;
title "ln_Price V Building Area";	
proc sgplot data=data1
     noautolegend;
  reg x=BuildingArea y=ln_Price/ markerattrs=(size=10 symbol=CircleFilled color="Rose");
run;

*Showing Correlation Between ln_Price & Amonunt Of Bathrooms;
title "ln_Price V Bathroom";	
proc sgplot data=data1
     noautolegend;
  reg x=Bathroom y=ln_Price/ markerattrs=(size=10 symbol=CircleFilled color="Purple");;
run;

*Creating Average ln_Price By Year Table;
title"Does Year Built Effect Price";
proc sql; 
	create table want as
	select YearBuilt, avg(ln_Price) as average_sales
	from Data1
	group by YearBuilt
	order by YearBuilt;
quit;

*Does Year Built Effect Price With Outlier, Graphic 1;
proc print data=want;
title "ln_Price V YearBuilt With Outlier";	
proc sgplot data=want
     noautolegend;
  series x=YearBuilt y=average_sales;
run;

*Does Year Built Effect Price With Outlier, Graphic 2;
title "ln_Price V YearBuilt With Outlier";	
proc sgplot data=data1
     noautolegend;
  reg x=YearBuilt y=ln_Price;
run;

*Deleting Outlier;
data want;
    set want;
    if YearBuilt = 1196 then delete;
run;

*Deleting Outlier;
data data3;
    set data1;
    if YearBuilt = 1196 then delete;
run;

*Does Year Built Effect Price Without Outlier, Graphic 1;
title "ln_Price V By Year Without Outlier";	
proc sgplot data=want
     noautolegend;
  series x=YearBuilt y=average_sales;
run;

*Does Year Built Effect Price Without Outlier, Graphic 2;
title"ln_Price V YearBuilt Without Outlier";
proc sgplot data=data3
     noautolegend;
  reg x=YearBuilt y=ln_Price;
run;

*Adding House Price Going To Be Predicted To Data Set;
title "Prediction + Dataset";
data prediction;
	set Data1 new;
run;

*Preidcting House Price Using Regression Model;
title "Regression Model";
proc reg data=prediction;
	model ln_price = Distance Bedroom Bathroom CarSpace Landsize BuildingArea YearBuilt/p cli clm;
run; 

