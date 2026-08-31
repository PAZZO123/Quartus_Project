Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
public class WinF {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    public static void MinimizeWnd(IntPtr h) { ShowWindow(h, 6); Thread.Sleep(100); }
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
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$log = @()

# Minimize Chrome
Get-Process | Where-Object { $_.Name -like "*chrome*" -and $_.MainWindowHandle -ne [IntPtr]::Zero } | ForEach-Object { [WinF]::MinimizeWnd($_.MainWindowHandle) }
Start-Sleep -Milliseconds 400

$proc = Get-Process -Id 49136
[WinF]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 600

$isFg = [WinF]::IsFg($proc.MainWindowHandle)
$log += "Focus: $isFg"

if ($isFg) {
    # Use UIAutomation via PowerShell (no inline C#)
    $root = [System.Windows.Automation.AutomationElement]::RootElement
    
    $pidProp = [System.Windows.Automation.AutomationElement]::ProcessIdProperty
    $pidCond = New-Object System.Windows.Automation.PropertyCondition($pidProp, [int]$proc.Id)
    $quartusEl = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $pidCond)
    
    if ($quartusEl) {
        $log += "Found Quartus window: $($quartusEl.Current.Name)"
        
        # List top-level children to find menu
        $trueC = [System.Windows.Automation.Condition]::TrueCondition
        $children = $quartusEl.FindAll([System.Windows.Automation.TreeScope]::Children, $trueC)
        foreach ($ch in $children) {
            $log += "  Child ControlType=$($ch.Current.ControlType.ProgrammaticName) Name='$($ch.Current.Name)'"
        }
    } else {
        $log += "Quartus element NOT found"
    }
}

$log | Out-File "C:\Users\USER\Documents\MIPS_Project\uia_log.txt"
