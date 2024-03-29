shared TransformSourceData =
let
      customer = List.First(Source[customers]),      
      stateMap = Record.FromTable(Table.FromRecords({
				[Name = "Alabama", Value = "AL"],
				[Name = "Alaska", Value = "AK"],
				[Name = "American Samoa", Value = "AS"],
				[Name = "Arizona", Value = "AZ"],
				[Name = "Arkansas", Value = "AR"],
				[Name = "Armed Forces Africa", Value = "AE"],
				[Name = "Armed Forces Americas", Value = "AA"],
				[Name = "Armed Forces Canada", Value = "AE"],
				[Name = "Armed Forces Europe", Value = "AE"],
				[Name = "Armed Forces Middle East", Value = "AE"],
				[Name = "Armed Forces Pacific", Value = "AP"],
				[Name = "California", Value = "CA"],
				[Name = "Colorado", Value = "CO"],
				[Name = "Connecticut", Value = "CT"],
				[Name = "Delaware", Value = "DE"],
				[Name = "District of Columbia", Value = "DC"],
				[Name = "Federated States Of Micronesia", Value = "FM"],
				[Name = "Florida", Value = "FL"],
				[Name = "Georgia", Value = "GA"],
				[Name = "Guam", Value = "GU"],
				[Name = "Hawaii", Value = "HI"],
				[Name = "Idaho", Value = "ID"],
				[Name = "Illinois", Value = "IL"],
				[Name = "Indiana", Value = "IN"],
				[Name = "Iowa", Value = "IA"],
				[Name = "Kansas", Value = "KS"],
				[Name = "Kentucky", Value = "KY"],
				[Name = "Louisiana", Value = "LA"],
				[Name = "Maine", Value = "ME"],
				[Name = "Marshall Islands", Value = "MH"],
				[Name = "Maryland", Value = "MD"],
				[Name = "Massachusetts", Value = "MA"],
				[Name = "Michigan", Value = "MI"],
				[Name = "Minnesota", Value = "MN"],
				[Name = "Mississippi", Value = "MS"],
				[Name = "Missouri", Value = "MO"],
				[Name = "Montana", Value = "MT"],
				[Name = "Nebraska", Value = "NE"],
				[Name = "Nevada", Value = "NV"],
				[Name = "New Hampshire", Value = "NH"],
				[Name = "New Jersey", Value = "NJ"],
				[Name = "New Mexico", Value = "NM"],
				[Name = "New York", Value = "NY"],
				[Name = "North Carolina", Value = "NC"],
				[Name = "North Dakota", Value = "ND"],
				[Name = "Northern Mariana Islands", Value = "CM"],
				[Name = "Ohio", Value = "OH"],
				[Name = "Oklahoma", Value = "OK"],
				[Name = "Oregon", Value = "OR"],
				[Name = "Palau", Value = "PW"],
				[Name = "Pennsylvania", Value = "PA"],
				[Name = "Puerto Rico", Value = "PR"],
				[Name = "Rhode Island", Value = "RI"],
				[Name = "South Carolina", Value = "SC"],
				[Name = "South Dakota", Value = "SD"],
				[Name = "Tennessee", Value = "TN"],
				[Name = "Texas", Value = "TX"],
				[Name = "Utah", Value = "UT"],
				[Name = "Vermont", Value = "VT"],
				[Name = "Virgin Islands", Value = "VI"],
				[Name = "Virginia", Value = "VA"],
				[Name = "Washington", Value = "WA"],
				[Name = "West Virginia", Value = "WV"],
				[Name = "Wisconsin", Value = "WI"],
				[Name = "Wyoming", Value = "WY"]
			})),	
	external_id = customer[id],
	address1 = if List.Count(customer[addresses]) > 0 then customer[addresses]{0} else null,
	address2 = if List.Count(customer[addresses]) > 1 then customer[addresses]{1} else null,	 
	account_base = [
		name = Record.FieldOrDefault(customer, "first_name") & " " & Record.FieldOrDefault(customer, "last_name"),
		telephone1 =  Record.FieldOrDefault(customer, "phone"), 
		emailaddress1 = Record.FieldOrDefault(customer, "email"),
		description = Record.FieldOrDefault(customer, "note")
	],
	account_with_addr1 = if address1 <> null then Record.Combine({account_base, [
		address1_line1 = Record.FieldOrDefault(address1, "address1"),
		address1_line2 = Record.FieldOrDefault(address1, "address2"),
		address1_city = Record.FieldOrDefault(address1, "city"),
		address1_stateorprovince = 
			if Record.FieldOrDefault(address1, "province") = null then null else 
			if Record.FieldOrDefault(stateMap, Record.FieldOrDefault(address1, "province")) = null then Record.FieldOrDefault(address1, "province") else 
				Record.FieldOrDefault(stateMap, Record.FieldOrDefault(address1, "province")),
		address1_postalcode = Record.FieldOrDefault(address1, "zip"),
		address1_country = Record.FieldOrDefault(address1, "country"),
		address1_telephone1 = Record.FieldOrDefault(address1, "phone")
	]}) else account_base,
	account_final = if address2 <> null then Record.Combine({account_with_addr1, [
		address2_line1 = Record.FieldOrDefault(address2, "address1"),
		address2_line2 = Record.FieldOrDefault(address2, "address2"),
		address2_city = Record.FieldOrDefault(address2, "city"),
		address2_stateorprovince = 
			if Record.FieldOrDefault(address2, "province") = null then null else 
			if Record.FieldOrDefault(stateMap, Record.FieldOrDefault(address2, "province")) = null then Record.FieldOrDefault(address2, "province") else 
				Record.FieldOrDefault(stateMap, Record.FieldOrDefault(address2, "province")),
		address2_postalcode = Record.FieldOrDefault(address2, "zip"),
		address2_country = Record.FieldOrDefault(address2, "country"),
		address2_telephone1 = Record.FieldOrDefault(address2, "phone")
	]}) else account_with_addr1
in Text.FromBinary(Json.FromValue(account_final));