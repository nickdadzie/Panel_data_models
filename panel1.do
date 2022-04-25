clear
clear matrix
set mem 1g
set more off
****************************************

****************************************
/* **** USING THE AGGREGATE DATASETS      */

use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\New_Aggregates_1994-2004\land_123456.dta", clear    // land for each hh

*drop if hhid > 999

gen u_hhid =  q1a*100000 + q1c*1000 + hhid  
replace u_hhid = hhid  if q1a== . & hhid > 999
drop if u_hhid == . 

duplicates tag u_hhid, gen (chk)
drop if chk ==1

reshape long land, i(u_hhid) j(round)

drop  flag_ha_36 flag_ha_42 chk 
save ethio_123456.dta, replace 


use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\New_Aggregates_1994-2004\consumptionaggregates_123456.dta", clear
/*  mergin the aggregate data on hhsize n consumption  */
/* using PA (peasant association/vill) to reconcile paid */
gen     woreda = 1 if paid  == 1
replace woreda = 2 if paid == 2
replace woreda = 3 if paid == 3
replace woreda = 5 if paid == 5
replace woreda = 6 if paid == 6 
replace woreda = 7 if paid == 7 
replace woreda = 8 if paid == 8
replace woreda = 9 if paid == 9 
replace woreda = 10 if paid == 10 
replace woreda = 12 if paid == 12
replace woreda = 13 if paid == 13
replace woreda = 14 if paid == 14
replace woreda = 15 if paid == 15
replace woreda = 16 if paid == 16 
replace woreda = 4 if paid >=17 & paid < 21

gen q1b = woreda
/*  using woreda :q1b to get region  */
gen region = 1 if q1b >=1 & q1b < 3
replace region=3 if q1b >= 3 & q1b  < 7
replace region=4 if q1b >= 7 & q1b  < 11
replace region=7 if q1b >= 11 & q1b < 14
replace region=8 if q1b >= 14 & q1b <  15
replace region=9 if q1b >= 15 & q1b < 17 

gen q1a = region 
gen u_hhid =  q1a*100000 + paid*1000 + hhid  
replace u_hhid = hhid if hhid > 999 
 duplicates tag u_hhid, gen(wr)
drop if wr ==1

reshape long hhsize cons poor, i(u_hhid) j(round)

 save hhsize_123456.dta, replace
 
use ethio_123456.dta, clear

merge 1:1 u_hhid round using hhsize_123456.dta, keepusing(hhsize cons poor)
drop if _merge == 2
drop _merge

save ethio_123456.dta, replace 

/*  merging the aggregate data on livestock units  */ 
use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\New_Aggregates_1994-2004\livestockaggregates_123456.dta", clear

gen q1a = 1 if paid >=1 & paid <3
replace q1a =3 if paid >=3 & paid <7
replace q1a =4 if paid >=7 & paid <11
replace q1a =7 if paid >=11 & paid <14
replace q1a =8 if paid >=14 & paid < 15
replace q1a =9 if paid >=15 & paid < 21 

gen u_hhid =  q1a*100000 + paid*1000 + hhid  
replace u_hhid = hhid if hhid > 999 
duplicates tag u_hhid, gen(wr1)
drop if wr1 ==1

reshape long  livval  lsu, i(u_hhid) j(round)
save livestk_123456.dta, replace

use ethio_123456.dta, clear 

merge 1:1 u_hhid round using livestk_123456.dta, keepusing(livval  lsu)
drop if _merge == 2
drop _merge


save ethio_123456.dta, replace 

/* demographic features for r123 */
use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\1994-95\demo123.dta",clear
gen q1a =  1 if q1b >=1 & q1b < 3
replace q1a=3 if q1b >= 3 & q1b  < 7
replace q1a=4 if q1b >= 7 & q1b  < 11
replace q1a=7 if q1b >= 11 & q1b < 14
replace q1a=8 if q1b >= 14 & q1b <  15
replace q1a=9 if q1b >= 15 & q1b < 17

gen u_hhid = q1a*100000 +  q1c*1000 + hhid

gen agehead1 = q11_6a if q11_1b ==1
gen hhd_die2  = 1 if (agehead1> 0 & agehead1 < .) & ind2 == .
gen hhd_die3  = 1 if (agehead1> 0 & agehead1 < .) & ind3 == .
gen sex_hd1 = q11_5 if q11_1b == 1
save demo123_r, replace
use demo123_r, clear
collapse (count) ind1 ind2 ind3 , by(u_hhid)     // collapsing the dataset 
reshape long ind, i(u_hhid) j(round)        // converting into long form 
save indiv_r123, replace
 
use ethio_123456.dta, clear
merge 1:1 u_hhid round using indiv_r123.dta,
drop if _merge == 2
drop _merge

save ethio_123456.dta, replace

use demo123_r, clear  
collapse (min) agehead1 hhd_die2 hhd_die3 sex_hd1, by(u_hhid)
gen agehead2 = agehead1     if hhd_die2 != 1
gen agehead3 = agehead1 + 1 if hhd_die3 != 1 
gen sex_hd2 = sex_hd1       if hhd_die2 != 1
gen sex_hd3 = sex_hd1       if hhd_die2 != 1
save agesex_123, replace
reshape long agehead sex_hd, i(u_hhid) j(round)        // converting into long form 

save agesex123, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using agesex123.dta,
drop if _merge == 2
drop _merge

save ethio_123456.dta, replace
/* demographic features for r4 */
use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\1997\age_sex_r4.dta", clear
gen u_hhid =  q1a*100000 +  q1c*1000 + q1d   
gen agehead4 = age4 if reltn4 == 1
gen sex_hd4 = sex if reltn4 == 1
replace agehead4 = age4 if reltn4 == -9
replace sex_hd4 = sex if reltn4 == -9

collapse (min) agehead4 sex_hd4, by(u_hhid)
gen round = 4
save agesex4, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using agesex4.dta, keepusing(agehead4 sex_hd4)
drop if _merge == 2
drop _merge
replace agehead = agehead4 if round ==4
replace sex_hd = sex_hd4   if round == 4
drop agehead4 sex_hd4

save ethio_123456.dta, replace

/* demographic features for r5 */
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_5_1999\p1sec1.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid
gen agehead5 =  p1s1q4 if  p1s1q2 == 1
gen sex_hd5 =  p1t1q2 if p1s1q2  == 1

collapse (min) agehead5 sex_hd5, by(u_hhid)
gen round = 5
save agesex5, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using agesex5.dta, keepusing(agehead5 sex_hd5)
drop if _merge == 2
drop _merge
replace agehead = agehead5 if round ==5
replace sex_hd = sex_hd5   if round == 5
drop agehead5 sex_hd5

save ethio_123456.dta, replace

/* demographic features for r6 */
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_6_2004\r6p1s1a.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid  
gen agehead6 =  q11a_2  if  q11a_1 ==1

collapse (min) agehead6 , by(u_hhid)
gen round = 6
save age6, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using age6.dta, keepusing(agehead6)
drop if _merge == 2
drop _merge
replace agehead = agehead6 if round ==6
drop agehead6

save ethio_123456, replace
* Checking the age and sex  vars
*do age_sexchk
drop  q1a q1b q1c paid hhid land hhsize cons poor livval lsu ind hhd_die2 hhd_die3
reshape wide agehead sex_hd, i(u_hhid) j(round)
gen chk3 =  agehead3 - agehead1   // 1261 hhs correct transition
gen chk4 = agehead4 - agehead1
tab chk4 if chk3 ==1
*drop if chk3 != 1   // has to be used REALLY
count if chk4 < 0 & chk3 == 1   // 81 obs with chk4 < 0   ( might drop obs)
replace agehead4 = agehead1 + 3 if chk4 == 0

save agechk, replace 
merge 1:1 u_hhid using agesex_123.dta, keepusing(hhd_die2 hhd_die3) 
drop if _merge == 2
drop _merge
count if hhd_die3 ==1 & chk4 < 0 & chk3 ==1 
count if hhd_die2 ==1 & chk4 < 0 & chk3 ==1 
 
gen chk5 = agehead5 - agehead1
tab chk5 if chk3 == 1
count if chk5 < 0 & chk3 ==1  

gen chk6 = agehead6 - agehead1
tab chk6 if chk3 ==1 
save agechk, replace
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_6_2004\r6p1s0.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid
gen round = 6
duplicates tag u_hhid, gen(c1)
drop if c1 == 1
rename  q100_2 hh_6_y5
save r6p1s0_id, replace
use agechk, clear

merge 1:1 u_hhid using r6p1s0_id.dta, keepusing(hh_6_y5)
drop if _merge == 2
drop _merge

replace sex_hd6 = sex_hd5 if hh_6_y5==1
replace agehead6 = agehead5 + 5 if hh_6_y5 ==1

drop  chk3 chk4 hhd_die2 hhd_die3 chk5 chk6 hh_6_y5
reshape long agehead sex_hd, i(u_hhid) j(round)        // converting into long form 
rename agehead ageheadt
rename sex_hd sex_hdt
save agechk, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using agechk.dta, keepusing(ageheadt sex_hdt)
drop if _merge== 2
drop _merge
gen chk11 = 1 if agehead > 0 & agehead != . & ageheadt == .
replace agehead = ageheadt if chk11 != 1
replace sex_hd = sex_hdt
drop chk11 sex_hdt ageheadt

replace agehead = 27 if u_hhid == 102032  & round == 1
replace agehead = 27 if u_hhid == 102032  & round == 2
replace agehead = 28 if u_hhid == 102032  & round == 3
save ethio_123456, replace

/* education level of household head */
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_1_1994a\r1p1s1t4.dta", clear
gen prim_edu =  (q12_5 > 3 & q12_5 < .)
gen hhd_edu1 = prim_edu if q11_1b == 1
gen hhm_edu1 = prim_edu 
gen u_hhid =  q1a*100000 +  q1c*1000 + q5

collapse (sum) hhd_edu1 hhm_edu1 , by(u_hhid)     //  education levels for round 1
gen round = 1
save edu_r1, replace
use ethio_123456.dta, clear
merge 1:1 u_hhid round using edu_r1.dta, keepusing(hhd_edu1 hhm_edu1)
drop if _merge==2
drop _merge
rename hhd_edu1 hhd_edu
rename hhm_edu1 hhm_edu
save ethio_123456.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_2_1994b\r2p1s2a.dta", clear
gen u_hhid =  q1a*100000 +  q1c*1000 + q2   
gen prim_edu = (q12_1b >8 & q12_1b < .) 
gen hhd_edu2 = prim_edu if q12_1a ==1
gen hhm_edu2 = prim_edu

collapse (sum) hhd_edu2 hhm_edu2 , by(u_hhid) // education levels for round 2
gen round =2
save edu_r2, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using edu_r2.dta, keepusing(hhd_edu2 hhm_edu2)
drop if _merge==2
drop _merge
replace hhd_edu= hhd_edu2 if round ==2 
replace hhm_edu = hhm_edu2 if round ==2
drop hhd_edu2 hhm_edu2
save ethio_123456.dta, replace

