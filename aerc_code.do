clear
clear matrix
*set mem 1g
set more off
****************************************

*use aerc1.dta, clear

use hh_base_2011.dta, clear
* to merge the household member data
drop country_name count0 country_code distr0 regio0 vil_n0 urban0
duplicates tag hh_code, gen(c1)
drop if c1 == 1
gen u_hh_fo = hh_code*10000 + fo_code
drop c1
save hh_base_2011_n, replace

*years of membership in the fo
egen years_fo = rowtotal(a1_1c a1_2c a1_3c)
egen assist_12m = rowmean( a2_1f a2_2f a2_3f a2_6f a2_7f)

rename a2_1f assist_tech
rename a2_2f assist_credit
rename a2_3f assist_cash
rename a2_7f assist_stor


 
*years_fo  assist_12m  land land_farm hhsize sex_hd age_hd educ_hd 
*maiz_areat maiz_hvstt rice_areat rice_hvstt cowp_areat cowp_hvstt
*maiz_qtys_s1t  maiz_sale_s1t  rice_qtys_s1t  rice_sale_s1t mill_qtys_s1t  mill_sale_s1t
*sorg_qtys_s1t  sorg_sale_s1t
/*
a2_1f  availability of technical assistance during past 12 months    [ cov1 for psmatch
a2_2f availability of input credit during past 12 months
a2_3f availability of cash loans for agric
a2_6f availability of selling assistance during past 12 months
a2_7f availability of storage assistance during past 12 months    */

*b1_1a  total land owned, *b1_1b  units of land owned by hh 
rename b1_1a land

*b1_2a land area for ag prodn during season, *b1_2b units of land for prodn
rename b1_2a land_farm

/* j1 household size
j2_1c sex of hh_head
j2_1e age of hh_head
j2_1f educ of hh_head  */

rename j1 hhsize
rename j2_1c sex_hd
rename j2_1e age_hd
rename j2_1f educ_hd


egen food_exp = rowtotal(g1_1 g1_2 g1_3 g1_4 g1_5 g1_6 g1_7 g1_8 g1_9 g1_10 g1_11 g1_12 g1_13 g1_14 g1_15 g1_16)
egen nfood_exp = rowtotal(g2 g3_1 g3_2 g3_3 g3_4 g3_5 g3_6 g3_7 g3_8)


*b7_0a  (crop_type grown - maize, rice, cowpea,  g_nut cassava, yam, ) dummies for crop types
/*  b7_0c farm size planted , b7_0d  area unit of farm planted, b7_0e  qty harvested , b7_0f weight unit   */

gen maiz = 1 if b7_0a ==1 
replace maiz = 0 if b7_0a != 1

gen rice = 1 if b7_0a == 14
replace rice = 0 if b7_0a  != 14

gen sorg = 1 if b7_0a == 2
replace sorg = 0 if b7_0a  != 2

gen mill = 1 if b7_0a == 5
replace mill = 0 if b7_0a  != 5

gen cowp = 1 if b7_0a == 24
replace cowp = 0 if b7_0a  != 24

/* gen cass = 1 if b7_0a = 9
replace cass = 0 if b7_0a  != 9

gen yam = 1 if b7_0a = 31
replace yam = 0 if b7_0a  != 31    */

gen maiz_area = b7_0c if maiz == 1     //  * maize area
replace maiz_area = 0 if maiz == 0 

gen sorg_area = b7_0c if sorg == 1     //  * sorg area
replace sorg_area = 0 if sorg == 0 

gen mill_area = b7_0c if mill == 1     //  * millet area
replace mill_area = 0 if mill == 0 

gen rice_area = b7_0c if rice == 1     //  * rice area
replace rice_area = 0 if rice == 0 

gen cowp_area = b7_0c if cowp == 1     //  * cowpea area
replace cowp_area = 0 if cowp == 0 

/* gen yam_area = b7_0c if yam == 1     //  * yam area
replace yam_area = 0 if yam == 0 

gen cass_area = b7_0c if cass == 1     //  * cass area
replace cass_area = 0 if cass == 0   */

/*
use fo_base_2011.dta, clear
use fo_follow_2014.dta, clear  */
/* Key vars for 1st primary analysis  */
{
/*
a1_1a which hh member is part of fo
a1_1c years of membership  (total yrs of membership of all registred members) 
a1_1d composition of fo (males, females or mixed)

a1_2a  which hh member is part of fo
a1_2c  years of membership  (total yrs of membership of all registred members) 
a1_2d composition of fo (males, females or mixed)

a1_3a  which hh member is part of fo
a1_3c  years of membership  (total yrs of membership of all registred members)
a1_3d  composition of fo (males, females or mixed)

a2_1f  availability of technical assistance during past 12 months    [ cov1 for psmatch
a2_2f availability of input credit during past 12 months
a2_3f availability of cash loans for agric
a2_6f availability of selling assistance during past 12 months
a2_7f availability of storage assistance during past 12 months    */
}
*

* crop 1 season 1 harvests obtained
local listhvsts "maiz sorg mill rice cowp"
foreach x of local listhvsts {
gen `x'_hvst = b7_0e if `x' == 1 & b7_0f == 2    // * 
replace `x'_hvst  = 0 if `x' == 0 
replace `x'_hvst  = b7_0e*100 if `x' ==1 & b7_0f == 3 
replace `x'_hvst  = b7_0e*90 if `x' ==1 & b7_0f == 4
replace `x'_hvst  = b7_0e*50 if `x' ==1 & b7_0f == 5
replace `x'_hvst  = b7_0e*30 if `x' ==1 & b7_0g < 80 &  b7_0g != . 
replace `x'_hvst  = b7_0e*120 if `x' ==1 & b7_0g > 80 &  b7_0g < 200
}
*

 
/*
b7_1a  (crop_type grown - maize, cassava, rice, cowpea, yam, g_nut)
create dummies for crop types (crop 2)
b7_1c farm size planted  (crop 2) , b7_1d  area unit of farm planted  (crop 2), b7_1e  qty harvested, b7_1f weight unit  */

*crop 2 season 1 
gen maiz1 = 1 if b7_1a ==1 
replace maiz1 = 0 if b7_1a != 1

gen sorg1 = 1 if b7_1a == 2
replace sorg1 = 0 if b7_1a  != 2

gen mill1 = 1 if b7_1a == 5
replace mill1 = 0 if b7_1a  != 5

gen rice1 = 1 if b7_1a == 14
replace rice1 = 0 if b7_1a  != 14

gen cowp1 = 1 if b7_1a == 24
replace cowp1 = 0 if b7_1a  != 24

/* gen cass1 = 1 if b7_1a = 9
replace cass1 = 0 if b7_1a  != 9

gen yam1 = 1 if b7_1a = 31
replace yam1 = 0 if b7_1a  != 31  */
 
gen maiz_area1 = b7_1c if maiz1 == 1     //  * maize area  crop2 (note its 1 here)
replace maiz_area1 = 0 if maiz1 == 0 

gen sorg_area1 = b7_1c if sorg1 == 1     //  * sorg area crop2 (note its 1 here)
replace sorg_area1 = 0 if sorg1 == 0 

gen mill_area1 = b7_1c if mill1 == 1     //  * millet area  crop2 (note its 1 here)
replace mill_area1 = 0 if mill1 == 0 

gen rice_area1 = b7_1c if rice1 == 1     //  * rice area crop2 (note its 1 here)
replace rice_area1 = 0 if rice1 == 0 

gen cowp_area1 = b7_1c if cowp1 == 1     //  * cowpea area crop2 (note its 1 here)
replace cowp_area1 = 0 if cowp1 == 0 

/* gen yam_area1 = b7_1c if yam1 == 1     //  * yam area  crop2 (note its 1 here)
replace yam_area1 = 0 if yam1 == 0 

gen cass_area1 = b7_1c if cass1 == 1     //  * cass area  crop2 (note its 1 here)
replace cass_area1 = 0 if cass1 == 0    */

local listhvsts1 "maiz sorg mill rice cowp "
foreach x of local listhvsts1{
gen `x'_hvst1 = b7_1e if `x'1 == 1 & b7_1f == 2    // * 
replace `x'_hvst1  = 0 if `x'1 == 0 
replace `x'_hvst1  = b7_1e*100 if `x'1 ==1 & b7_1f == 3 
replace `x'_hvst1  = b7_1e*90 if `x'1 ==1 & b7_1f == 4
replace `x'_hvst1  = b7_1e*50 if `x'1 ==1 & b7_1f == 5
replace `x'_hvst1  = b7_1e*30 if `x'1 ==1 & b7_1g < 80 &  b7_1g != . 
replace `x'_hvst1  = b7_1e*120 if `x'1 ==1 & b7_1g > 80 &  b7_1g < 200
 
}
*


/*  
b7_2a  (crop_type grown - maize, cassava, rice, cowpea, yam, g_nut)
create dummies for crop types (crop 3)
b7_2c farm size planted  (crop 3), b7_2d  area unit of farm planted  (crop 3), b7_2e  qty harvested, b7_2f weight unit  */

gen maiz2 = 1 if b7_2a ==1 
replace maiz2 = 0 if b7_2a != 1

gen sorg2 = 1 if b7_2a == 2
replace sorg2 = 0 if b7_2a  != 2

gen mill2 = 1 if b7_2a == 5
replace mill2 = 0 if b7_2a  != 5

gen rice2 = 1 if b7_2a == 14
replace rice2 = 0 if b7_2a  != 14

gen cowp2 = 1 if b7_2a == 24
replace cowp2 = 0 if b7_2a  != 24

/* gen cass2 = 1 if b7_2a = 9
replace cass2 = 0 if b7_2a  != 9

gen yam2 = 1 if b7_2a = 31
replace yam2 = 0 if b7_2a  != 31  */
 
gen maiz_area2 = b7_2c if maiz2 == 1     //  * maize area  crop3 (note its 2 here)
replace maiz_area2 = 0 if maiz2 == 0 

gen sorg_area2 = b7_2c if sorg2 == 1     //  * sorg area crop3 (note its 2 here)
replace sorg_area2 = 0 if sorg2 == 0 

gen mill_area2 = b7_2c if mill2 == 1     //  * millet area  crop3 (note its 2 here)
replace mill_area2 = 0 if mill2 == 0 

gen rice_area2 = b7_2c if rice2 == 1     //  * rice area crop3 (note its 2 here)
replace rice_area2 = 0 if rice2 == 0 

gen cowp_area2 = b7_2c if cowp2 == 1     //  * cowpea area crop3 (note its 2 here)
replace cowp_area2 = 0 if cowp2 == 0 

/* gen yam_area2 = b7_2c if yam2 == 1     //  * yam area  crop3 (note its 2 here)
replace yam_area2 = 0 if yam2 == 0 

gen cass_area2 = b7_2c if cass2 == 1     //  * cass area  crop3 (note its 2 here)
replace cass_area2 = 0 if cass2 == 0     */


* for the harvested areas for crop3 (crop 2 here)
 local listcrp3 "maiz sorg mill rice cowp"
 foreach x of local listcrp3{
 gen `x'_hvst2 = b7_2e if `x'2 == 1 & b7_2f == 2 
 replace `x'_hvst2 = 0 if `x'2 == 0 
 replace `x'_hvst2 = b7_2e*100  if `x'2== 1 & b7_2f == 3
 replace `x'_hvst2 = b7_2e*90   if `x'2== 1 & b7_2f == 4
 replace `x'_hvst2 = b7_2e*50  if `x'2== 1 & b7_2f == 5
 replace `x'_hvst2 = b7_2e*30 if `x'2== 1 & b7_2g < 80 & b7_1g != .
replace `x'_hvst2  = b7_2e*120 if `x'2==1 & b7_1g > 80 &  b7_1g < 200 
}
*

*compiling the values for all the crops
foreach x of local listcrp3{
egen `x'_areat = rowtotal(`x'_area `x'_area1 `x'_area2)
egen  `x'_hvstt = rowtotal(`x'_hvst `x'_hvst1 `x'_hvst2)
}
*



/* input cost data would be incorporated
 -labor use and labor costs
 -chemical input use and costs    */

*sales data:
/* b11_0a  crop type (crop 1 season 1)
b11_0b  qty sold of crop1 in season1 
b11_0c  unit of the quantity sold
b11_0d  kg equivalent of other weight category

b11_0f   total sales of crop1 in season1 (ghc)
b11_0h   total selling costs of crp1 in season 1 */

* sales for crop 1 season 1
gen maiz_s = 1 if b11_0a ==1 
replace maiz_s = 0 if b11_0a != 1

gen sorg_s = 1 if b11_0a == 2
replace sorg_s = 0 if b11_0a  != 2

gen mill_s = 1 if b11_0a == 5
replace mill_s = 0 if b11_0a  != 5

gen rice_s = 1 if b11_0a == 14
replace rice_s = 0 if b11_0a  != 14

