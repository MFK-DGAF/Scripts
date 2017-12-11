select distinct UserName from usersecuritylog A
join tblUsers B on A.SourceUserID=B.UserCounter
where 
B.ProductFlag = '1'
and ActiveFlag = '0'
and A.Detail ='User has successfully signed in.'
and CreatedDate >  DATEADD(month, -6, GETDATE())