* FOR ROUND 3 COPY EDUCATION LEVELS FOR ROUND 2
/* modifying and copying education levels from r2 for r3   */
use edu_r2, clear
drop round
gen round=3
rename hhd_edu2 hhd_edu3
rename hhm_edu2 hhm_edu3
save edu_r3, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using edu_r3.dta, keepusing(hhd_edu3 hhm_edu3)
drop if _merge == 2
drop _merge
replace hhd_edu = hhd_edu3 if round == 3
replace hhm_edu = hhm_edu3 if round == 3
drop hhd_edu3 hhm_edu3
save ethio_123456.dta, replace


* FOR ROUND 4 , THE ROSTER IS UPDATED AND THE EDUCATIONAL LEVEL OF THE NEW HH MEMBERS ARE ADDED
* this indicates that for round 4 can copy edu of round 3
use edu_r3, clear
drop round
gen round = 4
rename hhd_edu3 hhd_edu4
rename hhm_edu3 hhm_edu4
save edu_r4, replace

use ethio_123456.dta, clear
merge 1:1 u_hhid round using edu_r4.dta, keepusing(hhd_edu4 hhm_edu4)
drop if _merge ==2
drop _merge
replace hhd_edu = hhd_edu4 if round ==4
replace hhm_edu = hhm_edu4 if round == 4
drop hhd_edu4 hhm_edu4
save ethio_123456.dta, replace


* ROUND FIVE HAS EDUCATIONAL DATA AGAIN. 
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_5_1999\p1sec2.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid          // round 5

gen prim_edu = (p1s2q3 > 8 & p1s2q3 < . )
gen hhd_edu5 = prim_edu if  p1s2_id1 == 1
gen hhm_edu5 = prim_edu

collapse(sum) hhd_edu5 hhm_edu5 , by(u_hhid)     // education levels for round 5
gen round = 5
save edu_r5, replace
use ethio_123456, clear
merge 1:1 u_hhid round using edu_r5.dta, keepusing(hhd_edu5 hhm_edu5)
drop if _merge ==2
drop _merge
replace hhd_edu = hhd_edu5 if round==5
replace hhm_edu = hhm_edu5 if round==5
drop hhd_edu5 hhm_edu5
save ethio_123456.dta, replace

*Round 6 educational info
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_6_2004\r6p1s1a.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid   
gen prim_edu =  (q11a_5 > 6 &  q11a_5 < .)
gen hhd_edu6 = prim_edu if  q11a_1 ==1 
gen hhm_edu6 = prim_edu
collapse (sum) hhd_edu6 hhm_edu6, by(u_hhid)
gen round = 6

save edu_r6, replace
use ethio_123456.dta, clear
merge 1:1 u_hhid round using edu_r6.dta, keepusing(hhd_edu6 hhm_edu6)
drop if _merge==2
drop _merge
replace hhd_edu = hhd_edu6 if round == 6
replace hhm_edu = hhm_edu6 if round == 6
drop hhd_edu6 hhm_edu6
save ethio_123456.dta, replace
 
/*  MERGING   HHSIZE CONS AND POOR FROM ROUND 7 (later Livval Lsu Sex_hd)   */

use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Aggregates_2009\consumptionAggrgates_r7.dta", clear    // round 7
gen u_hhid = region*100000 + pa*1000 + hhid 
drop cons7 
rename conspc7 cons7
rename poorpc7 poor7
rename hhsize hhsize7
gen round = 7
drop if u_hhid == 319001 & hhid == 1
save cons_7.dta, replace

use ethio_123456.dta, clear
drop  q1a q1b q1c paid hhid ind hhd_die2 hhd_die3 hhd_edu hhm_edu land agehead  sex_hd livval lsu

reshape wide hhsize cons poor, i(u_hhid) j(round)                 // reshaping to wide in order to add round 7 hhsize, cons n poor
merge 1:1 u_hhid using cons_7.dta, keepusing(hhsize7 cons7 poor7)
drop if _merge == 2
drop _merge

reshape long hhsize cons poor, i(u_hhid) j(round)        //  reshaping to long form and then add initial vars
save ethio_1234567.dta, replace                                  // the filename changes here to ethio_1234567.dta

/* file  many to one merging */
use ethio_123456.dta, clear
drop if round != 1
save ethio_r1_2merge, replace

use ethio_1234567.dta, clear
merge m:1 u_hhid using ethio_r1_2merge, keepusing(q1a q1b q1c paid hhid)      // merging the regional vars across all the hhs
drop _merge

merge 1:1 u_hhid round using ethio_123456.dta, keepusing(ind hhd_die2 hhd_die3 hhd_edu hhm_edu land agehead  sex_hd livval lsu)
drop _merge
save ethio_1234567.dta, replace

merge 1:1 u_hhid round using cons_7.dta, keepusing (malehead)             // merging the sex of hhead from R7
drop if _merge == 2
drop _merge
replace sex_hd = malehead if round == 7
drop malehead
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Aggregates_2009\livestock_agg_round7.dta", clear
gen u_hhid = region*100000 + pa*1000 + hhid 
drop if u_hhid == 319001 & hhid == 1
gen round = 7

save liv_lsu_7, replace

use ethio_1234567, clear
merge 1:1 u_hhid round using liv_lsu_7.dta, keepusing ( lvs_val7 tlu7)
drop if _merge == 2
drop _merge
replace livval = lvs_val7 if round == 7
replace lsu    = tlu7     if round == 7                             // merging livestock val and livestock units for round 7
drop lvs_val7 tlu7
save ethio_1234567, replace 


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_7_2009\R7p1_s1a.dta", clear
gen u_hhid = region*100000 + pa*1000 + hhid 
drop if u_hhid == 319001 & hhid == 1
gen agehead7 = q2p1s1a if q1p1s1a == 1
gen edu = (q2ap1s1a > 3 &  q2ap1s1a !=  .)
gen h_edu7 = edu if q1p1s1a == 1
gen chk1 = (q2p1s1a > 0 & q1p1s1a == 1)
collapse (sum) chk1 agehead7 h_edu7, by(u_hhid)
drop if chk1 == 2
gen round = 7
save age_edu_7, replace

use ethio_1234567, clear
merge 1:1 u_hhid round using age_edu_7.dta, keepusing (agehead7 h_edu7)             // merging age n edu of hhead for Round 7
drop if _merge == 2
drop _merge
replace agehead = agehead7 if round == 7
replace hhd_edu = h_edu7   if round == 7 
drop agehead7 h_edu7
save ethio_1234567.dta, replace




/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  current progress on merging the 2009 dataset   
  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/ 
 
/*    AGRICULTURAL OUTPUT AND AREA    */
use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Agricultural_Aggregates_1994-2004\area_output_94.dta",clear

gen u_hhid = q1a*100000 + q1c*1000 + hhid
drop if u_hhid == . 
gen round = 1
save area_output_r1, replace

duplicates tag u_hhid, gen(chk1)


use ethio_1234567.dta, clear
merge 1:1 u_hhid round using area_output_r1.dta, keepusing(wtefha94 btefha94 barlha94 whtha94 maizha94 sorgha94 coffha94 chatha94 ensetha94  ///
 wtefyld94 btefyld94 barlyld94 whtyld94 maizyld94 sorgyld94 coffyld94 chatyld94 ensetyld94)
drop if _merge == 2
drop _merge
rensfix 94    //  renames the suffixes in the crop names from wtefha94 to wtefha 
save ethio_1234567.dta, replace



use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Agricultural_Aggregates_1994-2004\area_output_r2r3rev.dta",clear
gen q1a =  1 if q1b >=1 & q1b < 3
replace q1a=3 if q1b >= 3 & q1b  < 7
replace q1a=4 if q1b >= 7 & q1b  < 11
replace q1a=7 if q1b >= 11 & q1b < 14
replace q1a=8 if q1b >= 14 & q1b <  15
replace q1a=9 if q1b >= 15 & q1b < 17

gen u_hhid = q1a*100000 + paid*1000 + hhid
gen round = 3
*rensfix 95
save area_output_r3.dta, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using area_output_r3.dta, keepusing(wtefha95 btefha95 barlha95 whtha95 maizha95 sorgha95 coffha95 chatha95 ensetha95  ///
 wtefyld95 btefyld95 barlyld95 whtyld95 maizyld95 sorgyld95 coffyld95 chatyld95 ensetyld95) 
