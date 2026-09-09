*******************************************************
* 204 PROJECT
* The Effect of Travel Time on Wage Income
*******************************************************

clear all
set more off

*******************************************************
* Load Data Set
*******************************************************

use "/Users/willahock/Desktop/travel time project/Data/IPUMS 2024 All Vars but no weight vars (2).dta", clear

*******************************************************
* Clean Data
*******************************************************

* Keep working-age adults
keep if inrange(age, 18, 65)

* Keep employed individuals
keep if empstat == 1

* Keep positive wage income
keep if incwage > 0 & incwage < 999998

* Keep valid commute times, including 0 minutes
keep if trantime >= 0 & !missing(trantime)

* Check sample size
count

*******************************************************
* Create Variables
*******************************************************

* Natural log of wage income
gen ln_wage = ln(incwage)

* Commute time measured in 10-minute units
gen commute10 = trantime / 10

* Check main variables
summarize incwage ln_wage trantime commute10

*******************************************************
* Control Variables
*******************************************************

* Female indicator
gen female = (sex == 2)
label variable female "Female"

reg trantime incwage age, r

* Check education and race categories
tab educ
tab race

* Check usual hours worked
summarize uhrswork

* Order
order year age sex female educ race trantime commute10 incwage ln_wage uhrswork

*******************************************************
* Check Variables
*******************************************************

misstable summarize ln_wage commute10 age female educ race uhrswork

summarize ln_wage commute10 age female educ race uhrswork

*******************************************************
* Save Final Cleaned Data
*******************************************************

save "/Users/willahock/Desktop/travel time project/Data/IPUMS_2024_cleaned.dta", replace

* Regression Models

label variable ln_wage "Log Annual Wage Income"
label variable commute10 "Commute Time, 10-Minute Units"
label variable age "Age"
label variable female "Female"
label variable educ "Educational Attainment"
label variable race "Race"
label variable uhrswork "Usual Weekly Work Hours"

* Model 1: Simple OLS
reg incwage commute10,r
sum ln_wage commute10
reg ln_wage commute10, r

outreg2 using "/Users/willahock/Desktop/travel time project/Output/Final_Regression_Table.doc", replace word ///
ctitle("OLS") ///
label dec(3) ///
addtext(Demographic Controls, No, Education Controls, No, Race Controls, No, Hours Worked, No, Interaction, No)

* Model 2: Add demographic controls
sum age female
reg ln_wage commute10 age female, r

outreg2 using "/Users/willahock/Desktop/travel time project/Output/Final_Regression_Table.doc", append word ///
ctitle("+ Demographics") ///
label dec(3) ///
addtext(Demographic Controls, Yes, Education Controls, No, Race Controls, No, Hours Worked, No, Interaction, No)

* Model 3: Add Education 

capture drop educ4
gen educ4 = .

replace educ4 = 1 if inlist(educ,0,1,2,3,4,5)
replace educ4 = 2 if educ == 6
replace educ4 = 3 if inlist(educ,7,8)
replace educ4 = 4 if inlist(educ,9,10,11)

label define educ4_lbl 1 "Less than HS" 2 "High School" 3 "Some College" 4 "Bachelor's or Higher", replace
label values educ4 educ4_lbl
label variable educ4 "Education"

tab educ4, missing
order educ4

reg ln_wage commute10 age female i.educ4, r

outreg2 using "/Users/willahock/Desktop/travel time project/Output/Final_Regression_Table.doc", append word ///
ctitle("+ Education") ///
label dec(3) ///
addtext(Demographic Controls, Yes, Education Controls, Yes, Race Controls, No, Hours Worked, No, Interaction, No)


* Model 4: Add Race

gen race4 = .

replace race4 = 1 if race == 1
replace race4 = 2 if race == 2
replace race4 = 3 if inlist(race,4,5,6)
replace race4 = 4 if inlist(race,3,7,8,9)

label define race4_lbl 1 "White" 2 "Black" 3 "Asian" 4 "Other or Multiracial", replace
label values race4 race4_lbl
label variable race4 "Race"

tab race4, missing
order race4

reg ln_wage commute10 age female i.educ4 i.race4, r

outreg2 using "/Users/willahock/Desktop/travel time project/Output/Final_Regression_Table.doc", append word ctitle("+ Race") label dec(3) addtext(Demographic Controls, Yes, Education Controls, Yes, Race Controls, Yes, Hours Worked, No, Interaction, No)


* Model 5: Add Hours Worked and Interaction

summarize uhrswork
order uhrswork
label variable female "Female"

capture drop female_commute
generate female_commute = commute10 * female

label variable commute10 "Commute Time"
label variable female "Female"
label variable female_commute "Commute Time x Female"
label variable age "Age"
label variable uhrswork "Weekly Work Hours"

reg ln_wage commute10 female female_commute age i.educ4 i.race4 uhrswork, r

outreg2 using "/Users/willahock/Desktop/travel time project/Output/Final_Regression_Table.doc", append word ctitle("+ Hours & Interaction") label dec(3) addtext(Demographic Controls, Yes, Education Controls, Yes, Race Controls, Yes, Hours Worked, Yes, Interaction, Yes)

* Table 2: Summary Stats

estpost summarize ln_wage commute10 age female uhrswork

esttab using "/Users/willahock/Desktop/travel time project/Output/Table2_Summary_Statistics.rtf", cells("count(fmt(0) label(N)) mean(fmt(3) label(Mean)) sd(fmt(3) label(Std. Dev.)) min(fmt(3) label(Min)) max(fmt(3) label(Max))") label noobs nonumber replace

*Graph

twoway (scatter incwage commute10, msize(vtiny) mcolor(navy%20)) (lfit incwage commute10, lcolor(red) lwidth(medthick)), yscale(log) ylabel(1000 5000 10000 25000 50000 100000 200000, angle(0) format(%9.0fc)) title("Relationship Between Commute Time and Wage Income") subtitle("2024 Employed Adults Ages 18-65") xtitle("Commute Time (10-Minute Units)") ytitle("Annual Wage Income (USD, Log Scale)") legend(order(1 "Workers" 2 "Fitted Line")) graphregion(color(white))


graph export "\Users\willahock\Desktop\travel time project\Output\Commute_vs_Wage_Graph.png", replace

. 
