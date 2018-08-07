* Appendix materials

* S1 Fig

	use "${directory}/data/analysis.dta" , clear

	gen check = 1 // Incorrect assumed
	replace check = 2 if correct == 0 & med > 0
	replace check = 3 if correct == 1 // overtreatment
	replace check = 4 if check == 3 & ((med==0 & case !=3) | (med==1&case==3))

	label def case 1 "Case 1" 2 "Case 2" 3 "Case 3" 4 "Case 4", modify

	tabgen check

	graph bar check_? [pweight=weight], xsize(6) stack over(case) ylab(${pct}) ///
		bar(1, fc(navy) fi(100) lc(black) lw(thin)) bar(2, fc(maroon) fi(100) lc(black) lw(thin)) bar(3, fc(gold) fi(100) lc(black) lw(thin)) bar(4, fc(dkgreen) fi(100) lc(black) lw(thin) )  ///
		$graph_opts1 legend(order(4 "Correct Treatment Only" 2 "Other Medication Only" 3 "Correct + Other Medication"  1 "Not Correct, No Medication") symxsize(small) symysize(small) c(2) pos(6))

	graph export "${directory}/appendix/S1_Fig.png" , replace

* S2 Fig

	use "${directory}/data/analysis.dta" , clear


	gen check = 1 // Incorrect assumed
	replace check = 2 if correct == 0 & med > 0
	replace check = 3 if correct == 1
	replace check = 4 if check == 3 & ((med==0 & case !=3) | (med==1&case==3))

	label def check 4 " Correct Treatment Only" 2 "Other Medication Only" 3 "Correct + Other Medication"  1 "Not Correct, No Medication"
		label val check check

	label def case 1 "Case 1" 2 "Case 2" 3 "Case 3" 4 "Case 4" , modify
	local opts lw(thin) lc(white) la(center) fi(100)

	weightab ///
		t_12 t_12a t_12b t_12c t_12d t_12e  ///
		if city == 2 ///
		[pweight = weight_city] ///
		, $graph_opts barlab title("Patna") over(check) graph  xlab(${pct}) legend(pos(6) ring(1) c(2) symxsize(small) symysize(small) ///
			order(1 "Correct Treatment Only" 3 "Other Medication Only" 2 "Correct + Other Medication"  4 "Not Correct, No Medication"))  ///
		barlook(1 fc(dkgreen) `opts' 2 fc(gold) `opts' 3 fc(maroon) `opts'  4 fc(navy) `opts')

		graph save "${directory}/appendix/S2_Fig_1.gph" , replace

	weightab ///
		t_12 t_12a t_12b t_12c t_12d t_12e  ///
		if city == 3 ///
		[pweight = weight_city] ///
		, $graph_opts barlab title("Mumbai") over(check) graph legend(off) xlab(${pct}) ///
		barlook(1 fc(dkgreen) `opts' 2 fc(gold) `opts' 3 fc(maroon) `opts'  4 fc(navy) `opts' )

		graph save "${directory}/appendix/S2_Fig_2.gph" , replace

		grc1leg ///
			"${directory}/appendix/S2_Fig_1.gph" ///
			"${directory}/appendix/S2_Fig_2.gph" ///
			, $comb_opts xsize(8) r(1)

		graph export "${directory}/appendix/S2_Fig.png" , replace width(1000)

* S3 Fig

	set matsize 5000
	use "${directory}/data/analysis.dta" , clear

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

		graph export "${directory}/appendix/S3_Fig.png" , replace width(1000)

* S4 Fig

	use "${directory}/data/analysis.dta" , clear

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
			legend(c(1)) barlook(1 fc(maroon) ${bar} fi(100) 2 fc(navy) ${bar} )

		graph export "${directory}/appendix/S4_Fig.png" , replace

* S5 Fig

	use "${directory}/data/analysis.dta" , clear

	local checklist ///
	sp1_h_1 sp1_h_2 sp1_h_3 sp1_h_4 sp1_h_5 sp1_h_6 sp1_h_7 sp1_h_8 sp1_h_9 sp1_h_10 sp1_h_11 sp1_h_12 ///
		sp1_h_13 sp1_h_14 sp1_h_15 sp1_h_16 sp1_h_17 sp1_h_18 sp1_h_19 sp1_h_20 sp1_h_21 ///
	sp2_h_1 sp2_h_2 sp2_h_3 sp2_h_4 sp2_h_5 sp2_h_6 sp2_h_7 sp2_h_8 sp2_h_9 sp2_h_10 sp2_h_11 sp2_h_12 ///
		sp2_h_13 sp2_h_14 sp2_h_15 sp2_h_16 sp2_h_17 sp2_h_18 sp2_h_19 sp2_h_20 sp2_h_21 sp2_h_22 sp2_h_23 sp2_h_24 sp2_h_25 sp2_h_26 sp2_h_27 sp2_h_28 ///
	sp3_h_1 sp3_h_2 sp3_h_3 sp3_h_4 sp3_h_5 sp3_h_6 sp3_h_7 sp3_h_8 sp3_h_9 sp3_h_10 sp3_h_11 sp3_h_12 ///
		sp3_h_13 sp3_h_14 sp3_h_15 sp3_h_16 sp3_h_17 sp3_h_18 sp3_h_19 sp3_h_20 sp3_h_21 sp3_h_22 sp3_h_23 ///
	sp4_h_1 sp4_h_2 sp4_h_3 sp4_h_4 sp4_h_5 sp4_h_6 sp4_h_7 sp4_h_8 sp4_h_9 sp4_h_10 sp4_h_11 sp4_h_12 ///
		sp4_h_13 sp4_h_14 sp4_h_15 sp4_h_16 sp4_h_17 sp4_h_18 sp4_h_19 sp4_h_20 sp4_h_21 sp4_h_22 sp4_h_23 ///
		sp4_h_24 sp4_h_25 sp4_h_26 sp4_h_27 sp4_h_28 sp4_h_29 sp4_h_30 sp4_h_31

	egen check1 = rownonmiss(`checklist')
	egen check2 = rowtotal(`checklist')
	gen fehat = check2/check1

	egen sp_city_id = group(city sp_id)
	egen sp_city_mbbs = group(city type_formal case) , label
	egen fac = group(facilitycode providerid)

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
		, $graph_opts xlab(${pct}) ytit("") ylab(none) xtit("Checklist Completion in Case 1 {&rarr}") ///
			legend(pos(12) r(1) order(1 "Patna Non-MBBS" 3 "Mumbai Non-MBBS"  2 "Patna MBBS" 4 "Mumbai MBBS")) xsize(7)

		graph export "${directory}/appendix/S5_Fig.png" , replace width(1000)

* S6 Fig

	use "${directory}/data/analysis.dta" , clear

	keep if type_formal == 0

	chartable ///
		correct treat_cxr re_3 treat_refer med_any med_l_any_2 med_l_any_3  med_k_any_9  ///
		if cp_5_det < 3 & city == 2 ///
		[pweight = weight_city] ///
		, rhs(2.cp_5_det i.case ) case0(Non-AYUSH) case1(AYUSH) or command(logit) xsize(8)

		graph export "${directory}/appendix/S6_Fig.png" , replace

* Have a lovely day!