drop if _merge == 2
drop _merge
local listx2 "wtefha btefha barlha whtha maizha sorgha coffha chatha ensetha wtefyld btefyld barlyld whtyld maizyld sorgyld coffyld chatyld ensetyld"
foreach x of local listx2 {
replace `x' = `x'95 if round == 3
drop `x'95
}
*
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Agricultural_Aggregates_1994-2004\area_output_r2r3rev.dta",clear
gen q1a =  1 if q1b >=1 & q1b < 3
replace q1a=3 if q1b >= 3 & q1b  < 7
replace q1a=4 if q1b >= 7 & q1b  < 11
replace q1a=7 if q1b >= 11 & q1b < 14
replace q1a=8 if q1b >= 14 & q1b <  15
replace q1a=9 if q1b >= 15 & q1b < 17

gen u_hhid = q1a*100000 + paid*1000 + hhid
gen round = 2
*rensfix r2r3
save area_output_r2.dta, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using area_output_r2.dta, keepusing( wtefyldr2r3 btefyldr2r3 barlyldr2r3 whtyldr2r3 maizyldr2r3 sorgyldr2r3 coffyldr2r3 chatyldr2r3 ensetyldr2r3)
/*   have produce  values for 94b,  can use ha values from 94a to create yld for 94b  */
drop if _merge == 2
drop _merge
local listx21 "wtefyld btefyld barlyld whtyld maizyld sorgyld coffyld chatyld ensetyld"
foreach x of local listx21 {
replace `x' = `x'r2r3 if round == 2
drop `x'r2r3
}
*
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Agricultural_Aggregates_1994-2004\area_output_97.dta",clear

replace q1a=1 if q1b >= 1 & q1b  < 3 & q1a == .
replace q1a=3 if q1b >= 3 & q1b  < 7 & q1a == .
replace q1a=4 if q1b >= 7 & q1b  < 11 & q1a == .
replace q1a=7 if q1b >= 11 & q1b < 14 & q1a == .
replace q1a=8 if q1b >= 14 & q1b < 15 & q1a == .
replace q1a=9 if q1b >= 15 & q1b < 17 & q1a == .

gen u_hhid = q1a*100000 + paid*1000 + hhid
duplicates tag u_hhid, gen(wr2)
gen round = 4
save area_output_r4, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using area_output_r4.dta, keepusing( wtefha97 btefha97 barlha97 whtha97 maizha97 sorgha97 coffha97 chatha97 ensetha97 ///
 wtefyldr4 btefyldr4 barlyldr4 whtyldr4 maizyldr4 sorgyldr4 coffyldr4 chatyldr4 ensetyldr4)
drop if _merge == 2
drop _merge
local listx23 "wtefha btefha barlha whtha maizha sorgha coffha chatha ensetha "
foreach x of local listx23 {
replace `x' = `x'97 if round == 4
drop `x'97
}
*
local listx24 "wtefyld btefyld barlyld whtyld maizyld sorgyld coffyld chatyld ensetyld"
foreach x of local listx24{
replace `x' = `x'r4 if round ==4
drop `x'r4
}
*
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Agricultural_Aggregates_1994-2004\area_output_99.dta",clear
gen q1a = 1 if paid >=1 & paid <3
replace q1a =3 if paid >=3 & paid <7
replace q1a =4 if paid >=7 & paid <11
replace q1a =7 if paid >=11 & paid <14
replace q1a =8 if paid >=14 & paid < 15
replace q1a =9 if paid >=15 & paid < 21 

gen u_hhid = q1a*100000 + paid*1000 + hhid
replace u_hhid = hhid if hhid > 999 
duplicates tag u_hhid, gen(ch2)
drop if ch2 ==1
gen round = 5
save area_output_r5, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using area_output_r5.dta, keepusing( wtefha99 btefha99 barlha99 whtha99 maizha99 sorgha99 coffha99 chatha99 ensetha99 ///
 wtefyld99 btefyld99 barlyld99 whtyld99 maizyld99 sorgyld99 coffyld99 chatyld99 ensetyld99)
drop if _merge == 2
drop _merge
local listxw2 "wtefha btefha barlha whtha maizha sorgha coffha chatha ensetha wtefyld btefyld barlyld whtyld maizyld sorgyld coffyld chatyld ensetyld"
foreach x of local listxw2 {
replace `x' = `x'99 if round == 5
drop `x'99
}
*
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Agricultural_Aggregates_1994-2004\area_output_04rev.dta",clear
gen q1a = 1 if paid >=1 & paid <3
replace q1a =3 if paid >=3 & paid <7
replace q1a =4 if paid >=7 & paid <11
replace q1a =7 if paid >=11 & paid <14
replace q1a =8 if paid >=14 & paid < 15
replace q1a =9 if paid >=15 & paid < 21 

gen u_hhid = q1a*100000 + paid*1000 + hhid
replace u_hhid = hhid if hhid > 999 
duplicates tag u_hhid, gen(ch12)
drop if ch12 ==1
gen round = 6
save area_output_r6, replace
 
use ethio_1234567.dta, clear
merge 1:1 u_hhid round using area_output_r6.dta, keepusing( wtefha04 btefha04 barlha04 whtha04 maizha04 sorgha04 coffha04 chatha04 ensetha04 ///
 wtefyld04 btefyld04 barlyld04 whtyld04 maizyld04 sorgyld04 coffyld04 chatyld04 ensetyld04)
drop if _merge == 2
drop _merge
local listxw2 "wtefha btefha barlha whtha maizha sorgha coffha chatha ensetha wtefyld btefyld barlyld whtyld maizyld sorgyld coffyld chatyld ensetyld"
foreach x of local listxw2 {
replace `x' = `x'04 if round == 6
drop `x'04
}
*
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Ethiopia_Aggregates\Aggregates_2009\erhs7_meher_area_output_cereals_2009.dta", clear     // round 7 agric output data
gen u_hhid = region*100000 + pa*1000 + hhid 
drop if u_hhid == 319001 & hhid == 1
gen round = 7 
save area_output_r7, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using area_output_r7.dta, keepusing (wtefha09 btefha09 barlha09 whtha09 maizha09 sorgha09        /// 
           sorgyld09 maizyld09 whtyld09 barlyld09 btefyld09 wtefyld09)
drop if _merge == 2
drop _merge
local list09ag "wtefha btefha barlha whtha maizha sorgha  sorgyld maizyld whtyld barlyld btefyld wtefyld"
foreach x of local list09ag {
replace `x' = `x'09 if round == 7
drop `x'09
}
* 
save ethio_1234567.dta, replace

 
* MERGING DATA ON NON-FARM EARNINGS
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_1_1994a\r1p1s8.dta",clear  // ROund 1
gen u_hhid =  q1a*100000 +  q1c*1000 + q5
gen ffw = (q18_3 ==10)
duplicates tag u_hhid , gen(hhy)
collapse (sum)  q18_6a q18_6b ffw, by(u_hhid)
egen nfinc = rowtotal(q18_6a  q18_6b), missing
gen round = 1

save nfinc_r1, replace
use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_1_1994a\r1p3s6.dta", clear    // round 1 direct aid
gen u_hhid =  q1a*100000 +  q1c*1000 + q5
gen g_aid = (q36_4c == 5 )
gen aid = (q36_4c == 6)
gen f_ffw = (q36_4c == 7) 
collapse (sum) g_aid aid f_ffw, by(u_hhid)
gen round = 1
save n_ffw1, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using nfinc_r1.dta, keepusing(nfinc ffw)
drop if _merge == 2
drop _merge

merge 1:1 u_hhid round using n_ffw1.dta, keepusing(g_aid aid f_ffw)      
drop if _merge == 2
drop _merge

save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_2_1994b\r2p1s7a.dta", clear    
gen u_hhid =  q1a*100000 +  q1c*1000 + q2                          // round 2
gen ffw2 = (q17_3 ==10)
collapse (sum)  q17_6a q17_6b ffw, by(u_hhid)
egen nfinc2 = rowtotal( q17_6a  q17_6b), missing
gen round = 2
save nfinc_r2, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_2_1994b\r2p3s6a.dta", clear    // round 2 direct aid
gen u_hhid =  q1a*100000 +  q1c*1000 + q2  
gen g_aid2 = (q36_4c == 5 )
gen aid2 = (q36_4c == 6)
gen f_ffw2 = (q36_4c == 7) 
collapse (sum) g_aid2 aid2 f_ffw2, by(u_hhid)
gen round = 2
save n_ffw2, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using nfinc_r2.dta, keepusing(nfinc2 ffw2)
drop if _merge == 2
drop _merge
replace ffw = ffw2 if round == 2 
replace nfinc = nfinc2 if round == 2
drop ffw2 nfinc2

merge 1:1 u_hhid round using n_ffw2.dta, keepusing(g_aid2 aid2 f_ffw2)
drop if _merge == 2
drop _merge
replace g_aid = g_aid2 if round == 2 
replace aid = aid2 if round == 2
replace f_ffw = f_ffw2 if round == 2
drop g_aid2 aid2 f_ffw2

save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_3_1995\r3p1s5a3", clear
gen u_hhid =  q1a*100000 +  q1c*1000 + q2                          // round 3
gen ffw3 = (q15_3 ==10)
collapse (sum)  q15_6a q15_6b ffw3, by(u_hhid)
egen nfinc3 =  rowtotal(q15_6a q15_6b), missing
gen round = 3
save nfinc_r3, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_3_1995\r3p3s6a3.dta", clear
gen u_hhid =  q1a*100000 +  q1c*1000 + q2                          // round 3 direct aid
gen g_aid3 = (q36_4c == 5 )
gen aid3 = (q36_4c == 6)
gen f_ffw3 = (q36_4c == 7) 
collapse (sum) g_aid3 aid3 f_ffw3, by(u_hhid)
gen round = 3
save n_ffw3, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using nfinc_r3.dta, keepusing(nfinc3 ffw3)
drop if _merge == 2
drop _merge
replace ffw = ffw3 if round == 3 
replace nfinc = nfinc3 if round == 3
drop ffw3 nfinc3

merge 1:1 u_hhid round using n_ffw3.dta, keepusing(g_aid3 aid3 f_ffw3)
drop if _merge == 2
drop _merge
replace g_aid = g_aid3 if round == 3 
replace aid = aid3 if round == 3
replace f_ffw = f_ffw3 if round == 3
drop g_aid3 aid3 f_ffw3
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_4_1997\r4p1s7af.dta", clear
gen u_hhid =  q1a*100000 +  q1c*1000 + q1d                          // round 4
gen ffw4 = (q17_3 == 10)
collapse (sum) q17_6a q17_6b ffw4, by(u_hhid)
egen nfinc4 = rowtotal(q17_6a  q17_6b), missing
gen round = 4
save nfinc_r4, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_4_1997\r4p3s6f.dta", clear
gen u_hhid =  q1a*100000 +  q1c*1000 + q1d                          // round 4 direct aid 
gen g_aid4 = (q36_4c == 5 )
gen aid4 = (q36_4c == 6)
gen f_ffw4 = (q36_4c == 7) 
collapse (sum) g_aid4 aid4 f_ffw4, by(u_hhid)
gen round = 4
save n_ffw4, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using nfinc_r4.dta, keepusing(nfinc4 ffw4)
drop if _merge == 2
drop _merge
replace ffw = ffw4 if round == 4 
replace nfinc = nfinc4 if round == 4
drop ffw4 nfinc4

merge 1:1 u_hhid round using n_ffw4.dta, keepusing(g_aid4 aid4 f_ffw4)
drop if _merge == 2
drop _merge
replace g_aid = g_aid4 if round == 4 
replace aid = aid4 if round == 4
replace f_ffw = f_ffw4 if round == 4
drop g_aid4 aid4 f_ffw4
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_5_1999\p1sec6.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid          // round 5
gen ffw5 = (p1s6q2== 8)
collapse(sum)  p1s6q71a p1s6q71b p1s6q72a p1s6q72b ffw5, by(u_hhid)
egen nfinc5 =  rowtotal( p1s6q71a  p1s6q72a), missing
egen nfinc12 = rowtotal(p1s6q71b  p1s6q72b), missing
gen round  = 5
save nfinc_r5, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_5_1999\p3sec3.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid          // round 5 direct aid
gen g_aid5 = (p3s3q4_3 == 5 )
gen aid5 = (p3s3q4_3 == 6)
gen f_ffw5 = (p3s3q4_3 == 7) 
collapse (sum) g_aid5 aid5 f_ffw5, by(u_hhid)
gen round = 5
save n_ffw5, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using nfinc_r5.dta, keepusing(nfinc5  nfinc12 ffw5)
drop if _merge == 2
drop _merge
replace ffw = ffw5 if round == 5 
replace nfinc = nfinc5 if round == 5
drop ffw5 nfinc5 nfinc12 
save ethio_1234567.dta, replace

merge 1:1 u_hhid round using n_ffw5.dta, keepusing( g_aid5 aid5 f_ffw5)
drop if _merge == 2
drop _merge
replace g_aid = g_aid5 if round == 5 
replace aid = aid5 if round == 5
replace f_ffw = f_ffw5 if round == 5
drop g_aid5 aid5 f_ffw5
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_6_2004\r6p1s6_Q2to7", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid          // round 6
gen ffw6 = (q16_3 == 10)
collapse (sum)  q16_6a  q16_6b ffw6, by(u_hhid)
egen nfinc6 =  rowtotal(q16_6a q16_6b), missing
gen round = 6
save nfinc_r6, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_6_2004\r6p3s6.dta", clear
gen u_hhid =  q1a*100000 +  paid*1000 + hhid          // round 6 direct aid 
gen g_aid6 = (q36_4c == 5 )
gen aid6 = (q36_4c == 6)
gen f_ffw6 = (q36_4c == 7) 
collapse (sum) g_aid6 aid6 f_ffw6, by(u_hhid)
gen round = 6
save n_ffw6, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using nfinc_r6.dta, keepusing(nfinc6 ffw6)
drop if _merge == 2
drop _merge
replace ffw = ffw6 if round == 6 
replace nfinc = nfinc6 if round == 6
drop ffw6 nfinc6
save ethio_1234567.dta, replace

merge 1:1 u_hhid round using n_ffw6.dta, keepusing(g_aid6 aid6 f_ffw6)
drop if _merge == 2
drop _merge
replace g_aid = g_aid6 if round == 6 
replace aid = aid6 if round == 6
replace f_ffw = f_ffw6 if round == 6
drop g_aid6 aid6 f_ffw6
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_7_2009\R7p1_s6b.dta", clear       // round 7
gen u_hhid = region*100000 + pa*1000 + hhid 
drop if u_hhid == 319001 & hhid == 1
gen ffw7 = ( q3p1s6b == 10)
collapse (sum)  q6ap1s6b ffw7, by(u_hhid)
gen nfinc7 =  q6ap1s6b 
gen round = 7
save nfinc_r7, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_7_2009\R7p3_s6a.dta", clear       // round 7 direct aid
gen u_hhid = region*100000 + pa*1000 + hhid 
drop if u_hhid == 319001 & hhid == 1
gen g_aid7 = (q1e3p3s6 == 5 )
gen aid7 = (q1e3p3s6 == 6)
gen f_ffw7 = (q1e3p3s6 == 7) 
collapse (sum) g_aid7 aid7 f_ffw7, by(u_hhid)
gen round = 7
save n_ffw7, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using nfinc_r7.dta, keepusing(nfinc7 ffw7)
drop if _merge == 2
drop _merge
replace ffw = ffw7 if round == 7 
replace nfinc = nfinc7 if round == 7
drop ffw7 nfinc7
save ethio_1234567.dta, replace

merge 1:1 u_hhid round using n_ffw7.dta, keepusing(g_aid7 aid7 f_ffw7)
drop if _merge == 2
drop _merge
replace g_aid = g_aid7 if round == 7 
replace aid = aid7 if round == 7
replace f_ffw = f_ffw7 if round == 7
drop g_aid7 aid7 f_ffw7
replace nfinc = 0 if nfinc < 0 
save ethio_1234567.dta, replace


/* AGRICULTURAL/WEATHER SHOCKS AFFECTING CROPPING N CROP CHOICES   */

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_3_1995\r3p2s6a3.dta", clear      // round 3
gen u_hhid =  q1a*100000 +  q1c*1000 + q2  
gen l_rain = 1 if q26_4 != 1
gen l_mrain = 1 if q26_4 == 3
collapse (sum) l_rain l_mrain, by(u_hhid)
gen round = 3
save r_shock3, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using r_shock3.dta, keepusing(l_rain l_mrain)
drop if _merge == 2
drop _merge
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_4_1997\r4p2s8af.dta", clear     // round 4
gen u_hhid =  q1a*100000 +  q1c*1000 + q1d    
gen l_rain4 = 1 if  q28_3 != 1
gen l_mrain4 = 1 if  q28_3 == 3
gen round = 4 
save r_shock4, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using r_shock4.dta, keepusing(l_rain4 l_mrain4)
drop if _merge == 2
drop _merge
replace l_rain = l_rain4 if round == 4
replace l_mrain = l_mrain4 if round == 4
drop l_rain4 l_mrain4
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_5_1999\p2sec7.dta", clear       // round 5
gen u_hhid =  q1a*100000 +  paid*1000 + hhid  
gen l_rain5 = 1 if  p2s7q18 != 1
gen l_mrain5 = 1 if p2s7q18 == 3
collapse (sum) l_rain5 l_mrain5, by(u_hhid)
gen round = 5
save r_shock5, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using r_shock5.dta, keepusing (l_rain5 l_mrain5)
drop if _merge == 2
drop _merge
replace l_rain = l_rain5 if round == 5
replace l_mrain = l_mrain5 if round == 5
drop l_rain5 l_mrain5
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_6_2004\r6p2s6_Q1to6.dta", clear       // round 6
gen u_hhid =  q1a*100000 +  paid*1000 + hhid  
gen l_rain6 = 1 if q26_4 != 1
gen l_mrain6 = 1 if q26_4 == 3
collapse (sum) l_rain6 l_mrain6, by(u_hhid)
gen round = 6
save r_shock6, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using r_shock6.dta, keepusing (l_rain6 l_mrain6)
drop if _merge == 2
drop _merge
replace l_rain = l_rain6 if round == 6
replace l_mrain = l_mrain6 if round == 6
drop l_rain6 l_mrain6
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_7_2009\R7p2_s6a.dta", clear       //  round 7
gen u_hhid = region*100000 + pa*1000 + hhid 
drop if u_hhid == 319001 & hhid == 1
gen l_rain7 = 1 if q4p2s6 != 1
gen l_mrain7 = 1 if q4p2s6 == 3
collapse (sum) l_rain7 l_mrain7, by(u_hhid)
gen round = 7
save r_shock7, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using r_shock7.dta, keepusing (l_rain7 l_mrain7)
drop if _merge ==2
drop _merge
replace l_rain = l_rain7 if round == 7
replace l_mrain = l_mrain7 if round ==7
drop l_rain7 l_mrain7
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_2_1994b\r2p2s9t10a.dta", clear     // round 2
gen u_hhid =  q1a*100000 +  q1c*1000 + q2  
gen l_rain2 = 1 if q29_6 != 1
gen l_mrain2 = 1 if q29_6 == 3
collapse (sum) l_rain2 l_mrain2, by(u_hhid)
gen round = 2
save r_shock2, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using r_shock2.dta, keepusing (l_rain2 l_mrain2)
drop if _merge == 2
drop _merge
replace l_rain = l_rain2 if round == 2
replace l_mrain = l_mrain2 if round == 2
drop l_rain2 l_mrain2
save ethio_1234567.dta, replace

use r_shock2, clear                                                    // round 1
replace round = 1 
rename l_rain2 l_rain1
rename l_mrain2 l_mrain1
save r_shock1, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using r_shock1.dta, keepusing (l_rain1 l_mrain1)
drop if _merge == 2
drop _merge
replace l_rain = l_rain1 if round == 1
replace l_mrain = l_mrain1 if round == 1
drop l_rain1 l_mrain1
save ethio_1234567.dta, replace

/* USING THE SHOCK INDICES USED IN PAPER 3 */

merge 1:1 u_hhid round using "C:\Users\Nicholas\Desktop\Stata_Progs\paper3\ethio_pap3.dta", keepusing(rain_indx n_rainsh  livst_indx)
drop if _merge == 2
drop _merge

save ethio_1234567.dta, replace 


/*  CONSUMPTION SMOOTHING OPTIONS (EX-POST - CREDIT ACCESS AND NON-FARM INCOMES)  */

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_4_1997\r4p1s4af.dta", clear    // round 4
gen u_hhid =  q1a*100000 +  q1c*1000 + q1d    
recode  q14_1 (1=1) (2=0), gen(credit)
collapse (sum) credit, by(u_hhid)
gen round = 4
save credit4, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using credit4.dta, keepusing (credit)
drop if _merge ==2 
drop _merge
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_3_1995\r3p1s3a3.dta", clear    // round 3
gen u_hhid =  q1a*100000 +  q1c*1000 + q2  
recode q13_1 (1=1) (2=0), gen(credit3)
collapse (sum) credit3, by(u_hhid)
gen round = 3
save credit3, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using credit3.dta, keepusing (credit3)
drop if _merge == 2
drop _merge
replace credit = credit3 if round == 3
drop credit3
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_2_1994b\r2p1s5a.dta", clear      // round 2
gen u_hhid =  q1a*100000 +  q1c*1000 + q2  
recode  q15_1a (1=1) (2=0), gen(credit2)
collapse (sum) credit2, by(u_hhid)
gen round = 2
save credit2, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using credit2.dta, keepusing (credit2)
drop if _merge == 2
drop _merge
replace credit = credit2 if round == 2
drop credit2
save ethio_1234567.dta, replace


use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_1_1994a\r1p1s6.dta", clear       // round 1
gen u_hhid =  q1a*100000 +  q1c*1000 + q5
recode q16_1 (1=1) (2=0) , gen(credit1)
collapse (sum) credit1, by(u_hhid)
gen round = 1
save credit1, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using credit2.dta, keepusing (credit2)
drop if _merge == 2
drop _merge
replace credit = credit2 if round == 2
drop credit2
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_5_1999\p1sec4.dta", clear        // round 5
gen u_hhid =  q1a*100000 +  paid*1000 + hhid  
recode  p1s4q1 (1=1) (2=0), gen(credit5)
collapse (sum) credit5, by(u_hhid)
gen round = 5
save credit5, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using credit5.dta, keepusing (credit5)
drop if _merge ==2 
drop _merge
replace credit = credit5 if round == 5
drop credit5
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_6_2004\r6p1s4_Q1to2.dta", clear     // round 6
gen u_hhid =  q1a*100000 +  paid*1000 + hhid  
recode q14_1 (1=1) (2=0), gen(credit6)
collapse (sum) credit6, by(u_hhid)
gen round = 6
save credit6, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using credit6.dta, keepusing (credit6)
drop if _merge == 2
drop _merge
replace credit = credit6 if round ==6
drop credit6
save ethio_1234567.dta, replace

use "C:\Users\Nicholas\Desktop\Household_Data\ERHS_Round_7_2009\R7p1_s4a.dta", clear         // round 7 
gen u_hhid = region*100000 + pa*1000 + hhid 
drop if u_hhid == 319001 & hhid == 1
recode q1p1s4 (1=1) (2=0), gen(credit7)
collapse (sum) credit7, by (u_hhid)
gen round = 7 
save credit7, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using credit7.dta, keepusing (credit7)
drop if _merge ==2
drop _merge
replace credit = credit7 if round == 7 
drop credit7
save ethio_1234567.dta, replace


/* how to differentiate between the missing values and the zero values ...
   in some yrs some households did not plant at all ............
   if i collapse by hh's over the crop options and match it to the original dataset .. what does that tell me
   the proportion of hh's that have no values for the crop varieties.
   then i can drop zero acreage hh's ... ( that shd be v helpful)
   ------------  --------------   ---------------    ------------
   then i can align the hh's that hv the ffw or nfinc and then regress or do descriptive stats
   */
/*  */
gen wtef_ = 1 if wtefha != .
replace wtef_ = 0 if wtefha == 0 
gen btef_ = 1 if btefha != .
replace btef_ = 0 if btefha == 0
gen barl_ = 1 if barlha != .
replace barl_ = 0 if barlha == 0 
gen wht_ = 1 if whtha != .
replace wht_ = 0 if whtha == 0 
gen maiz_ = 1 if maizha != . 
replace maiz_ = 0 if maizha == 0 
gen sorg_ = 1 if sorgha != .
replace sorg_ = 0 if sorgha == 0 
gen coff_ = 1 if coffha != . 
replace coff_ = 0 if coffha == 0 
gen chat_ = 1 if chatha != .
replace chat_ = 0 if chatha == 0 
gen enset_ = 1 if ensetha != . 
replace enset_ = 0 if ensetha == 0 

/*  Sample reduction to working sample   */
drop if hhsize == . & cons== . & poor == . & livval == . & lsu == .

egen crp_count = rowtotal(wtef_ btef_ barl_ wht_ maiz_ sorg_ coff_ chat_ enset_), missing 

qui {
/* this code checks if am missing some observatns due to bad coding */
local listshk "wtef btef barl wht maiz sorg coff chat enset"
foreach x of local listshk{
  gen chk_`x' = 1 if `x'yld > 0 & `x'yld != . & `x'ha == 0
  replace chk_`x' = 1 if `x'yld > 0 & `x'yld != . & `x'ha == .
  replace chk_`x' = 0 if chk_`x' == .
  disp "`x'"
  count if chk_`x' == 1
 }
*
egen miss_crp = rowtotal(chk_wtef chk_btef chk_barl chk_wht chk_maiz chk_sorg chk_coff chk_chat chk_enset), missing 
}
*
/*  Might have to drop round 2 in the analysis */
*drop if crp_count == 0 

/*  How do i hv a regression where ffw or nfinc is lagged and the dependent variable is cultivation of particular crop in the    */
/* there is a positive and significant correlation bn NFINC and  barley, maize, sorghum and chat */

pwcorr ffw nfinc wtef_ btef_ barl_ wht_ maiz_ sorg_ coff_ chat_ enset_ crp_count , star (.05)

/*  Linear probability model for the effect of FFW/NFINC on barley, maize, sorghum n chat  panel data models   */ 
* Using Panel data descriptive methods  
*agehead sex_hd hhd_edu
xtset  u_hhid round   // sets the data in long form n generates a unique time_invariant identifier
xtdescribe   // describes the dataset
xtsum   agehead sex_hd hhd_edu hhsize cons livval lsu ffw nfinc barl_ maiz_ sorg_ chat_  land  poor  // checks between and within variation for the regressors of interest
gen l_nfinc = log(nfinc + 1) 
recode sex_hd (1=1) (2=0), gen(sex) 


/* variables included for Broussard paper ....age of hhead, sex of hhead, hhsize, education (completed primary edu), 
   log of livestock val, log landholding per capita (1994), log consumption per capita   */
/* Broussard further estimates a fixed effect logit and a random effects probit model ( in these models she does not 
account for the dynamic component of the decision she is interested in)  */

/* Dercon n Christiansen (2011) examine several household x'tics, shock variables, asset holdings (livestock), 
    per capita consumption to establish the causality in the usage of fert. */ 
	
/* In the estimations we can examine for the balanced and unbalanced panel 
 in the cereal yields model, crops focused on are: black teff, barley, maize, sorghum and wheat
 Dercon notes that fertilizer is used more on cereal 
 This implies that for my analysis asset holdings and wealth levels might constrain cereal cultivation  */	
 
 /* there were no FFW programs in Adaa, Bule, Enemayi, Basso na Worana,   */
* Significant levels of FFW programs are in  Atsbi(1 3 4 6) , Dodota(6), Cheha(2 3),   Boloso Sorie(2), Subhassahssie(1 6), Kersa/Alemaya (1 6) Gardula/Daramalo (3) Kedida Gamela (6) Ankober (6)
* Candidate woredas for the study "Atsbi 1 , Cheha 12, Subhassahssie 2, Kersa/Alemaya 8 "

/*  In Broussard and Dercon's Paper (2009), they use the power variables recorded in round 6 and also use the membership in associations vars in round 3 
control variables include household size, age of the household head, gender of the household head,
whether someone in the household has completed primary education, the number of male adults and the number of female adults   */

   /*  Other things that i want to consider in the essay
   - joint effect of the FFW, non-farm income and other measures to smooth income  */
 /* label list for vills: 
                          Atsbi - 1                       // Haresaw  - Tigray (Dry Weyna Dega) [I]                             ++++++++++++++++
						  Subhassahssie - 2               // Geblen   - Tigray (Dry Weyna Dega) [I]                             ++++++++++++++++  
						  Ankober - 3                     // Dinki   -  Amhara  (Moist Weyna Dega) [II]                         ++++++++++++++++
						  Basso na Worana- 4    (no FFW)  // D/B Milki, D/B Korma, D/B Karaf, D/B Bokaf                         ++++++++++++++++
						  Enemayi - 5           (no FFW)  // Yetmen      - Amhara  (Moist Weyna Dega / Moist Dega)  [II]        ++++++++++++++++
						  Bugna  - 6                      // Shumsheha   -  Amhara  (Dry Weyna Dega) [I]                        ++++++++++++++++
						  Adaa - 7              (no FFW)  // Sirbana Goditi - Oromia (                                          ++++++++++++++++
						  Kersa/Alemaya  - 8              // Adele Keke  - Oromia (Dry Weyna Dega) [I]                          ++++++++++++++++
						  Dodota - 9                      // Korodegaga - Oromia ( Dry Kolla / Dry Weyna Dega) [V]  [I]         ++++++++++++++++
						  Shashemene - 10                 // Trirufe/Ketchema Oromia  (Moist Weyna Dega / Moist Dega)  [II]     ++++++++++++++++
						  
						  Cheha - 12                      //Imdibir -  SSNP (Moist Weyna Dega / Moist Dega)  [II]               ++++++++++++++++
						  Kedida Gamela -13               // Aze Deboa - SNNP   ( Moist Weyna Dega  / Moist Dega)  [II]         ++++++++++++++++
						  Bule  - 14             (no FFW) // Adado     - Oromia        (Wet Dega)                               ++++++++++++++++
						  Boloso Sorie - 15               // Gara Godo  -SNNP   ( Moist Weyna Dega  / Moist Dega)  [II]         ++++++++++++++++
						  Gardula/Daramalo - 16           // Doma   SNNP ( Moist Weyna Dega / Moist Kolla  - )  [IV]  [II]      ++++++++++++++++                    */   
					  
/*  Dry Weyna Dega - wheat teff (maize)  [I]
 Moist Weyna Dega - maize sorghum teff wheat barley (enset)  [II]					  
Moist Dega	- barley wheat  [III]
Moist Kolla - sorghum (teff)  [IV]					  
Dry Kolla  - (sorghum) (teff)  [V]
Wet Dega  - barley wheat
  */						  

*subhassah ankober dodota shashemen boloso/so gardula  //  subhassah ankober dodota shashemen gardula boloso/so
gen sample_1 = 1 if q1b == 2
replace sample_1 = 1 if q1b == 3 
replace sample_1  = 1 if q1b == 9 
replace sample_1 = 1 if q1b == 10
replace sample_1 = 1 if q1b == 15 
replace sample_1 = 1 if q1b == 16

  
gen d_w_dega = 1 if q1b < 3       // creating var for Dry Weyna Dega   / atsbi subhas bugna kersa dodta 
replace d_w_dega = 1 if q1b == 6    // Atsbi Subhassahssie Bugna Kersa/Alemaya Dodota
replace d_w_dega  = 1 if q1b == 8    
replace d_w_dega  = 1 if q1b == 9 

gen m_w_dega = 1 if q1b > 9      // creating var for Moist Weyna Dega   / shashm cheha keddag boloso gardul
replace m_w_dega = 1 if q1b == 3   // vills: Shashemene Cheha  Kedida_Gamela Boloso_Sorie Gardula/Daramalo 
replace m_w_dega = . if q1b == 14  

*"Atsbi 1 , Cheha 12, Subhassahssie 2, Kersa/Alemaya 8 "
gen r_sample = 1 if q1b == 1
replace r_sample = 1 if q1b == 2
replace r_sample = 1 if q1b == 8
replace r_sample = 1 if q1b == 12


gen w_dega = d_w_dega
replace w_dega = 1 if m_w_dega
replace w_dega = . if d_w_dega != 1 & m_w_dega != 1
  
local list212 "wtef_ btef_ barl_ wht_ maiz_ sorg_ coff_ chat_ enset_"					  
foreach x of local list212 {
 replace `x' = . if `x' == 0
 }
 *
