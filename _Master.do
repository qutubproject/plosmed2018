* Master

	global directory "/Users/bbdaniels/Dropbox/WorldBank/QuTub/Restricted/CrossCityAnalysis/"

* Adofiles

	qui do "$directory/adofiles/MetadataImport/import_metadata.ado"
	qui do "$directory/adofiles/chartable/chartable.ado"
	qui do "$directory/adofiles/chartable/chartable_SP3.ado"
	qui do "$directory/adofiles/BetterBarGraph/betterbar.ado"
	qui do "$directory/adofiles/LabelCollapse/labelcollapse.ado"
	qui do "$directory/adofiles/AnyCategory/anycat.ado"
	qui do "$directory/adofiles/WeightTab/weightab.ado"
	qui do "$directory/adofiles/oddsratios/ornado.ado"
	qui do "$directory/adofiles/dateencoding/datecode.ado"
	qui do "$directory/adofiles/tabstatout/tabstatout.ado"
	qui do "$directory/adofiles/intervals/intervals.ado"
	qui do "$directory/adofiles/tableout/tableout.ado"
	qui do "$directory/adofiles/medicinelookup/medlookup.ado"
	qui do "$directory/adofiles/randomtrialregression/rctreg.ado"
	qui do "$directory/adofiles/tabgen/tabgen.ado"
	qui do "$directory/adofiles//xiLabels/xiplus.ado"
	qui do "$directory/adofiles//freereshape/freeshape.ado"
	qui do "$directory/adofiles//easyirt/easyirt.ado"
	qui do "$directory/adofiles//referencecomparisons/reftab.ado"
	qui do "$directory/adofiles//knapsack/knapsack.ado"
	qui do "$directory/adofiles//openstatakit/saveopendata.ado"


* Options

	global graph_opts ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) la(center)) ///
		ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
		yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

	global graph_opts1 ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) la(center)) ///
		ylab(,angle(0) nogrid)  ///
		yscale(noline) legend(region(lc(none) fc(none)))

	global comb_opts ///
		graphregion(color(white) lc(white) lw(med) la(center))

	global hist_opts ///
		ylab(, angle(0) axis(2)) yscale(off alt axis(2)) ///
		ytit(, axis(2)) ytit(, axis(1))  yscale(alt)

	global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
	global numbering `""(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)""'

* For presentation

	* global directory "/Users/bbdaniels/Dropbox/WorldBank/QuTub/Restricted"

* Clean for release
-
	cd $directory/outputs/BaselinePaper/

	use "$directory/constructed/analysis_baseline.dta" , clear
		saveopendata ///
			"analysis_baseline" ///
		using ///
			"baseline_results.do baseline_appendix.do" ///
		, compact

	use "$directory/constructed/analysis_baseline_sp4.dta" , clear
		saveopendata ///
			"analysis_baseline_sp4" ///
		using ///
			"baseline_results.do baseline_appendix.do" ///
		, compact



* Have a lovely day!
