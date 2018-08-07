* Appendix materials

* Overtreatment

	use "$directory/constructed/analysis_baseline.dta" , clear

	gen check = 1 // Incorrect assumed
	replace check = 2 if correct == 0 & med > 0
	replace check = 3 if correct == 1 // overtreatment
	replace check = 4 if check == 3 & ((med==0 & case !=3) | (med==1&case==3))

	label def case 1 "Case 1" 2 "Case 2" 3 "Case 3" 4 "Case 4", modify

	tabgen check

	graph bar check_? [pweight=weight], xsize(6) stack over(case) ylab(${pct}) ///
		bar(1, fc(navy) fi(100) lc(black) lw(thin)) bar(2, fc(maroon) fi(100) lc(black) lw(thin)) bar(3, fc(gold) fi(100) lc(black) lw(thin)) bar(4, fc(dkgreen) fi(100) lc(black) lw(thin) )  ///
		$graph_opts1 legend(order(4 "Correct Treatment Only" 2 "Other Medication Only" 3 "Correct + Other Medication"  1 "Not Correct, No Medication") symxsize(small) symysize(small) c(2) pos(6))

	graph export "$directory/outputs/BaselinePaper/images/A_case_overtreatment.png" , replace


* Informal - AYUSH

	use "$directory/constructed/analysis_baseline.dta" , clear

	keep if type_formal == 0

	chartable ///
		correct treat_cxr re_3 treat_refer med_any med_l_any_2 med_l_any_3  med_k_any_9  ///
		if cp_5_det < 3 & city == 2 ///
		[pweight = weight_city] ///
		, rhs(2.cp_5_det i.case ) case0(Non-AYUSH) case1(AYUSH) or command(logit) xsize(8)

		graph export "$directory/outputs/BaselinePaper/images/A_informal_ayush.png" , replace