local list122 "wtef_ btef_ barl_ wht_ maiz_ sorg_ coff_ chat_ enset_"
foreach x of local list122 {
replace `x' = 0 if `x' == .
 }
 *
egen teff = rowtotal(wtef_ btef_)
replace teff = 1 if teff == 2

gen d_sample = 1 
replace d_sample = . if q1b == 4
replace d_sample = . if q1b == 5
replace d_sample = . if q1b == 7
replace d_sample = . if q1b == 14

/*  CREATING VILLAGE DUMMIES   */
gen atsbi = (q1b ==1 )
gen subhas= (q1b ==2 )
gen ankobr= (q1b ==3 )
gen bugna = (q1b ==6 )
gen kersa = (q1b ==8 )
gen dodta = (q1b ==9 )
gen shashm= (q1b ==10)
gen cheha = (q1b ==12)
gen keddag= (q1b ==13)
gen boloso= (q1b ==15)
gen gardul= (q1b ==16)   // dummy dropped
*atsbi subhas ankobr bugna kersa dodta shashm cheha keddag boloso gardul 

gen ffw_n = ffw
replace ffw_n = 1 if g_aid > 0 & g_aid < . 
replace ffw_n = 1 if aid > 0 & aid < . 
replace ffw_n = 1 if f_ffw > 0 & f_ffw < . 

