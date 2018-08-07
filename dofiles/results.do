* Final paper figures

**********
* Tables *
**********

* Table 1 & 2 are manual: Sampling and Case Descriptions

***********
* Figures *
***********

* Figure 1. Outcomes by City & Case

	use "${directory}/data/analysis.dta" , clear

	label def case 1 "Case 1" 2 "Case 2" 3 "Case 3" 4 "Case 4" , modify

	local opts lw(thin) lc(white) la(center)

	weightab ///
		correct treat_cxr re_3 re_4 treat_refer t_12 ///
		med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9   ///
		if city == 2 ///
		[pweight = weight_city] ///
		, $graph_opts barlab barlook(1 `opts' fi(100)) title("Patna") over(case) graph legend(off) xlab(${pct})

		graph save "${directory}/outputs/Fig_1_1.gph" , replace

	weightab ///
		correct treat_cxr re_3 re_4 treat_refer t_12 ///
		med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9  ///
		if city == 3 ///
		[pweight = weight_city] ///
		, $graph_opts barlab barlook(1 `opts'  fi(100)) title("Mumbai") over(case) graph legend(pos(5) ring(0) c(1) symxsize(small) symysize(small)) xlab(${pct})

		graph save "${directory}/outputs/Fig_1_2.gph" , replace

		graph combine ///
			"${directory}/outputs/Fig_1_1.gph" ///
			"${directory}/outputs/Fig_1_2.gph" ///
			, $comb_opts xsize(7) r(1)

		graph export "${directory}/outputs/Fig_1.tif" , replace width(2000)


* Figure 2:  Case 1 Venn Diagram

	use "${directory}/data/analysis.dta" ///
		if correct == 0 & case == 1 ///
		, clear

	vennprep  med_l_any_2 med_k_any_16 med_l_any_3 med_k_any_9

	* Data then entered into generator at http://www.pangloss.com/seidel/Protocols/venn4.cgi


* Figure 3. Differences by city and qualification

	use "${directory}/data/analysis.dta" , clear

		chartable ///
			correct treat_cxr re_3 treat_refer med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9  ///
			[pweight = weight_city] ///
			, $graph_opts rhs(type_formal 3.city i.case ) case0(Non-MBBS) case1(MBBS+) or command(logit) title("A. Differences by MBBS Qualification")

			graph save "${directory}/outputs/Fig_3_1.gph" , replace

		chartable ///
			correct treat_cxr re_3 re_4 treat_refer med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9  ///
			if type_formal == 0 ///
			[pweight = weight_city] ///
			, $graph_opts rhs(3.city i.case ) case0(Patna Non-MBBS) case1(Mumbai Non-MBBS) or command(logit) title("B. Non-MBBS Differences by City")

			graph save "${directory}/outputs/Fig_3_2.gph" , replace

		chartable ///
			correct treat_cxr re_3 re_4 treat_refer med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9  ///
			if type_formal == 1 ///
			[pweight = weight_city] ///
			, $graph_opts rhs(3.city i.case ) case0(Patna MBBS+) case1(Mumbai MBBS+) or command(logit) title("C. MBBS Differences by City")

			graph save "${directory}/outputs/Fig_3_3.gph" , replace

		graph combine ///
			"${directory}/outputs/Fig_3_1.gph" ///
			"${directory}/outputs/Fig_3_2.gph" ///
			"${directory}/outputs/Fig_3_3.gph" ///
			, $comb_opts xsize(5) c(1) ysize(6) altshrink

			graph export "${directory}/outputs/Fig_3.tif" , replace width(2000)

* Figure 4. Case 3v1 ; Case 4v4

	use "${directory}/data/analysis.dta" , clear

		keep if (case == 3 | case == 1)

		bys facilitycode providerid : egen casemax = max(case)
		bys facilitycode providerid : egen casemin = min(case)
		keep if (casemax == 3 & casemin == 1)
		egen fac = group (facilitycode providerid)

		label def case 1 "Case 1" 2 "Case 2" 3 "Case 3" 4 "Case 4" , modify

		chartable ///
			correct treat_cxr re_3 re_4 treat_refer med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9  ///
			[pweight = weight_city] , $graph_opts title("A. Case 1 vs Case 3 in all providers receiving both cases")  rhs(3.case i.city i.type_formal) case0(Case 1 (N=407)) case1(Case 3 (N=352)) or command(logit)

		graph save "${directory}/outputs/Fig_4_1.gph" , replace

	use "${directory}/data/analysis_sp4.dta" , clear

		label def sp4_spur_1 0 "Ordinary Case 4" 1 "Case 4 w/Sputum Report"
			label val sp4_spur_1 sp4_spur_1

		chartable ///
			correct treat_cxr re_3 re_4 treat_refer med_any med_l_any_1 med_l_any_2 med_l_any_3  med_k_any_9  ///
			, $graph_opts title("B. SP4 with and without sputum report in Mumbai MBBS+") rhs(sp4_spur_1) case0(Ordinary (N=51)) case1(Report (N=50)) or command(logit)

		graph save "${directory}/outputs/Fig_4_2.gph" , replace

		graph combine ///
			"${directory}/outputs/Fig_4_1.gph" ///
			"${directory}/outputs/Fig_4_2.gph" ///
			, $comb_opts xsize(7) c(1)

		graph export "${directory}/outputs/Fig_4.tif" , replace width(2000)


* Have a lovely day!
