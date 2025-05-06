*Proposal 2025 
*TITLE : Joseph or Josephine: Does Gender of the Migrant have an   impact on the Welfare of Left-Behind Households
* Creator :Nyengo Msakambewa

*We need to create the following modules 
*(1)Gender 
*(2)Food security
*(3)Remittance 


*****************************
*  Food Consumption Score *// DEPENDENT Variable// 
****************************

use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\HH_MOD_G2.dta"
* Calculate weighted scores for each food group
gen staple_score = hh_g08a * 2
gen tuber_score = hh_g08b * 2
gen pulse_score = hh_g08c * 3
gen vegetable_score = hh_g08d * 1
gen meat_score = hh_g08e * 4
gen fruit_score = hh_g08f * 1
gen milk_score = hh_g08g * 4
gen fat_score = hh_g08h * 0.5
gen sugar_score = hh_g08i * 0.5

* Calculate FCS
gen fcs = staple_score + tuber_score + pulse_score + vegetable_score + meat_score + fruit_score + milk_score + fat_score + sugar_score

* Create FCS categories
gen fcs_category = .
replace fcs_category = 1 if fcs <= 21           
replace fcs_category = 2 if fcs > 21 & fcs <= 35 
replace fcs_category = 3 if fcs > 35 

* Label the categories
label define fcs_cat 1 "Poor" 2 "Borderline" 3 "Acceptable"
label values fcs_category fcs_cat

* Summarize FCS
summarize fcs

* Tabulate FCS categories
tabulate fcs_category
keep case_id HHID fcs_category
label variable fcs_category "food consumption score"
save fcs_category, replace  
clear

*******************************************************************
*Main Independent Variable (Remittance)
****************************
* 1. Remittance *
****************************
use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\HH_MOD_O.dta"

keep case_id HHID hh_o09 hh_o09_oth hh_o11 hh_o15 

*a. productivity
* this variable incorporates all productive migrants

* b . remittance
sort HHID case_id
bysort HHID : keep if _n == 1
tab hh_o11
tab hh_o15
codebook hh_o11
recode hh_o11 (2=0)
tab hh_o11
replace hh_o11 = 0 if missing( hh_o11)
tab hh_o11
codebook hh_o11
rename  hh_o11 remit

*c. in_kind_assistance
tab hh_o15
recode hh_o15 (2=0)
replace hh_o15 = 0 if missing( hh_o15 )
tab hh_o15
rename hh_o15 in_kind_assistance

* d . Assistance
gen Assistance = ( remit==1| in_kind_assistance==1)
codebook Assistance
drop remit in_kind_assistance hh_o09 hh_o09_oth
 
save Remittance, replace

 
************************************
* 2. Gender , Education & Migration
************************************
 use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\HH_MOD_B.dta"
tab hh_b07
tab hh_b18
tab hh_b04
keep case_id HHID hh_b03 hh_b07 hh_b18 hh_b04

*a. gender 
tab hh_b04, gen (head)
gen male_head = ( hh_b03 == 1 & head1 ==1)
tab male_head
gen female_head = ( hh_b03 == 2 & head1 ==1)
tab female_head
gen hh_head = .
replace hh_head = 1 if female_head == 1
replace hh_head = 2 if male_head == 1
label define hh_head_label 1 "Female-head" 2 "Male-head"
label values hh_head hh_head_label
tab hh_head
tab hh_head, missing
drop if missing( hh_head)
keep hh_b18 hh_head case_id HHID


*b. Education Level
tab hh_b18
gen education_level = hh_b18
replace education_level = 3 if education_level == 4
replace education_level = 3 if education_level == 5
tab education_level
replace education_level =6 if education_level >= 6 & education_level <= 9
label define education_level 1"none" 2"primary" 3"secondary" 4"tertiary" 5"unknown"
label value education_level education_level
tab education_level
numlabel,add
tab education_level
label variable education_level "highest level of education for household head"
replace education_level =6 if education_level >= 6 & education_level <= 9
tab education_level
recode education_level (6=4) (10=5)
tab education_level
label value education_level education_level
drop hh_b18 


save Gender, replace
clear

*********************************************************
*3. Safety nets 
*********************************************************
use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\HH_MOD_R.dta"
sort HHID case_id
bysort HHID : keep if _n == 1
codebook hh_r01
recode hh_r01 (2=0)
rename hh_r01 Safety_net
keep case_id HHID Safety_net 
label variable Safety_net "did the household recieved any safety nets"
save Safety_Nets, replace

**********************************************************
*4. Access to Credit 
***********************************************************
use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\HH_MOD_S1.dta"
codebook hh_s01
sort HHID case_id
bysort HHID : keep if _n == 1
recode hh_s01 (2=0)
rename hh_s01 Access_to_credit
keep case_id HHID Access_to_credit
save Access_to_Credit, replace