gen ffwnlag = L.ffw_n
gen ffwn2lag = L.ffwnlag
*ffw_n ffwnlag ffwn2lag
* agehead sex_hd hhd_edu
gen barl_lag = L.barl_        // creates lagged variable  chat_lag wht_lag teff_lag sorg_lag barl_lag
gen ffw_lag = L.ffw
gen maiz_lag = L.maiz_
gen sorg_lag = L.sorg_
gen wht_lag = L.wht_
gen chat_lag = L.chat_
gen btef_lag = L.btef_
gen enset_lag = L.enset_
gen teff_lag = L.teff
gen maiz2lag = L.maiz_lag    // lagging for second time
gen ffw2lag = L.ffw_lag  

gen rainlag = L.l_mrain      // lagging rainfall var

gen d_round1 = (round ==1)
gen d_round2 = (round ==2)
gen d_round3 = (round ==3)
gen d_round4 = (round ==4)
gen d_round5 = (round ==5)
gen d_round6 = (round ==6)  
gen d_round7 = (round ==7)   //

bysort u_hhid: gen n_round = [_N]   // reducing unbalanced to balanced, keeping obs where n_round== 6
count if ffw  == . & n_round > 4
gen ffw_c = 1 if ffw == . & n_round > 4
replace ffw =  0 if ffw_c == 1	

