update prod.TemaMetaData

SET
	[OPDATERETDATO] = cast(getdate()-100 as date)

where
[AUTOOPDATERINGAKTIV] = 'True'