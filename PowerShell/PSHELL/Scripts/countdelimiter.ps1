cls
$line='PATIENT_NUM|TRANSACTION_KEY|SOURCE_FLAG|TRANSACTION_TYPE_CD|TRANSACTION_SOURCE_CD|PROCEDURE_CD|MEDICATION_ID|SUPPLY_ID|SERVICE_DATE|POST_DATE|TRANSACTION_AMT|TRAMSACTION_QTY|COST_CENTER_CD|GL_CREDIT_NUM|REVENUE_CD|CPT_CD|COPAY_AMOUNT|COINSURANCE_AMOUNT|DEDUCTIBLE_AMOUNT|PAYOR_ID|PLAN_ID|BUCKET_ID|INT_CONTROL_NUMBER|PERFORMING_CACTUS_PHYSICIAN_ID|BILLING_CACTUS_PHYSICIAN_ID|PERFORMING_EPIC_PHYSICIAN_ID|BILLING_EPIC_PHYSICIAN_ID|PERIOD_START_DATE|PERIOD_END_DATE|RUN_DATE|FACILITY_ID'
$c_delimiter_type='|'
$DelimCount = ([char[]]$line -eq $c_delimiter_type).count
$DelimCount