save ethio_1234567, replace

drop q1a q1b q1c paid hhid land hhsize cons poor livval lsu ind hhd_die2 hhd_die3  sex_hd hhm_edu wtefha  d_w_dega d_sample    /// 
     btefha barlha whtha maizha sorgha coffha chatha ensetha wtefyld btefyld barlyld whtyld maizyld sorgyld coffyld chatyld    /// 
	 ensetyld ffw nfinc       wtef_ btef_ barl_ wht_ maiz_ sorg_ coff_ chat_ enset_ crp_count l_nfinc ffw_c barl_lag          ///
	 atsbi subhas ankobr bugna kersa dodta shashm cheha keddag boloso gardul ffw_lag maiz_lag sorg_lag wht_lag chat_lag        ///
	 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 d_round7  g_aid aid f_ffw maiz2lag ffw2lag btef_lag teff r_sample l_rain l_mrain  ///
	 ffwn2lag  ffwnlag ffw_n rainlag credit teff_lag rain_indx n_rainsh  livst_indx enset_lag  chk_wtef chk_btef chk_barl chk_wht  /// 
	 chk_maiz chk_sorg chk_coff chk_chat chk_enset miss_crp
	 
reshape wide agehead sex hhd_edu n_round, i(u_hhid) j(round)
gen age5_c = 1 if agehead5 == . & n_round1 > 4 & agehead4 != .
replace agehead5 = agehead4 + 2 if age5_c ==1

gen age6_c =1 if agehead6 == . & n_round1 > 4 & agehead4 != .
replace agehead6 = agehead4 + 7 if age6_c ==1

gen sex5_c = 1 if sex5== . & n_round1 > 4 & sex4 != .
replace sex5 = sex4 if sex5_c == 1

gen sex6_c = 1 if sex6== . & n_round1 > 4 & sex4 != .
replace sex6 = sex4 if sex6_c ==1

gen hhdedu5_c = 1 if hhd_edu5 == . & n_round1 > 4 & hhd_edu4 != .
replace hhd_edu5 = hhd_edu4  if hhdedu5_c == 1

gen hhdedu6_c = 1 if hhd_edu6 == . & n_round1 > 4 & hhd_edu4 != .
replace hhd_edu6 = hhd_edu4 if hhdedu6_c == 1

reshape long agehead sex hhd_edu n_round, i(u_hhid) j(round)       
rename agehead agehead_c 
rename sex sex_c 
rename hhd_edu hhd_edu_c

save agsex_ed, replace

use ethio_1234567.dta, clear
merge 1:1 u_hhid round using agsex_ed.dta, keepusing(agehead_c sex_c hhd_edu_c)
drop if _merge == 2
drop _merge
replace sex = sex_c if n_round > 4
replace agehead = agehead_c if n_round > 4
replace hhd_edu = hhd_edu_c if n_round > 4
gen age_sqrd  = agehead * agehead


drop sex_c agehead_c hhd_edu_c 
replace ffw = 1 if ffw > 1 & ffw < .
replace ffw_lag = 1 if ffw_lag > 1 & ffw_lag < . 
replace ffw2lag = 1 if ffw2lag > 1 & ffw2lag < .

gen d_nfinc  = (nfinc > 0 & nfinc < . )

gen l_cons = ln(cons)
gen l_lival = ln(livval + 1)

save ethio_1234567.dta, replace

*edu_r

local listdelf "credit r_shock nfinc_r n_ffw area_output_r"
foreach x of local listdelf {
 forval i = 1/7 {
      erase `x'`i'.dta
	  }
}
*
replace livst_indx = 0.5 if livst_indx < 0

save ethio_1234567.dta, replace

*** INCORPORATING PRICE RISK VARS*********8

use "C:\Users\Nicholas\Downloads\Ethiopian_Rural Household Surveys_1989-2009\Conversions\Price1234\price1234_rev.dta", clear
gen itemid = q1b*1000 + item1234


egen maiz_spr = rowsd(p_r1 p_r2 p_r3 p_r4) if item1234 == 5     // maize price std dev
egen sorg_spr = rowsd(p_r1 p_r2 p_r3 p_r4) if item1234 == 6     // sorghum 
egen wht_spr  = rowsd(p_r1 p_r2 p_r3 p_r4) if item1234 == 4     // wheat
egen barl_spr = rowsd(p_r1 p_r2 p_r3 p_r4) if item1234 == 3     // barley
egen wtef_spr = rowsd(p_r1 p_r2 p_r3 p_r4) if item1234 == 1     // white teff
egen btef_spr = rowsd(p_r1 p_r2 p_r3 p_r4) if item1234 == 2     // black n mixed teff


gen wtef_pr1  = p_r1 if item1234 == 1        // white teff
gen wtef_pr2  = p_r2 if item1234 == 1        // white teff
gen wtef_pr3  = p_r3 if item1234 == 1        // white teff
gen wtef_pr4  = p_r4 if item1234 == 1        // white teff

gen btef_pr1  = p_r1 if item1234 == 2        // black n mixed teff
gen btef_pr2  = p_r2 if item1234 == 2        // black n mixed teff
gen btef_pr3  = p_r3 if item1234 == 2        // black n mixed teff
gen btef_pr4  = p_r4 if item1234 == 2        // black n mixed teff
 
gen barl_pr1 = p_r1 if item1234 == 3   // barley r1
gen barl_pr2 = p_r2 if item1234 == 3   // barley r2
gen barl_pr3 = p_r3 if item1234 == 3   // barley r3
gen barl_pr4 = p_r4 if item1234 == 3   // barley r4

gen wht_pr1  = p_r1 if item1234 == 4        // wheat 
gen wht_pr2  = p_r3 if item1234 == 4        // wheat 
gen wht_pr3  = p_r3 if item1234 == 4        // wheat 
gen wht_pr4  = p_r4 if item1234 == 4        // wheat 

gen sorg_pr1  = p_r1 if item1234 == 6        // sorg
gen sorg_pr2  = p_r2 if item1234 == 6        // sorg
gen sorg_pr3  = p_r3 if item1234 == 6        // sorg
gen sorg_pr4  = p_r4 if item1234 == 6        // sorg

gen maiz_pr1  = p_r1 if item1234 == 5        // maiz 
gen maiz_pr2  = p_r2 if item1234 == 5        // maiz 
gen maiz_pr3  = p_r3 if item1234 == 5        // maiz 
gen maiz_pr4  = p_r4 if item1234 == 5        // maiz 


save price_pap2, replace
  
use ethio_1234567.dta, clear
gen itemid= q1b*1000 + 3    // barley itemid for merginng

merge m:1 itemid using price_pap2, keepusing(barl_spr barl_pr1 barl_pr2 barl_pr3 barl_pr4 )
drop if _merge == 2
drop _merge itemid

gen itemid= q1b*1000 + 4    // wheat itemid for merginng

merge m:1 itemid using price_pap2, keepusing(wht_spr wht_pr1 wht_pr2 wht_pr3 wht_pr4)
drop if _merge == 2
drop _merge itemid

gen itemid= q1b*1000 + 5    // maiz itemid for merginng

merge m:1 itemid using price_pap2, keepusing(maiz_spr maiz_pr1 maiz_pr2 maiz_pr3 maiz_pr4)
drop if _merge == 2
drop _merge itemid

gen itemid= q1b*1000 + 6    // sorg itemid for merginng

merge m:1 itemid using price_pap2, keepusing(sorg_spr sorg_pr1 sorg_pr2 sorg_pr3 sorg_pr4)
drop if _merge == 2
drop _merge itemid


gen itemid= q1b*1000 + 1    // white teff itemid for merginng

merge m:1 itemid using price_pap2, keepusing(wtef_spr wtef_pr1 wtef_pr2 wtef_pr3 wtef_pr4)
drop if _merge == 2
drop _merge itemid

gen itemid= q1b*1000 + 2    // black n mixed teff itemid for merginng

merge m:1 itemid using price_pap2, keepusing(btef_spr btef_pr1 btef_pr2 btef_pr3 btef_pr4)
drop if _merge == 2
drop _merge itemid
save ethio_1234567.dta, replace 

local listcval "maiz sorg wht barl wtef btef"
foreach x of local listcval {
       gen `x'_val = `x'yld * land * `x'_pr1 if round ==1
forval i = 2/4 {
   replace `x'_val = `x'yld * land * `x'_pr`i' if round ==`i' 
    	}
}
*
	
egen crop_val= rowtotal(maiz_val sorg_val wht_val barl_val wtef_val btef_val), missing
	
gen land_sqrd = land * land 	
replace maizha = 0 if maizha == . & d_w_dega == 1
replace barlha = 0 if barlha == . & d_w_dega == 1

save ethio_1234567.dta, replace

**maiz_spr  barl_spr wht_spr sorg_spr
*********
**********                                                                           RUN CODE TO THIS POINT TO OBTAIN THE DATASET NEEDED FOR ANALYSIS

/*  CREATING A DATASET FOR DIS-ADOPTION ANALYSIS   */
collapse (sum) maiz_ credit, by(hhid)



