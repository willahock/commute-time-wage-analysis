*******************************************************
* COMMUTE TIME AND WAGE INCOME
* Econometric Analysis Using 2024 IPUMS USA Data
* Author: Willa Hock
*******************************************************

clear all
set more off

*******************************************************
* Load Data
*******************************************************

* Raw IPUMS data are not included in this repository.
* Update the path below to the location of your IPUMS extract.
use "Data/IPUMS_2024.dta", clear


*******************************************************
* Clean Data
*******************************************************

* Keep working-age adults
keep if inrange(age, 18, 65)

* Keep employed individuals
keep if empstat == 1

* Keep positive and valid wage income
keep if incwage > 0 & incwage < 999998

* Keep valid commute times, including 0 minutes
keep if trantime >= 0 & !missing(trantime)

* Check final analytical sample size
count


*******************************************************
* Create Variables
*******************************************************

* Natural log of annual wage income
gen ln_wage = ln(incwage)

* Commute time measured in 10-minute units
gen commute10 = trantime / 10

* Female indicator
gen female = (sex == 2)

* Variable labels
label variable ln_wage "Log Annual Wage Income"
label variable commute10 "Commute Time, 10-Minute Units"
label variable age "Age"
label variable female "Female"
label variable educ "Educational Attainment"
label variable race "Race"
label variable uhrswork "Usual Weekly Work Hours"

* Check main variables
summarize incwage ln_wage trantime commute10
summarize age female uhrswork
tab educ
tab race

* Check for missing values
misstable summarize ln_wage commute10 age female educ race uhrswork


*******************************************************
* Model 1: Simple OLS
*******************************************************

reg ln_wage commute10, r

outreg2 using "Output/Final_Regression_Table.doc", replace word ///
    ctitle("OLS") ///
    label dec(3) ///
    addtext(Demographic Controls, No, Education Controls, No, ///
    Race Controls, No, Hours Worked, No, Interaction, No)


*******************************************************
* Model 2: Add Demographic Controls
*******************************************************

reg ln_wage commute10 age female, r

outreg2 using "Output/Final_Regression_Table.doc", append word ///
    ctitle("+ Demographics") ///
    label dec(3) ///
    addtext(Demographic Controls, Yes, Education Controls, No, ///
    Race Controls, No, Hours Worked, No, Interaction, No)


*******************************************************
* Model 3: Add Education Controls
*******************************************************

capture drop educ4
gen educ4 = .

replace educ4 = 1 if inlist(educ, 0, 1, 2, 3, 4, 5)
replace educ4 = 2 if educ == 6
replace educ4 = 3 if inlist(educ, 7, 8)
replace educ4 = 4 if inlist(educ, 9, 10, 11)

label define educ4_lbl ///
    1 "Less than HS" ///
    2 "High School" ///
    3 "Some College" ///
    4 "Bachelor's or Higher", replace

label values educ4 educ4_lbl
label variable educ4 "Education"

tab educ4, missing

reg ln_wage commute10 age female i.educ4, r

outreg2 using "Output/Final_Regression_Table.doc", append word ///
    ctitle("+ Education") ///
    label dec(3) ///
    addtext(Demographic Controls, Yes, Education Controls, Yes, ///
    Race Controls, No, Hours Worked, No, Interaction, No)


*******************************************************
* Model 4: Add Race Controls
*******************************************************

capture drop race4
gen race4 = .

replace race4 = 1 if race == 1
replace race4 = 2 if race == 2
replace race4 = 3 if inlist(race, 4, 5, 6)
replace race4 = 4 if inlist(race, 3, 7, 8, 9)

label define race4_lbl ///
    1 "White" ///
    2 "Black" ///
    3 "Asian" ///
    4 "Other or Multiracial", replace

label values race4 race4_lbl
label variable race4 "Race"

tab race4, missing

reg ln_wage commute10 age female i.educ4 i.race4, r

outreg2 using "Output/Final_Regression_Table.doc", append word ///
    ctitle("+ Race") ///
    label dec(3) ///
    addtext(Demographic Controls, Yes, Education Controls, Yes, ///
    Race Controls, Yes, Hours Worked, No, Interaction, No)


*******************************************************
* Model 5: Add Hours Worked and Gender Interaction
*******************************************************

capture drop female_commute
gen female_commute = commute10 * female

label variable female_commute "Commute Time x Female"

reg ln_wage commute10 female female_commute age ///
    i.educ4 i.race4 uhrswork, r

outreg2 using "Output/Final_Regression_Table.doc", append word ///
    ctitle("+ Hours & Interaction") ///
    label dec(3) ///
    addtext(Demographic Controls, Yes, Education Controls, Yes, ///
    Race Controls, Yes, Hours Worked, Yes, Interaction, Yes)


*******************************************************
* Table 2: Summary Statistics
*******************************************************

estpost summarize ln_wage commute10 age female uhrswork

esttab using "Output/Table2_Summary_Statistics.rtf", ///
    cells("count(fmt(0) label(N)) mean(fmt(3) label(Mean)) ///
    sd(fmt(3) label(Std. Dev.)) min(fmt(3) label(Min)) ///
    max(fmt(3) label(Max))") ///
    label noobs nonumber replace


*******************************************************
* Figure 1: Commute Time and Wage Income
*******************************************************

twoway ///
    (scatter incwage commute10, msize(vtiny) mcolor(navy%20)) ///
    (lfit incwage commute10, lcolor(red) lwidth(medthick)), ///
    yscale(log) ///
    ylabel(1000 5000 10000 25000 50000 100000 200000, ///
    angle(0) format(%9.0fc)) ///
    title("Relationship Between Commute Time and Wage Income") ///
    subtitle("2024 Employed Adults Ages 18-65") ///
    xtitle("Commute Time (10-Minute Units)") ///
    ytitle("Annual Wage Income (USD, Log Scale)") ///
    legend(order(1 "Workers" 2 "Fitted Line")) ///
    graphregion(color(white))

graph export "Output/Commute_vs_Wage_Graph.png", replace