* Followups

	use "$directory/constructed/analysis_baseline.dta" , clear


	gen check = 1 // Incorrect assumed
	replace check = 2 if correct == 0 & med > 0
	replace check = 3 if correct == 1 // overtreatment
	replace check = 4 if check == 3 & ((med==0 & case !=3) | (med==1&case==3))

	label def check 4 " Correct Treatment Only" 2 "Other Medication Only" 3 "Correct + Other Medication"  1 "Not Correct, No Medication"
		label val check check

	label def case 1 "Case 1" 2 "Case 2" 3 "Case 3" 4 "Case 4" , modify
	local opts lw(thin) lc(white) la(center) fi(100)

	weightab ///
		t_12 t_12?  ///
		if city == 2 ///
		[pweight = weight_city] ///
		, $graph_opts barlab title("Patna") over(check) graph  xlab(${pct}) legend(pos(6) ring(1) c(2) symxsize(small) symysize(small) ///
			order(1 "Correct Treatment Only" 3 "Other Medication Only" 2 "Correct + Other Medication"  4 "Not Correct, No Medication"))  ///
		barlook(1 fc(dkgreen) `opts' 2 fc(gold) `opts' 3 fc(maroon) `opts'  4 fc(navy) `opts')

		graph save "$directory/outputs/BaselinePaper/images/A_followup_1.gph" , replace

	weightab ///
		t_12 t_12?  ///
		if city == 3 ///
		[pweight = weight_city] ///
		, $graph_opts barlab title("Mumbai") over(check) graph legend(off) xlab(${pct}) ///
		barlook(1 fc(dkgreen) `opts' 2 fc(gold) `opts' 3 fc(maroon) `opts'  4 fc(navy) `opts' )

		graph save "$directory/outputs/BaselinePaper/images/A_followup_2.gph" , replace

		grc1leg ///
			"$directory/outputs/BaselinePaper/images/A_followup_1.gph" ///
			"$directory/outputs/BaselinePaper/images/A_followup_2.gph" ///
			, $comb_opts xsize(8) r(1)

		graph export "$directory/outputs/BaselinePaper/images/A_followup.png" , replace width(1000)


* Figure 5: ANOVA


	set matsize 5000
	use "$directory/constructed/analysis_baseline.dta" , clear

	cap mat drop theResults

	egen sp_city_id = group(city sp_id)
	egen sp_city_mbbs = group(city type_formal case)
	egen fac = group(facilitycode providerid)

	local x = 0
	qui foreach var of varlist ///
		correct treat_cxr re_3 re_4 treat_refer ///
		med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 {

		mean `var' [pweight = weight_city]
		mat a = e(b)
		local mean = a[1,1]
		local mean = string(round(100*`mean',0))
		local mean = substr("`mean'",1,strpos("`mean'",".")+1)

		local ++x
		local theLabel : var label `var'
		local theLabels `" `theLabels' `x' "`theLabel'" "' // [`mean'%]

		cap mat drop theResult
		reg `var' i.city [pweight = weight_city]
			local theR21 = `e(r2)'
			mat theResult = nullmat(theResult) , [`theR21']

		reg `var' i.city i.case [pweight = weight_city]
			local theR22 = `e(r2)' - `theR21'
			mat theResult = nullmat(theResult) , [`theR22']

		reg `var' i.city i.case i.type_formal  [pweight = weight_city]
			local theR23 = `e(r2)' - `theR21' - `theR22'
			mat theResult = nullmat(theResult) , [`theR23']

		reg `var' i.city i.case i.type_formal i.sp_city_id  [pweight = weight_city]
			local theR24 = `e(r2)' - `theR21' - `theR22' - `theR23'
			mat theResult = nullmat(theResult) , [`theR24']

		reg `var' i.city i.case i.type_formal i.sp_city_id i.sp_city_mbbs [pweight = weight_city]
			local theR25 = `e(r2)' - `theR21' - `theR22' - `theR23' - `theR24'
			mat theResult = nullmat(theResult) , [`theR25']

		mean `var' [pweight = weight_city]
		mat a = e(b)
		local mean = a[1,1]
		mat theResult = nullmat(theResult) , [`mean']

			mat theResults = nullmat(theResults) \ theResult
			matlist theResults

			}

		clear
		svmat theResults
		gen n = _n
		label def n `theLabels'
		label val n n

		graph bar (sum) theResults1 theResults2 theResults3 theResults4 theResults5  ///
			, ylab(${pct}) $graph_opts1 hor stack over(n) xsize(6) ///
			bar(1, lc(black) lw(thin)) ///
			bar(2, lc(black) lw(thin)) ///
			bar(3, lc(black) lw(thin)) ///
			bar(4, fc(black) lc(black) lw(thin)) ///
			bar(5, fc(gs12) lc(black) lw(thin)) ///
			legend(pos(5) ring(0) c(1) symxsize(small) symysize(small)  ///
			order(6 "Variance Explained By:" 1 "City Setting" 2 "Case Scenario" 3 "MBBS Degree" 4 "All SP Characteristics" 5 "Full Interaction Model"  ))

		graph export "$directory/outputs/BaselinePaper/images/A_ANOVA.png" , replace width(1000)


* Consistency

	use "$directory/constructed/analysis_baseline.dta" , clear

	bys providerid case: egen maxvisit = max(visit)
		keep if maxvisit == 2

	bys providerid case: egen minvisit = min(visit)
		keep if minvisit == 1

	keep providerid correct treat_cxr re_3 treat_refer ///
		med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9 ///
		type_formal weight_city visit

		encode providerid, gen(id)
		xtset id visit
			local x = 0
			foreach item in correct treat_cxr re_3 treat_refer ///
				med_any  med_l_any_2 med_l_any_3  med_k_any_9 {
					local ++x
					local theLabel : var label `item'
					gen cons_`x' = d.`item'
					recode cons_`x' (0=1)(.=.)(*=0)
					label var cons_`x' "`theLabel'"
					}

		label def type_formal 0 "Non-MBBS" 1 "MBBS+"
			label val type_formal type_formal

		drop if cons_1 == .

		betterbar cons*  ///
			, xsize(6)  se n over(type_formal) $graph_opts xlab($pct) legend(r(1) symxsize(small) symysize(small)) ///
			legend(c(1)) barlook(1 fc(maroon) lw(thin) lc(white) fi(100) 2 fc(navy) lw(thin) lc(white) fi(100) )

		graph export "$directory/outputs/BaselinePaper/images/A_consistency.png" , replace

* Distributions of checklist by city and qualification

	use "$directory/constructed/analysis_baseline.dta" , clear

	egen check1 = rownonmiss(sp?_h_*)
	egen check2 = rowtotal(sp?_h_*)
	gen fehat = check2/check1

	egen sp_city_id = group(city sp_id)
	egen sp_city_mbbs = group(city type_formal case) , label
	egen fac = group(facilitycode providerid)

	/*
	xtset fac
	xtreg correct  i.city i.case i.type_formal i.sp_city_id i.sp_city_mbbs , fe
		predict fehat , u
		replace fehat = fehat + _b[_cons]
		replace fehat = . if fehat > 1
		replace fehat = . if fehat < 0
	*/

	label def formal 0 "Non-MBBS" 1 "MBBS+" , modify
		label val type_formal formal
	cap drop typetemp
	egen typetemp = group(city type_formal ) , label

	keep if case == 1
	duplicates drop fac, force
	local theWeight "[aweight=weight_city]"
		tw ///
			(kdensity fehat if typetemp == 1 `theWeight', lw(thick) fi(100)) ///
			(kdensity fehat if typetemp == 2 `theWeight', lw(thick) lc(dkgreen)  fi(100)) ///
			(kdensity fehat if typetemp == 3 `theWeight', lw(thick) lc(maroon)  fi(100)) ///
			(kdensity fehat if typetemp == 4 `theWeight', lw(thick) fi(100)) ///
			, $graph_opts xlab(${pct}) ylab(none) xtit("Checklist Completion in Case 1 {&rarr}") ///
				legend(pos(12) r(1) order(1 "Patna Non-MBBS" 3 "Mumbai Non-MBBS"  2 "Patna MBBS" 4 "Mumbai MBBS")) xsize(7)

			graph export "$directory/outputs/BaselinePaper/images/A_distributions.png" , replace width(1000)

/* Followups

	use "$directory/constructed/analysis_baseline.dta" , clear

	label def case 1 "Case 1" 2 "Case 2" 3 "Case 3" 4 "Case 4" , modify

	weightab ///
		t_12 t_12?  ///
		if city == 2 ///
		[pweight = weight_city] ///
		, $graph_opts barlab barlook(1 lw(thin) lc(white) fi(100)) title("Patna") over(case) graph legend(off) xlab(${pct})

		graph save "$directory/outputs/BaselinePaper/images/A_followup_1.gph" , replace

	weightab ///
		t_12 t_12?  ///
		if city == 3 ///
		[pweight = weight_city] ///
		, $graph_opts barlab barlook(1 lw(thin) lc(white) fi(100)) title("Mumbai") over(case) graph legend(pos(3) ring(0) c(1) symxsize(small) symysize(small)) xlab(${pct})

		graph save "$directory/outputs/BaselinePaper/images/A_followup_2.gph" , replace

		graph combine ///
			"$directory/outputs/BaselinePaper/images/A_followup_1.gph" ///
			"$directory/outputs/BaselinePaper/images/A_followup_2.gph" ///
			, $comb_opts xsize(6) r(1)

		graph export "$directory/outputs/BaselinePaper/images/A_followup.png" , replace width(1000)

* Have a lovely day!
