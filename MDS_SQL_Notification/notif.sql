USE [MARUNI_20110621]
GO
/****** Object:  StoredProcedure [dbo].[SBO_SP_PostTransactionNotice]    Script Date: 06/28/2011 17:53:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[SBO_SP_PostTransactionNotice]

@object_type nvarchar(20), 				-- SBO Object Type
@transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
@num_of_cols_in_key int,
@list_of_key_cols_tab_del nvarchar(255),
@list_of_cols_val_tab_del nvarchar(255)

AS

begin

-- Return values
declare @error  int				-- Result (0 for no error)
declare @error_message nvarchar (200) 		-- Error string to be displayed
select @error = 0
select @error_message = N'Ok'

--------------------------------------------------------------------------------------------------------------------------------

--	ADD	YOUR	CODE	HERE

--------------------------------------------------------------------------------------------------------------------------------

-- oIncomingPayments 24 Payments object 
IF @transaction_type = 'A' AND @Object_type = '24'

BEGIN

	DECLARE @PDCBANKID NVARCHAR(8),
			@PDCNO NVARCHAR(10)

	-- Get BANK + GIRO#			
	SELECT
	@PDCBANKID = U_PDCBankID, @PDCNO = U_PDCNo
	FROM ORCT
	WHERE DocEntry = CAST(@list_of_cols_val_tab_del AS INT) -- 311100178 -- 
	
	-- Update GIRO Header, giro status C = cair
	UPDATE dbo.[@MIS_PDC]
	SET U_ORCTDocEntry = CAST(@list_of_cols_val_tab_del AS INT), -- 1, -- 
		U_PDCStatus = 'C'
	WHERE --DocEntry = 1
	U_PDCBankID = @PDCBANKID AND U_PDCNo = @PDCNO


	---- UPDATE GIRO Detail, giro status C = cair

	UPDATE [@MIS_PDCL]
	SET U_InvPaidStatus = 'C'
	FROM [@MIS_PDCL] T0 
	JOIN [@MIS_PDC] T1 ON T1.DocEntry = T0.DocEntry 
	JOIN ORCT T2 ON T2.U_PDCBankID = T1.U_PDCBankID AND T2.U_PDCNo = T1.U_PDCNo
	WHERE T1.U_PDCBankID = @PDCBANKID AND T1.U_PDCNo = @PDCNO
		
END
--End of oIncomingPayments 24 Payments object 


-- Select the return values
select @error, @error_message

end