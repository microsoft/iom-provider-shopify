 shared ImportMappingKey = [
  account = {
      [
        ExternalRecordKey = [customer_id = Text.From(Source[order][customer][id])],
        SelectedFields = {"accountid"}
      ]
    },
  pricelevel = {
      [
        ExternalRecordKey = [ProviderName = "Shopify"],
        SelectedFields = {"pricelevelid"}
      ]
    },
  product = List.Distinct(List.Transform(Source[order][line_items], each
      [
        ExternalRecordKey = [productid = Number.ToText(_[product_id])],
        SelectedFields = {"productid"}
      ])),
  uom = {
      [
        ExternalRecordKey = [unit = "each"],
        SelectedFields = {"uomid"}
      ]
    }
];
 
 shared TransformSourceData =
 
  let

  #"Converted to table" = Table.FromRecords({Source}),
  order = #"Converted to table"[order]{0},
  current_subtotal_price_set = order[current_subtotal_price_set],
  shop_money = current_subtotal_price_set[shop_money],
  current_total_discounts_set = order[current_total_discounts_set],
  billing_address = order[billing_address],
  shipping_address = order[shipping_address],
  shipping_lines = order[shipping_lines],
  leadtime = 2,
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
  
  useWriteInProductEnabled = order[useWriteInProductEnabled],
  isDualWriteEnabled = order[isDualWriteEnabled],
  account = IOM.MapRecord(IOM.MappingTables[account], [customer_id = Text.From(Source[order][customer][id])]),
  pricelevel = IOM.MapRecord(IOM.MappingTables[pricelevel], [ProviderName = "Shopify"]),
  orderheader = Record.FromTable
        (
            Table.SelectRows
            (
                Record.ToTable
                (
                    [
                        name = if Record.HasFields(order, "name") then Record.FieldOrDefault(order, "name") else Record.FieldOrDefault(order, "id"),
                        #"customerid_account@odata.bind" = "/accounts(" & Text.From(account[accountid]) & ")",
                        #"pricelevelid@odata.bind" = "/pricelevels(" & Text.From(pricelevel[pricelevelid]) & ")",
                        emailaddress = if Record.HasFields(order, "contact_email") then Record.FieldOrDefault(order, "contact_email") else null,
                        createdon = if Record.HasFields(order, "created_at") then Record.FieldOrDefault(order, "created_at") else null,
                        modifiedon = if Record.HasFields(order, "updated_at") then Record.FieldOrDefault(order, "updated_at") else null,
                        msdyn_invoiceaddresslatitude = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "latitude") else null,
                        msdyn_invoiceaddresslongitude = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "longitude") else null,
                        billto_composite = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "address1") else null,
                        billto_city = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "city") else null,
                        billto_contactname = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "name") else null,
                        billto_country = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "country_code") else null,
                        billto_name = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "name") else null,
                        billto_telephone = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "phone") else null,
                        billto_stateorprovince = if Record.FieldOrDefault(billing_address, "province_code") <> null then Record.FieldOrDefault(billing_address, "province_code") else if Record.FieldOrDefault(billing_address, "province") = null then null else if Record.FieldOrDefault(stateMap, Record.FieldOrDefault(billing_address, "province")) = null then Record.FieldOrDefault(billing_address, "province") else Record.FieldOrDefault(stateMap, Record.FieldOrDefault(billing_address, "province")),
                        billto_line1 = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "address1") else null,
                        billto_line2  = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "address2") else null,
                        billto_postalcode = if Record.HasFields(order, "billing_address") then Record.FieldOrDefault(billing_address, "zip") else null,
                        shipto_composite = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "address1") else null,
                        shipto_city = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "city") else null,
                        shipto_contactname = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "name") else null,
                        shipto_country = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "country_code") else null,
                        shipto_name = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "name") else null,
                        shipto_telephone = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "phone") else null,
                        shipto_stateorprovince = if Record.FieldOrDefault(shipping_address, "province_code") <> null then Record.FieldOrDefault(shipping_address, "province_code") else if Record.FieldOrDefault(shipping_address, "province") = null then null else if Record.FieldOrDefault(stateMap, Record.FieldOrDefault(shipping_address, "province")) = null then Record.FieldOrDefault(shipping_address, "province") else Record.FieldOrDefault(stateMap, Record.FieldOrDefault(shipping_address, "province")),
                        shipto_line1 = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "address1") else null,
                        shipto_line2 = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "address2") else null,
                        shipto_postalcode = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "zip") else null,
                        msdyn_deliverychoice = if Record.HasFields(order, "shipping_lines") then if List.Count(Record.FieldOrDefault(order, "shipping_lines")) > 0 then Record.FieldOrDefault(List.First(shipping_lines), "title") else null else null,
                        msdyn_shipmentamount = if Record.HasFields(order, "shipping_lines") then if List.Count(Record.FieldOrDefault(order, "shipping_lines")) > 0 then Decimal.From(Record.FieldOrDefault(List.First(shipping_lines), "price")) else null else null,
                        totalamount = if Record.HasFields(order, "total_price") then Decimal.From(Record.FieldOrDefault(order, "total_price")) else null,
                        discountamount = if Record.HasFields(order, "current_total_discounts") then Decimal.From(Record.FieldOrDefault(order, "current_total_discounts")) else null,
                        totaldiscountamount = if Record.HasFields(order, "total_discounts") then Decimal.From(Record.FieldOrDefault(order, "total_discounts")) else null,
                        totaltax = if Record.HasFields(order, "total_tax") then Decimal.From(Record.FieldOrDefault(order, "total_tax")) else null,
                        requestdeliveryby = Date.AddDays(DateTime.LocalNow(), leadtime)
                    ]
                ), each [Value] <> null
            )    
        ),
  orderlines = List.Transform(order[line_items], each
                  Record.FromTable
                  (
                      Table.SelectRows
                      (
                          Record.ToTable
                          (
                              [
                                  isproductoverridden = if useWriteInProductEnabled = true 
                                                        then if Record.HasFields(IOM.MapRecord(IOM.MappingTables[product], [productid = Text.From(Record.FieldOrDefault(_, "product_id"))]), "productid") 
                                                        then false 
                                                        else if isDualWriteEnabled = false 
                                                        then true 
                                                        else false 
                                                        else false,
                                  productdescription = if useWriteInProductEnabled = true 
                                                        then if Record.HasFields(IOM.MapRecord(IOM.MappingTables[product], [productid = Text.From(Record.FieldOrDefault(_, "product_id"))]), "productid") 
                                                        then null 
                                                        else if isDualWriteEnabled = false 
                                                        then Text.From(Record.FieldOrDefault(_, "product_id")) 
                                                        else null 
                                                        else null,
                                  #"productid@odata.bind" = if useWriteInProductEnabled = true 
                                                            then if Record.HasFields(IOM.MapRecord(IOM.MappingTables[product], [productid = Text.From(Record.FieldOrDefault(_, "product_id"))]), "productid") 
                                                            then "/products(" & IOM.MapRecord(IOM.MappingTables[product], [productid = Text.From(Record.FieldOrDefault(_, "product_id"))])[productid] & ")" 
                                                            else if isDualWriteEnabled = false 
                                                            then null 
                                                            else "/products(" & IOM.MapRecord(IOM.MappingTables[product], [productid = Text.From(Record.FieldOrDefault(_, "product_id"))])[productid] & ")" 
                                                            else "/products(" & IOM.MapRecord(IOM.MappingTables[product], [productid = Text.From(Record.FieldOrDefault(_, "product_id"))])[productid] & ")",
                                  #"uomid@odata.bind" = if useWriteInProductEnabled = true 
                                                        then if Record.HasFields(IOM.MapRecord(IOM.MappingTables[product], [productid = Text.From(Record.FieldOrDefault(_, "product_id"))]), "productid") 
                                                        then "/uoms(" & IOM.MapRecord(IOM.MappingTables[uom], [unit = "each"])[uomid] & ")" 
                                                        else if isDualWriteEnabled = false 
                                                        then null 
                                                        else "/uoms(" & IOM.MapRecord(IOM.MappingTables[uom], [unit = "each"])[uomid] & ")" 
                                                        else "/uoms(" & IOM.MapRecord(IOM.MappingTables[uom], [unit = "each"])[uomid] & ")",
                                  productname = if Record.HasFields(_, "name") then Record.FieldOrDefault(_, "name") else null,
                                  ispriceoverridden = true,
                                  quantity = if Record.HasFields(_, "quantity") then Decimal.From(Record.FieldOrDefault(_, "quantity")) else null,
                                  priceperunit = if Record.HasFields(_, "price") then Decimal.From(Record.FieldOrDefault(_, "price")) else null,
                                  manualdiscountamount = List.Sum(List.Transform(Record.FieldOrDefault(_, "discount_allocations"), each Decimal.From(Record.FieldOrDefault(_, "amount")))),
                                  shipto_name = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "name") else null,
                                  shipto_contactname = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "name") else null,
                                  shipto_line1 = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "address1") else null,
                                  shipto_line2 = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "address2") else null,
                                  shipto_city = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "city") else null,
                                  shipto_stateorprovince = if Record.FieldOrDefault(shipping_address, "province_code") <> null then Record.FieldOrDefault(shipping_address, "province_code") else if Record.FieldOrDefault(shipping_address, "province") = null then null else if Record.FieldOrDefault(stateMap, Record.FieldOrDefault(shipping_address, "province")) = null then Record.FieldOrDefault(shipping_address, "province") else Record.FieldOrDefault(stateMap, Record.FieldOrDefault(shipping_address, "province")),
                                  shipto_country = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "country_code") else null,
                                  shipto_postalcode = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "zip") else null,
                                  shipto_telephone = if Record.HasFields(order, "shipping_address") then Record.FieldOrDefault(shipping_address, "phone") else null 
                              ]
                          ), each [Value] <> null
                      )
                  )
              ),
  salesorder = Record.AddField(orderheader, "order_details", orderlines)
in
  Text.FromBinary(Json.FromValue(salesorder));