gen cowp_s = 1 if b11_0a == 24
replace cowp_s = 0 if b11_0a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */

local listcrps "maiz sorg mill rice cowp"
foreach x of local listcrps {
gen `x'_qtys = b11_0b if `x'_s == 1
replace `x'_qtys = 0 if `x'_s == 0
replace `x'_qtys  = b11_0b*100  if `x'_s== 1 & b11_0c == 3
replace `x'_qtys = b11_0b*90   if `x'_s== 1 & b11_0c == 4
replace `x'_qtys = b11_0b*50   if `x'_s== 1 & b11_0c == 5
replace `x'_qtys = b11_0b*30   if `x'_s== 1 & b11_0d < 80 & b11_0d != .
replace `x'_qtys  = b11_0b*120  if `x'_s==1 & b11_0d > 80 &  b11_0d < 400  

gen `x'_sales = b11_0f if  `x'_s== 1
}
*

/*  

b11_1a    crop 2 (season 1) 
b11_1b  qty sold of crop2 in season1 
b11_1c  unit of the quantity sold (crop 2)
b11_1d  kg equivalent of other weight category  (crop 2)

b11_1f   total sales of crop1 in season1 (ghc)   (crop 2)
b11_1h   total selling costs of crp1 in season 1  (crop 2)  */

*sales for crop 2 season 1
gen maiz_s1 = 1 if b11_1a ==1 
replace maiz_s1 = 0 if b11_1a != 1

gen sorg_s1 = 1 if b11_1a == 2
replace sorg_s1 = 0 if b11_1a  != 2

gen mill_s1 = 1 if b11_1a == 5
replace mill_s1 = 0 if b11_1a  != 5

gen rice_s1 = 1 if b11_1a == 14
replace rice_s1 = 0 if b11_1a  != 14

gen cowp_s1 = 1 if b11_1a == 24
replace cowp_s1 = 0 if b11_1a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */

local listcrps2 "maiz sorg mill rice cowp"
foreach x of local listcrps2 {
gen `x'_qtys1 = b11_1b if `x'_s1 == 1
replace `x'_qtys1 = 0 if `x'_s1 == 0
replace `x'_qtys1  = b11_1b*100  if `x'_s1== 1 & b11_1c == 3
replace `x'_qtys1 = b11_1b*90   if `x'_s1== 1 & b11_1c == 4
replace `x'_qtys1 = b11_1b*50   if `x'_s1== 1 & b11_1c == 5
replace `x'_qtys1 = b11_1b*30   if `x'_s1== 1 & b11_1d < 80 & b11_1d != .
replace `x'_qtys1  = b11_1b*120  if `x'_s1==1 & b11_1d > 80 &  b11_1d < 400  

gen `x'_sales1 = b11_1f if  `x'_s1== 1
}
*

/*
b11_2b  qty sold of crop2 in season1 
b11_2c  unit of the quantity sold (crop 3)
b11_2d  kg equivalent of other weight category  (crop 3)

b11_2f   total sales of crop1 in season1 (ghc)   (crop 3)
b11_2h   total selling costs of crp1 in season 1  (crop 3)  */

*sales for crop 3 season 1
gen maiz_s2 = 1 if b11_2a ==1 
replace maiz_s2 = 0 if b11_2a != 1

gen sorg_s2 = 1 if b11_2a == 2
replace sorg_s2 = 0 if b11_2a  != 2

gen mill_s2 = 1 if b11_2a == 5
replace mill_s2 = 0 if b11_2a  != 5

gen rice_s2 = 1 if b11_2a == 14
replace rice_s2 = 0 if b11_2a  != 14

gen cowp_s2 = 1 if b11_2a == 24
replace cowp_s2 = 0 if b11_2a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */


local listcrps3 "maiz sorg mill rice cowp"
foreach x of local listcrps3 {
gen `x'_qtys2 = b11_2b if `x'_s2 == 1
replace `x'_qtys2 = 0 if `x'_s2 == 0
replace `x'_qtys2  = b11_2b*100  if `x'_s2== 1 & b11_2c == 3
replace `x'_qtys2 = b11_2b*90   if `x'_s2== 1 & b11_2c == 4
replace `x'_qtys2 = b11_2b*50   if `x'_s2== 1 & b11_2c == 5
replace `x'_qtys2 = b11_2b*30   if `x'_s2== 1 & b11_2d < 80 & b11_2d != .
replace `x'_qtys2  = b11_2b*120  if `x'_s2==1 & b11_2d > 80 &  b11_2d < 400  

gen `x'_sales2 = b11_2f if  `x'_s2== 1
}
*

local listcrps_1 "maiz sorg mill rice cowp"
foreach x of local listcrps_1 {
egen `x'_qtys_s1t  = rowtotal(`x'_qtys  `x'_qtys1 `x'_qtys2)
egen `x'_sales_s1t = rowtotal(`x'_sales  `x'_sales1  `x'_sales2)
}
*


 /*season  2 */
 /* b11_5a
b11_5b  qty sold of crop1 in season2 
b11_5c  unit of the quantity sold
b11_5d  kg equivalent of other weight category

b11_5f   total sales of crop1 in season2 (ghc)
b11_5h   total selling costs of crp1 in season 1   */


*sales for season 2 crop 1
gen maiz_s21 = 1 if b11_5a ==1 
replace maiz_s21 = 0 if b11_5a != 1

gen sorg_s21 = 1 if b11_5a == 2
replace sorg_s21 = 0 if b11_5a  != 2

gen mill_s21 = 1 if b11_5a == 5
replace mill_s21 = 0 if b11_5a  != 5

gen rice_s21 = 1 if b11_5a == 14
replace rice_s21 = 0 if b11_5a  != 14

gen cowp_s21 = 1 if b11_5a == 24
replace cowp_s21 = 0 if b11_5a  != 24

/* gen yam_s21 = 1 if b11_5a = 31
replace yam_s21 = 0 if b11_5a  != 31

gen cass_s21 = 1 if b11_5a = 9
replace cass_s21 = 0 if b11_5a  != 9 */

local listcrp_s "maiz sorg mill rice cowp"
foreach x of local listcrp_s {
gen `x'_qtys21 = b11_5b if `x'_s21 == 1
replace `x'_qtys21 = 0  if `x'_s21 == 0
replace `x'_qtys21 = b11_5b*100  if `x'_s21== 1 & b11_5c == 3
replace `x'_qtys21 = b11_5b*90   if `x'_s21== 1 & b11_5c == 4
replace `x'_qtys21 = b11_5b*50   if `x'_s21== 1 & b11_5c == 5
replace `x'_qtys21 = b11_5b*30   if `x'_s21== 1 & b11_5d < 80 & b11_5d != .
replace `x'_qtys21 = b11_5b*120  if `x'_s21==1 & b11_5d > 80 &  b11_5d < 400  

gen `x'_sales21 = b11_5f if  `x'_s21== 1
}
*

/*
b11_6a
b11_6b  qty sold of crop2 in season2 
b11_6c  unit of the quantity sold (crop 2)
b11_6d  kg equivalent of other weight category  (crop 2)

b11_6f   total sales of crop1 in season2 (ghc)   (crop 2)
b11_6h   total selling costs of crp1 in season 1  (crop 2)   */

*sales for season 2 crop 2
gen maiz_s22 = 1 if b11_6a ==1 
replace maiz_s22 = 0 if b11_6a != 1

gen sorg_s22 = 1 if b11_6a == 2
replace sorg_s22 = 0 if b11_6a  != 2

gen mill_s22 = 1 if b11_6a == 5
replace mill_s22 = 0 if b11_6a  != 5

gen rice_s22 = 1 if b11_6a == 14
replace rice_s22 = 0 if b11_6a  != 14

gen cowp_s22 = 1 if b11_6a == 24
replace cowp_s22 = 0 if b11_6a  != 24

/* gen yam_s22 = 1 if b11_6a = 31
replace yam_s22 = 0 if b11_6a  != 31

gen cass_s22 = 1 if b11_6a = 9
replace cass_s22 = 0 if b11_6a  != 9 */

local listcrp_s2 "maiz sorg mill rice cowp"
foreach x of local listcrp_s2 {
gen `x'_qtys22 = b11_6b if `x'_s22 == 1
replace `x'_qtys22 = 0  if `x'_s22 == 0
replace `x'_qtys22 = b11_6b*100  if `x'_s22== 1 & b11_6c == 3
replace `x'_qtys22 = b11_6b*90   if `x'_s22== 1 & b11_6c == 4
replace `x'_qtys22 = b11_6b*50   if `x'_s22== 1 & b11_6c == 5
replace `x'_qtys22 = b11_6b*30   if `x'_s22== 1 & b11_6d < 80 &  b11_6d != .
replace `x'_qtys22 = b11_6b*120  if `x'_s22==1  & b11_6d > 80 &  b11_6d < 400  

gen `x'_sales22 = b11_6f if  `x'_s22== 1
}
*

/*

b11_7a
b11_7b  qty sold of crop2 in season2 
b11_7c  unit of the quantity sold (crop 3)
b11_7d  kg equivalent of other weight category  (crop 3)

b11_7f   total sales of crop1 in season2 (ghc)   (crop 3)
b11_7h   total selling costs of crp1 in season 1  (crop 3)   */

*sales for season 2 crop 3
gen maiz_s23 = 1 if b11_7a ==1 
replace maiz_s23 = 0 if b11_7a != 1

gen sorg_s23 = 1 if b11_7a == 2
replace sorg_s23 = 0 if b11_7a  != 2

gen mill_s23 = 1 if b11_7a == 5
replace mill_s23 = 0 if b11_7a  != 5

gen rice_s23 = 1 if b11_7a == 14
replace rice_s23 = 0 if b11_7a  != 14

gen cowp_s23 = 1 if b11_7a == 24
replace cowp_s23 = 0 if b11_7a  != 24

/* gen yam_s23 = 1 if b11_7a = 31
replace yam_s23 = 0 if b11_7a  != 31

gen cass_s23 = 1 if b11_7a = 9
replace cass_s23 = 0 if b11_7a  != 9  */

local listcrps23 "maiz sorg mill rice cowp"
foreach x of local listcrps23{
gen `x'_qtys23 = b11_7b if `x'_s23 == 1
replace `x'_qtys23 = 0  if `x'_s23 == 0
replace `x'_qtys23 = b11_7b*100  if `x'_s23== 1 & b11_7c == 3
replace `x'_qtys23 = b11_7b*90   if `x'_s23== 1 & b11_7c == 4
replace `x'_qtys23 = b11_7b*50   if `x'_s23== 1 & b11_7c == 5
replace `x'_qtys23 = b11_7b*30   if `x'_s23== 1 & b11_7d < 80 &  b11_7d != .
replace `x'_qtys23 = b11_7b*120  if `x'_s23==1  & b11_7d > 80 &  b11_7d < 400  

gen `x'_sales23 = b11_7f if  `x'_s23== 1
}
*
local listcrps_11 "maiz sorg mill rice cowp"
foreach x of local listcrps_11 {
egen `x'_qtys_s2t  = rowtotal(`x'_qtys21  `x'_qtys22  `x'_qtys23)
egen `x'_sales_s2t = rowtotal(`x'_sales21  `x'_sales22  `x'_sales23)
}
*  maiz_sales_s2t maiz_sales_s1t
	  
	  
*Data on market participation rates
/* b12_1b  proportion sold  immediate  (crop 1)
b12_1c  proportion sold  later      (crop 1)
b12_1d  lost (spoilage or pest)     (crop 1)
b12_1e  retained for hh             (crop 1) 
b12_1f  retained for farm           (crop 1)

b12_1p    proportion sold via fo       (crop 1)
b12_1q    proportion sold at farmgate  (crop 1)
b12_1r    proportion sold at market    (crop 1)

b12_1s    proportion sold within 4wks  (crop 1)
b12_1t    proportion sold later 4wks   (crop 1)  */

*marketing channels and participation
gen maiz_m1 = 1 if b12_1a  ==1 
replace maiz_m1 = 0 if b12_1a != 1

gen sorg_m1 = 1 if b12_1a == 2
replace sorg_m1 = 0 if b12_1a  != 2

gen mill_m1 = 1 if b12_1a == 5
replace mill_m1 = 0 if b12_1a  != 5

gen rice_m1 = 1 if b12_1a == 14
replace rice_m1 = 0 if b12_1a  != 14

gen cowp_m1 = 1 if b12_1a == 24
replace cowp_m1 = 0 if b12_1a  != 24

/* gen cass_m1 = 1 if b12_1a = 9
replace cass_m1 = 0 if b12_1a  != 9

gen yam_m1 = 1 if b12_1a = 31
replace yam_m1 = 0 if b12_1a  != 31  */

