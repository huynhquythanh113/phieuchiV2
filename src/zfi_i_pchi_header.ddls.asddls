@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Phiếu chi header'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZFI_I_PCHI_HEADER
  with parameters
    OwnDocumentOnly : boolean
  as select distinct from I_JournalEntry             as bkpf
    inner join            I_OperationalAcctgDocItem  as bseg             on  bkpf.CompanyCode        =    bseg.CompanyCode
                                                                         and bkpf.FiscalYear         =    bseg.FiscalYear
                                                                         and bkpf.AccountingDocument =    bseg.AccountingDocument
                                                                         and bseg.GLAccount          like '00111%'
                                                                         and bseg.PostingKey         =    '50'
  //    left outer join            ZFI_I_PHTHU_CUS_VEN   as _AccountType          on  bkpf.CompanyCode        = _AccountType.CompanyCode
  //                                                                         and bkpf.FiscalYear         = _AccountType.FiscalYear
  //                                                                         and bkpf.AccountingDocument = _AccountType.AccountingDocument
    left outer join       I_CompanyCode              as companyCode      on bkpf.CompanyCode = companyCode.CompanyCode
    left outer join       I_Address_2                as company_address  on companyCode.AddressID = company_address.AddressID
  //and text.PostingKey = '40'
  //Vendor/customer D = customer, K = supplier
    left outer join       I_Customer                 as D                on D.Customer = bseg.Customer
    left outer join       I_AddrOrgNamePostalAddress as customer_address on D.AddressID = customer_address.AddressID
    left outer join       I_Supplier                 as K                on K.Supplier = bseg.Supplier
    left outer join       ZI_CHUKY                   as ChuKiTONGGIAMDOC on ChuKiTONGGIAMDOC.Id = 'TONGGIAMDOC'
    left outer join       ZI_CHUKY                   as ktt              on ktt.Id = 'KETOANTRUONG'
    left outer join       ZI_CHUKY                   as thuQuy           on thuQuy.Id = 'THUQUY'
  composition [0..*] of ZFI_I_PCHI_ITEM as _Item
{
      @Consumption.filter: { mandatory: true , selectionType: #SINGLE,
      multipleSelections: false , defaultValue: '1000' }
      @Search.defaultSearchElement: true
  key bkpf.CompanyCode,
      @Consumption.filter: { mandatory: true , selectionType: #SINGLE,
      multipleSelections: false}
      @Search.defaultSearchElement: true
  key bkpf.FiscalYear,
      @Search.defaultSearchElement: true
  key bkpf.AccountingDocument,
      @Search.defaultSearchElement: true
      cast( bkpf.DocumentReferenceID as zde_reference)                                     as Reference, //Reference 2 (Kèm theo)
      @Consumption.filter.hidden: true
      bkpf.AccountingDocCreatedByUser,
      @Consumption.filter.hidden: true
      bseg.DocumentDate,
      @Search.defaultSearchElement: true
      bkpf.AccountingDocumentCreationDate,
      @Consumption.filter.hidden: true
      bseg.AmountInCompanyCodeCurrency,
      @Consumption.filter.hidden: true
      bseg.CompanyCodeCurrency,
      //       @Consumption.filter.hidden: true
      //      _AccountType.Supplier, //Supplier 9
      //      @Consumption.filter.hidden: true
      //      _AccountType.Customer, //Customer 10
      //      @Consumption.filter.hidden: true
      //      case
      //        when _AccountType.Supplier = ''
      //            then _AccountType._Customer.CustomerName
      //            else _AccountType._Supplier.SupplierName
      //      end
      ''                                                                                   as AccountName,
      @Consumption.filter.hidden: true
      bseg.DocumentItemText,
      @Consumption.filter.hidden: true
      bkpf.AccountingDocumentType,
      @Consumption.filter.hidden: true
      company_address.AddresseeFullName                                                    as TenCongTy,
      @Consumption.filter.hidden: true
      concat_with_space(concat(company_address.StreetName,','),company_address.CityName,1) as DiaChiCty,
      @Search.defaultSearchElement: true
      bseg.PostingDate,
      //Người nhận tiền //sửa ở đây
      //      @Consumption.filter.hidden: true
      //      case
      //        when _AccountType.Customer <> ''
      //            then case
      //                when
      //                         concat_with_space(_AccountType._Customer.BusinessPartnerName2,concat_with_space(_AccountType._Customer.BusinessPartnerName3,_AccountType._Customer.BusinessPartnerName4,1),1) = ''
      //                            then _AccountType._Customer.BusinessPartnerName1
      //                            else   concat_with_space(_AccountType._Customer.BusinessPartnerName2,concat_with_space(_AccountType._Customer.BusinessPartnerName3,_AccountType._Customer.BusinessPartnerName4,1),1)
      //                            end
      //                  else
      //                  case
      //                  when
      //                         concat_with_space(_AccountType._Supplier.BusinessPartnerName2,concat_with_space(_AccountType._Supplier.BusinessPartnerName3,_AccountType._Supplier.BusinessPartnerName4,1),1) = ''
      //                            then _AccountType._Supplier.BusinessPartnerName1
      //                            else   concat_with_space(_AccountType._Supplier.BusinessPartnerName2,concat_with_space(_AccountType._Supplier.BusinessPartnerName3,_AccountType._Supplier.BusinessPartnerName4,1),1)
      //                            end
      //      end
      ''                                                                                   as NguoiNhanTien,
      //      @Consumption.filter.hidden: true
      //      case
      //            when _AccountType.Customer <> ''
      //                then concat_with_space(_AccountType._Customer._AddressRepresentation.StreetName,concat_with_space(_AccountType._Customer._AddressRepresentation.StreetPrefixName1, concat_with_space(_AccountType._Customer._AddressRepresentation.StreetPrefixName2,_AccountType._Customer._AddressRepresentation.StreetSuffixName1,1),1),1)
      //                else concat_with_space(_AccountType._Supplier._AddressRepresentation.StreetName,concat_with_space(_AccountType._Supplier._AddressRepresentation.StreetPrefixName1, concat_with_space(_AccountType._Supplier._AddressRepresentation.StreetPrefixName2,_AccountType._Supplier._AddressRepresentation.StreetSuffixName1,1),1),1)
      //      end
      ''                                                                                   as DiaChiNguoiNhanTien,
      @Consumption.filter.hidden: true
      case
           when bseg.DocumentItemText <> ''
                then bseg.DocumentItemText
                else
                bkpf.AccountingDocumentHeaderText
      end                                                                                  as LyDoThu,
      @Consumption.filter.hidden: true
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      bseg.AmountInTransactionCurrency                                                     as SoTien,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_AccountingDocumentCategory', element: 'AccountingDocumentCategory' }}]
      @Search.defaultSearchElement: true
      cast( bseg.AccountingDocumentCategory as zde_entrycategory)                          as Type,
      @Consumption.filter: { mandatory: false , selectionType: #SINGLE,
      multipleSelections: false , defaultValue: ' ' }
      @Search.defaultSearchElement: true
      bkpf.IsReversed,
      //Chữ Ký
      @Consumption.filter.hidden: true
      ChuKiTONGGIAMDOC.Hoten                                                               as IdGiamDoc,
      @Consumption.filter.hidden: true
      ktt.Hoten                                                                            as IdKeToan,
      @Consumption.filter.hidden: true
      thuQuy.Hoten                                                                         as IdThuQuy,
      _Item
}
where
  (
    (
          $parameters.OwnDocumentOnly     is initial
    )
    or(
          $parameters.OwnDocumentOnly     is not initial
      and bkpf.AccountingDocCreatedByUser = $session.user
    )
  )
