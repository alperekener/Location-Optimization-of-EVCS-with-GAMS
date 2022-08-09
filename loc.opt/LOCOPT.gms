sets
v vehicles /car1, car2, car3/
t time horizon /morning,noon,evening/
j candidate locations /basaksehir, besiktas, kadikoy, cekmekoy/
;

scalar
R_initial_Car1 amount of initial charge (km) of vehicle car1 /20/
R_initial_Car2 amount of initial charge (km) of vehicle car2 /50/
R_initial_Car3 amount of initial charge (km) of vehicle car3 /60/
;


parameters
q(j) capacity of the candidate locations
/basaksehir 8
 besiktas 15
 kadikoy 15
 cekmekoy 10/
 
k(v) battery capacity (km) of the vehicles
/car1 100
 car2 100
 car3 100/;
 
table n(v,t) distance to target location
      morning    noon    evening
car1  16         10      5
car2  35         11      38
car3  21         31      17
;

table d(v,t,j) the distance between the location of v in period t and location j
                basaksehir  besiktas  kadikoy  cekmekoy
car1.morning    15          21        25       56
car1.noon       15          15        18       49
car1.evening    15          21        25       56
car2.morning    10          25        38       52
car2.noon       34          12        8        17
car2.evening    43          20        5        33
car3.morning    53          26        12       29
car3.noon       40          14        11       29
car3.evening    60          38        31       17 ;

table e(v,t,j) the distance between location j and destination
                basaksehir  besiktas  kadikoy  cekmekoy
car1.morning    16          15        17       52
car1.noon       16          21        25       58
car1.evening    16          21        25       58
car2.morning    44          12        13       36
car2.noon       44          25        7        36
car2.evening    12          21        38       54
car3.morning    38          19        11       30
car3.noon       59          40        35       19
car3.evening    52          36        20       29 ;

variable
Z objective function ;

positive variable
r(v,t) amount of current charge (km) of vehicle v in period t
a(v,t) amount of charge (km) that vehicle v receives in period t
p The minimum number of the electic charge stations
;

binary variable
x(v,t,j) whether v vehicle is charging in period
y(j) whether to open a charging station at candidate location j
;

equation
objective To minimize the distance of any vehicle from any charging station at any time.
constraint1 A vehicle cannot be charged at more than one station at the same time.
constraint2 Every vehicle must be charged at least once a day.
constraint3 In order for charging station must first be opened at that location.
constraint4 If the capacity of the station is full vehicles cannot be charged there.
constraint5 The number of stations opened should be the minimum amount.
constraint6 Charge received from a station cannot exceed the charge capacity of the vehicle 
constraint7 Vehicles cannot be discharged
constraint8 Vehicles should be able to go to the station if needed.
constraint9 The charge value is 0 if we are not going to visit location j
constraint10 If the range is not enough it indicates that we have to go to the charging station
constraint11 Current range to decrease by the distance we travel
constraint12 The initial available range amounts of car1
constraint13 The initial available range amounts of car2
constraint14 The initial available range amounts of car3
;


objective.. Z =e= sum((v,t,j),d(v,t,j)*x(v,t,j));

constraint1(v,t).. sum(j,x(v,t,j)) =l= 1;
constraint2(v).. sum((t,j),x(v,t,j)) =g= 1;
constraint3(v,t,j).. x(v,t,j) =l= y(j);
constraint4(t,j).. sum(v,x(v,t,j)) =l= q(j)*y(j);
constraint5.. sum((v,t,j),x(v,t,j)) =l= p;
constraint6(v,t,j).. r(v,t)+a(v,t)-(d(v,t,j)*x(v,t,j)) =l= k(v);
constraint7(v,t).. a(v,t) =g= 0;
constraint8(v,t,j).. r(v,t) =g= d(v,t,j)*x(v,t,j);
constraint9(v,t).. a(v,t) =l= k(v)*sum(j,x(v,t,j));
constraint10(v,t).. r(v,t)+a(v,t)-sum(j,((e(v,t,j)+d(v,t,j))*x(v,t,j)))-(n(v,t)*(1-sum(j,x(v,t,j)))) =g= 0;
constraint11(v,t+1).. r(v,t+1) =e= r(v,t)+a(v,t)-sum(j,((e(v,t,j)+d(v,t,j))*x(v,t,j)))-(n(v,t)*(1-sum(j,x(v,t,j)))) ;
constraint12.. r('car1','morning') =e= R_initial_Car1;
constraint13.. r('car2','morning') =e= R_initial_Car2;
constraint14.. r('car3','morning') =e= R_initial_Car3;


model LOCOPT /all/;
solve LOCOPT using MIP minimizing Z;
display x.l,r.l,a.l,p.l,y.l;