/*  DESCRIPTIVE STATS  */
 qui {
forval i=1/7 {
 disp "round`i'"
 tab  q1b ffw if round == `i' & d_w_dega == 1   // run the code from 1/6
}
*
forval i=1/7 {
quietly 
mean maiz_ btef_ sorg_ barl_ wht_ teff if round == `i' & d_w_dega == 1
estimates store m`i'
}
*
estimates table m1 m2 m3 m4 m5 m6 m7


sum agehead sex hhd_edu hhsize cons livval lsu ffw nfinc barl_ maiz_ sorg_ btef_  teff chat_  land  poor  rain_indx livst_indx  if d_w_dega ==1 & round ==6 & ffw==0

xttrans maiz_ if d_w_dega == 1

*bysort round: sum agehead sex hhd_edu hhsize cons livval lsu ffw nfinc barl_ maiz_ sorg_ btef_  chat_  land  poor if m_w_dega ==1  // not relevant 

* nifty way to do a test of means for the diff vars>>>>>>>>>>>>

local list5 "agehead sex hhd_edu hhsize cons livval lsu ffw nfinc barl_ maiz_ sorg_ btef_  teff chat_  land  poor "
foreach x of local list5 {
use ethio_1234567.dta, clear
gen `x'11 = `x' if d_w_dega ==1 & round ==1 & ffw==1
gen `x'22 = `x' if d_w_dega ==1 & round ==1 & ffw==0
stack `x'11 `x'22, into(`x'_1)
display "`x'- ffwr1"
ttest `x'_1, by(_stack)  unequal
}
*


local list7 "agehead sex hhd_edu hhsize cons livval lsu ffw nfinc barl_ maiz_ sorg_ btef_  teff chat_  land  poor "
foreach x of local list7 {
use ethio_1234567.dta, clear
gen `x'16 = `x' if d_w_dega ==1 & round ==6 & ffw==1
gen `x'26 = `x' if d_w_dega ==1 & round ==6 & ffw==0
stack `x'16 `x'26, into(`x'_6)
display "`x'- ffwr6"
ttest `x'_6, by(_stack)  unequal
}
*
}
*

/* PRELIMINARY     */ 

* atsbi subhas ankobr bugna kersa dodta shashm cheha keddag boloso gardul 
* to combine btef_ and wtef_ l_nfinc   atsbi subha bugna kersa
 qui {

/*   /*  FOr checking cereal price trends over time  */
 use "C:\Users\Nicholas\Downloads\Ethiopian_Rural Household Surveys_1989-2009\Conversions\Price1234\price1234_rev.dta", clear
  gen maiz_pr1 = p_r1 if item1234 == 5
  gen maiz_pr2 = p_r2 if item1234 == 5
  gen maiz_pr3 = p_r3 if item1234 == 5
  gen maiz_pr4 = p_r4 if item1234 == 5
 
 gen barl_pr1 = p_r1 if item1234 == 3
 gen barl_pr2 = p_r2 if item1234 == 3
 gen barl_pr3 = p_r3 if item1234 == 3
 gen barl_pr4 = p_r4 if item1234 == 3

gen wheat_pr1 = p_r1 if item1234 == 4
gen wheat_pr2 = p_r2 if item1234 == 4
gen wheat_pr3 = p_r3 if item1234 == 4
gen wheat_pr4 = p_r4 if item1234 == 4

gen sorg_pr1 = p_r1 if item1234 == 6
gen sorg_pr2 = p_r2 if item1234 == 6
gen sorg_pr3 = p_r3 if item1234 == 6
gen sorg_pr4 = p_r4 if item1234 == 6
  */

*OBTAINING A SAMPLE of HH'S THAT HV AT LEAST ONCE RECEIVED FFW
use ethio_1234567.dta, clear
collapse (sum) ffw , by(u_hhid)
gen ffw_use = ffw
replace ffw_use = 1 if ffw > 1  
save ffw_use, replace


use ethio_1234567.dta, clear
merge m:1 u_hhid using ffw_use
drop if _merge == 2
drop _merge


/*   reducing the unbalanced panel to a balanced panel 
-->> bysort u_hhid: gen n_round = [_N]
	 *keeping obs where n_round ==6 yields a balanced panel 

However; obtaining the balanced does not rid of the missing vars	 
-->> count ffw varlist if varlist = . & n_round ==6	 
     gen ffw_c = 1 if ffw == . & n_round == 6
     replace ffw = 0 if ffw_c == 1   */
*CREATING NEW TYPE OF LAGGED VARIABLE


}
*
  
*PRELIMINARY FIXED EFFECTS  & RANDOM EFFECTS REGRESSIONS  
*rain_indx n_rainsh  livst_indx
* VARS FOR THE CORRELATED RANDOM EFFECTS MODEL ;;;NOT DYNAMIC YET

xttrans maiz_ if d_w_dega == 1

corr maiz_ maiz_lag maiz2lag

pwcorr credit maiz_ , star(.05)

pwcorr credit maiz_  if d_w_dega==1, star(.05)


 
bysort u_hhid: egen ffw_ = mean( ffw)
bysort u_hhid: egen ffwlg_ = mean(ffw_lag)
bysort u_hhid: egen ffw2lg_ = mean(ffw2lag)
bysort u_hhid: egen agehd_ = mean(agehead)
bysort u_hhid: egen agesq_ = mean(age_sqrd)
bysort u_hhid: egen sex_ = mean(sex)
bysort u_hhid: egen hedu_ = mean(hhd_edu)
bysort u_hhid: egen land_ = mean(land)
bysort u_hhid: egen land_sqrd_ = mean(land_sqrd)
bysort u_hhid: egen hsize_ = mean(hhsize)
bysort u_hhid: egen cons_ = mean(cons)
bysort u_hhid: egen poor_ = mean(poor)
bysort u_hhid: egen lival_ = mean(livval)
bysort u_hhid: egen lsu_ = mean (lsu)
bysort u_hhid: egen l_cons_ = mean(l_cons)
bysort u_hhid: egen l_lival_ = mean(l_lival)


* time-varying vars to use for the full-blown Chamberlain procedure ++ land hhhsize l_cons l_lival lsu 
/*  can generate the time varying vars via
     */
local listcml "land hhsize l_cons l_lival lsu land_sqrd ffw_lag ffw2lag"
foreach x of local listcml {
forval i = 1/7 {
gen `x'_`i' = `x'
replace `x'_`i' = . if round!= `i'
bysort u_hhid: egen `x'_r`i' = min(`x'_`i')
    drop `x'_`i'
	}
	
}
*

xtreg maiz_ credit agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx d_round3 d_round4 d_round5 d_round6 , fe vce(robust)   

*MAIZE
***********************with lags of other crops*****************************************************************

xtreg maiz_ ffw_lag ffw2lag wht_lag  btef_lag  barl_lag sorg_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx d_round3 d_round4 d_round5 d_round6  if d_w_dega== 1 , fe vce(robust)     // fixed effects lpm   FINAL !!!
est store maiz_fe

qui xtprobit maiz_ ffw_lag ffw2lag wht_lag  btef_lag  barl_lag sorg_lag  agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_  d_round3 d_round4 d_round5 d_round6   if d_w_dega== 1,   // CRE probit model FINAL !!!   (have to double check)
estpost margins, predict(pu0) dydx(*) quietly    // this generates the average marginal effects 
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store maiz_cre

qui xtprobit maiz_ ffw_lag ffw2lag wht_lag  btef_lag  barl_lag sorg_lag  agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_  d_round3 d_round4 d_round5 d_round6  atsbi subha bugna kersa  if d_w_dega== 1,   // CRE probit model FINAL !!!   (have to double check)
estpost margins, predict(pu0) dydx(*) quietly    // this generates the average marginal effects 
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store maiz_crev


*BARLEY
***********************with lags of other crops*****************************************************************  d_round1 d_round2 d_round3

xtreg barl_ ffw_lag ffw2lag sorg_lag maiz_lag wht_lag btef_lag  agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 if d_w_dega== 1 , fe vce(robust)     // fixed effects lpm   FINAL !!!
est store barl_fe

qui xtprobit barl_  ffw_lag ffw2lag sorg_lag maiz_lag wht_lag btef_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_  d_round3 d_round4 d_round5 d_round6  if d_w_dega == 1    // for Dry Weyna Dega  (can use w_dega == 1)
estpost margins, predict(pu0) dydx(*) quietly  // gives average marginal effects
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store barl_cre

qui xtprobit barl_  ffw_lag ffw2lag sorg_lag maiz_lag wht_lag btef_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_  d_round3 d_round4 d_round5 d_round6 atsbi subha bugna kersa if d_w_dega == 1    // for Dry Weyna Dega  (can use w_dega == 1)
estpost margins, predict(pu0) dydx(*) quietly  // gives average marginal effects
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store barl_crev

esttab maiz_fe maiz_cre maiz_crev barl_fe barl_cre barl_crev using "C:\Users\Nicholas\Desktop\Thesis\Second Essay\crpmaizbarl1.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(r2 r2_w r2_b r2_o ll N N_g F p ) replace

*SORGHUM

***********************with lags of other crops*****************************************************************
xtreg sorg_ ffw_lag ffw2lag wht_lag  btef_lag maiz_lag barl_lag  agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx  d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 if d_w_dega== 1, fe vce(robust)     // fixed effects lpm   FINAL !!!
est store sorg_fe

qui xtprobit sorg_  ffw_lag ffw2lag wht_lag  btef_lag maiz_lag barl_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_  d_round1 d_round2 d_round3 d_round4 d_round5 d_round6  if d_w_dega == 1    // for Dry Weyna Dega  (can use w_dega == 1)
estpost margins, predict(pu0) dydx(*) quietly  // gives average marginal effects
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store sorg_cre

qui xtprobit sorg_  ffw_lag ffw2lag wht_lag  btef_lag maiz_lag barl_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_  d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 atsbi subha bugna kersa  if d_w_dega == 1    // for Dry Weyna Dega  (can use w_dega == 1)
estpost margins, predict(pu0) dydx(*) quietly  // gives average marginal effects
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store sorg_crev


*WHEAT

***********************with lags of other crops*****************************************************************
xtreg wht_ ffw_lag ffw2lag sorg_lag  btef_lag maiz_lag barl_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 if d_w_dega== 1, fe vce(robust)     // fixed effects lpm   FINAL !!!
est store wht_fe

qui xtprobit  wht_ ffw_lag ffw2lag sorg_lag  btef_lag maiz_lag barl_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize  l_lival lsu rain_indx  ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_ d_round1 d_round2 d_round3 d_round4 d_round5 d_round6  if d_w_dega== 1 , re      //  probit re FINAL !!!
estpost margins, predict(pu0) dydx(*) quietly  // gives average marginal effects
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store wht_cre


qui xtprobit  wht_ ffw_lag ffw2lag sorg_lag  btef_lag maiz_lag barl_lag agehead age_sqrd sex hhd_edu land land_sqrd hhsize  l_lival lsu rain_indx  ffwlg_ ffw2lg_ land_ land_sqrd_ hsize_  l_lival_ lsu_ d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 atsbi subha bugna kersa if d_w_dega== 1 , re      //  probit re FINAL !!!
estpost margins, predict(pu0) dydx(*) quietly  // gives average marginal effects
esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store wht_crev

esttab sorg_fe sorg_cre sorg_crev wht_fe wht_cre wht_crev using "C:\Users\Nicholas\Desktop\Thesis\Second Essay\crp_sorgwht.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(r2 r2_w r2_b r2_o ll N N_g F p ) replace



*******************************************************************************************************************atsbi subha bugna kersa 
**************PORTFOLIO CHOICES************************************************************************************  d_round1 d_round2 d_round3
gen l_cropval = ln(crop_val + 1)

xtreg   l_cropval ffw_lag  agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx   if d_w_dega== 1 , fe vce(robust)     // lpm fe    FINAL !!!
est store cropval1

