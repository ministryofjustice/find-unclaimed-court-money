Case.create!(account_number: "1200000198014", year_carried_over:	"2021", case_name: "Miss M Moazzam vs Mr M Waheed A/C Miss M Moazzam", date_account_opened: "30/07/2012", case_date: Date.parse("30/07/2012"))
Case.create!(account_number: "1200000215595", year_carried_over:	"2016", case_name: "The Sec. of State for Enviroment for Wales re the absent owner of the land being Plot 7 of the form er Six Bells Colliery Abertillery  Blaeunau Gwent", date_account_opened: "20/08/2012", case_date: Date.parse("20/08/2012"))
Case.create!(account_number: "1200000513084", year_carried_over:	"2016", case_name: "NATIONAL WESTMINSTER HOME LOANS LIMITED AND KWAN LAI LEUNG RE FLAT 4    COPESWOOD COURT SIPSON ROAD SIPSON WEST DRAYTON UB7 0JF", date_account_opened: "22/08/2013", case_date: Date.parse("22/08/2013"))
Case.create!(account_number: "20691839L", year_carried_over:	"2018", case_name: "BLAKE (INF) V SPENCER	L", date_account_opened: "24/11/2006", case_date: Date.parse("24/11/2006"))
Case.create!(account_number: "19680007B", year_carried_over:	"1968", case_name: "BARBER	B", date_account_opened: "01/01/1952", case_date: Date.parse("01/01/1952"), credit_details: "IN THE MATTER OF THE TRUSTS OF THE    RESIDUARY ESTATE OF ANN BARBER DECEASED. (306487).")
Case.create!(account_number: "19231452A", year_carried_over:	"1923", case_name: "GERMAN UNION & TELEGRAPH & TRUST CO LTD	A", date_account_opened: "01/01/1891", case_date: Date.parse("01/01/1891"), credit_details: "THE GERMAN UNION AND TELEGRAPH AND TRUST COMPANY LIMITED (IN LIQUIDATION) (FOLIO PW3001).")

60.times do |i|
  Case.create!(account_number: i, year_carried_over: "2000", case_name: "case name #{i}", date_account_opened: "15/02/2022", case_date: Date.parse("15/02/2022"))
end

User.create!(name: "admin", password: "admin")
