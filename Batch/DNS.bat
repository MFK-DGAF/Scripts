@echo off
set dnsserver=10.1.4.17
set dnsserver2=10.1.4.40
for /f "tokens=1,2,3*" %%i in ('netsh interface show interface') do (
 if %%i EQU Enabled (
 rem echo change "%%l" : %dnsserver%
 netsh interface ipv4 set dnsserver name="%%l" static %dnsserver% both
 netsh interface ipv4 add dnsserver name="%%l" %dnsserver2% index=2
 )
)