local listm_crps "maiz sorg mill rice cowp "
foreach x of local listm_crps{
gen   `x'_sold1 = b12_2b  + b12_2c  if `x'_m1 ==  1
replace  `x'_sold1 = 0      if  `x'_m1 == 0 
gen      `x'_lost1 = b12_2d if  `x'_m1 == 1
replace  `x'_lost1 = 0      if  `x'_m1 == 0 
gen  `x'_ret1 = b12_2e + b12_2f if `x'_m1 == 1
replace `x'_ret1 = 0  if `x'_m1 == 0 
egen `x'_mtot1 = rowtotal( `x'_ret1 `x'_lost1 `x'_sold1)

}
*
foreach x of local listm_crps{
gen `x'_fo1 = b12_1p  if `x'_m1 == 1
replace  `x'_fo1 = 0 if `x'_m1 == 0 
gen `x'_farmg1 = b12_1q  if `x'_m1 == 1
replace  `x'_farmg1 = 0 if `x'_m1 == 0 
gen `x'_mrkt1 = b12_1r  if `x'_m1 == 1
replace  `x'_mrkt1 = 0 if `x'_m1 == 0 

egen `x'_chnn1 = rowtotal(`x'_fo1 `x'_farmg1 `x'_mrkt1)

}
*

*maiz_sold1 rice_sold1 cowp_sold1
*maiz_fo1   rice_fo1   cowp_fo1


/* b12_2b  proportion sold  immediate  (crop 2)
b12_2c  proportion sold  later      (crop 2)
b12_2d  lost (spoilage or pest)     (crop 2)
b12_2e  retained for hh             (crop 2)
b12_2f  retained for farm           (crop 2)
 
b12_2p   proportion sold via fo       (crop 2)
b12_2q   proportion sold at farmgate  (crop 2)
b12_2r   proportion sold at market    (crop 2)

b12_2s    proportion sold within 4wks  (crop 2)
b12_2t    proportion sold later 4wks   (crop 2)  */


gen maiz_m2 = 1 if b12_2a  ==1 
replace maiz_m2 = 0 if b12_2a != 1

gen sorg_m2 = 1 if b12_2a == 2
replace sorg_m2 = 0 if b12_2a  != 2

gen mill_m2 = 1 if b12_2a == 5
replace mill_m2 = 0 if b12_2a  != 5

gen rice_m2 = 1 if b12_2a == 14
replace rice_m2 = 0 if b12_2a  != 14

gen cowp_m2 = 1 if b12_2a == 24
replace cowp_m2 = 0 if b12_2a  != 24

/* gen cass_m2 = 1 if b12_2a == 9
replace cass_m2 = 0 if b12_2a  != 9

gen yam_m2 = 1 if b12_2a == 31
replace yam_m2 = 0 if b12_2a  != 31  */

local listm_crps2 "maiz sorg mill rice cowp"
foreach x of local listm_crps2{
gen   `x'_sold2 = b12_2b  + b12_2c  if `x'_m2 ==  1
replace  `x'_sold2 = 0      if  `x'_m2 == 0 
gen      `x'_lost2 = b12_2d if  `x'_m2 == 1
replace  `x'_lost2 = 0      if  `x'_m2 == 0 
gen  `x'_ret2 = b12_2e + b12_2f if `x'_m2 == 1
replace `x'_ret2 = 0  if `x'_m2 == 0 

egen `x'_mtot2 = rowtotal( `x'_ret2 `x'_lost2 `x'_sold2)
}
*
foreach x of local listm_crps2{
gen `x'_fo2 = b12_2p  if `x'_m2 == 1
replace  `x'_fo2 = 0 if `x'_m2 == 0 
gen `x'_farmg2 = b12_2q  if `x'_m2 == 1
replace  `x'_farmg2 = 0 if `x'_m2 == 0 
gen `x'_mrkt2 = b12_2r  if `x'_m2 == 1
replace  `x'_mrkt2 = 0 if `x'_m2 == 0 

egen `x'_chnn2 = rowtotal(`x'_fo2 `x'_farmg2 `x'_mrkt2)

egen `x'_sold = rowtotal( `x'_sold1 `x'_sold2)
egen `x'_fo   = rowtotal( `x'_fo1    `x'_fo2)

}
*
egen maiz_sales_r1 = rowtotal(maiz_sales_s2t maiz_sales_s1t)

*maiz_sold maiz_fo rice_sold rice_fo
*

rename p4pstatus p4p

save hh_base_2011_n1, replace

*PLACE THE * ON THE NEXT LINE TO RUN JUST THE CODE FOR THE FIRST SURVEY ROUND


*years_fo  assist_12m  land land_farm hhsize sex_hd age_hd educ_hd 
*maiz_areat maiz_hvstt rice_areat rice_hvstt cowp_areat cowp_hvstt
*maiz_qtys_s1t  maiz_sale_s1t  rice_qtys_s1t  rice_sale_s1t mill_qtys_s1t  mill_sale_s1t  sorg_qtys_s1t  sorg_sale_s1t
*maiz_sold maiz_fo rice_sold rice_fo

*DESCRIPTIVE STATS SURVEY 1

bysort p4p: su  years_fo  assist_12m  land land_farm hhsize sex_hd age_hd educ_hd 

bysort p4p: su maiz_areat maiz_hvstt rice_areat rice_hvstt cowp_areat cowp_hvstt  

bysort p4p: su maiz_sold maiz_fo rice_sold rice_fo cowp_sold cowp_fo


/*   Testing mean differences between the variables  
local list5 "years_fo  assist_12m  land land_farm hhsize sex_hd age_hd educ_hd "
foreach x of local list5 {
use hh_base_2011_n1.dta, clear
gen `x'11 = `x' if p4p ==1
gen `x'22 = `x' if p4p ==0
stack `x'11 `x'22, into(`x'_1)
display "`x'- ffwr1"
ttest `x'_1, by(_stack)  unequal
}
*

local list5 "maiz_sold maiz_fo rice_sold rice_fo cowp_sold cowp_fo"
foreach x of local list5 {
use hh_base_2011_n1.dta, clear
gen `x'11 = `x' if p4p ==1
gen `x'22 = `x' if p4p ==0
stack `x'11 `x'22, into(`x'_1)
display "`x'- ffwr1"
ttest `x'_1, by(_stack)  unequal
}
*/



***********************************************************************************************************************************************
***********************************************************************************************************************************************
/*   COMPILING NEEDED VARS FOR FOLLOW UP SURVEY (2013) */
***********************************************************************************************************************************************
***********************************************************************************************************************************************

use hh_follow_2013.dta, clear
 duplicates tag hh_code, gen(c1)
 drop if c1 == 1
gen u_hh_fo = hh_code*10000 + fo_code
drop c1

*years of membership in the fo
egen years_fo_r2 = rowtotal(a1_1c a1_2c a1_3c)
egen assist_12m_r2 = rowmean( a2_1f a2_2f a2_3f a2_6f a2_7f)

rename a2_1f assist_tech_r2
rename a2_2f assist_credit_r2
rename a2_3f assist_cash_r2
rename a2_7f assist_stor_r2


 
*b1_1a  total land owned, *b1_1b  units of land owned by hh 
rename b1_1a land_r2

*b1_2a land area for ag prodn during season, *b1_2b units of land for prodn
rename b1_2a land_farm_r2

/* j1 household size
j2_1c sex of hh_head
j2_1e age of hh_head
j2_1f educ of hh_head  */

rename j1 hhsize_r2
rename j2_1c sex_hd_r2
rename j2_1e age_hd_r2
rename j2_1f educ_hd_r2

egen food_exp_r2 = rowtotal(g1_1 g1_2 g1_3 g1_4 g1_5 g1_6 g1_7 g1_8 g1_9 g1_10 g1_11 g1_12 g1_13 g1_14 g1_15 g1_16)
egen nfood_exp_r2 = rowtotal(g2 g3_1 g3_2 g3_3 g3_4 g3_5 g3_6 g3_7 g3_8)

*years_fo_r2  assist_12m_r2  land_r2 land_farm_r2 hhsize_r2 sex_hd_r2 age_hd_r2 educ_hd_r2 
*maiz_areat_r2 maiz_hvstt_r2 rice_areat_r2 rice_hvstt_r2 cowp_areat_r2 cowp_hvstt_r2
*maiz_qtys_s1t  maiz_sale_s1t  rice_qtys_s1t  rice_sale_s1t mill_qtys_s1t  mill_sale_s1t
*sorg_qtys_s1t  sorg_sale_s1t


*qty produced and harvestd data
gen maiz = 1 if b7_0a ==1 
replace maiz = 0 if b7_0a != 1

gen rice = 1 if b7_0a == 14
replace rice = 0 if b7_0a  != 14

gen sorg = 1 if b7_0a == 2
replace sorg = 0 if b7_0a  != 2

gen mill = 1 if b7_0a == 5
replace mill = 0 if b7_0a  != 5

gen cowp = 1 if b7_0a == 24
replace cowp = 0 if b7_0a  != 24


gen maiz_area = b7_0c if maiz == 1     //  * maize area
replace maiz_area = 0 if maiz == 0 

gen sorg_area = b7_0c if sorg == 1     //  * sorg area
replace sorg_area = 0 if sorg == 0 

gen mill_area = b7_0c if mill == 1     //  * millet area
replace mill_area = 0 if mill == 0 

gen rice_area = b7_0c if rice == 1     //  * rice area
replace rice_area = 0 if rice == 0 

gen cowp_area = b7_0c if cowp == 1     //  * cowpea area
replace cowp_area = 0 if cowp == 0 


* crop 1 season 1 harvests obtained
local listhvsts "maiz sorg mill rice cowp"
foreach x of local listhvsts {
gen `x'_hvst = b7_0e if `x' == 1 & b7_0f == 2    // * 
replace `x'_hvst  = 0 if `x' == 0 
replace `x'_hvst  = b7_0e*100 if `x' ==1 & b7_0f == 3 
replace `x'_hvst  = b7_0e*90 if `x' ==1 & b7_0f == 4
replace `x'_hvst  = b7_0e*50 if `x' ==1 & b7_0f == 5
replace `x'_hvst  = b7_0e*30 if `x' ==1 & b7_0g < 80 &  b7_0g != . 
replace `x'_hvst  = b7_0e*120 if `x' ==1 & b7_0g > 80 &  b7_0g < 200
}
*


gen maiz1 = 1 if b7_1a ==1 
replace maiz1 = 0 if b7_1a != 1

gen sorg1 = 1 if b7_1a == 2
replace sorg1 = 0 if b7_1a  != 2

gen mill1 = 1 if b7_1a == 5
replace mill1 = 0 if b7_1a  != 5

gen rice1 = 1 if b7_1a == 14
replace rice1 = 0 if b7_1a  != 14

gen cowp1 = 1 if b7_1a == 24
replace cowp1 = 0 if b7_1a  != 24

/* gen cass1 = 1 if b7_1a = 9
replace cass1 = 0 if b7_1a  != 9

gen yam1 = 1 if b7_1a = 31
replace yam1 = 0 if b7_1a  != 31  */
 
gen maiz_area1 = b7_1c if maiz1 == 1     //  * maize area  crop2 (note its 1 here)
replace maiz_area1 = 0 if maiz1 == 0 

gen sorg_area1 = b7_1c if sorg1 == 1     //  * sorg area crop2 (note its 1 here)
replace sorg_area1 = 0 if sorg1 == 0 

gen mill_area1 = b7_1c if mill1 == 1     //  * millet area  crop2 (note its 1 here)
replace mill_area1 = 0 if mill1 == 0 

gen rice_area1 = b7_1c if rice1 == 1     //  * rice area crop2 (note its 1 here)
replace rice_area1 = 0 if rice1 == 0 

gen cowp_area1 = b7_1c if cowp1 == 1     //  * cowpea area crop2 (note its 1 here)
replace cowp_area1 = 0 if cowp1 == 0 



local listhvsts1 "maiz sorg mill rice cowp "
foreach x of local listhvsts1{
gen `x'_hvst1 = b7_1e if `x'1 == 1 & b7_1f == 2    // * 
replace `x'_hvst1  = 0 if `x'1 == 0 
replace `x'_hvst1  = b7_1e*100 if `x'1 ==1 & b7_1f == 3 
replace `x'_hvst1  = b7_1e*90 if `x'1 ==1 & b7_1f == 4
replace `x'_hvst1  = b7_1e*50 if `x'1 ==1 & b7_1f == 5
replace `x'_hvst1  = b7_1e*30 if `x'1 ==1 & b7_1g < 80 &  b7_1g != . 
replace `x'_hvst1  = b7_1e*120 if `x'1 ==1 & b7_1g > 80 &  b7_1g < 200
 
}
*


gen maiz2 = 1 if b7_2a ==1 
replace maiz2 = 0 if b7_2a != 1

gen sorg2 = 1 if b7_2a == 2
replace sorg2 = 0 if b7_2a  != 2

gen mill2 = 1 if b7_2a == 5
replace mill2 = 0 if b7_2a  != 5

gen rice2 = 1 if b7_2a == 14
replace rice2 = 0 if b7_2a  != 14

