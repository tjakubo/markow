set autoscale 
set terminal windows
set key right bottom
set grid 

plot "points.out" using 1 title "1,1" with lines, \
 "points.out" using 2 title "1,2" with lines, \
 "points.out" using 3 title "1,3" with lines, \
 "points.out" using 4 title "2,1" with lines, \
 "points.out" using 5 title "2,2" with lines, \
 "points.out" using 6 title "2,3" with lines, \
 "points.out" using 7 title "3,1" with lines, \
 "points.out" using 8 title "3,2" with lines, \
 "points.out" using 9 title "3,3" with lines, \
 "points.out" using 10 title "4,1" with lines, \
 "points.out" using 11 title "4,2" with lines, \
 "points.out" using 12 title "4,3" with lines
 pause -1