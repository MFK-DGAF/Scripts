(gwmi Win32_TerminalServiceSetting –Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1)

(gwmi Win32_TSGeneralSetting -Namespace root\cimv2\TerminalServices).SetUserAuthenticationRequired(0)