gen cowp2 = 1 if b7_2a == 24
replace cowp2 = 0 if b7_2a  != 24

/* gen cass2 = 1 if b7_2a = 9
replace cass2 = 0 if b7_2a  != 9

gen yam2 = 1 if b7_2a = 31
replace yam2 = 0 if b7_2a  != 31  */
 
gen maiz_area2 = b7_2c if maiz2 == 1     //  * maize area  crop3 (note its 2 here)
replace maiz_area2 = 0 if maiz2 == 0 

gen sorg_area2 = b7_2c if sorg2 == 1     //  * sorg area crop3 (note its 2 here)
replace sorg_area2 = 0 if sorg2 == 0 

gen mill_area2 = b7_2c if mill2 == 1     //  * millet area  crop3 (note its 2 here)
replace mill_area2 = 0 if mill2 == 0 

gen rice_area2 = b7_2c if rice2 == 1     //  * rice area crop3 (note its 2 here)
replace rice_area2 = 0 if rice2 == 0 

gen cowp_area2 = b7_2c if cowp2 == 1     //  * cowpea area crop3 (note its 2 here)
replace cowp_area2 = 0 if cowp2 == 0 

/* gen yam_area2 = b7_2c if yam2 == 1     //  * yam area  crop3 (note its 2 here)
replace yam_area2 = 0 if yam2 == 0 

gen cass_area2 = b7_2c if cass2 == 1     //  * cass area  crop3 (note its 2 here)
replace cass_area2 = 0 if cass2 == 0     */


* for the harvested areas for crop3 (crop 2 here)
 local listcrp3 "maiz sorg mill rice cowp"
 foreach x of local listcrp3{
 gen `x'_hvst2 = b7_2e if `x'2 == 1 & b7_2f == 2 
 replace `x'_hvst2 = 0 if `x'2 == 0 
 replace `x'_hvst2 = b7_2e*100  if `x'2== 1 & b7_2f == 3
 replace `x'_hvst2 = b7_2e*90   if `x'2== 1 & b7_2f == 4
 replace `x'_hvst2 = b7_2e*50  if `x'2== 1 & b7_2f == 5
 replace `x'_hvst2 = b7_2e*30 if `x'2== 1 & b7_2g < 80 & b7_1g != .
replace `x'_hvst2  = b7_2e*120 if `x'2==1 & b7_1g > 80 &  b7_1g < 200 
}
*

*compiling the values for all the crops
foreach x of local listcrp3{
egen `x'_areat_r2 = rowtotal(`x'_area `x'_area1 `x'_area2)
egen  `x'_hvstt_r2 = rowtotal(`x'_hvst `x'_hvst1 `x'_hvst2)
}
*


* sales for crop 1 season 1
gen maiz_s = 1 if b11_0a ==1 
replace maiz_s = 0 if b11_0a != 1

gen sorg_s = 1 if b11_0a == 2
replace sorg_s = 0 if b11_0a  != 2

gen mill_s = 1 if b11_0a == 5
replace mill_s = 0 if b11_0a  != 5

gen rice_s = 1 if b11_0a == 14
replace rice_s = 0 if b11_0a  != 14

gen cowp_s = 1 if b11_0a == 24
replace cowp_s = 0 if b11_0a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */

local list1crps "maiz sorg mill rice cowp"
foreach x of local list1crps {
gen `x'_qtys = b11_0b if `x'_s == 1
replace `x'_qtys = 0 if `x'_s == 0
replace `x'_qtys  = b11_0b*100  if `x'_s== 1 & b11_0c == 3
replace `x'_qtys = b11_0b*90   if `x'_s== 1 & b11_0c == 4
replace `x'_qtys = b11_0b*50   if `x'_s== 1 & b11_0c == 5
replace `x'_qtys = b11_0b*30   if `x'_s== 1 & b11_0d < 80 & b11_0d != .
replace `x'_qtys  = b11_0b*120  if `x'_s==1 & b11_0d > 80 &  b11_0d < 400  

gen `x'_sales = b11_0f if  `x'_s== 1
}
*

/*  

b11_1a    crop 2 (season 1) 
b11_1b  qty sold of crop2 in season1 
b11_1c  unit of the quantity sold (crop 2)
b11_1d  kg equivalent of other weight category  (crop 2)

b11_1f   total sales of crop1 in season1 (ghc)   (crop 2)
b11_1h   total selling costs of crp1 in season 1  (crop 2)  */

*sales for crop 2 season 1
gen maiz_s1 = 1 if b11_1a ==1 
replace maiz_s1 = 0 if b11_1a != 1

gen sorg_s1 = 1 if b11_1a == 2
replace sorg_s1 = 0 if b11_1a  != 2

gen mill_s1 = 1 if b11_1a == 5
replace mill_s1 = 0 if b11_1a  != 5

gen rice_s1 = 1 if b11_1a == 14
replace rice_s1 = 0 if b11_1a  != 14

gen cowp_s1 = 1 if b11_1a == 24
replace cowp_s1 = 0 if b11_1a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */

local list2crps "maiz sorg mill rice cowp"
foreach x of local list2crps {
gen `x'_qtys1 = b11_1b if `x'_s1 == 1
replace `x'_qtys1 = 0 if `x'_s1 == 0
replace `x'_qtys1  = b11_1b*100  if `x'_s1== 1 & b11_1c == 3
replace `x'_qtys1 = b11_1b*90   if `x'_s1== 1 & b11_1c == 4
replace `x'_qtys1 = b11_1b*50   if `x'_s1== 1 & b11_1c == 5
replace `x'_qtys1 = b11_1b*30   if `x'_s1== 1 & b11_1d < 80 & b11_1d != .
replace `x'_qtys1  = b11_1b*120  if `x'_s1==1 & b11_1d > 80 &  b11_1d < 400  

gen `x'_sales1 = b11_1f if  `x'_s1== 1
}
*

/*
b11_2b  qty sold of crop2 in season1 
b11_2c  unit of the quantity sold (crop 3)
b11_2d  kg equivalent of other weight category  (crop 3)

b11_2f   total sales of crop1 in season1 (ghc)   (crop 3)
b11_2h   total selling costs of crp1 in season 1  (crop 3)  */

*sales for crop 3 season 1
gen maiz_s2 = 1 if b11_2a ==1 
replace maiz_s2 = 0 if b11_2a != 1

gen sorg_s2 = 1 if b11_2a == 2
replace sorg_s2 = 0 if b11_2a  != 2

gen mill_s2 = 1 if b11_2a == 5
replace mill_s2 = 0 if b11_2a  != 5

gen rice_s2 = 1 if b11_2a == 14
replace rice_s2 = 0 if b11_2a  != 14

gen cowp_s2 = 1 if b11_2a == 24
replace cowp_s2 = 0 if b11_2a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */


local list3crps "maiz sorg mill rice cowp"
foreach x of local list3crps {
gen `x'_qtys2 = b11_2b if `x'_s2 == 1
replace `x'_qtys2 = 0 if `x'_s2 == 0
replace `x'_qtys2  = b11_2b*100  if `x'_s2== 1 & b11_2c == 3
replace `x'_qtys2 = b11_2b*90   if `x'_s2== 1 & b11_2c == 4
replace `x'_qtys2 = b11_2b*50   if `x'_s2== 1 & b11_2c == 5
replace `x'_qtys2 = b11_2b*30   if `x'_s2== 1 & b11_2d < 80 & b11_2d != .
replace `x'_qtys2  = b11_2b*120  if `x'_s2==1 & b11_2d > 80 &  b11_2d < 400  

gen `x'_sales2 = b11_2f if  `x'_s2== 1
}
*

local listcrps_1 "maiz sorg mill rice cowp"
foreach x of local listcrps_1 {
egen `x'_qtys_s1t_r2   = rowtotal(`x'_qtys  `x'_qtys1 `x'_qtys2)
egen `x'_sales_s1t_r2  = rowtotal(`x'_sales  `x'_sales1  `x'_sales2)
}
*


*sales for season 2 crop 1
gen maiz_s21 = 1 if b11_5a ==1 
replace maiz_s21 = 0 if b11_5a != 1

gen sorg_s21 = 1 if b11_5a == 2
replace sorg_s21 = 0 if b11_5a  != 2

gen mill_s21 = 1 if b11_5a == 5
replace mill_s21 = 0 if b11_5a  != 5

gen rice_s21 = 1 if b11_5a == 14
replace rice_s21 = 0 if b11_5a  != 14

gen cowp_s21 = 1 if b11_5a == 24
replace cowp_s21 = 0 if b11_5a  != 24

/* gen yam_s21 = 1 if b11_5a = 31
replace yam_s21 = 0 if b11_5a  != 31

gen cass_s21 = 1 if b11_5a = 9
replace cass_s21 = 0 if b11_5a  != 9 */

local listcrps "maiz sorg mill rice cowp"
foreach x of local listcrps{
gen `x'_qtys21 = b11_5b if `x'_s21 == 1
replace `x'_qtys21 = 0  if `x'_s21 == 0
replace `x'_qtys21 = b11_5b*100  if `x'_s21== 1 & b11_5c == 3
replace `x'_qtys21 = b11_5b*90   if `x'_s21== 1 & b11_5c == 4
replace `x'_qtys21 = b11_5b*50   if `x'_s21== 1 & b11_5c == 5
replace `x'_qtys21 = b11_5b*30   if `x'_s21== 1 & b11_5d < 80 & b11_5d != .
replace `x'_qtys21 = b11_5b*120  if `x'_s21==1 & b11_5d > 80 &  b11_5d < 400  

gen `x'_sales21 = b11_5f if  `x'_s21== 1
}
*

/*
b11_6a
b11_6b  qty sold of crop2 in season2 
b11_6c  unit of the quantity sold (crop 2)
b11_6d  kg equivalent of other weight category  (crop 2)

b11_6f   total sales of crop1 in season2 (ghc)   (crop 2)
b11_6h   total selling costs of crp1 in season 1  (crop 2)   */

*sales for season 2 crop 2
gen maiz_s22 = 1 if b11_6a ==1 
replace maiz_s22 = 0 if b11_6a != 1

gen sorg_s22 = 1 if b11_6a == 2
replace sorg_s22 = 0 if b11_6a  != 2

gen mill_s22 = 1 if b11_6a == 5
replace mill_s22 = 0 if b11_6a  != 5

gen rice_s22 = 1 if b11_6a == 14
replace rice_s22 = 0 if b11_6a  != 14

gen cowp_s22 = 1 if b11_6a == 24
replace cowp_s22 = 0 if b11_6a  != 24

/* gen yam_s22 = 1 if b11_6a = 31
replace yam_s22 = 0 if b11_6a  != 31

gen cass_s22 = 1 if b11_6a = 9
replace cass_s22 = 0 if b11_6a  != 9 */

local listcrps "maiz sorg mill rice cowp"
foreach x of local listcrps{
gen `x'_qtys22 = b11_6b if `x'_s22 == 1
replace `x'_qtys22 = 0  if `x'_s22 == 0
replace `x'_qtys22 = b11_6b*100  if `x'_s22== 1 & b11_6c == 3
replace `x'_qtys22 = b11_6b*90   if `x'_s22== 1 & b11_6c == 4
replace `x'_qtys22 = b11_6b*50   if `x'_s22== 1 & b11_6c == 5
replace `x'_qtys22 = b11_6b*30   if `x'_s22== 1 & b11_6d < 80 &  b11_6d != .
replace `x'_qtys22 = b11_6b*120  if `x'_s22==1  & b11_6d > 80 &  b11_6d < 400  

gen `x'_sales22 = b11_6f if  `x'_s22== 1
}
*


*sales for season 2 crop 3
gen maiz_s23 = 1 if b11_7a ==1 
replace maiz_s23 = 0 if b11_7a != 1

gen sorg_s23 = 1 if b11_7a == 2
replace sorg_s23 = 0 if b11_7a  != 2

gen mill_s23 = 1 if b11_7a == 5
replace mill_s23 = 0 if b11_7a  != 5

gen rice_s23 = 1 if b11_7a == 14
replace rice_s23 = 0 if b11_7a  != 14

gen cowp_s23 = 1 if b11_7a == 24
replace cowp_s23 = 0 if b11_7a  != 24

/* gen yam_s23 = 1 if b11_7a = 31
replace yam_s23 = 0 if b11_7a  != 31

gen cass_s23 = 1 if b11_7a = 9
replace cass_s23 = 0 if b11_7a  != 9  */

