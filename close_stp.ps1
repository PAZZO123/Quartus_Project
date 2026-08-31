Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
public class WinCtrl {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    
    public static void ForceFront(IntPtr hWnd) {
        IntPtr fg = GetForegroundWindow();
        uint pid; uint fgT = GetWindowThreadProcessId(fg, out pid);
        uint myT = GetCurrentThreadId();
        AttachThreadInput(myT, fgT, true);
        BringWindowToTop(hWnd); ShowWindow(hWnd, 3); SetForegroundWindow(hWnd);
        Thread.Sleep(200);
        AttachThreadInput(myT, fgT, false);
    }
    public static bool IsFg(IntPtr h) { return GetForegroundWindow() == h; }
    public static void MinimizeWnd(IntPtr h) { ShowWindow(h, 6); Thread.Sleep(150); }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Minimize Chrome
$chromes = Get-Process | Where-Object { $_.Name -like "*chrome*" -and $_.MainWindowHandle -ne [IntPtr]::Zero }
foreach ($c in $chromes) { [WinCtrl]::MinimizeWnd($c.MainWindowHandle) }
Start-Sleep -Milliseconds 400

# Force Quartus to front and close SignalTap via Ctrl+W
$proc = Get-Process -Id 49136
[WinCtrl]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 500

if ([WinCtrl]::IsFg($proc.MainWindowHandle)) {
    # Close SignalTap with Ctrl+W
    [System.Windows.Forms.SendKeys]::SendWait("^w")
    Start-Sleep -Milliseconds 1000
    
    # Screenshot to verify SignalTap is closed
    [int]$w=1920; [int]$h=1080
    $b = New-Object System.Drawing.Bitmap($w,$h)
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g.Dispose()
    $b.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_after_close.png")
    $b.Dispose()
    "Closed" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt"
}