xtreg   l_cropval ffw_lag  agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx d_round1 d_round2 d_round3   if d_w_dega== 1 , fe vce(robust)     // lpm fe    FINAL !!!
est store cropval2

xtreg   l_cropval ffw_lag  agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx d_round1 d_round2 d_round3 subha bugna kersa  if d_w_dega== 1 , fe vce(robust)     // lpm fe    FINAL !!!
est store cropval3

esttab cropval1 cropval2 cropval3 using "C:\Users\Nicholas\Desktop\Thesis\Second Essay\crp_val.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats(r2 r2_w r2_b r2_o ll N N_g F p ) replace


   
/*****************************************************/ 
/*      WOOLDRIDGE'S CONDITIONAL ML ESTIMATOR (2005)  FOR THE DYNAMIC MODEL ESTIMATIONS */ 
/*****************************************************/ 

* HAVE TO EXCLUDE THE SECOND ROUND OF THE SURVEY 




* land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 land_r7 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5 hhsize_r6 hhsize_r7 
* l_cons_r1 l_cons_r2 l_cons_r3 l_cons_r4 l_cons_r5 l_cons_r6 l_cons_r7 l_lival_r1 l_lival_r2 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 l_lival_r7 
* lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6 lsu_r7   


gen barl_r1 = barl_
replace barl_r1 = . if round != 1
bysort u_hhid: egen barl_1 = min(barl_r1)

gen maiz_r1 = maiz_
replace maiz_r1 = . if round != 1
bysort u_hhid: egen maiz_1 = min(maiz_r1)

gen sorg_r1 = sorg_
replace sorg_r1 = . if round != 1
bysort u_hhid: egen sorg_1 = min(sorg_r1)

gen wht_r1 = wht_
replace wht_r1 = . if round != 1
bysort u_hhid: egen wht_1 = min(wht_r1)

gen btef_r1 = btef_
replace btef_r1 = . if round != 1
bysort u_hhid: egen btef_1 = min(btef_r1)



/*  estimates for Dry Weyna Dega and Moist Weyna Dega (rainlag */
* d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 atsbi subha bugna kersa 
*   ffw_lag_r2 ffw_lag_r3 ffw_lag_r4 ffw_lag_r5 ffw_lag_r6    ffw2lag_r3 ffw2lag_r4 ffw2lag_r5 ffw2lag_r6
*BARLEY
qui xtprobit barl_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         barl_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store barldy


qui xtprobit barl_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         barl_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///   
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6  ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store barldy1


qui xtprobit barl_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         barl_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///  
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6   ffw_lag_r2 ffw_lag_r3 ffw_lag_r4 ffw_lag_r5 ffw_lag_r6     ///  
		 ffw2lag_r3 ffw2lag_r4 ffw2lag_r5 ffw2lag_r6       ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store barldy2

esttab  barldy  barldy1  barldy2,  b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
esttab  barldy  barldy1  barldy2 using  "C:\Users\Nicholas\Desktop\Thesis\Second Essay\crp_barldy.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats( ll N N_g  ) replace 



*MAIZE (works for Dry Weyna Dega even after controlling for village effects)  l_cons l_cons_
qui xtprobit maiz_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         maiz_1  land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    /// 
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6   ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store maizdy

qui xtprobit maiz_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         maiz_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///   
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6  ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store maizdy1


qui xtprobit maiz_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         maiz_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///  
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6   ffw_lag_r2 ffw_lag_r3 ffw_lag_r4 ffw_lag_r5 ffw_lag_r6     ///  
		 ffw2lag_r3 ffw2lag_r4 ffw2lag_r5 ffw2lag_r6       ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store maizdy2

esttab  maizdy  maizdy1  maizdy2,  b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
esttab  maizdy  maizdy1  maizdy2 using  "C:\Users\Nicholas\Desktop\Thesis\Second Essay\crp_maizdy.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats( ll N N_g  ) replace 

		 

*SORGHUM
qui xtprobit sorg_  ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      /// 
        sorg_1  land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6   l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    /// 
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6  ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store sorgdy

qui xtprobit sorg_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         sorg_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///   
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6  ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store sorgdy1


qui xtprobit sorg_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         sorg_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///  
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6   ffw_lag_r2 ffw_lag_r3 ffw_lag_r4 ffw_lag_r5 ffw_lag_r6     ///  
		 ffw2lag_r3 ffw2lag_r4 ffw2lag_r5 ffw2lag_r6       ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store sorgdy2

esttab  sorgdy  sorgdy1  sorgdy2,  b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
esttab  sorgdy  sorgdy1  sorgdy2 using  "C:\Users\Nicholas\Desktop\Thesis\Second Essay\crp_sorgdy.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats( ll N N_g  ) replace 



*WHEAT
qui xtprobit wht_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
          wht_1  land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6   l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    /// 
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6  ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store whtdy

qui xtprobit wht_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         wht_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///   
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6  ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store whtdy1


qui xtprobit wht_ ffw_lag ffw2lag  barl_lag maiz_lag sorg_lag wht_lag btef_lag        /// 
          agehead age_sqrd sex hhd_edu land land_sqrd hhsize l_lival lsu rain_indx      ///
         wht_1 land_r1 land_r2 land_r3 land_r4 land_r5 land_r6 hhsize_r1 hhsize_r2 hhsize_r3 hhsize_r4 hhsize_r5   ///
		 hhsize_r6  l_lival_r1 l_lival_r2  ///
		 l_lival_r3 l_lival_r4 l_lival_r5 l_lival_r6 lsu_r1 lsu_r2 lsu_r3 lsu_r4 lsu_r5 lsu_r6    ///
		 land_sqrd_r1 land_sqrd_r2 land_sqrd_r3 land_sqrd_r4 land_sqrd_r5 land_sqrd_r6      ///  
		 d_round1 d_round2 d_round3 d_round4 d_round5 d_round6   ffw_lag_r2 ffw_lag_r3 ffw_lag_r4 ffw_lag_r5 ffw_lag_r6     ///  
		 ffw2lag_r3 ffw2lag_r4 ffw2lag_r5 ffw2lag_r6       ///
         if d_w_dega == 1  & round != 7    // gets significant results when focus on the Dry Weyna Dega group
estpost margins, predict(pu0) dydx(*) quietly

esttab  . , b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
est store whtdy2

esttab  whtdy  whtdy1  whtdy2,  b(%7.4f) star(* 0.10 ** 0.05 *** 0.01) se(%7.4f) stats( ll N N_g  ) 
esttab  whtdy  whtdy1  whtdy2 using  "C:\Users\Nicholas\Desktop\Thesis\Second Essay\crp_whtdy.rtf",  b(%7.3f) star(* 0.10 ** 0.05 *** 0.01) se(%7.3f) stats( ll N N_g  ) replace 







   
qui {

use ethio_123456.dta, clear
drop if round ==2 
recode round (1=1) (3=2) (4=3) (5=4) (6=5), gen(nround)
drop round 
rename nround round




*wht_lag teff_lag sorg_lag barl_lag btef_lag
*************************************************************************************************************************************************************
********************MULTIVARIATE PROBIT MODEL****************************************************************************************************************
*************************************************************************************************************************************************************
mvprobit (maiz_ = ffw_lag ffw2lag agehead age_sqrd hhd_edu land hhsize lsu l_lival rainlag)  (barl_ = ffw_lag ffw2lag agehead age_sqrd hhd_edu land hhsize lsu l_lival rainlag)  ///
         (sorg_ = ffw_lag ffw2lag agehead age_sqrd hhd_edu land hhsize lsu l_lival rainlag)  if d_w_dega== 1 & round == 4, dr(50)


mvprobit (maiz_ = ffw_lag ffw2lag agehead age_sqrd hhd_edu land hhsize lsu l_lival rainlag)  (barl_ = ffw_lag ffw2lag agehead age_sqrd hhd_edu land hhsize lsu l_lival rainlag)  ///
         (sorg_ = ffw_lag ffw2lag agehead age_sqrd hhd_edu land hhsize lsu l_lival rainlag)  if d_w_dega== 1 & round == 5,  nolog dr(10)
		 
		 
 }
*

  
*****************************************************************************************************************************************************************   
*************CROP CHOICE MODEL   INCORPORATING PRICE RISK INTO CROP DECISIONS  ******************************************************************************
*not bad hw about multivariate probit with the price risk accounted for 
* another thing is this: if i have some data on prices and can account for the price risk what prevents me from computing net returns per crop

gen ffw_1  =  ffw
replace ffw_1 = . if round > 4
bysort u_hhid: egen n_ffw = mean(ffw_1)


regress maiz_  n_ffw agehead age_sqrd sex hhd_edu land hhsize poor livval lsu rain_indx  maiz_spr  barl_spr wht_spr sorg_spr  if d_w_dega ==1 & round == 6

probit maiz_  n_ffw agehead age_sqrd sex hhd_edu land hhsize poor livval lsu rain_indx  maiz_spr  barl_spr wht_spr sorg_spr  if d_w_dega ==1 & round == 6
	   

regress maiz_  ffw_lag agehead age_sqrd sex hhd_edu land hhsize poor livval lsu rain_indx /* maiz_spr  barl_spr wht_spr sorg_spr */ if d_w_dega ==1 & round == 5
	   
	   
/*
some of the ideas i tried in the third essay, with regards to creating an index can also be experimented with the second essay. 

Questions like how FFW affects total allocations to perennial crops and cereals can be analyzed and how FFW affects intra-cereal cropping decisions can also 
be addressed. 
Keep in mind that the 
The big question is that: several variants of these questions can be asked. 
WHich of them is policy relevant regarding the role of FFW programs
Which of them is important to the farmer
what can be well addressed given the limitations of the dataset. 

WHich of these concerns can be neatly(emphasized) inserted into the essay without completely distorting the entire story
*/	   

************************************************
***********LAND ALLOCATIONS*********************
xtreg maizha ffw_lag ffw2lag agehead age_sqrd hhd_edu land land_sqrd hhsize  l_lival rain_indx d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 if d_w_dega== 1, fe vce(robust)     // fixed effects 

xtreg  barlha ffw_lag ffw2lag agehead age_sqrd hhd_edu land land_sqrd hhsize  l_lival rain_indx  d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 if d_w_dega== 1, fe vce(robust)     // fixed effects 
 
   
xtreg  sorgha ffw_lag ffw2lag agehead age_sqrd hhd_edu land land_sqrd hhsize  l_lival rain_indx d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 if d_w_dega== 1, fe vce(robust)     // fixed effects 

xtreg  whtha ffw_lag ffw2lag agehead age_sqrd hhd_edu land land_sqrd hhsize  l_lival rain_indx  d_round1 d_round2 d_round3 d_round4 d_round5 d_round6 if d_w_dega== 1, fe vce(robust)     // fixed effects 



	   
	   