local listcrps23 "maiz sorg mill rice cowp"
foreach x of local listcrps23{
gen `x'_qtys23 = b11_7b if `x'_s23 == 1
replace `x'_qtys23 = 0  if `x'_s23 == 0
replace `x'_qtys23 = b11_7b*100  if `x'_s23== 1 & b11_7c == 3
replace `x'_qtys23 = b11_7b*90   if `x'_s23== 1 & b11_7c == 4
replace `x'_qtys23 = b11_7b*50   if `x'_s23== 1 & b11_7c == 5
replace `x'_qtys23 = b11_7b*30   if `x'_s23== 1 & b11_7d < 80 &  b11_7d != .
replace `x'_qtys23 = b11_7b*120  if `x'_s23==1  & b11_7d > 80 &  b11_7d < 400  

gen `x'_sales23 = b11_7f if  `x'_s23== 1
}
*
local listcrps_1 "maiz sorg mill rice cowp"
foreach x of local listcrps_1 {
egen `x'_qtys_s2t_r2  = rowtotal(`x'_qtys21  `x'_qtys22  `x'_qtys23)
egen `x'_sales_s2t_r2 = rowtotal(`x'_sales21  `x'_sales22  `x'_sales23)
}
*      maiz_sales_s2t maiz_sales_s1t maiz_sales_s2t_r2  maiz_sales_s1t_r2

egen maiz_sales_r2 = rowtotal(maiz_sales_s2t_r2  maiz_sales_s1t_r2) 

*marketing channels and participation
gen maiz_m1 = 1 if b12_1a  ==1 
replace maiz_m1 = 0 if b12_1a != 1

gen sorg_m1 = 1 if b12_1a == 2
replace sorg_m1 = 0 if b12_1a  != 2

gen mill_m1 = 1 if b12_1a == 5
replace mill_m1 = 0 if b12_1a  != 5

gen rice_m1 = 1 if b12_1a == 14
replace rice_m1 = 0 if b12_1a  != 14

gen cowp_m1 = 1 if b12_1a == 24
replace cowp_m1 = 0 if b12_1a  != 24

/* gen cass_m1 = 1 if b12_1a = 9
replace cass_m1 = 0 if b12_1a  != 9

gen yam_m1 = 1 if b12_1a = 31
replace yam_m1 = 0 if b12_1a  != 31  */

local listm_crps "maiz sorg mill rice cowp "
foreach x of local listm_crps{
gen   `x'_sold1 = b12_2b  + b12_2c  if `x'_m1 ==  1
replace  `x'_sold1 = 0      if  `x'_m1 == 0 
gen      `x'_lost1 = b12_2d if  `x'_m1 == 1
replace  `x'_lost1 = 0      if  `x'_m1 == 0 
gen  `x'_ret1 = b12_2e + b12_2f if `x'_m1 == 1
replace `x'_ret1 = 0  if `x'_m1 == 0 
egen `x'_mtot1 = rowtotal( `x'_ret1 `x'_lost1 `x'_sold1)

}
*
foreach x of local listm_crps{
gen `x'_fo1 = b12_1p  if `x'_m1 == 1
replace  `x'_fo1 = 0 if `x'_m1 == 0 
gen `x'_farmg1 = b12_1q  if `x'_m1 == 1
replace  `x'_farmg1 = 0 if `x'_m1 == 0 
gen `x'_mrkt1 = b12_1r  if `x'_m1 == 1
replace  `x'_mrkt1 = 0 if `x'_m1 == 0 

egen `x'_chnn1 = rowtotal(`x'_fo1 `x'_farmg1 `x'_mrkt1)

}
*

*maiz_sold1 rice_sold1 cowp_sold1
*maiz_fo1   rice_fo1   cowp_fo1


/* b12_2b  proportion sold  immediate  (crop 2)
b12_2c  proportion sold  later      (crop 2)
b12_2d  lost (spoilage or pest)     (crop 2)
b12_2e  retained for hh             (crop 2)
b12_2f  retained for farm           (crop 2)
 
b12_2p   proportion sold via fo       (crop 2)
b12_2q   proportion sold at farmgate  (crop 2)
b12_2r   proportion sold at market    (crop 2)

b12_2s    proportion sold within 4wks  (crop 2)
b12_2t    proportion sold later 4wks   (crop 2)  */


gen maiz_m2 = 1 if b12_2a  ==1 
replace maiz_m2 = 0 if b12_2a != 1

gen sorg_m2 = 1 if b12_2a == 2
replace sorg_m2 = 0 if b12_2a  != 2

gen mill_m2 = 1 if b12_2a == 5
replace mill_m2 = 0 if b12_2a  != 5

gen rice_m2 = 1 if b12_2a == 14
replace rice_m2 = 0 if b12_2a  != 14

gen cowp_m2 = 1 if b12_2a == 24
replace cowp_m2 = 0 if b12_2a  != 24

/* gen cass_m2 = 1 if b12_2a == 9
replace cass_m2 = 0 if b12_2a  != 9

gen yam_m2 = 1 if b12_2a == 31
replace yam_m2 = 0 if b12_2a  != 31  */

local listm_crps2 "maiz sorg mill rice cowp"
foreach x of local listm_crps2{
gen   `x'_sold2 = b12_2b  + b12_2c  if `x'_m2 ==  1
replace  `x'_sold2 = 0      if  `x'_m2 == 0 
gen      `x'_lost2 = b12_2d if  `x'_m2 == 1
replace  `x'_lost2 = 0      if  `x'_m2 == 0 
gen  `x'_ret2 = b12_2e + b12_2f if `x'_m2 == 1
replace `x'_ret2 = 0  if `x'_m2 == 0 

egen `x'_mtot2 = rowtotal( `x'_ret2 `x'_lost2 `x'_sold2)
}
*
foreach x of local listm_crps2{
gen `x'_fo2 = b12_2p  if `x'_m2 == 1
replace  `x'_fo2 = 0 if `x'_m2 == 0 
gen `x'_farmg2 = b12_2q  if `x'_m2 == 1
replace  `x'_farmg2 = 0 if `x'_m2 == 0 
gen `x'_mrkt2 = b12_2r  if `x'_m2 == 1
replace  `x'_mrkt2 = 0 if `x'_m2 == 0 

egen `x'_chnn2 = rowtotal(`x'_fo2 `x'_farmg2 `x'_mrkt2)

egen `x'_sold_r2 = rowtotal( `x'_sold1 `x'_sold2)
egen `x'_fo_r2   = rowtotal( `x'_fo1    `x'_fo2)

}
*
rename p4pstatus p4p_r2

save hh_follow_2013_n, replace
/* *******************************************************************************************
************************compiling the latest household survey round **************************
*********************************************************************************************/
*usespss using "C:\Users\dadzie\Desktop\Research Work\Stata_Progs\aerc_project\hh_follow_up_2015.sav", clear saving("hh_follow_2015_nw.dta")

use hh_follow_2015_nw, clear
duplicates tag hh_code, gen(c11)
rename FO_code fo_code
gen u_hh_fo = hh_code*10000 + fo_code
*years of membership in the fo

qui{
egen years_fo_r3 = rowtotal(A1_1c A1_2c A1_3c)
egen assist_12m_r3 = rowmean( A2_1f A2_2f A2_3f A2_6f A2_7f)
 

rename A2_1f assist_tech_r3
rename A2_2f assist_credit_r3
rename A2_3f assist_cash_r3
rename A2_7f assist_stor_r3
 
 
 *b1_1a  total land owned, *b1_1b  units of land owned by hh 
rename B1_1a land_r3

*b1_2a land area for ag prodn during season, *b1_2b units of land for prodn
rename B1_2a land_farm_r3

/* j1 household size
j2_1c sex of hh_head
j2_1e age of hh_head
j2_1f educ of hh_head  */

rename J1 hhsize_r3
rename J2_1c sex_hd_r3
rename J2_1e age_hd_r3
rename J2_1f educ_hd_r3


*qty produced and harvestd data
gen maiz = 1 if B7_0a ==1 
replace maiz = 0 if B7_0a != 1

gen rice = 1 if B7_0a == 14
replace rice = 0 if B7_0a  != 14

gen sorg = 1 if B7_0a == 2
replace sorg = 0 if B7_0a  != 2

gen mill = 1 if B7_0a == 5
replace mill = 0 if B7_0a  != 5

gen cowp = 1 if B7_0a == 24
replace cowp = 0 if B7_0a  != 24


gen maiz_area = B7_0c if maiz == 1     //  * maize area
replace maiz_area = 0 if maiz == 0 

gen sorg_area = B7_0c if sorg == 1     //  * sorg area
replace sorg_area = 0 if sorg == 0 

gen mill_area = B7_0c if mill == 1     //  * millet area
replace mill_area = 0 if mill == 0 

gen rice_area = B7_0c if rice == 1     //  * rice area
replace rice_area = 0 if rice == 0 

gen cowp_area = B7_0c if cowp == 1     //  * cowpea area
replace cowp_area = 0 if cowp == 0 

* crop 1 season 1 harvests obtained
local listhvsts "maiz sorg mill rice cowp"
foreach x of local listhvsts {
gen `x'_hvst = B7_0e if `x' == 1 & B7_0f == 2    // * 
replace `x'_hvst  = 0 if `x' == 0 
replace `x'_hvst  = B7_0e*100 if `x' ==1 & B7_0f == 3 
replace `x'_hvst  = B7_0e*90 if `x' ==1 & B7_0f == 4
replace `x'_hvst  = B7_0e*50 if `x' ==1 & B7_0f == 5
replace `x'_hvst  = B7_0e*30 if `x' ==1 & B7_0g < 80 &  B7_0g != . 
replace `x'_hvst  = B7_0e*120 if `x' ==1 & B7_0g > 80 &  B7_0g < 200
}
*


gen maiz1 = 1 if B7_1a ==1 
replace maiz1 = 0 if B7_1a != 1

gen sorg1 = 1 if B7_1a == 2
replace sorg1 = 0 if B7_1a  != 2

gen mill1 = 1 if B7_1a == 5
replace mill1 = 0 if B7_1a  != 5

gen rice1 = 1 if B7_1a == 14
replace rice1 = 0 if B7_1a  != 14

gen cowp1 = 1 if B7_1a == 24
replace cowp1 = 0 if B7_1a  != 24

/* gen cass1 = 1 if b7_1a = 9
replace cass1 = 0 if b7_1a  != 9

gen yam1 = 1 if b7_1a = 31
replace yam1 = 0 if b7_1a  != 31  */
 
gen maiz_area1 = B7_1c if maiz1 == 1     //  * maize area  crop2 (note its 1 here)
replace maiz_area1 = 0 if maiz1 == 0 

gen sorg_area1 = B7_1c if sorg1 == 1     //  * sorg area crop2 (note its 1 here)
replace sorg_area1 = 0 if sorg1 == 0 

gen mill_area1 = B7_1c if mill1 == 1     //  * millet area  crop2 (note its 1 here)
replace mill_area1 = 0 if mill1 == 0 

gen rice_area1 = B7_1c if rice1 == 1     //  * rice area crop2 (note its 1 here)
replace rice_area1 = 0 if rice1 == 0 

gen cowp_area1 = B7_1c if cowp1 == 1     //  * cowpea area crop2 (note its 1 here)
replace cowp_area1 = 0 if cowp1 == 0 



local listhvsts1 "maiz sorg mill rice cowp "
foreach x of local listhvsts1{
gen `x'_hvst1 = B7_1e if `x'1 == 1 & B7_1f == 2    // * 
replace `x'_hvst1  = 0 if `x'1 == 0 
replace `x'_hvst1  = B7_1e*100 if `x'1 ==1 & B7_1f == 3 
replace `x'_hvst1  = B7_1e*90 if `x'1 ==1 & B7_1f == 4
replace `x'_hvst1  = B7_1e*50 if `x'1 ==1 & B7_1f == 5
replace `x'_hvst1  = B7_1e*30 if `x'1 ==1 & B7_1g < 80 &  B7_1g != . 
replace `x'_hvst1  = B7_1e*120 if `x'1 ==1 & B7_1g > 80 &  B7_1g < 200
 
}
*


gen maiz2 = 1 if B7_2a ==1 
replace maiz2 = 0 if B7_2a != 1

gen sorg2 = 1 if B7_2a == 2
replace sorg2 = 0 if B7_2a  != 2

gen mill2 = 1 if B7_2a == 5
replace mill2 = 0 if B7_2a  != 5

gen rice2 = 1 if B7_2a == 14
replace rice2 = 0 if B7_2a  != 14

gen cowp2 = 1 if B7_2a == 24
replace cowp2 = 0 if B7_2a  != 24

/* gen cass2 = 1 if b7_2a = 9
replace cass2 = 0 if b7_2a  != 9

gen yam2 = 1 if b7_2a = 31
replace yam2 = 0 if b7_2a  != 31  */
 
gen maiz_area2 = B7_2c if maiz2 == 1     //  * maize area  crop3 (note its 2 here)
replace maiz_area2 = 0 if maiz2 == 0 

gen sorg_area2 = B7_2c if sorg2 == 1     //  * sorg area crop3 (note its 2 here)
replace sorg_area2 = 0 if sorg2 == 0 

gen mill_area2 = B7_2c if mill2 == 1     //  * millet area  crop3 (note its 2 here)
replace mill_area2 = 0 if mill2 == 0 