*************************************************************
* 5. Location 
*************************************************************
use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\hh_mod_a_filt.dta"
keep case_id HHID reside
codebook reside
recode reside (2=0)
codebook reside
rename reside Location
label variable Location "rural or urban"
save Location, replace

*****************************************************************
* 6. Shocks 
****************************************************************
use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\HH_MOD_U.dta"
keep case_id HHID hh_u01
sort HHID case_id
bysort HHID : keep if _n == 1
recode hh_u01 (2=0)
codebook hh_u01 
rename hh_u01 Shocks 
save Shocks, replace

***************************************************************
* 7. Agricultural Asset Ownership
************************************************************
use "C:\Users\NyengoPM\Desktop\STATA TRAINING\IHS5 Data set\IHS5 Data set\HH_MOD_M.dta"
keep case_id HHID hh_m00 
sort HHID case_id
bysort HHID : keep if _n == 1
recode hh_m00 (2=0)
codebook hh_m00 
rename hh_m00 Agricultural_Asset_Ownership
label variable Agricultural_Asset_Ownership "does your household own any agricultural asset"
save Agricultural_Asset_Ownership, replace

*merging data sets.

use Access_to_Credit
 merge m:m case_id HHID using "C:\Users\NyengoPM\Desktop\PROPOSAL\Remittance.dta"
 keep if _merge==3
 drop _merge
 save final_dataset, replace
 
 use final_dataset
 merge m:m case_id HHID using "C:\Users\NyengoPM\Desktop\PROPOSAL\Safety_Nets.dta"
keep if _merge==3
drop _merge
save final_dataset, replace

use final_dataset
merge m:m case_id HHID using "C:\Users\NyengoPM\Desktop\PROPOSAL\Gender.dta"
keep if _merge==3
drop _merge
save final_dataset, replace

use final_dataset
merge m:m case_id HHID using "C:\Users\NyengoPM\Desktop\PROPOSAL\Location.dta"
keep if _merge==3
drop _merge
save final_dataset, replace

use final_dataset
merge m:m case_id HHID using "C:\Users\NyengoPM\Desktop\PROPOSAL\Shocks.dta"
keep if _merge==3
drop _merge
save final_dataset, replace

use final_dataset
merge m:m case_id HHID using "C:\Users\NyengoPM\Desktop\PROPOSAL\Agricultural_Asset_Ownership.dta"
keep if _merge==3
drop _merge
save final_dataset, replace

use final_dataset
merge m:m case_id HHID using "C:\Users\NyengoPM\Desktop\PROPOSAL\fcs_category.dta"
keep if _merge==3
drop _merge
save final_dataset, replace
***************************************************************
*Summary Statistics 
summarize i.fcs_category Access_to_credit Assistance Safety_net hh_head i.education_level Location Shocks Agricultural_Asset_Ownership
asdoc summarize, save(summary.doc) replace
shellout using `"summary.doc"'
***************************************************************
* Regression Analysis *
ologit i.fcs_category Access_to_credit Assistance Safety_net hh_head i.education_level Location Shocks Agricultural_Asset_Ownership
outreg2 using regression_results.doc, replace word stats(coef se pval)
*************************************************************
* Diagnosis Tests *
****************************************************
*A proportional odd assumption

clear
use final_dataset.dta
global myvars Access_to_credit Assistance Safety_net hh_head education_level Location Shocks Agricultural_Asset_Ownership
ologit fcs_category $myvars
foreach var of global myvars {
	summarize `var'
}
omodel logit fcs_category $myvars

*********************************************************************

*.B likelihood ratio test - to confirm results

clear 
set more off 
use final_dataset, clear 

local depvar fcs_category
local vars myvars Access_to_credit Assistance Safety_net hh_head education_level Location Shocks Agricultural_Asset_Ownership
* Ensure the post file is created 
postfile results str20(variable) double(chi2 p) using lrtest_results.dta, replace 

foreach var of local vars {
    quietly ologit `depvar' `vars'
    est store full_model 

    * Remove the current variable from the list
    local remaining_vars `vars'
    local remaining_vars: list remaining_vars - var

    quietly ologit `depvar' `remaining_vars'
    est store restricted_model 

    lrtest restricted_model full_model

    if !missing(r(chi2)) {
        local chi2 = r(chi2)
        local p = r(p)

        * Post results correctly 
        post results ("`var'") (`chi2') (`p') 
    }
}

* Close postfile 
postclose results

* Load and view results
use lrtest_results.dta, clear 
list 

* Export results to Excel
export excel using lrtest_results.xlsx, replace firstrow(variables)


