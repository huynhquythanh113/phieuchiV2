@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Phiếu chi item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_PCHI_ITEM as select  from I_OperationalAcctgDocItem as bseg
association [1..1] to ZFI_I_PHTHU_TAIKHOANNO   as _TaiKhoanNo      on  $projection.CompanyCode        = _TaiKhoanNo.CompanyCode
                                                                     and $projection.AccountingDocument = _TaiKhoanNo.AccountingDocument
                                                                     and $projection.FiscalYear         = _TaiKhoanNo.FiscalYear
                                                                     and $projection.GLAccount          = _TaiKhoanNo.GLAccount

  association [1..1] to ZFI_I_PHTHU_TAIKHOANCO   as _TaiKhoanCo      on  $projection.CompanyCode        = _TaiKhoanCo.CompanyCode
                                                                     and $projection.AccountingDocument = _TaiKhoanCo.AccountingDocument
                                                                     and $projection.FiscalYear         = _TaiKhoanCo.FiscalYear
                                                                     and $projection.GLAccount          = _TaiKhoanCo.GLAccount
association to parent ZFI_I_PCHI_HEADER as _Header on  $projection.AccountingDocument = _Header.AccountingDocument
                                                     and $projection.CompanyCode        = _Header.CompanyCode
                                                     and $projection.FiscalYear= _Header.FiscalYear
{
    key bseg.CompanyCode,//Tên công ty
    key bseg.AccountingDocument,
    key bseg.FiscalYear,
//    key bseg.AccountingDocumentItem,
    key bseg.GLAccount,
    bseg.TransactionCurrency,
    case 
        when bseg.DebitCreditCode = 'S'
            then bseg.GLAccount
     end as TaiKhoanNo,
     case 
        when bseg.DebitCreditCode = 'H'
            then bseg.GLAccount
     end as TaiKhoanCo,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    case 
        when bseg.DebitCreditCode = 'S'
            then sum(bseg.AmountInTransactionCurrency)
     end as SoTienNo,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
     case 
        when bseg.DebitCreditCode = 'H'
            then sum(bseg.AmountInTransactionCurrency)
     end as SoTienCo,
     _Header
} group by CompanyCode, FiscalYear, AccountingDocument,GLAccount, TransactionCurrency,bseg.DebitCreditCode,bseg.GLAccount