gen rice_area2 = B7_2c if rice2 == 1     //  * rice area crop3 (note its 2 here)
replace rice_area2 = 0 if rice2 == 0 

gen cowp_area2 = B7_2c if cowp2 == 1     //  * cowpea area crop3 (note its 2 here)
replace cowp_area2 = 0 if cowp2 == 0 

/* gen yam_area2 = b7_2c if yam2 == 1     //  * yam area  crop3 (note its 2 here)
replace yam_area2 = 0 if yam2 == 0 

gen cass_area2 = b7_2c if cass2 == 1     //  * cass area  crop3 (note its 2 here)
replace cass_area2 = 0 if cass2 == 0     */


* for the harvested areas for crop3 (crop 2 here)
 local listcrp3 "maiz sorg mill rice cowp"
 foreach x of local listcrp3{
 gen `x'_hvst2 = B7_2e if `x'2 == 1 & B7_2f == 2 
 replace `x'_hvst2 = 0 if `x'2 == 0 
 replace `x'_hvst2 = B7_2e*100  if `x'2== 1 & B7_2f == 3
 replace `x'_hvst2 = B7_2e*90   if `x'2== 1 & B7_2f == 4
 replace `x'_hvst2 = B7_2e*50  if `x'2== 1 & B7_2f == 5
 replace `x'_hvst2 = B7_2e*30 if `x'2== 1 & B7_2g < 80 & B7_1g != .
replace `x'_hvst2  = B7_2e*120 if `x'2==1 & B7_1g > 80 &  B7_1g < 200 
}
*

*compiling the values for all the crops
foreach x of local listcrp3{
egen `x'_areat_r3 = rowtotal(`x'_area `x'_area1 `x'_area2)
egen  `x'_hvstt_r3 = rowtotal(`x'_hvst `x'_hvst1 `x'_hvst2)
}
*

*SALES DATA FOR ROUND 3 ********
* sales for crop 1 season 1
gen maiz_s = 1 if B11_0a ==1 
replace maiz_s = 0 if B11_0a != 1

gen sorg_s = 1 if B11_0a == 2
replace sorg_s = 0 if B11_0a  != 2

gen mill_s = 1 if B11_0a == 5
replace mill_s = 0 if B11_0a  != 5

gen rice_s = 1 if B11_0a == 14
replace rice_s = 0 if B11_0a  != 14

gen cowp_s = 1 if B11_0a == 24
replace cowp_s = 0 if B11_0a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */

local list_1crps "maiz sorg mill rice cowp"
foreach x of local list_1crps {
gen `x'_qtys = B11_0b if `x'_s == 1
replace `x'_qtys = 0 if `x'_s == 0
replace `x'_qtys  = B11_0b*100  if `x'_s== 1 & B11_0c == 3
replace `x'_qtys = B11_0b*90   if `x'_s== 1 & B11_0c == 4
replace `x'_qtys = B11_0b*50   if `x'_s== 1 & B11_0c == 5
replace `x'_qtys = B11_0b*30   if `x'_s== 1 & B11_0d < 80 & B11_0d != .
replace `x'_qtys  = B11_0b*120  if `x'_s==1 & B11_0d > 80 &  B11_0d < 400  

gen `x'_sales = B11_0f if  `x'_s== 1
}
*

/*  

b11_1a    crop 2 (season 1) 
b11_1b  qty sold of crop2 in season1 
b11_1c  unit of the quantity sold (crop 2)
b11_1d  kg equivalent of other weight category  (crop 2)

b11_1f   total sales of crop1 in season1 (ghc)   (crop 2)
b11_1h   total selling costs of crp1 in season 1  (crop 2)  */

*sales for crop 2 season 1
gen maiz_s1 = 1 if B11_1a ==1 
replace maiz_s1 = 0 if B11_1a != 1

gen sorg_s1 = 1 if B11_1a == 2
replace sorg_s1 = 0 if B11_1a  != 2

gen mill_s1 = 1 if B11_1a == 5
replace mill_s1 = 0 if B11_1a  != 5

gen rice_s1 = 1 if B11_1a == 14
replace rice_s1 = 0 if B11_1a  != 14

gen cowp_s1 = 1 if B11_1a == 24
replace cowp_s1 = 0 if B11_1a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */

local list_2crps "maiz sorg mill rice cowp"
foreach x of local list_2crps {
gen `x'_qtys1 = B11_1b if `x'_s1 == 1
replace `x'_qtys1 = 0 if `x'_s1 == 0
replace `x'_qtys1  = B11_1b*100  if `x'_s1== 1 & B11_1c == 3
replace `x'_qtys1 = B11_1b*90   if `x'_s1== 1 & B11_1c == 4
replace `x'_qtys1 = B11_1b*50   if `x'_s1== 1 & B11_1c == 5
replace `x'_qtys1 = B11_1b*30   if `x'_s1== 1 & B11_1d < 80 & B11_1d != .
replace `x'_qtys1  = B11_1b*120  if `x'_s1==1 & B11_1d > 80 &  B11_1d < 400  

gen `x'_sales1 = B11_1f if  `x'_s1== 1
}
*

/*
b11_2b  qty sold of crop2 in season1 
b11_2c  unit of the quantity sold (crop 3)
b11_2d  kg equivalent of other weight category  (crop 3)

b11_2f   total sales of crop1 in season1 (ghc)   (crop 3)
b11_2h   total selling costs of crp1 in season 1  (crop 3)  */

*sales for crop 3 season 1
gen maiz_s2 = 1 if B11_2a ==1 
replace maiz_s2 = 0 if B11_2a != 1

gen sorg_s2 = 1 if B11_2a == 2
replace sorg_s2 = 0 if B11_2a  != 2

gen mill_s2 = 1 if B11_2a == 5
replace mill_s2 = 0 if B11_2a  != 5

gen rice_s2 = 1 if B11_2a == 14
replace rice_s2 = 0 if B11_2a  != 14

gen cowp_s2 = 1 if B11_2a == 24
replace cowp_s2 = 0 if B11_2a  != 24

/* gen cass_s = 1 if b11_0a = 9
replace cass_s = 0 if b11_0a  != 9

gen yam_s = 1 if b11_0a = 31
replace yam_s = 0 if b11_0a  != 31  */


local list_3crps "maiz sorg mill rice cowp"
foreach x of local list_3crps {
gen `x'_qtys2 = B11_2b if `x'_s2 == 1
replace `x'_qtys2 = 0 if `x'_s2 == 0
replace `x'_qtys2  = B11_2b*100  if `x'_s2== 1 & B11_2c == 3
replace `x'_qtys2 = B11_2b*90   if `x'_s2== 1 & B11_2c == 4
replace `x'_qtys2 = B11_2b*50   if `x'_s2== 1 & B11_2c == 5
replace `x'_qtys2 = B11_2b*30   if `x'_s2== 1 & B11_2d < 80 & B11_2d != .
replace `x'_qtys2  = B11_2b*120  if `x'_s2==1 & B11_2d > 80 &  B11_2d < 400  

gen `x'_sales2 = B11_2f if  `x'_s2== 1
}
*

local listcrps_1 "maiz sorg mill rice cowp"
foreach x of local listcrps_1 {
egen `x'_qtys_s1t_r3   = rowtotal(`x'_qtys  `x'_qtys1 `x'_qtys2)
egen `x'_sales_s1t_r3  = rowtotal(`x'_sales  `x'_sales1  `x'_sales2)
}
*   


*sales for season 2 crop 1
gen maiz_s21 = 1 if B11_5a ==1 
replace maiz_s21 = 0 if B11_5a != 1

gen sorg_s21 = 1 if B11_5a == 2
replace sorg_s21 = 0 if B11_5a  != 2

gen mill_s21 = 1 if B11_5a == 5
replace mill_s21 = 0 if B11_5a  != 5

gen rice_s21 = 1 if B11_5a == 14
replace rice_s21 = 0 if B11_5a  != 14

gen cowp_s21 = 1 if B11_5a == 24
replace cowp_s21 = 0 if B11_5a  != 24

/* gen yam_s21 = 1 if b11_5a = 31
replace yam_s21 = 0 if b11_5a  != 31

gen cass_s21 = 1 if b11_5a = 9
replace cass_s21 = 0 if b11_5a  != 9 */

local listcrps "maiz sorg mill rice cowp"
foreach x of local listcrps{
gen `x'_qtys21 = B11_5b if `x'_s21 == 1
replace `x'_qtys21 = 0  if `x'_s21 == 0
replace `x'_qtys21 = B11_5b*100  if `x'_s21== 1 & B11_5c == 3
replace `x'_qtys21 = B11_5b*90   if `x'_s21== 1 & B11_5c == 4
replace `x'_qtys21 = B11_5b*50   if `x'_s21== 1 & B11_5c == 5
replace `x'_qtys21 = B11_5b*30   if `x'_s21== 1 & B11_5d < 80 & B11_5d != .
replace `x'_qtys21 = B11_5b*120  if `x'_s21==1 & B11_5d > 80 &  B11_5d < 400  

gen `x'_sales21 = B11_5f if  `x'_s21== 1
}
*

/*
b11_6a
b11_6b  qty sold of crop2 in season2 
b11_6c  unit of the quantity sold (crop 2)
b11_6d  kg equivalent of other weight category  (crop 2)

b11_6f   total sales of crop1 in season2 (ghc)   (crop 2)
b11_6h   total selling costs of crp1 in season 1  (crop 2)   */

*sales for season 2 crop 2
gen maiz_s22 = 1 if B11_6a ==1 
replace maiz_s22 = 0 if B11_6a != 1

gen sorg_s22 = 1 if B11_6a == 2
replace sorg_s22 = 0 if B11_6a  != 2

gen mill_s22 = 1 if B11_6a == 5
replace mill_s22 = 0 if B11_6a  != 5

gen rice_s22 = 1 if B11_6a == 14
replace rice_s22 = 0 if B11_6a  != 14

gen cowp_s22 = 1 if B11_6a == 24
replace cowp_s22 = 0 if B11_6a  != 24

/* gen yam_s22 = 1 if b11_6a = 31
replace yam_s22 = 0 if b11_6a  != 31

gen cass_s22 = 1 if b11_6a = 9
replace cass_s22 = 0 if b11_6a  != 9 */

local listcrps "maiz sorg mill rice cowp"
foreach x of local listcrps{
gen `x'_qtys22 = B11_6b if `x'_s22 == 1
replace `x'_qtys22 = 0  if `x'_s22 == 0
replace `x'_qtys22 = B11_6b*100  if `x'_s22== 1 & B11_6c == 3
replace `x'_qtys22 = B11_6b*90   if `x'_s22== 1 & B11_6c == 4
replace `x'_qtys22 = B11_6b*50   if `x'_s22== 1 & B11_6c == 5
replace `x'_qtys22 = B11_6b*30   if `x'_s22== 1 & B11_6d < 80 &  B11_6d != .
replace `x'_qtys22 = B11_6b*120  if `x'_s22==1  & B11_6d > 80 &  B11_6d < 400  

gen `x'_sales22 = B11_6f if  `x'_s22== 1
}
*


*sales for season 2 crop 3
gen maiz_s23 = 1 if B11_7a ==1 
replace maiz_s23 = 0 if B11_7a != 1

gen sorg_s23 = 1 if B11_7a == 2
replace sorg_s23 = 0 if B11_7a  != 2

gen mill_s23 = 1 if B11_7a == 5
replace mill_s23 = 0 if B11_7a  != 5

gen rice_s23 = 1 if B11_7a == 14
replace rice_s23 = 0 if B11_7a  != 14

gen cowp_s23 = 1 if B11_7a == 24
replace cowp_s23 = 0 if B11_7a  != 24

/* gen yam_s23 = 1 if b11_7a = 31
replace yam_s23 = 0 if b11_7a  != 31

gen cass_s23 = 1 if b11_7a = 9
replace cass_s23 = 0 if b11_7a  != 9  */

local listcrps23 "maiz sorg mill rice cowp"
foreach x of local listcrps23{
gen `x'_qtys23 = B11_7b if `x'_s23 == 1
replace `x'_qtys23 = 0  if `x'_s23 == 0
replace `x'_qtys23 = B11_7b*100  if `x'_s23== 1 & B11_7c == 3
replace `x'_qtys23 = B11_7b*90   if `x'_s23== 1 & B11_7c == 4
replace `x'_qtys23 = B11_7b*50   if `x'_s23== 1 & B11_7c == 5
replace `x'_qtys23 = B11_7b*30   if `x'_s23== 1 & B11_7d < 80 &  B11_7d != .
replace `x'_qtys23 = B11_7b*120  if `x'_s23==1  & B11_7d > 80 &  B11_7d < 400  

gen `x'_sales23 = B11_7f if  `x'_s23== 1
}
*
local listcrps_1 "maiz sorg mill rice cowp"
foreach x of local listcrps_1 {
egen `x'_qtys_s2t_r3  = rowtotal(`x'_qtys21  `x'_qtys22  `x'_qtys23)
egen `x'_sales_s2t_r3 = rowtotal(`x'_sales21  `x'_sales22  `x'_sales23)
}
* maiz_sales_s2t maiz_sales_s1t maiz_sales_s2t_r2 maiz_sales_s1t_r2  maiz_sales_s1t_r3  maiz_sales_s2t_r3   

egen maiz_sales_r3 = rowtotal(maiz_sales_s1t_r3  maiz_sales_s2t_r3)

*marketing channels and participation
gen maiz_m1 = 1 if B12_1a  ==1 
replace maiz_m1 = 0 if B12_1a != 1

gen sorg_m1 = 1 if B12_1a == 2
replace sorg_m1 = 0 if B12_1a  != 2

gen mill_m1 = 1 if B12_1a == 5
replace mill_m1 = 0 if B12_1a  != 5

gen rice_m1 = 1 if B12_1a == 14
replace rice_m1 = 0 if B12_1a  != 14

gen cowp_m1 = 1 if B12_1a == 24
replace cowp_m1 = 0 if B12_1a  != 24

/* gen cass_m1 = 1 if b12_1a = 9
replace cass_m1 = 0 if b12_1a  != 9

gen yam_m1 = 1 if b12_1a = 31
replace yam_m1 = 0 if b12_1a  != 31  */

local listm_crps "maiz sorg mill rice cowp "
foreach x of local listm_crps{
gen   `x'_sold1 = B12_2b  + B12_2c  if `x'_m1 ==  1
replace  `x'_sold1 = 0      if  `x'_m1 == 0 
gen      `x'_lost1 = B12_2d if  `x'_m1 == 1
replace  `x'_lost1 = 0      if  `x'_m1 == 0 
gen  `x'_ret1 = B12_2e + B12_2f if `x'_m1 == 1
replace `x'_ret1 = 0  if `x'_m1 == 0 
egen `x'_mtot1 = rowtotal( `x'_ret1 `x'_lost1 `x'_sold1)

}
*
foreach x of local listm_crps{
gen `x'_fo1 = B12_1p  if `x'_m1 == 1
replace  `x'_fo1 = 0 if `x'_m1 == 0 
gen `x'_farmg1 = B12_1q  if `x'_m1 == 1
replace  `x'_farmg1 = 0 if `x'_m1 == 0 
gen `x'_mrkt1 = B12_1r  if `x'_m1 == 1
replace  `x'_mrkt1 = 0 if `x'_m1 == 0 

egen `x'_chnn1 = rowtotal(`x'_fo1 `x'_farmg1 `x'_mrkt1)

}
*

*maiz_sold1 rice_sold1 cowp_sold1
*maiz_fo1   rice_fo1   cowp_fo1


/* b12_2b  proportion sold  immediate  (crop 2)
b12_2c  proportion sold  later      (crop 2)
b12_2d  lost (spoilage or pest)     (crop 2)
b12_2e  retained for hh             (crop 2)
b12_2f  retained for farm           (crop 2)
 
b12_2p   proportion sold via fo       (crop 2)
b12_2q   proportion sold at farmgate  (crop 2)
b12_2r   proportion sold at market    (crop 2)

b12_2s    proportion sold within 4wks  (crop 2)
b12_2t    proportion sold later 4wks   (crop 2)  */


gen maiz_m2 = 1 if B12_2a  ==1 
replace maiz_m2 = 0 if B12_2a != 1

gen sorg_m2 = 1 if B12_2a == 2
replace sorg_m2 = 0 if B12_2a  != 2

gen mill_m2 = 1 if B12_2a == 5
replace mill_m2 = 0 if B12_2a  != 5

gen rice_m2 = 1 if B12_2a == 14
replace rice_m2 = 0 if B12_2a  != 14

gen cowp_m2 = 1 if B12_2a == 24
replace cowp_m2 = 0 if B12_2a  != 24

/* gen cass_m2 = 1 if b12_2a == 9
replace cass_m2 = 0 if b12_2a  != 9

gen yam_m2 = 1 if b12_2a == 31
replace yam_m2 = 0 if b12_2a  != 31  */

local listm_crps2 "maiz sorg mill rice cowp"
foreach x of local listm_crps2{
gen   `x'_sold2 = B12_2b  + B12_2c  if `x'_m2 ==  1
replace  `x'_sold2 = 0      if  `x'_m2 == 0 
gen      `x'_lost2 = B12_2d if  `x'_m2 == 1
replace  `x'_lost2 = 0      if  `x'_m2 == 0 
gen  `x'_ret2 = B12_2e + B12_2f if `x'_m2 == 1
replace `x'_ret2 = 0  if `x'_m2 == 0 

egen `x'_mtot2 = rowtotal( `x'_ret2 `x'_lost2 `x'_sold2)
}
*
foreach x of local listm_crps2{
gen `x'_fo2 = B12_2p  if `x'_m2 == 1
replace  `x'_fo2 = 0 if `x'_m2 == 0 
gen `x'_farmg2 = B12_2q  if `x'_m2 == 1
replace  `x'_farmg2 = 0 if `x'_m2 == 0 
gen `x'_mrkt2 = B12_2r  if `x'_m2 == 1
replace  `x'_mrkt2 = 0 if `x'_m2 == 0 

egen `x'_chnn2 = rowtotal(`x'_fo2 `x'_farmg2 `x'_mrkt2)

egen `x'_sold_r3 = rowtotal( `x'_sold1 `x'_sold2)
egen `x'_fo_r3   = rowtotal( `x'_fo1    `x'_fo2)

}
*
rename P4Pstatus p4p_r3


}
*

  */

egen food_exp_r3 = rowtotal(G1_1 G1_2 G1_3 G1_4 G1_5 G1_6 G1_7 G1_8 G1_9 G1_10 G1_11 G1_12 G1_13 G1_14 G1_15 G1_16)
egen nfood_exp_r3 = rowtotal(G2 G3_1 G3_2 G3_3 G3_4 G3_5 G3_6 G3_7 G3_8)

save hh_follow_2015, replace

*use hh_follow_2015, clear 

 keep u_hh_fo  p4p_r3 years_fo_r3 assist_12m_r3 assist_tech_r3 assist_credit_r3 assist_cash_r3 assist_stor_r3 land_r3 land_farm_r3 hhsize_r3 sex_hd_r3 age_hd_r3 educ_hd_r3 maiz_sales_r3       ///
   maiz_areat_r3 maiz_hvstt_r3 rice_areat_r3 rice_hvstt_r3 cowp_areat_r3 cowp_hvstt_r3 maiz_sold_r3 maiz_fo_r3 rice_sold_r3 rice_fo_r3 cowp_sold_r3 cowp_fo_r3 food_exp_r3 nfood_exp_r3

 save hh_follow_2015n, replace
 
*maiz_sales_s2t maiz_sales_s1t maiz_sales_s2t_r2 maiz_sales_s1t_r2  maiz_sales_s1t_r3  maiz_sales_s2t_r3   
*****************************************************************************************************
***MERGING ALL THE ROUNDS ***************************************************************************
*****************************************************************************************************
* Put * on the next line to run the entire code
/*
rename a2_1f assist_tech
rename a2_2f assist_credit
rename a2_3f assist_cash
rename a2_7f assist_stor  */



use hh_base_2011_n1, clear
local listf1 "p4p years_fo  assist_12m assist_tech assist_credit assist_cash assist_stor land land_farm hhsize sex_hd age_hd educ_hd maiz_areat maiz_hvstt rice_areat rice_hvstt maiz_sold maiz_fo rice_sold rice_fo cowp_sold cowp_fo food_exp nfood_exp"
foreach x of local listf1{
rename `x' `x'_r1
}
*


merge 1:1 u_hh_fo using hh_follow_2013_n.dta, keepusing(p4p_r2 years_fo_r2  assist_12m_r2  assist_tech_r2 assist_credit_r2 assist_cash_r2 assist_stor_r2 land_r2 land_farm_r2 hhsize_r2 sex_hd_r2 age_hd_r2 educ_hd_r2     ///
           maiz_areat_r2 maiz_hvstt_r2 rice_areat_r2 rice_hvstt_r2 cowp_areat_r2 cowp_hvstt_r2 maiz_sold_r2 maiz_fo_r2 maiz_sales_r2 rice_sold_r2 rice_fo_r2 cowp_sold_r2 cowp_fo_r2 food_exp_r2 nfood_exp_r2 )

drop _merge
		   
*variable equivalents for r3:
merge 1:1 u_hh_fo using hh_follow_2015n.dta, keepusing(p4p_r3 years_fo_r3 assist_12m_r3 assist_tech_r3 assist_credit_r3 assist_cash_r3 assist_stor_r3 land_r3 land_farm_r3 hhsize_r3 sex_hd_r3 age_hd_r3 educ_hd_r3            ///
		   maiz_areat_r3 maiz_hvstt_r3 rice_areat_r3 rice_hvstt_r3 cowp_areat_r3 cowp_hvstt_r3 maiz_sold_r3 maiz_fo_r3 maiz_sales_r3 rice_sold_r3 rice_fo_r3 cowp_sold_r3 cowp_fo_r3 food_exp_r3 nfood_exp_r3) 
*drop _merge

keep u_hh_fo p4p_r2 years_fo_r2  assist_12m_r2  assist_tech_r2 assist_credit_r2 assist_cash_r2 assist_stor_r2 land_r2 land_farm_r2 hhsize_r2 sex_hd_r2 age_hd_r2 educ_hd_r2     ///
           maiz_areat_r2 maiz_hvstt_r2 rice_areat_r2 rice_hvstt_r2 cowp_areat_r2 cowp_hvstt_r2 maiz_sold_r2 maiz_fo_r2 rice_sold_r2 rice_fo_r2 cowp_sold_r2 cowp_fo_r2  food_exp_r2 nfood_exp_r2 ///
		   p4p_r1 years_fo_r1  assist_12m_r1 assist_12m_r1  assist_tech_r1 assist_credit_r1 assist_cash_r1 assist_stor_r1 land_r1 land_farm_r1 hhsize_r1 sex_hd_r1 age_hd_r1 educ_hd_r1 maiz_areat_r1 maiz_hvstt_r1 rice_areat_r1    ///
		   rice_hvstt_r1 maiz_sold_r1 maiz_fo_r1 rice_sold_r1 rice_fo_r1 cowp_sold_r1 cowp_fo_r1  food_exp_r1 nfood_exp_r1 maiz_sales_r1 maiz_sales_r2 maiz_sales_r3                ///
		   p4p_r3 years_fo_r3  assist_12m_r3  assist_tech_r3 assist_credit_r3 assist_cash_r3 assist_stor_r3  land_r3 land_farm_r3 hhsize_r3 sex_hd_r3 age_hd_r3 educ_hd_r3 maiz_areat_r3 maiz_hvstt_r3 rice_areat_r3    ///
		   rice_hvstt_r3 maiz_sold_r3 maiz_fo_r3 rice_sold_r3 rice_fo_r3 cowp_sold_r3 cowp_fo_r3  food_exp_r3 nfood_exp_r3

   
save hh_r123.dta , replace

use hh_r123.dta, clear

*gen d_maiz_fo = maiz_fo_r2 - maiz_fo_r1     // vars for diff-diff procedures
*gen d_maiz_sld= maiz_sold_r2 - maiz_sold_r1    // vars for diff-diff procedures

keep 	u_hh_fo maiz_areat_r1 maiz_hvstt_r1 maiz_sold_r1 maiz_fo_r1  p4p_r1 years_fo_r1  assist_12m_r1  assist_tech_r1 assist_credit_r1 assist_cash_r1 assist_stor_r1  land_r1 land_farm_r1 hhsize_r1 sex_hd_r1 age_hd_r1 educ_hd_r1  maiz_sales_r1  food_exp_r1 nfood_exp_r1 ///
 	            maiz_areat_r2 maiz_hvstt_r2 maiz_sold_r2 maiz_fo_r2  p4p_r2 years_fo_r2  assist_12m_r2  assist_tech_r2 assist_credit_r2 assist_cash_r2 assist_stor_r2  land_r2 land_farm_r2 hhsize_r2 sex_hd_r2 age_hd_r2 educ_hd_r2  maiz_sales_r2  food_exp_r2 nfood_exp_r2 ///
                maiz_areat_r3 maiz_hvstt_r3 maiz_sold_r3 maiz_fo_r3  p4p_r3 years_fo_r3  assist_12m_r3  assist_tech_r3 assist_credit_r3 assist_cash_r3 assist_stor_r3  land_r3 land_farm_r3 hhsize_r3 sex_hd_r3 age_hd_r3 educ_hd_r3  maiz_sales_r3  food_exp_r3 nfood_exp_r3 ///
 
		   
reshape long  maiz_areat_r maiz_hvstt_r maiz_sold_r maiz_fo_r  p4p_r years_fo_r assist_12m_r  assist_tech_r assist_credit_r assist_cash_r assist_stor_r land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r maiz_sales_r food_exp_r nfood_exp_r, i(u_hh_fo) j(round)
 
save aerc_r123, replace

use aerc_r123, clear   

xtset u_hh_fo round, 
*****


***CORRELATED RANDOM EFFECTS MODEL
*******
bysort u_hh_fo: egen yrs_fo_ = mean(years_fo_r)  
bysort u_hh_fo: egen assist_ = mean(assist_12m_r)  
bysort u_hh_fo: egen land_r_ = mean(land_r)  
bysort u_hh_fo: egen l_farm_ = mean(land_farm_r) 
bysort u_hh_fo: egen hhsize_ = mean(hhsize_r)     

gen maiz_sell = 1 if maiz_sales_r > 0 & maiz_sales_r != .
replace maiz_sell = 0 if maiz_sell == . 


gen l_maiz_sales = log(maiz_sales_r + 1)   
gen l_food_exp   = log(food_exp_r + 1)
gen l_nfood_exp  = log(nfood_exp_r + 1)

l_maiz_sales  l_food_exp l_nfood_exp

l
gen fo_maiz = 1 if maiz_fo_r > 0 & maiz_fo_r != . 

gen     wave = 0 if round == 1 
replace wave = 1 if round == 2
replace wave = 2 if round == 3

gen wavy = 0 if round == 1
replace wavy = 1 if round == 2

/*  DESCRIPTIVE ANALYSES   */


mean  nfood_exp_r, over(round)

/*  what other var would there be a potential impact for the p4p prog
    non-farm income
	liquid assets
	on-farm investments
	*/

xtline maiz_areat_r, t(round) i(u_hh_fo) overlay



*generating treatment vars;
 gen treat1 = wave*p4p_r
 gen treat1y = wavy*p4p_r 
 
 gen treat2 = wave*fo_maiz
 gen treat3 = p4p_r*fo_maiz
 gen treat4 = wave*p4p_r*fo_maiz
 
*yrs_fo_  assist_ land_r_ l_farm_ hhsize_ 


*MIMICKING MUAMBA ANALYSIS
/*  xtreg lnprice wave p4pstatus treat1, fe vce(r)     // model 1 in paper
xtreg lnprice wave p4pstatus treat1 maize_exp hhsize educ production1 land i.fo_code, fe vce(r)   // model 2 in paper
xtreg lnprice wave FO_sale p4pstatus treat1 treat2 treat3 treat4, fe vce(r)   // model 3    
xtreg lnprice wave FO_sale p4pstatus treat1 treat2 treat3 treat4 maize_exp hhsize educ production1 land i.fo_code, fe vce(r)    // model 4    */


xtreg l_maiz_sale wave p4p_r treat1, fe vce(r)
est store m1_rev
xtreg l_maiz_sale wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, fe vce(r)
est store m2_rev
xtreg l_maiz_sale wave p4p_r fo_maiz treat1 treat2 treat3 treat4, fe vce(r)
est store m3_rev
xtreg l_maiz_sale wave p4p_r fo_maiz treat1 treat2 treat3 treat4 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, fe vce(r)
est store m4_rev

esttab m1_rev m2_rev m3_rev m4_rev , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab m1_rev m2_rev m3_rev m4_rev using "C:\Users\dadzie\Desktop\Research Work\Estimation_results\aerc\mz_rev_2016.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace

*USING REGRESS NOT XTREG
regress l_maiz_sale wave p4p_r treat1, vce(r)
est store m1_1rev
regress l_maiz_sale wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, vce(r)
est store m2_1rev
regress l_maiz_sale wave p4p_r fo_maiz treat1 treat2 treat3 treat4, vce(r)
est store m3_1rev
regress l_maiz_sale wave p4p_r fo_maiz treat1 treat2 treat3 treat4 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, vce(r)
est store m4_1rev

esttab m1_1rev m2_1rev m3_1rev m4_1rev , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab m1_1rev m2_1rev m3_1rev m4_1rev using "C:\Users\dadzie\Desktop\Research Work\Estimation_results\aerc\reg_rev_2016.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace



*DDD for food expenditure analysis
xtreg l_food_exp wave p4p_r treat1, fe vce(r)
est store m1_food

xtreg l_food_exp wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, fe vce(r)
est store m2_food

xtreg l_food_exp wave fo_maiz p4p_r treat1 treat2 treat3 treat4, fe vce(r)
est store m3_food

xtreg l_food_exp wave fo_maiz p4p_r treat1 treat2 treat3 treat4 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, fe vce(r)
est store m4_food

esttab m1_food m2_food m3_food m4_food , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab m1_food m2_food m3_food m4_food using "C:\Users\dadzie\Desktop\Research Work\Estimation_results\aerc\mz_food_2016.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace




***CRE Model ****
gen wave1 = (round == 2)
gen wave2 = (round == 3)

gen w1_p4p = wave1*p4p_r
gen w2_p4p = wave2*p4p_r 

regress l_maiz_sales p4p_r wave1 wave2 w1_p4p w2_p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r
est store mz_rev  //  maiz revenue

regress l_maiz_sales p4p_r wave1 wave2 w1_p4p w2_p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust)
est store mz_rev_cre   //  maiz revenue  with CRE model 
  

regress   maiz_sold_r  p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r
est store mz_sale 

/* xtreg maiz_sold_r  p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r,fe 
est store mz_sale_fe  */

regress   maiz_sold_r  p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust) 
est store mz_sale_cre  


regress   maiz_fo_r    p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r
est store mz_fo

/* xtreg maiz_fo_r    p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, fe
est store mz_fo_fe */

regress   maiz_fo_r    p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust) 
est store mz_fo_cre

regress food_exp_r   p4p_r  wave1 wave2 w1_p4p w2_p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust) 
est store food_exp_cre

regress nfood_exp_r  p4p_r wave1 wave2 w1_p4p w2_p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust) 
est store n_food_exp_cre


regress maiz_sales_r  p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust) 


esttab food_exp_cre n_food_exp_cre  , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab food_exp_cre n_food_exp_cre using "C:\Users\dadzie\Desktop\Research Work\Estimation_results\aerc\mz_food_exp.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace



esttab mz_rev  mz_rev_cre  , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab mz_rev  mz_rev_cre using "C:\Users\dadzie\Desktop\Research Work\Estimation_results\aerc\mz_rev_cre.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace


esttab mz_rev  mz_rev_cre mz_fo mz_fo_cre , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab mz_sale  mz_sale_cre mz_fo mz_fo_cre using "C:\Users\dadzie\Desktop\Research Work\Estimation_results\aerc\mz_fo_2016.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace




regress   maiz_sold_r  p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust) 
est store mz_sale_cre  

regress   maiz_sold_r  p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(cluster u_hh_fo) 


regress   maiz_fo_r    p4p_r years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r yrs_fo_  assist_ land_r_ l_farm_ hhsize_, vce(robust) 
est store mz_fo_cre


****************************************************************
***DIFFERENCES IN DIFFERENCES APPROACH WITH MATCHING ***********
****************************************************************

/* diff fte, t(treated) p(t) cov(bk kfc roys) kernel id(id)
       d_var  p4p     round     x_vars                hh_id   */
keep maiz_fo_r maiz_sold_r p4p_r round years_fo_r assist_12m_r land_r land_farm_r hhsize_r u_hh_fo

su maiz_fo_r maiz_sold_r p4p_r round years_fo_r assist_12m_r land_r land_farm_r hhsize_r u_hh_fo,

gen c22=1 if maiz_fo_r != . & maiz_sold_r != . & p4p_r != . & round != . & years_fo_r != . & assist_12m_r != . & land_r != . & land_farm_r != . ///
                          & hhsize_r    != . 
	   
drop if round== 3
	   
 

*regress maiz_fo  p4p years_fo  assist_12m  land land_farm hhsize sex_hd age_hd educ_hd

**years_fo_r2  assist_12m_r2  land_r2 land_farm_r2 hhsize_r2 sex_hd_r2 age_hd_r2 educ_hd_r2 
*maiz_areat_r2 maiz_hvstt_r2 rice_areat_r2 rice_hvstt_r2 cowp_areat_r2 cowp_hvstt_r2


/*  Naive DID using first two rounds  */
 * maiz_sold_r  maiz_fo_r  l_maiz_sales p4p_r wave1   
reg y time treated did, r


reg maiz_sold_r wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r if wave != 2, r 


reg l_maiz_sales wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r if wave != 2, r 



/* Different specification for the DID using baseline and last survey   */

reg l_maiz_sales wavy p4p_r treat1y years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r if wave != 1, r 


/* Difference in Difference with Propensity Score matching techniques 
  this code actually gets some results
  need to interpret them */

 recode assist_tech_r (0=0) (1=1), gen(tech_assist)
replace tech_assist = 0 if tech_assist == . 
 recode assist_credit_r (0=0) (1=1), gen(credit_assist)
replace credit_assist = 0 if credit_assist == .  
  recode assist_cash_r (0=0) (1=1), gen(cash_assist) 
replace cash_assist = 0 if cash_assist == .   
  recode assist_stor_r (0=0) (1=1), gen(stor_assist) 
replace stor_assist = 0 if stor_assist == .   

gen 

*tech_assist credit_assist cash_assist stor_assist  

logit p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r tech_assist credit_assist cash_assist stor_assist if wave != 2
est store logit_res


esttab logit_res , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab logit_res using "C:\Users\dadzie\Desktop\New folder\Research Work\Estimation_results\aerc\logit_res.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace



 
psmatch2 p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r tech_assist credit_assist cash_assist stor_assist if wave != 2  & wave != 1, out(maiz_fo_r) common logit
est store psmatchp4p

psmatch2 p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r tech_assist credit_assist cash_assist stor_assist if wave != 2 , out(maiz_fo_r) common
est store psmatchp4p_prob


esttab psmatchp4p  psmatchp4p_prob , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab psmatchp4p  psmatchp4p_prob using "C:\Users\dadzie\Desktop\New folder\Research Work\Estimation_results\aerc\psmtach.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace


logit p4p years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r tech_assist credit_assist cash_assist stor_assist if wave != 2  & wave != 1


psgraph

pstest years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r tech_assist credit_assist cash_assist stor_assist

*food_exp_r nfood_exp_r maiz_areat_r maiz_hvstt_r maiz_sales_r maiz_sold_r

		
diff maiz_fo_r if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report  addcov(sex_hd_r age_hd_r educ_hd_r) support
diff maiz_fo_r if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report support logit 

*l_maiz_sales  l_food_exp l_nfood_exp  maiz_sold_r
diff maiz_sold_r if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report support logit pscore(_ps)
est store diff_mzfo

diff l_maiz_sales if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report support logit 
est store diff_mzsales

diff food_exp if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report support 
est store diff_fdexp


diff l_nfood_exp if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report support logit pscore(_ps)
est store diff_nfdexp


esttab diff_mzfo  diff_mzsales diff_fdexp diff_nfdexp  , b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N N_g )
esttab diff_mzfo  diff_mzsales diff_fdexp diff_nfdexp using "C:\Users\dadzie\Desktop\New folder\Research Work\Estimation_results\aerc\diff_match.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(ll N F p ) replace






diff l_maiz_sales if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report  addcov(sex_hd_r age_hd_r educ_hd_r)

diff maiz_fo_r if wave != 2 , t(p4p_r) p(wave) cov(years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r) kernel id(u_hh_fo) report  addcov(sex_hd_r age_hd_r educ_hd_r)

/* So far i understand the kind of data that i am working with and some of the results 
  The key here is the most efficient(or strategy to minimize data loss) of incorporating the two followup surveys
  Method 1 : traditional Diff in diff  ( this can be done on pre vs post1 and pre vs post2
  Method 2 : Diff in diff with propensity score matching ( also done with pre vs post1 or pre vs post2 
  Method 3 : Diff in diff in diff  ( approach with Muamba : here he used pre vs post1 
  Method 4 : David Mckenzie approach where pre, post1 and post2 are used in a single estimation procedure
  
  Given the program goals, its really a case of using the diff in diff with matching 
  method 1 not qualifying 
  */


  /* David McKenzie recommends estimation methods should be picked dependent on the autocorrelation in the dataset (dependent variable) 
    Testing for autocorrelation using xtserial   */
xtserial maiz_sold_r wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r
	
xtserial l_maiz_sales wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r
xtserial maiz_fo_r wave p4p_r treat1 years_fo_r  assist_12m_r  land_r land_farm_r hhsize_r sex_hd_r age_hd_r educ_hd_r, output
	
/*   New question: what is the difference between Wooldridge autocorrelation test using xtserial and simple corr  */
	
/* ANCOVA-suggested by David Mckenzie is an extension of the anova command in stata  */

	  
